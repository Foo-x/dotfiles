# Kafka リファレンス

## 検出キーワード
- kafka, kafkajs, spring-kafka, confluent-kafka, segmentio/kafka-go

## チャンネル定義パターン
- トピック名を `topic` / `topics` / `topicName` で扱う実装
- 例: `producer.send({ topic: 'user.signedup' })`

**Grepパターン例:**
- "topic"\s*:\s*['\"]([^'\"]+)['\"]
- producer\.send\(
- consumer\.subscribe\(

## 典型的なファイル場所
- `src/**/producer*.*`
- `src/**/consumer*.*`
- `src/**/kafka*.*`

## バインディングの要点
- `servers[*].bindings.kafka`
- `channels[*].bindings.kafka`
- `operations[*].bindings.kafka`
- `messages[*].bindings.kafka`
