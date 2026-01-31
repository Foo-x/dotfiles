# MQTT リファレンス

## 検出キーワード
- mqtt, paho-mqtt, hbmqtt

## チャンネル定義パターン
- `client.subscribe('topic')`, `client.publish('topic')`

**Grepパターン例:**
- subscribe\(\s*['\"]([^'\"]+)['\"]
- publish\(\s*['\"]([^'\"]+)['\"]

## 典型的なファイル場所
- `src/**/mqtt*.*`
- `src/**/subscriber*.*`
- `src/**/publisher*.*`

## バインディングの要点
- `servers[*].bindings.mqtt`
- `channels[*].bindings.mqtt`
- `operations[*].bindings.mqtt`
- `messages[*].bindings.mqtt`
