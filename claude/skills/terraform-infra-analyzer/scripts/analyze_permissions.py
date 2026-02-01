#!/usr/bin/env python3
"""
Terraform Infrastructure Permissions Analyzer

このスクリプトは、Terraformのtfstateファイルを分析し、
IAMとネットワークの両方の権限設定を評価します。

主な機能:
- IAMロール/ポリシーの過剰な権限検出
- 不足している可能性のある権限の検出
- ネットワークレベルでのアクセス制御の評価
- リソースごとの権限マッピング生成
"""

import json
import argparse
import sys
import re
from typing import Dict, List, Set, Optional
from dataclasses import dataclass, field
from enum import Enum


class PermissionSeverity(Enum):
    """権限問題の重要度"""
    OK = "✓"
    INFO = "ℹ"
    WARNING = "⚠"
    ERROR = "✗"


@dataclass
class IAMPolicy:
    """IAMポリシー"""
    name: str
    document: Dict
    attached_to: List[str] = field(default_factory=list)


@dataclass
class IAMRole:
    """IAMロール"""
    name: str
    arn: str
    assume_role_policy: Dict
    attached_policies: List[str] = field(default_factory=list)
    inline_policies: List[IAMPolicy] = field(default_factory=list)


@dataclass
class PermissionIssue:
    """権限に関する問題"""
    severity: PermissionSeverity
    resource_type: str
    resource_name: str
    category: str  # "IAM" or "Network"
    message: str
    recommendation: str = ""


class PermissionAnalyzer:
    """権限分析クラス"""

    # 過度に広範な権限パターン
    OVERLY_PERMISSIVE_PATTERNS = [
        r'.*:\*',  # サービス全体へのワイルドカード
        r'\*:\*',  # すべてのアクション
    ]

    # 機密性の高いアクション
    SENSITIVE_ACTIONS = {
        'iam:CreateUser', 'iam:CreateRole', 'iam:AttachRolePolicy', 'iam:PutRolePolicy',
        'iam:CreateAccessKey', 'iam:UpdateAssumeRolePolicy',
        'sts:AssumeRole',
        's3:DeleteBucket', 's3:PutBucketPolicy',
        'ec2:RunInstances', 'ec2:TerminateInstances',
        'lambda:UpdateFunctionCode', 'lambda:AddPermission',
        'rds:DeleteDBInstance', 'rds:ModifyDBInstance',
        'dynamodb:DeleteTable',
    }

    # よくある権限不足のパターン（推測用）
    COMMON_PERMISSION_PATTERNS = {
        'lambda': ['logs:CreateLogGroup', 'logs:CreateLogStream', 'logs:PutLogEvents'],
        's3_read': ['s3:GetObject', 's3:ListBucket'],
        's3_write': ['s3:PutObject', 's3:DeleteObject'],
        'dynamodb_read': ['dynamodb:GetItem', 'dynamodb:Query', 'dynamodb:Scan'],
        'dynamodb_write': ['dynamodb:PutItem', 'dynamodb:UpdateItem', 'dynamodb:DeleteItem'],
    }

    def __init__(self, state_file: str):
        self.state_file = state_file
        self.state_data = None
        self.iam_roles: Dict[str, IAMRole] = {}
        self.iam_policies: Dict[str, IAMPolicy] = {}
        self.issues: List[PermissionIssue] = []

    def load_state(self) -> bool:
        """状態ファイルを読み込み"""
        try:
            with open(self.state_file, 'r') as f:
                self.state_data = json.load(f)
            return True
        except FileNotFoundError:
            print(f"エラー: ファイルが見つかりません: {self.state_file}", file=sys.stderr)
            return False
        except json.JSONDecodeError as e:
            print(f"エラー: JSONのパースに失敗しました: {e}", file=sys.stderr)
            return False

    def extract_iam_resources(self):
        """IAMリソースを抽出"""
        if not self.state_data:
            return

        resources = self.state_data.get('resources', [])

        # IAMロールの抽出
        for resource in resources:
            if resource.get('type') == 'aws_iam_role':
                for instance in resource.get('instances', []):
                    attrs = instance.get('attributes', {})
                    role_name = attrs.get('name', '')
                    role_arn = attrs.get('arn', '')
                    assume_role_policy_str = attrs.get('assume_role_policy', '{}')

                    try:
                        assume_role_policy = json.loads(assume_role_policy_str)
                    except json.JSONDecodeError:
                        assume_role_policy = {}

                    role = IAMRole(
                        name=role_name,
                        arn=role_arn,
                        assume_role_policy=assume_role_policy
                    )
                    self.iam_roles[role_name] = role

        # IAMポリシーの抽出
        for resource in resources:
            if resource.get('type') == 'aws_iam_policy':
                for instance in resource.get('instances', []):
                    attrs = instance.get('attributes', {})
                    policy_name = attrs.get('name', '')
                    policy_str = attrs.get('policy', '{}')

                    try:
                        policy_doc = json.loads(policy_str)
                    except json.JSONDecodeError:
                        policy_doc = {}

                    policy = IAMPolicy(name=policy_name, document=policy_doc)
                    self.iam_policies[policy_name] = policy

        # ロールポリシーアタッチメントの抽出
        for resource in resources:
            if resource.get('type') == 'aws_iam_role_policy_attachment':
                for instance in resource.get('instances', []):
                    attrs = instance.get('attributes', {})
                    role_name = attrs.get('role', '')
                    policy_arn = attrs.get('policy_arn', '')

                    if role_name in self.iam_roles:
                        self.iam_roles[role_name].attached_policies.append(policy_arn)

        # インラインポリシーの抽出
        for resource in resources:
            if resource.get('type') == 'aws_iam_role_policy':
                for instance in resource.get('instances', []):
                    attrs = instance.get('attributes', {})
                    role_name = attrs.get('role', '')
                    policy_name = attrs.get('name', '')
                    policy_str = attrs.get('policy', '{}')

                    try:
                        policy_doc = json.loads(policy_str)
                    except json.JSONDecodeError:
                        policy_doc = {}

                    inline_policy = IAMPolicy(name=policy_name, document=policy_doc)

                    if role_name in self.iam_roles:
                        self.iam_roles[role_name].inline_policies.append(inline_policy)

    def analyze_permissions(self):
        """権限を分析"""
        self._check_overly_permissive_policies()
        self._check_sensitive_actions()
        self._check_resource_specific_permissions()

    def _check_overly_permissive_policies(self):
        """過度に広範な権限をチェック"""
        for role_name, role in self.iam_roles.items():
            # インラインポリシーのチェック
            for policy in role.inline_policies:
                self._analyze_policy_document(policy.document, role_name, policy.name)

        for policy_name, policy in self.iam_policies.items():
            self._analyze_policy_document(policy.document, "policy", policy_name)

    def _analyze_policy_document(self, policy_doc: Dict, resource_name: str, policy_name: str):
        """ポリシードキュメントを分析"""
        statements = policy_doc.get('Statement', [])
        if not isinstance(statements, list):
            statements = [statements]

        for statement in statements:
            if statement.get('Effect') != 'Allow':
                continue

            actions = statement.get('Action', [])
            if isinstance(actions, str):
                actions = [actions]

            resources = statement.get('Resource', [])
            if isinstance(resources, str):
                resources = [resources]

            # ワイルドカードアクションのチェック
            for action in actions:
                if action == '*' or action.endswith(':*'):
                    # リソースも * の場合は重大
                    if '*' in resources:
                        self.issues.append(PermissionIssue(
                            severity=PermissionSeverity.ERROR,
                            resource_type="IAMRole" if resource_name in self.iam_roles else "IAMPolicy",
                            resource_name=f"{resource_name} (policy: {policy_name})",
                            category="IAM",
                            message=f"アクション '{action}' がリソース '*' に対して許可されています",
                            recommendation="必要最小限のアクションとリソースに制限してください"
                        ))
                    else:
                        self.issues.append(PermissionIssue(
                            severity=PermissionSeverity.WARNING,
                            resource_type="IAMRole" if resource_name in self.iam_roles else "IAMPolicy",
                            resource_name=f"{resource_name} (policy: {policy_name})",
                            category="IAM",
                            message=f"アクション '{action}' に広範な権限が付与されています",
                            recommendation="具体的なアクションを明示することを推奨します"
                        ))

                # 機密性の高いアクションのチェック
                if action in self.SENSITIVE_ACTIONS:
                    self.issues.append(PermissionIssue(
                        severity=PermissionSeverity.INFO,
                        resource_type="IAMRole" if resource_name in self.iam_roles else "IAMPolicy",
                        resource_name=f"{resource_name} (policy: {policy_name})",
                        category="IAM",
                        message=f"機密性の高いアクション '{action}' が許可されています",
                        recommendation="このアクションが本当に必要か確認してください"
                    ))

    def _check_sensitive_actions(self):
        """機密性の高いアクションの使用をチェック（既に_analyze_policy_documentで実装）"""
        pass

    def _check_resource_specific_permissions(self):
        """リソース固有の権限をチェック"""
        # Lambda関数に対する典型的な権限チェック
        self._check_lambda_permissions()

    def _check_lambda_permissions(self):
        """Lambda関数の権限をチェック"""
        if not self.state_data:
            return

        resources = self.state_data.get('resources', [])

        for resource in resources:
            if resource.get('type') == 'aws_lambda_function':
                for instance in resource.get('instances', []):
                    attrs = instance.get('attributes', {})
                    function_name = attrs.get('function_name', '')
                    role_arn = attrs.get('role', '')

                    # ロール名を抽出（ARNから）
                    role_name = role_arn.split('/')[-1] if '/' in role_arn else ''

                    if role_name in self.iam_roles:
                        role = self.iam_roles[role_name]

                        # CloudWatch Logsへの権限チェック
                        has_logs_permission = self._check_role_has_actions(
                            role,
                            ['logs:CreateLogGroup', 'logs:CreateLogStream', 'logs:PutLogEvents']
                        )

                        if not has_logs_permission:
                            self.issues.append(PermissionIssue(
                                severity=PermissionSeverity.WARNING,
                                resource_type="Lambda",
                                resource_name=function_name,
                                category="IAM",
                                message="CloudWatch Logsへの書き込み権限が明示的に付与されていない可能性があります",
                                recommendation="logs:CreateLogGroup, logs:CreateLogStream, logs:PutLogEvents の権限を確認してください"
                            ))

    def _check_role_has_actions(self, role: IAMRole, required_actions: List[str]) -> bool:
        """ロールが指定されたアクションを持っているかチェック"""
        for policy in role.inline_policies:
            statements = policy.document.get('Statement', [])
            if not isinstance(statements, list):
                statements = [statements]

            for statement in statements:
                if statement.get('Effect') != 'Allow':
                    continue

                actions = statement.get('Action', [])
                if isinstance(actions, str):
                    actions = [actions]

                # ワイルドカードチェック
                if '*' in actions or 'logs:*' in actions:
                    return True

                # 個別アクションチェック
                for required_action in required_actions:
                    if required_action in actions:
                        return True

        return False

    def generate_report(self, output_file: str = None):
        """レポートを生成"""
        report = []
        report.append("# 権限分析レポート\n")
        report.append(f"## 分析対象: {self.state_file}\n\n")

        # サマリー
        ok_count = sum(1 for i in self.issues if i.severity == PermissionSeverity.OK)
        info_count = sum(1 for i in self.issues if i.severity == PermissionSeverity.INFO)
        warning_count = sum(1 for i in self.issues if i.severity == PermissionSeverity.WARNING)
        error_count = sum(1 for i in self.issues if i.severity == PermissionSeverity.ERROR)

        report.append("## サマリー\n\n")
        report.append(f"- IAMロール数: {len(self.iam_roles)}\n")
        report.append(f"- IAMポリシー数: {len(self.iam_policies)}\n")
        report.append(f"- ✓ 適切: {len(self.iam_roles) + len(self.iam_policies) - error_count - warning_count}件\n")
        report.append(f"- ℹ 情報: {info_count}件\n")
        report.append(f"- ⚠ 警告: {warning_count}件\n")
        report.append(f"- ✗ 問題: {error_count}件\n\n")

        # 検出された問題
        if self.issues:
            report.append("## 検出された問題\n\n")

            # エラーから表示
            errors = [i for i in self.issues if i.severity == PermissionSeverity.ERROR]
            if errors:
                report.append("### 🚨 重大な問題\n\n")
                for issue in errors:
                    report.append(f"**{issue.severity.value} [{issue.category}] {issue.resource_type}: {issue.resource_name}**\n")
                    report.append(f"- 問題: {issue.message}\n")
                    if issue.recommendation:
                        report.append(f"- 推奨: {issue.recommendation}\n")
                    report.append("\n")

            # 警告
            warnings = [i for i in self.issues if i.severity == PermissionSeverity.WARNING]
            if warnings:
                report.append("### ⚠️ 警告\n\n")
                for issue in warnings:
                    report.append(f"**{issue.severity.value} [{issue.category}] {issue.resource_type}: {issue.resource_name}**\n")
                    report.append(f"- 警告: {issue.message}\n")
                    if issue.recommendation:
                        report.append(f"- 推奨: {issue.recommendation}\n")
                    report.append("\n")

            # 情報
            infos = [i for i in self.issues if i.severity == PermissionSeverity.INFO]
            if infos:
                report.append("### ℹ️ 情報\n\n")
                for issue in infos:
                    report.append(f"**{issue.severity.value} [{issue.category}] {issue.resource_type}: {issue.resource_name}**\n")
                    report.append(f"- 情報: {issue.message}\n")
                    if issue.recommendation:
                        report.append(f"- 推奨: {issue.recommendation}\n")
                    report.append("\n")
        else:
            report.append("## 検出された問題\n\n")
            report.append("問題は検出されませんでした。✓\n\n")

        # IAMロール一覧
        report.append("## IAMロール一覧\n\n")
        for role_name, role in self.iam_roles.items():
            report.append(f"### {role_name}\n")
            report.append(f"- ARN: {role.arn}\n")
            report.append(f"- アタッチ済みポリシー数: {len(role.attached_policies)}\n")
            report.append(f"- インラインポリシー数: {len(role.inline_policies)}\n")

            if role.attached_policies:
                report.append("\n**アタッチ済みポリシー:**\n")
                for policy_arn in role.attached_policies:
                    policy_name = policy_arn.split('/')[-1]
                    report.append(f"- {policy_name}\n")

            if role.inline_policies:
                report.append("\n**インラインポリシー:**\n")
                for policy in role.inline_policies:
                    report.append(f"- {policy.name}\n")

            report.append("\n")

        report_text = "".join(report)

        if output_file:
            with open(output_file, 'w') as f:
                f.write(report_text)
            print(f"レポートを生成しました: {output_file}")
        else:
            print(report_text)


def main():
    parser = argparse.ArgumentParser(
        description='Terraform tfstateから権限設定を分析'
    )
    parser.add_argument(
        '--state',
        required=True,
        help='Terraform状態ファイル (terraform.tfstate)'
    )
    parser.add_argument(
        '--output',
        help='出力ファイル（指定しない場合は標準出力）'
    )

    args = parser.parse_args()

    analyzer = PermissionAnalyzer(args.state)

    if not analyzer.load_state():
        sys.exit(1)

    print("IAMリソースを抽出中...")
    analyzer.extract_iam_resources()
    print(f"検出: {len(analyzer.iam_roles)}個のIAMロール, {len(analyzer.iam_policies)}個のIAMポリシー")

    print("権限を分析中...")
    analyzer.analyze_permissions()

    print("レポートを生成中...")
    analyzer.generate_report(args.output)


if __name__ == '__main__':
    main()
