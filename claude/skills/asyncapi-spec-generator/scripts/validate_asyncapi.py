#!/usr/bin/env python3
"""
AsyncAPI仕様書バリデーションスクリプト

生成されたAsyncAPI仕様書を検証します:
- YAML/JSON 構文チェック
- AsyncAPI 3.x 仕様の必須フィールド確認
- channels / operations の基本整合性
"""

import json
import sys
from pathlib import Path
from typing import Any, Dict, List

import yaml


class AsyncAPIValidator:
    """AsyncAPI仕様書のバリデータ"""

    def __init__(self, spec_file: Path):
        self.spec_file = spec_file
        self.spec: Dict[str, Any] | None = None
        self.errors: List[str] = []
        self.warnings: List[str] = []

    def validate(self) -> bool:
        print(f"Validating AsyncAPI spec: {self.spec_file}")

        if not self.spec_file.exists():
            self.errors.append(f"File not found: {self.spec_file}")
            return False

        if not self._load_spec():
            return False

        self._validate_structure()
        self._validate_required_fields()
        self._validate_channels()
        self._validate_operations()
        self._print_results()

        return len(self.errors) == 0

    def _load_spec(self) -> bool:
        try:
            with open(self.spec_file, "r", encoding="utf-8") as handle:
                if self.spec_file.suffix in [".yaml", ".yml"]:
                    self.spec = yaml.safe_load(handle)
                elif self.spec_file.suffix == ".json":
                    self.spec = json.load(handle)
                else:
                    self.errors.append(f"Unsupported file format: {self.spec_file.suffix}")
                    return False
            return True
        except yaml.YAMLError as exc:
            self.errors.append(f"YAML parsing error: {exc}")
            return False
        except json.JSONDecodeError as exc:
            self.errors.append(f"JSON parsing error: {exc}")
            return False
        except Exception as exc:
            self.errors.append(f"Error loading file: {exc}")
            return False

    def _validate_structure(self) -> None:
        if not isinstance(self.spec, dict):
            self.errors.append("Root element must be an object")
            return

        version = self.spec.get("asyncapi", "")
        if not version:
            self.errors.append("Missing 'asyncapi' field")
        elif not version.startswith("3."):
            self.errors.append(f"Unsupported AsyncAPI version: {version}")
        else:
            print(f"✓ AsyncAPI version: {version}")

    def _validate_required_fields(self) -> None:
        if "info" not in self.spec:
            self.errors.append("Missing required field: 'info'")
        else:
            info = self.spec["info"]
            if not isinstance(info, dict):
                self.errors.append("'info' must be an object")
            else:
                if "title" not in info:
                    self.errors.append("Missing required field: 'info.title'")
                if "version" not in info:
                    self.errors.append("Missing required field: 'info.version'")

        if "channels" not in self.spec:
            self.errors.append("Missing required field: 'channels'")
        elif not isinstance(self.spec["channels"], dict):
            self.errors.append("'channels' must be an object")

        if "operations" not in self.spec:
            self.warnings.append("Missing field: 'operations' (recommended)")
        elif not isinstance(self.spec["operations"], dict):
            self.errors.append("'operations' must be an object")

    def _validate_channels(self) -> None:
        channels = self.spec.get("channels", {}) if isinstance(self.spec, dict) else {}
        if not channels:
            self.warnings.append("No channels defined")
            return

        print(f"\nValidating {len(channels)} channels...")

        for name, channel in channels.items():
            if not isinstance(channel, dict):
                self.errors.append(f"Channel '{name}' must be an object")
                continue
            if "messages" not in channel:
                self.warnings.append(f"Channel '{name}' missing 'messages' (recommended)")

    def _validate_operations(self) -> None:
        operations = self.spec.get("operations", {}) if isinstance(self.spec, dict) else {}
        if not operations:
            return

        for op_name, operation in operations.items():
            if not isinstance(operation, dict):
                self.errors.append(f"Operation '{op_name}' must be an object")
                continue
            action = operation.get("action")
            if action not in {"send", "receive"}:
                self.errors.append(f"Operation '{op_name}' has invalid action '{action}'")
            if "channel" not in operation:
                self.errors.append(f"Operation '{op_name}' missing 'channel'")

    def _print_results(self) -> None:
        if self.errors:
            print("\nErrors:")
            for error in self.errors:
                print(f"- {error}")
        if self.warnings:
            print("\nWarnings:")
            for warning in self.warnings:
                print(f"- {warning}")


def main() -> None:
    if len(sys.argv) != 2:
        print("Usage: validate_asyncapi.py <spec-file>")
        sys.exit(1)

    validator = AsyncAPIValidator(Path(sys.argv[1]))
    success = validator.validate()
    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
