# WebSocket リファレンス

## 検出キーワード
- websocket, ws, socket.io, spring-websocket

## チャンネル定義パターン
- `ws.on('message')`, `ws.send()`, `io.on('connection')`

**Grepパターン例:**
- on\(\s*['\"]message['\"]
- send\(
- socket\.emit\(

## 典型的なファイル場所
- `src/**/ws*.*`
- `src/**/websocket*.*`
- `src/**/socket*.*`

## バインディングの要点
- `servers[*].bindings.ws`
- `channels[*].bindings.ws`
- `operations[*].bindings.ws`
- `messages[*].bindings.ws`
