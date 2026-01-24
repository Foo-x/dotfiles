#!/usr/bin/env python3
"""
サブエージェント生成スクリプト
テンプレートベースでサブエージェントプロンプトを生成
"""

import os
import sys
import json
from pathlib import Path
from typing import Dict, List


class SubagentGenerator:
    """サブエージェント生成クラス"""

    def __init__(self, templates_dir: str):
        self.templates_dir = Path(templates_dir)
        self.available_templates = self._load_available_templates()

    def _load_available_templates(self) -> Dict[str, str]:
        """利用可能なテンプレートを読み込み"""
        templates = {}

        if not self.templates_dir.exists():
            return templates

        for template_file in self.templates_dir.glob('*.md'):
            template_name = template_file.stem
            try:
                with open(template_file, 'r', encoding='utf-8') as f:
                    templates[template_name] = f.read()
            except Exception as e:
                print(f"Warning: Failed to load template {template_name}: {e}", file=sys.stderr)

        return templates

    def generate(self, subagent_type: str, context: Dict) -> str:
        """サブエージェントプロンプトを生成

        Args:
            subagent_type: サブエージェントタイプ (backend-security, frontend-security, etc.)
            context: プロジェクト分析結果などのコンテキスト

        Returns:
            生成されたプロンプト
        """
        if subagent_type not in self.available_templates:
            raise ValueError(f"Unknown subagent type: {subagent_type}")

        template = self.available_templates[subagent_type]

        # コンテキストをテンプレートに挿入
        prompt = self._render_template(template, context)

        return prompt

    def _render_template(self, template: str, context: Dict) -> str:
        """テンプレートをレンダリング"""
        # プロジェクト情報を挿入
        languages = ', '.join(context.get('languages', []))
        frameworks = ', '.join(context.get('frameworks', []))
        project_type = context.get('project_type', 'unknown')

        # プレースホルダーを置換
        rendered = template.replace('{{LANGUAGES}}', languages)
        rendered = rendered.replace('{{FRAMEWORKS}}', frameworks)
        rendered = rendered.replace('{{PROJECT_TYPE}}', project_type)

        # 依存関係情報を追加
        if 'dependencies' in context:
            deps_text = self._format_dependencies(context['dependencies'])
            rendered = rendered.replace('{{DEPENDENCIES}}', deps_text)

        return rendered

    def _format_dependencies(self, dependencies: Dict[str, List[str]]) -> str:
        """依存関係情報をフォーマット"""
        lines = []
        for pkg_manager, deps in dependencies.items():
            if deps:
                lines.append(f"\n**{pkg_manager} dependencies:**")
                for dep in deps[:20]:  # 最大20件
                    lines.append(f"- {dep}")
                if len(deps) > 20:
                    lines.append(f"- ... and {len(deps) - 20} more")

        return '\n'.join(lines) if lines else 'No dependencies found'

    def list_available_subagents(self) -> List[str]:
        """利用可能なサブエージェントのリストを取得"""
        return list(self.available_templates.keys())

    def generate_batch(self, subagent_types: List[str], context: Dict) -> Dict[str, str]:
        """複数のサブエージェントプロンプトを一括生成

        Args:
            subagent_types: サブエージェントタイプのリスト
            context: プロジェクト分析結果

        Returns:
            {subagent_type: prompt} の辞書
        """
        results = {}

        for subagent_type in subagent_types:
            try:
                prompt = self.generate(subagent_type, context)
                results[subagent_type] = prompt
            except Exception as e:
                print(f"Warning: Failed to generate {subagent_type}: {e}", file=sys.stderr)
                results[subagent_type] = None

        return results


def main():
    """メイン関数"""
    if len(sys.argv) < 3:
        print("Usage: generate_subagent.py <templates_dir> <subagent_type> [context_json]")
        print("\nAvailable subagent types:")
        print("  - backend-security")
        print("  - frontend-security")
        print("  - infrastructure-security")
        print("  - api-security")
        sys.exit(1)

    templates_dir = sys.argv[1]
    subagent_type = sys.argv[2]

    # コンテキストの読み込み
    context = {}
    if len(sys.argv) > 3:
        try:
            context = json.loads(sys.argv[3])
        except json.JSONDecodeError:
            # ファイルパスとして扱う
            try:
                with open(sys.argv[3], 'r', encoding='utf-8') as f:
                    context = json.load(f)
            except Exception as e:
                print(f"Error: Failed to load context: {e}", file=sys.stderr)
                sys.exit(1)

    generator = SubagentGenerator(templates_dir)

    # リスト表示
    if subagent_type == '--list':
        print("Available subagents:")
        for name in generator.list_available_subagents():
            print(f"  - {name}")
        sys.exit(0)

    # プロンプト生成
    try:
        prompt = generator.generate(subagent_type, context)
        print(prompt)
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == '__main__':
    main()
