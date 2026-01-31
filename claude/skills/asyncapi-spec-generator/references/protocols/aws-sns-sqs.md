# AWS SNS/SQS リファレンス

## 検出キーワード
- sns, sqs, aws-sdk, boto3

## チャンネル定義パターン
- `TopicArn`, `QueueUrl`, `SendMessage`, `Publish`

**Grepパターン例:**
- TopicArn\s*[:=]\s*['\"]([^'\"]+)['\"]
- QueueUrl\s*[:=]\s*['\"]([^'\"]+)['\"]
- Publish\(|SendMessage\(

## 典型的なファイル場所
- `src/**/sns*.*`
- `src/**/sqs*.*`
- `src/**/aws*.*`

## バインディングの要点
- `servers[*].bindings.sns` / `servers[*].bindings.sqs`
- `channels[*].bindings.sns` / `channels[*].bindings.sqs`
- `operations[*].bindings.sns` / `operations[*].bindings.sqs`
- `messages[*].bindings.sns` / `messages[*].bindings.sqs`
