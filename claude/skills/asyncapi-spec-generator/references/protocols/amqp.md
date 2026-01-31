# RabbitMQ/AMQP リファレンス

## 検出キーワード
- amqp, amqplib, rabbitmq, spring-amqp

## チャンネル定義パターン
- `exchange`, `queue`, `routingKey`

**Grepパターン例:**
- exchange\s*[:=]\s*['\"]([^'\"]+)['\"]
- queue\s*[:=]\s*['\"]([^'\"]+)['\"]
- routingKey\s*[:=]\s*['\"]([^'\"]+)['\"]

## 典型的なファイル場所
- `src/**/amqp*.*`
- `src/**/rabbit*.*`
- `src/**/queue*.*`

## バインディングの要点
- `servers[*].bindings.amqp`
- `channels[*].bindings.amqp`
- `operations[*].bindings.amqp`
- `messages[*].bindings.amqp`
