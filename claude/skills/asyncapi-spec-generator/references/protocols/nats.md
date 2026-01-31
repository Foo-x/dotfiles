# NATS リファレンス

## 検出キーワード
- nats, nats.js, nats.go

## チャンネル定義パターン
- `nc.subscribe('subject')`, `nc.publish('subject')`

**Grepパターン例:**
- subscribe\(\s*['\"]([^'\"]+)['\"]
- publish\(\s*['\"]([^'\"]+)['\"]

## 典型的なファイル場所
- `src/**/nats*.*`
- `src/**/subscriber*.*`
- `src/**/publisher*.*`

## バインディングの要点
- `servers[*].bindings.nats`
- `channels[*].bindings.nats`
- `operations[*].bindings.nats`
- `messages[*].bindings.nats`
