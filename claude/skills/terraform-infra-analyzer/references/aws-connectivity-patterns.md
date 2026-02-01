# AWS接続パターンとセキュリティベストプラクティス

このドキュメントは、AWSインフラのネットワーク接続性と権限設定を分析する際の参考資料です。

## 目次

1. [一般的なアーキテクチャパターン](#一般的なアーキテクチャパターン)
2. [セキュリティグループのベストプラクティス](#セキュリティグループのベストプラクティス)
3. [IAM権限のベストプラクティス](#iam権限のベストプラクティス)
4. [よくある問題パターン](#よくある問題パターン)

---

## 一般的なアーキテクチャパターン

### 1. 3層アーキテクチャ (Web - App - DB)

```
Internet → ALB → Web層 (Public Subnet)
              ↓
           App層 (Private Subnet)
              ↓
           DB層 (Private Subnet)
```

**接続要件:**
- Internet → ALB: 443 (HTTPS), 80 (HTTP)
- ALB → Web層: 80または8080など
- Web層 → App層: アプリケーション固有ポート
- App層 → DB層: 3306 (MySQL), 5432 (PostgreSQL), など
- DB層 → Internet: **許可すべきでない**

### 2. サーバーレスアーキテクチャ (Lambda + DynamoDB/RDS)

```
API Gateway → Lambda (VPC内) → DynamoDB/RDS
```

**接続要件:**
- API Gateway → Lambda: AWS管理
- Lambda → DynamoDB: VPCエンドポイント経由またはNATゲートウェイ経由
- Lambda → RDS: セキュリティグループで制御

### 3. マイクロサービスアーキテクチャ

```
Service A ↔ Service B ↔ Service C
    ↓           ↓           ↓
  共有リソース (Cache, DB, Queue)
```

**接続要件:**
- サービス間: 相互通信（必要なサービスのみ）
- サービス → 共有リソース: 必要最小限のポート

---

## セキュリティグループのベストプラクティス

### ✅ 推奨される設定

1. **最小権限の原則**
   - 必要なポートのみ開放
   - 送信元を特定のセキュリティグループやCIDRに限定

2. **セキュリティグループ参照の使用**
   ```hcl
   ingress {
     security_groups = [aws_security_group.web.id]  # ✅ 推奨
   }
   ```

   CIDRブロックよりも、セキュリティグループ参照を使うことで動的な環境に対応できます。

3. **説明の記載**
   ```hcl
   ingress {
     description = "Allow HTTPS from ALB"
     # ...
   }
   ```

4. **Egressルールの制限**
   - デフォルトの `0.0.0.0/0` をすべてのポートで許可しない
   - 必要な通信先のみ許可

### ❌ 避けるべき設定

1. **広範囲なインターネット公開**
   ```hcl
   ingress {
     from_port   = 22
     to_port     = 22
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]  # ❌ SSHをインターネットに公開
   }
   ```

2. **すべてのポート/プロトコルの許可**
   ```hcl
   ingress {
     protocol    = "-1"
     cidr_blocks = ["0.0.0.0/0"]  # ❌ すべてのトラフィックを許可
   }
   ```

3. **データベースの直接公開**
   ```hcl
   # RDSセキュリティグループ
   ingress {
     from_port   = 3306
     to_port     = 3306
     cidr_blocks = ["0.0.0.0/0"]  # ❌ DBをインターネットに公開
   }
   ```

### 🔍 確認すべきポイント

- **SSHポート (22)**: 特定のIP、または踏み台サーバーからのみ
- **RDPポート (3389)**: 特定のIP、または踏み台サーバーからのみ
- **データベースポート (3306, 5432, 27017, 6379, 9200)**: VPC内部からのみ
- **管理ポート (8080, 9090, など)**: 信頼できるソースからのみ

---

## IAM権限のベストプラクティス

### ✅ 推奨される設定

1. **最小権限の原則**
   ```json
   {
     "Effect": "Allow",
     "Action": [
       "s3:GetObject",
       "s3:PutObject"
     ],
     "Resource": "arn:aws:s3:::my-bucket/*"
   }
   ```

2. **リソースの明示的な指定**
   ```json
   {
     "Effect": "Allow",
     "Action": "dynamodb:GetItem",
     "Resource": "arn:aws:dynamodb:us-east-1:123456789012:table/MyTable"
   }
   ```

3. **条件の使用**
   ```json
   {
     "Effect": "Allow",
     "Action": "s3:*",
     "Resource": "*",
     "Condition": {
       "IpAddress": {
         "aws:SourceIp": "10.0.0.0/16"
       }
     }
   }
   ```

### ❌ 避けるべき設定

1. **ワイルドカードの乱用**
   ```json
   {
     "Effect": "Allow",
     "Action": "*",
     "Resource": "*"  // ❌ 管理者権限に等しい
   }
   ```

2. **サービス全体への権限**
   ```json
   {
     "Effect": "Allow",
     "Action": "s3:*",
     "Resource": "*"  // ❌ すべてのS3バケットへのフルアクセス
   }
   ```

3. **機密性の高いアクションの無制限許可**
   ```json
   {
     "Effect": "Allow",
     "Action": [
       "iam:CreateUser",
       "iam:AttachUserPolicy"
     ],
     "Resource": "*"  // ❌ IAMユーザー作成が無制限
   }
   ```

### 🔍 よくある権限要件

#### Lambda関数

**最低限必要:**
```json
{
  "Effect": "Allow",
  "Action": [
    "logs:CreateLogGroup",
    "logs:CreateLogStream",
    "logs:PutLogEvents"
  ],
  "Resource": "arn:aws:logs:*:*:*"
}
```

**VPC内Lambda（追加で必要）:**
```json
{
  "Effect": "Allow",
  "Action": [
    "ec2:CreateNetworkInterface",
    "ec2:DescribeNetworkInterfaces",
    "ec2:DeleteNetworkInterface"
  ],
  "Resource": "*"
}
```

#### EC2インスタンス（S3アクセス）

```json
{
  "Effect": "Allow",
  "Action": [
    "s3:GetObject",
    "s3:ListBucket"
  ],
  "Resource": [
    "arn:aws:s3:::my-bucket",
    "arn:aws:s3:::my-bucket/*"
  ]
}
```

---

## よくある問題パターン

### 1. データベースがインターネットに公開されている

**症状:**
```hcl
resource "aws_security_group" "db" {
  ingress {
    from_port   = 3306
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

**修正:**
```hcl
resource "aws_security_group" "db" {
  ingress {
    from_port       = 3306
    security_groups = [aws_security_group.app.id]
  }
}
```

### 2. Lambda関数がCloudWatch Logsに書き込めない

**症状:**
Lambda実行エラー: "Unable to create log stream"

**原因:**
IAMロールにCloudWatch Logs権限がない

**修正:**
```hcl
resource "aws_iam_role_policy" "lambda_logs" {
  role = aws_iam_role.lambda.id

  policy = jsonencode({
    Statement = [{
      Effect = "Allow"
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      Resource = "arn:aws:logs:*:*:*"
    }]
  })
}
```

### 3. 過度に広範なIAM権限

**症状:**
```json
{
  "Effect": "Allow",
  "Action": "s3:*",
  "Resource": "*"
}
```

**修正:**
```json
{
  "Effect": "Allow",
  "Action": [
    "s3:GetObject",
    "s3:PutObject"
  ],
  "Resource": "arn:aws:s3:::specific-bucket/*"
}
```

### 4. NATゲートウェイがないPrivate Subnetからのインターネットアクセス

**症状:**
Private Subnet内のリソースがインターネットにアクセスできない

**修正:**
- NATゲートウェイを設置、またはVPCエンドポイントを使用

```hcl
resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.region.s3"

  route_table_ids = [aws_route_table.private.id]
}
```

### 5. セキュリティグループのEgressルールが過度に制限されている

**症状:**
必要な通信ができない（例: Lambda → DynamoDB）

**修正:**
必要な通信先へのEgressを明示的に許可

```hcl
egress {
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]  # またはVPCエンドポイントのSG
}
```

---

## チェックリスト

### ネットワーク接続性

- [ ] データベースがインターネットに公開されていないか
- [ ] SSH/RDPポートが0.0.0.0/0に公開されていないか
- [ ] 意図した通信経路が確保されているか（Web → App → DB など）
- [ ] 不要なEgressルールがないか
- [ ] 管理ポートが適切に保護されているか

### IAM権限

- [ ] ワイルドカード (`*`) が必要最小限に抑えられているか
- [ ] リソースが明示的に指定されているか
- [ ] 機密性の高いアクション（IAM操作など）が適切に制限されているか
- [ ] Lambda関数にCloudWatch Logs権限があるか
- [ ] VPC LambdaにENI作成権限があるか

---

## 参考リンク

- [AWS Security Best Practices](https://aws.amazon.com/security/best-practices/)
- [IAM Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)
- [VPC Security Best Practices](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-security-best-practices.html)
