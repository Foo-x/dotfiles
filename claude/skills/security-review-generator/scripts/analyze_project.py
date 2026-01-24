#!/usr/bin/env python3
"""
プロジェクト分析スクリプト
技術スタックを検出し、プロジェクトタイプを特定
"""

import json
import sys
from pathlib import Path
from typing import Dict, List, Set


class ProjectAnalyzer:
    """プロジェクト分析クラス"""

    def __init__(self, project_path: str):
        self.project_path = Path(project_path)
        self.tech_stack: Set[str] = set()
        self.project_type: str = "unknown"
        self.entry_points: List[str] = []
        self.frameworks: Set[str] = set()
        self.languages: Set[str] = set()

    def analyze(self) -> Dict:
        """プロジェクト全体を分析"""
        self._detect_languages()
        self._detect_frameworks()
        self._identify_entry_points()
        self._determine_project_type()

        return self.get_results()

    def _detect_languages(self):
        """言語を検出"""
        file_extensions = {
            '.py': 'Python',
            '.js': 'JavaScript',
            '.ts': 'TypeScript',
            '.java': 'Java',
            '.go': 'Go',
            '.rs': 'Rust',
            '.rb': 'Ruby',
            '.php': 'PHP',
            '.cs': 'C#',
            '.cpp': 'C++',
            '.c': 'C',
        }

        for ext, lang in file_extensions.items():
            if list(self.project_path.rglob(f'*{ext}')):
                self.languages.add(lang)

    def _detect_frameworks(self):
        """フレームワークを検出"""
        # パッケージマネージャーファイルをチェック
        framework_indicators = {
            'package.json': self._analyze_package_json,
            'requirements.txt': self._analyze_requirements,
            'Pipfile': self._analyze_pipfile,
            'go.mod': self._analyze_go_mod,
            'Cargo.toml': self._analyze_cargo,
            'pom.xml': self._analyze_maven,
            'build.gradle': self._analyze_gradle,
            'composer.json': self._analyze_composer,
            'Gemfile': self._analyze_gemfile,
        }

        for filename, analyzer in framework_indicators.items():
            filepath = self.project_path / filename
            if filepath.exists():
                analyzer(filepath)

    def _analyze_package_json(self, filepath: Path):
        """package.jsonを分析"""
        try:
            with open(filepath, 'r', encoding='utf-8') as f:
                data = json.load(f)

            deps = {**data.get('dependencies', {}), **data.get('devDependencies', {})}

            # フレームワーク検出
            if 'react' in deps:
                self.frameworks.add('React')
            if 'vue' in deps:
                self.frameworks.add('Vue.js')
            if 'angular' in deps or '@angular/core' in deps:
                self.frameworks.add('Angular')
            if 'next' in deps:
                self.frameworks.add('Next.js')
            if 'express' in deps:
                self.frameworks.add('Express')
            if 'fastify' in deps:
                self.frameworks.add('Fastify')
            if 'nestjs' in deps or '@nestjs/core' in deps:
                self.frameworks.add('NestJS')

        except Exception as e:
            print(f"Warning: Failed to parse package.json: {e}", file=sys.stderr)

    def _analyze_requirements(self, filepath: Path):
        """requirements.txtを分析"""
        try:
            with open(filepath, 'r', encoding='utf-8') as f:
                lines = f.readlines()

            deps = [line.split('==')[0].split('>=')[0].strip() for line in lines if line.strip() and not line.startswith('#')]

            # フレームワーク検出
            deps_lower = [d.lower() for d in deps]
            if 'django' in deps_lower:
                self.frameworks.add('Django')
            if 'flask' in deps_lower:
                self.frameworks.add('Flask')
            if 'fastapi' in deps_lower:
                self.frameworks.add('FastAPI')
            if 'sqlalchemy' in deps_lower:
                self.frameworks.add('SQLAlchemy')

        except Exception as e:
            print(f"Warning: Failed to parse requirements.txt: {e}", file=sys.stderr)

    def _analyze_pipfile(self, filepath: Path):
        """Pipfileを分析"""
        # 簡易的な実装（tomlパーサーがない場合）
        try:
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()

            if 'django' in content.lower():
                self.frameworks.add('Django')
            if 'flask' in content.lower():
                self.frameworks.add('Flask')
            if 'fastapi' in content.lower():
                self.frameworks.add('FastAPI')

        except Exception as e:
            print(f"Warning: Failed to parse Pipfile: {e}", file=sys.stderr)

    def _analyze_go_mod(self, filepath: Path):
        """go.modを分析"""
        try:
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()

            if 'gin-gonic/gin' in content:
                self.frameworks.add('Gin')
            if 'gorilla/mux' in content:
                self.frameworks.add('Gorilla Mux')
            if 'echo' in content:
                self.frameworks.add('Echo')

        except Exception as e:
            print(f"Warning: Failed to parse go.mod: {e}", file=sys.stderr)

    def _analyze_cargo(self, filepath: Path):
        """Cargo.tomlを分析"""
        try:
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()

            if 'actix-web' in content:
                self.frameworks.add('Actix Web')
            if 'rocket' in content:
                self.frameworks.add('Rocket')
            if 'axum' in content:
                self.frameworks.add('Axum')

        except Exception as e:
            print(f"Warning: Failed to parse Cargo.toml: {e}", file=sys.stderr)

    def _analyze_maven(self, filepath: Path):
        """pom.xmlを分析"""
        try:
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()

            if 'spring-boot' in content:
                self.frameworks.add('Spring Boot')
            if 'jakarta.servlet' in content or 'javax.servlet' in content:
                self.frameworks.add('Java Servlet')

        except Exception as e:
            print(f"Warning: Failed to parse pom.xml: {e}", file=sys.stderr)

    def _analyze_gradle(self, filepath: Path):
        """build.gradleを分析"""
        try:
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()

            if 'spring-boot' in content:
                self.frameworks.add('Spring Boot')

        except Exception as e:
            print(f"Warning: Failed to parse build.gradle: {e}", file=sys.stderr)

    def _analyze_composer(self, filepath: Path):
        """composer.jsonを分析"""
        try:
            with open(filepath, 'r', encoding='utf-8') as f:
                data = json.load(f)

            deps = data.get('require', {})
            if 'laravel/framework' in deps:
                self.frameworks.add('Laravel')
            if 'symfony/symfony' in deps:
                self.frameworks.add('Symfony')

        except Exception as e:
            print(f"Warning: Failed to parse composer.json: {e}", file=sys.stderr)

    def _analyze_gemfile(self, filepath: Path):
        """Gemfileを分析"""
        try:
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()

            if 'rails' in content:
                self.frameworks.add('Ruby on Rails')
            if 'sinatra' in content:
                self.frameworks.add('Sinatra')

        except Exception as e:
            print(f"Warning: Failed to parse Gemfile: {e}", file=sys.stderr)

    def _identify_entry_points(self):
        """エントリーポイントを特定"""
        entry_point_patterns = [
            'main.py',
            'app.py',
            'server.py',
            'index.js',
            'server.js',
            'main.go',
            'main.rs',
            'Main.java',
            'index.php',
            'app.rb',
        ]

        for pattern in entry_point_patterns:
            matches = list(self.project_path.rglob(pattern))
            self.entry_points.extend([str(m.relative_to(self.project_path)) for m in matches])

    def _determine_project_type(self):
        """プロジェクトタイプを判定"""
        # バックエンド判定
        backend_indicators = {
            'Django', 'Flask', 'FastAPI', 'Express', 'Fastify', 'NestJS',
            'Spring Boot', 'Gin', 'Laravel', 'Ruby on Rails'
        }

        # フロントエンド判定
        frontend_indicators = {
            'React', 'Vue.js', 'Angular', 'Next.js'
        }

        # インフラ判定
        infra_files = ['Dockerfile', 'docker-compose.yml', 'kubernetes/', 'terraform/', '.tf']
        has_infra = any((self.project_path / f).exists() for f in infra_files[:3]) or \
                    list(self.project_path.rglob('*.tf'))

        has_backend = bool(self.frameworks & backend_indicators)
        has_frontend = bool(self.frameworks & frontend_indicators)

        if has_backend and has_frontend:
            self.project_type = 'fullstack'
        elif has_backend:
            self.project_type = 'backend'
        elif has_frontend:
            self.project_type = 'frontend'
        elif has_infra:
            self.project_type = 'infrastructure'
        else:
            # 言語から推測
            if 'JavaScript' in self.languages or 'TypeScript' in self.languages:
                # package.jsonの確認
                pkg_json = self.project_path / 'package.json'
                if pkg_json.exists():
                    try:
                        with open(pkg_json, 'r') as f:
                            data = json.load(f)
                        if 'express' in str(data.get('dependencies', {})).lower():
                            self.project_type = 'backend'
                        else:
                            self.project_type = 'frontend'
                    except:
                        self.project_type = 'unknown'
            elif 'Python' in self.languages:
                self.project_type = 'backend'
            elif 'Go' in self.languages or 'Rust' in self.languages or 'Java' in self.languages:
                self.project_type = 'backend'

    def get_results(self) -> Dict:
        """分析結果を取得（依存関係は含まない）"""
        return {
            'project_type': self.project_type,
            'languages': list(self.languages),
            'frameworks': list(self.frameworks),
            'entry_points': self.entry_points,
            'recommended_subagents': self._get_recommended_subagents(),
        }

    def _get_recommended_subagents(self) -> List[str]:
        """推奨サブエージェントを取得"""
        subagents = []

        if self.project_type in ['backend', 'fullstack']:
            subagents.append('backend-security')

        if self.project_type in ['frontend', 'fullstack']:
            subagents.append('frontend-security')

        # API判定
        api_indicators = ['Express', 'FastAPI', 'Flask', 'Django', 'Spring Boot', 'Gin', 'Fastify']
        if any(indicator in self.frameworks for indicator in api_indicators):
            subagents.append('api-security')

        # インフラ判定
        if self.project_type == 'infrastructure' or \
           any((self.project_path / f).exists() for f in ['Dockerfile', 'docker-compose.yml']):
            subagents.append('infrastructure-security')

        return subagents


def main():
    """メイン関数"""
    if len(sys.argv) < 2:
        print("Usage: analyze_project.py <project_path>")
        sys.exit(1)

    project_path = sys.argv[1]

    analyzer = ProjectAnalyzer(project_path)
    results = analyzer.analyze()

    # JSON出力
    print(json.dumps(results, indent=2, ensure_ascii=False))


if __name__ == '__main__':
    main()
