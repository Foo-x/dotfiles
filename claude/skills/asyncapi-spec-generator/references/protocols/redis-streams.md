# Redis Streams リファレンス

## 検出キーワード
- redis, ioredis, xadd, xread, xgroup

## チャンネル定義パターン
- `xadd stream`, `xread stream`

**Grepパターン例:**
- xadd\s+['\"]([^'\"]+)['\"]
- xread\s+[^\n]*['\"]([^'\"]+)['\"]

## 典型的なファイル場所
- `src/**/redis*.*`
- `src/**/stream*.*`

## バインディングの要点
- `servers[*].bindings.redis`
- `channels[*].bindings.redis`
- `operations[*].bindings.redis`
- `messages[*].bindings.redis`
