#!/usr/bin/env python3
"""
OpenAPI仕様書バリデーションスクリプト

生成されたOpenAPI仕様書を検証します:
- YAML構文チェック
- OpenAPI 3.x 仕様への準拠確認
- 必須フィールドの存在確認
"""

import sys
import yaml
import json
from pathlib import Path
from typing import Dict, List, Any, Optional

class OpenAPIValidator:
    """OpenAPI仕様書のバリデータ"""

    def __init__(self, spec_file: Path):
        self.spec_file = spec_file
        self.spec = None
        self.errors: List[str] = []
        self.warnings: List[str] = []

    def validate(self) -> bool:
        """
        仕様書を検証

        Returns:
            bool: 検証が成功した場合True
        """
        print(f"Validating OpenAPI spec: {self.spec_file}")

        # ファイル存在確認
        if not self.spec_file.exists():
            self.errors.append(f"File not found: {self.spec_file}")
            return False

        # ファイル読み込み
        if not self._load_spec():
            return False

        # 基本構造チェック
        self._validate_structure()

        # 必須フィールドチェック
        self._validate_required_fields()

        # パスチェック
        self._validate_paths()

        # コンポーネントチェック
        self._validate_components()

        # 結果出力
        self._print_results()

        return len(self.errors) == 0

    def _load_spec(self) -> bool:
        """仕様書をロード"""
        try:
            with open(self.spec_file, 'r', encoding='utf-8') as f:
                if self.spec_file.suffix in ['.yaml', '.yml']:
                    self.spec = yaml.safe_load(f)
                elif self.spec_file.suffix == '.json':
                    self.spec = json.load(f)
                else:
                    self.errors.append(f"Unsupported file format: {self.spec_file.suffix}")
                    return False
            return True
        except yaml.YAMLError as e:
            self.errors.append(f"YAML parsing error: {e}")
            return False
        except json.JSONDecodeError as e:
            self.errors.append(f"JSON parsing error: {e}")
            return False
        except Exception as e:
            self.errors.append(f"Error loading file: {e}")
            return False

    def _validate_structure(self):
        """基本構造をチェック"""
        if not isinstance(self.spec, dict):
            self.errors.append("Root element must be an object")
            return

        # OpenAPIバージョンチェック
        openapi_version = self.spec.get('openapi', '')
        if not openapi_version:
            self.errors.append("Missing 'openapi' field")
        elif not openapi_version.startswith('3.'):
            self.errors.append(f"Unsupported OpenAPI version: {openapi_version}")
        elif openapi_version.startswith('3.2'):
            print(f"✓ OpenAPI version: {openapi_version}")
        elif openapi_version.startswith('3.1'):
            print(f"✓ OpenAPI version: {openapi_version}")
            self.warnings.append("OpenAPI 3.1 detected. Consider upgrading to 3.2.x")
        elif openapi_version.startswith('3.0'):
            print(f"✓ OpenAPI version: {openapi_version}")
            self.warnings.append("OpenAPI 3.0 detected. Consider upgrading to 3.2.x")

    def _validate_required_fields(self):
        """必須フィールドをチェック"""
        # info セクション
        if 'info' not in self.spec:
            self.errors.append("Missing required field: 'info'")
        else:
            info = self.spec['info']
            if not isinstance(info, dict):
                self.errors.append("'info' must be an object")
            else:
                if 'title' not in info:
                    self.errors.append("Missing required field: 'info.title'")
                if 'version' not in info:
                    self.errors.append("Missing required field: 'info.version'")

        # paths セクション
        if 'paths' not in self.spec:
            self.errors.append("Missing required field: 'paths'")
        elif not isinstance(self.spec['paths'], dict):
            self.errors.append("'paths' must be an object")

    def _validate_paths(self):
        """パスをチェック"""
        paths = self.spec.get('paths', {})
        if not paths:
            self.warnings.append("No paths defined")
            return

        print(f"\nValidating {len(paths)} paths...")

        for path, path_item in paths.items():
            if not isinstance(path_item, dict):
                self.errors.append(f"Path '{path}' must be an object")
                continue

            # HTTPメソッドチェック
            http_methods = ['get', 'post', 'put', 'patch', 'delete', 'options', 'head', 'trace']
            operations = {k: v for k, v in path_item.items() if k in http_methods}

            if not operations:
                self.warnings.append(f"Path '{path}' has no operations")
                continue

            for method, operation in operations.items():
                self._validate_operation(path, method, operation)

    def _validate_operation(self, path: str, method: str, operation: Dict[str, Any]):
        """オペレーションをチェック"""
        operation_id = f"{method.upper()} {path}"

        if not isinstance(operation, dict):
            self.errors.append(f"{operation_id}: operation must be an object")
            return

        # operationId の推奨
        if 'operationId' not in operation:
            self.warnings.append(f"{operation_id}: Missing 'operationId' (recommended)")

        # responses フィールドは必須
        if 'responses' not in operation:
            self.errors.append(f"{operation_id}: Missing required field 'responses'")
        else:
            self._validate_responses(operation_id, operation['responses'])

        # parameters チェック
        if 'parameters' in operation:
            self._validate_parameters(operation_id, operation['parameters'])

        # requestBody チェック
        if 'requestBody' in operation:
            self._validate_request_body(operation_id, operation['requestBody'])

    def _validate_responses(self, operation_id: str, responses: Dict[str, Any]):
        """レスポンスをチェック"""
        if not isinstance(responses, dict):
            self.errors.append(f"{operation_id}: 'responses' must be an object")
            return

        if not responses:
            self.errors.append(f"{operation_id}: 'responses' must have at least one response")
            return

        # ステータスコードチェック
        for status_code, response in responses.items():
            if status_code == 'default':
                continue

            # ステータスコードは3桁の数字または 'default'
            if not (status_code.isdigit() and len(status_code) == 3):
                self.errors.append(f"{operation_id}: Invalid status code '{status_code}'")

            if isinstance(response, dict):
                # description は必須
                if 'description' not in response:
                    self.errors.append(f"{operation_id}: Response {status_code} missing 'description'")

    def _validate_parameters(self, operation_id: str, parameters: List[Dict[str, Any]]):
        """パラメータをチェック"""
        if not isinstance(parameters, list):
            self.errors.append(f"{operation_id}: 'parameters' must be an array")
            return

        for i, param in enumerate(parameters):
            if not isinstance(param, dict):
                self.errors.append(f"{operation_id}: parameter[{i}] must be an object")
                continue

            # $ref の場合はスキップ
            if '$ref' in param:
                continue

            # 必須フィールド
            if 'name' not in param:
                self.errors.append(f"{operation_id}: parameter[{i}] missing 'name'")
            if 'in' not in param:
                self.errors.append(f"{operation_id}: parameter[{i}] missing 'in'")
            elif param['in'] not in ['query', 'header', 'path', 'cookie']:
                self.errors.append(f"{operation_id}: parameter[{i}] invalid 'in' value: {param['in']}")

            # path パラメータは required: true が必須
            if param.get('in') == 'path' and not param.get('required'):
                self.errors.append(f"{operation_id}: path parameter '{param.get('name')}' must have required: true")

    def _validate_request_body(self, operation_id: str, request_body: Dict[str, Any]):
        """リクエストボディをチェック"""
        if not isinstance(request_body, dict):
            self.errors.append(f"{operation_id}: 'requestBody' must be an object")
            return

        # $ref の場合はスキップ
        if '$ref' in request_body:
            return

        # content は必須
        if 'content' not in request_body:
            self.errors.append(f"{operation_id}: requestBody missing 'content'")

    def _validate_components(self):
        """コンポーネントをチェック"""
        if 'components' not in self.spec:
            return

        components = self.spec['components']
        if not isinstance(components, dict):
            self.errors.append("'components' must be an object")
            return

        # スキーマチェック
        if 'schemas' in components:
            schemas = components['schemas']
            if not isinstance(schemas, dict):
                self.errors.append("'components.schemas' must be an object")
            else:
                print(f"\nValidating {len(schemas)} schemas...")
                for schema_name, schema in schemas.items():
                    self._validate_schema(schema_name, schema)

        # セキュリティスキームチェック
        if 'securitySchemes' in components:
            sec_schemes = components['securitySchemes']
            if not isinstance(sec_schemes, dict):
                self.errors.append("'components.securitySchemes' must be an object")
            else:
                print(f"\nValidating {len(sec_schemes)} security schemes...")

    def _validate_schema(self, schema_name: str, schema: Any):
        """スキーマをチェック"""
        if not isinstance(schema, dict):
            self.errors.append(f"Schema '{schema_name}' must be an object")
            return

        # $ref の場合はスキップ
        if '$ref' in schema:
            return

        # type チェック (allOf, oneOf, anyOf がある場合は不要)
        if 'type' not in schema and not any(k in schema for k in ['allOf', 'oneOf', 'anyOf']):
            self.warnings.append(f"Schema '{schema_name}' missing 'type' field")

        # properties チェック (type: object の場合)
        if schema.get('type') == 'object':
            if 'properties' not in schema:
                self.warnings.append(f"Schema '{schema_name}' (type: object) has no 'properties'")

    def _print_results(self):
        """検証結果を出力"""
        print("\n" + "=" * 60)
        print("VALIDATION RESULTS")
        print("=" * 60)

        if self.warnings:
            print(f"\n⚠ Warnings ({len(self.warnings)}):")
            for warning in self.warnings:
                print(f"  - {warning}")

        if self.errors:
            print(f"\n✗ Errors ({len(self.errors)}):")
            for error in self.errors:
                print(f"  - {error}")
            print("\n❌ Validation FAILED")
        else:
            print("\n✅ Validation PASSED")

        print("=" * 60)


def main():
    """メイン関数"""
    if len(sys.argv) < 2:
        print("Usage: python validate_openapi.py <openapi-spec-file>")
        print("\nExample:")
        print("  python validate_openapi.py openapi.yaml")
        print("  python validate_openapi.py openapi.json")
        sys.exit(1)

    spec_file = Path(sys.argv[1])
    validator = OpenAPIValidator(spec_file)

    if validator.validate():
        sys.exit(0)
    else:
        sys.exit(1)


if __name__ == '__main__':
    main()
