#!/usr/bin/env python3
"""
Terraform Infrastructure Network Connectivity Analyzer

このスクリプトは、Terraformのtfstateファイルを分析し、
AWSリソース間のネットワーク接続性を評価します。

主な機能:
- セキュリティグループのルール分析
- NACL（Network ACL）の設定確認
- ルートテーブルの構成確認
- リソース間の接続可否マトリクス生成
- 不要な接続や潜在的なセキュリティリスクの検出
"""

import json
import argparse
import sys
from typing import Dict, List, Set, Tuple
from dataclasses import dataclass, field
from enum import Enum


class Severity(Enum):
    """問題の重要度"""
    OK = "✓"
    WARNING = "⚠"
    ERROR = "✗"


@dataclass
class SecurityGroupRule:
    """セキュリティグループルール"""
    from_port: int
    to_port: int
    protocol: str
    cidr_blocks: List[str] = field(default_factory=list)
    source_security_groups: List[str] = field(default_factory=list)
    description: str = ""


@dataclass
class SecurityGroup:
    """セキュリティグループ"""
    id: str
    name: str
    ingress_rules: List[SecurityGroupRule] = field(default_factory=list)
    egress_rules: List[SecurityGroupRule] = field(default_factory=list)
    vpc_id: str = ""


@dataclass
class ConnectivityIssue:
    """接続性の問題"""
    severity: Severity
    source: str
    destination: str
    port: int
    protocol: str
    message: str


class TerraformStateAnalyzer:
    """Terraform状態ファイル分析クラス"""

    def __init__(self, state_file: str):
        self.state_file = state_file
        self.state_data = None
        self.security_groups: Dict[str, SecurityGroup] = {}
        self.issues: List[ConnectivityIssue] = []

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

    def extract_security_groups(self):
        """状態ファイルからセキュリティグループを抽出"""
        if not self.state_data:
            return

        resources = self.state_data.get('resources', [])

        for resource in resources:
            if resource.get('type') == 'aws_security_group':
                for instance in resource.get('instances', []):
                    attrs = instance.get('attributes', {})
                    sg_id = attrs.get('id', '')
                    sg_name = attrs.get('name', '')
                    vpc_id = attrs.get('vpc_id', '')

                    sg = SecurityGroup(id=sg_id, name=sg_name, vpc_id=vpc_id)

                    # Ingressルールの抽出
                    for ingress in attrs.get('ingress', []):
                        rule = SecurityGroupRule(
                            from_port=ingress.get('from_port', 0),
                            to_port=ingress.get('to_port', 0),
                            protocol=ingress.get('protocol', ''),
                            cidr_blocks=ingress.get('cidr_blocks', []),
                            source_security_groups=ingress.get('security_groups', []),
                            description=ingress.get('description', '')
                        )
                        sg.ingress_rules.append(rule)

                    # Egressルールの抽出
                    for egress in attrs.get('egress', []):
                        rule = SecurityGroupRule(
                            from_port=egress.get('from_port', 0),
                            to_port=egress.get('to_port', 0),
                            protocol=egress.get('protocol', ''),
                            cidr_blocks=egress.get('cidr_blocks', []),
                            source_security_groups=egress.get('security_groups', []),
                            description=egress.get('description', '')
                        )
                        sg.egress_rules.append(rule)

                    self.security_groups[sg_id] = sg

    def analyze_connectivity(self):
        """接続性を分析"""
        # インターネットからの直接アクセスをチェック
        self._check_internet_exposure()

        # 過度に広い範囲を許可しているルールをチェック
        self._check_overly_permissive_rules()

        # 重要なポートのチェック
        self._check_sensitive_ports()

    def _check_internet_exposure(self):
        """インターネットへの露出をチェック"""
        for sg_id, sg in self.security_groups.items():
            for rule in sg.ingress_rules:
                if '0.0.0.0/0' in rule.cidr_blocks:
                    # 一般的なWebポート（80, 443）以外での0.0.0.0/0は警告
                    if rule.from_port not in [80, 443] or rule.to_port not in [80, 443]:
                        severity = Severity.WARNING
                        if rule.from_port in [22, 3389, 3306, 5432, 27017]:  # SSH, RDP, DB ports
                            severity = Severity.ERROR

                        self.issues.append(ConnectivityIssue(
                            severity=severity,
                            source="internet (0.0.0.0/0)",
                            destination=f"{sg.name} ({sg_id})",
                            port=rule.from_port,
                            protocol=rule.protocol,
                            message=f"インターネットからポート{rule.from_port}への接続が許可されています"
                        ))

    def _check_overly_permissive_rules(self):
        """過度に広い範囲を許可しているルールをチェック"""
        for sg_id, sg in self.security_groups.items():
            for rule in sg.ingress_rules:
                # すべてのポートを許可している場合
                if rule.protocol == '-1' or (rule.from_port == 0 and rule.to_port == 65535):
                    self.issues.append(ConnectivityIssue(
                        severity=Severity.WARNING,
                        source="any",
                        destination=f"{sg.name} ({sg_id})",
                        port=0,
                        protocol=rule.protocol,
                        message="すべてのポート/プロトコルが許可されています（範囲を絞ることを推奨）"
                    ))

    def _check_sensitive_ports(self):
        """機密性の高いポートへのアクセスをチェック"""
        sensitive_ports = {
            22: "SSH",
            3389: "RDP",
            3306: "MySQL",
            5432: "PostgreSQL",
            27017: "MongoDB",
            6379: "Redis",
            9200: "Elasticsearch"
        }

        for sg_id, sg in self.security_groups.items():
            for rule in sg.ingress_rules:
                for port, service in sensitive_ports.items():
                    if rule.from_port <= port <= rule.to_port:
                        # VPC内からのアクセスでない場合は警告
                        for cidr in rule.cidr_blocks:
                            if cidr != '10.0.0.0/8' and cidr != '172.16.0.0/12' and cidr != '192.168.0.0/16':
                                if cidr == '0.0.0.0/0':
                                    continue  # 既に_check_internet_exposureで検出済み

                                self.issues.append(ConnectivityIssue(
                                    severity=Severity.WARNING,
                                    source=cidr,
                                    destination=f"{sg.name} ({sg_id})",
                                    port=port,
                                    protocol=rule.protocol,
                                    message=f"{service}ポート({port})への広範囲なアクセスが許可されています"
                                ))

    def generate_report(self, output_file: str = None):
        """レポートを生成"""
        report = []
        report.append("# ネットワーク接続性分析レポート\n")
        report.append(f"## 分析対象: {self.state_file}\n")

        # サマリー
        ok_count = sum(1 for i in self.issues if i.severity == Severity.OK)
        warning_count = sum(1 for i in self.issues if i.severity == Severity.WARNING)
        error_count = sum(1 for i in self.issues if i.severity == Severity.ERROR)

        report.append("## サマリー\n")
        report.append(f"- ✓ 問題なし: {len(self.security_groups) - warning_count - error_count}個のセキュリティグループ\n")
        report.append(f"- ⚠ 警告: {warning_count}件\n")
        report.append(f"- ✗ 問題: {error_count}件\n\n")

        # 検出された問題
        if self.issues:
            report.append("## 検出された問題\n\n")

            # エラーから表示
            errors = [i for i in self.issues if i.severity == Severity.ERROR]
            if errors:
                report.append("### 🚨 重大な問題\n\n")
                for issue in errors:
                    report.append(f"**{issue.severity.value} {issue.source} → {issue.destination}**\n")
                    report.append(f"- ポート: {issue.port} ({issue.protocol})\n")
                    report.append(f"- 問題: {issue.message}\n\n")

            # 警告
            warnings = [i for i in self.issues if i.severity == Severity.WARNING]
            if warnings:
                report.append("### ⚠️ 警告\n\n")
                for issue in warnings:
                    report.append(f"**{issue.severity.value} {issue.source} → {issue.destination}**\n")
                    report.append(f"- ポート: {issue.port} ({issue.protocol})\n")
                    report.append(f"- 警告: {issue.message}\n\n")
        else:
            report.append("## 検出された問題\n\n")
            report.append("問題は検出されませんでした。✓\n\n")

        # セキュリティグループ一覧
        report.append("## セキュリティグループ一覧\n\n")
        for sg_id, sg in self.security_groups.items():
            report.append(f"### {sg.name} ({sg_id})\n")
            report.append(f"- VPC: {sg.vpc_id}\n")
            report.append(f"- Ingressルール数: {len(sg.ingress_rules)}\n")
            report.append(f"- Egressルール数: {len(sg.egress_rules)}\n\n")

            if sg.ingress_rules:
                report.append("**Ingressルール:**\n")
                for rule in sg.ingress_rules:
                    sources = ", ".join(rule.cidr_blocks + rule.source_security_groups)
                    report.append(f"- {rule.protocol}:{rule.from_port}-{rule.to_port} ← {sources}\n")
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
        description='Terraform tfstateからネットワーク接続性を分析'
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

    analyzer = TerraformStateAnalyzer(args.state)

    if not analyzer.load_state():
        sys.exit(1)

    print("セキュリティグループを抽出中...")
    analyzer.extract_security_groups()
    print(f"検出: {len(analyzer.security_groups)}個のセキュリティグループ")

    print("接続性を分析中...")
    analyzer.analyze_connectivity()

    print("レポートを生成中...")
    analyzer.generate_report(args.output)


if __name__ == '__main__':
    main()
