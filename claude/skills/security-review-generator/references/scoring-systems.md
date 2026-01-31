# セキュリティスコアリングシステム

## CVSS v3.1 (Common Vulnerability Scoring System)

脆弱性の深刻度を0.0～10.0のスコアで評価する業界標準システム。

### スコア範囲
- **9.0-10.0**: Critical（緊急）
- **7.0-8.9**: High（高）
- **4.0-6.9**: Medium（中）
- **0.1-3.9**: Low（低）

### Base Metrics（基本評価基準）

- **Attack Vector (AV)**: Network (N) / Adjacent (A) / Local (L) / Physical (P)
- **Attack Complexity (AC)**: Low (L) / High (H)
- **Privileges Required (PR)**: None (N) / Low (L) / High (H)
- **User Interaction (UI)**: None (N) / Required (R)
- **Scope (S)**: Unchanged (U) / Changed (C)
- **Confidentiality Impact (C)**: None (N) / Low (L) / High (H)
- **Integrity Impact (I)**: None (N) / Low (L) / High (H)
- **Availability Impact (A)**: None (N) / Low (L) / High (H)

### CVSS計算例

**SQLインジェクション: AV:N/AC:L/PR:N/UI:N/S:C/C:H/I:H/A:H → スコア: 10.0 (Critical)**

**XSS (Stored): AV:N/AC:L/PR:L/UI:R/S:C/C:L/I:L/A:N → スコア: 5.4 (Medium)**

**CSRF: AV:N/AC:L/PR:N/UI:R/S:U/C:H/I:H/A:H → スコア: 8.8 (High)**

---

## DREAD (Microsoft)

リスクを5つの要素で評価（各0-10点）。

### 評価項目

- **D - Damage Potential (損害の可能性)**: 10=完全なシステム侵害、0=損害なし
- **R - Reproducibility (再現性)**: 10=常に再現可能、0=再現不可能
- **E - Exploitability (悪用の容易さ)**: 10=初心者でも可能、0=理論的にのみ可能
- **A - Affected Users (影響を受けるユーザー)**: 10=全ユーザー、0=管理者のみ
- **D - Discoverability (発見の容易さ)**: 10=自動ツールで発見可能、0=実質的に不可能

### DREAD計算

```
DREADスコア = (D + R + E + A + D) / 5

リスクレベル:
- 8.0-10.0: Critical
- 6.0-7.9: High
- 4.0-5.9: Medium
- 0.0-3.9: Low
```

### DREAD評価例

**SQLインジェクション: D=10, R=10, E=8, A=10, D=9 → スコア: 9.4 (Critical)**

**XSS (Reflected): D=6, R=8, E=7, A=5, D=7 → スコア: 6.6 (High)**

---

## ビジネス影響度評価

### CIA Triad評価

**Confidentiality (機密性)**
- Critical: 企業秘密、顧客の金融情報
- High: 個人識別情報（PII）
- Medium: 内部文書
- Low: 公開情報

**Integrity (完全性)**
- Critical: 金融トランザクション
- High: 顧客データ
- Medium: 設定ファイル
- Low: ログファイル

**Availability (可用性)**
- Critical: 決済システム（SLA 99.99%）
- High: Webサービス（SLA 99.9%）
- Medium: 管理画面（SLA 99%）
- Low: レポート機能（SLA 95%）

---

## コスト vs リスク ROI分析

### ROI計算

```
ROI = (リスク軽減額 - 対策コスト) / 対策コスト × 100%

例:
- 潜在的損失: $52,000,000
- リスク軽減率: 95%
- リスク軽減額: $49,400,000
- 対策コスト: $65,000

ROI = ($49,400,000 - $65,000) / $65,000 × 100% = 75,900%
費用対効果: 1:760
```

### 優先度マトリクス

```
              対策コスト
           Low    Med    High
リスク  High   P1     P1     P2
       Med    P2     P2     P3
       Low    P3     P3     P4

P1: 即座に対応（1週間以内）
P2: 短期対応（1ヶ月以内）
P3: 中期対応（3ヶ月以内）
P4: 長期対応（6ヶ月以内）
```
