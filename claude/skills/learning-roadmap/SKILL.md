---
name: learning-roadmap
description: 最新の学習科学原則に基づいた効率的な学習ロードマップを生成するスキル。スペースド・リピティション、想起練習、インターリービング、プロジェクトベース学習を統合したインタラクティブHTMLを出力する。
disable-model-invocation: true
---

# 学習ロードマップ作成スキル

## 学習科学原則（必須ルール）

| 原則 | 実装ルール |
|------|----------|
| **スペースド・リピティション** | 復習間隔: 1d → 3d → 7d → 14d → 30d。結果に応じ: 80%以上→次の間隔へ進む、50-79%→翌日に再試行、50%未満→Day 1からリセット |
| **想起練習** | 各モジュールに3-5問。正答時: なぜ正しいかの説明＋関連知識の補足。誤答時: 正答の説明＋誤答が間違いである理由＋正しい理解への道筋 |
| **インターリービング** | 同一ドメイン内の関連概念のみ混合（ランダム混合禁止）。フェーズ間移行時に10-15問の混合セッションを配置 |
| **マイクロラーニング** | 各モジュール5-10分。1モジュール=1概念。学習目標を冒頭に提示 |
| **プロジェクトベース学習** | 3-5個、段階的複雑性（ガイド付き→部分的オープン→完全オープン）。明確な完了条件＋チェックリスト形式マイルストーン |

## テンプレートプレースホルダー仕様

テンプレートファイル: `template/roadmap-template.html`（**Stage 3 で Read ツールで読み込む。自動ロードされない**）

### プレースホルダー一覧（11個）

| プレースホルダー | 型 | 説明 |
|---------------|-----|------|
| `{{ROADMAP_TITLE}}` | string | ロードマップタイトル（`<title>` と `<h1>` の2箇所に使用） |
| `{{ROADMAP_ID}}` | string | localStorage キー用ID（英数字・ハイフンのみ、例: `python-beginner`） |
| `{{ESTIMATED_DURATION}}` | string | 推定期間（例: `8-10週間`） |
| `{{WEEKLY_HOURS}}` | string | 週あたり学習時間（例: `5-10時間`） |
| `{{DIFFICULTY}}` | string | 難易度（例: `初心者〜中級者`） |
| `{{PREREQUISITES}}` | HTML | `<li>` 要素のリスト |
| `{{LEARNING_OBJECTIVES}}` | HTML | `<li>` 要素のリスト |
| `{{MODULES_CONTENT}}` | HTML | モジュールアコーディオン群（下記パターン参照） |
| `{{INTERLEAVING_CONTENT}}` | HTML | インターリービングクイズカード群（下記パターン参照） |
| `{{PROJECTS_CONTENT}}` | HTML | プロジェクトカード群（下記パターン参照） |
| `{{RESOURCES_CONTENT}}` | HTML | リソースカテゴリリスト群（下記パターン参照） |

### `{{MODULES_CONTENT}}` HTMLパターン

```html
<!-- フェーズ見出し -->
<h3 style="margin: 2rem 0 1rem; color: var(--primary);">フェーズ1: 基礎</h3>

<!-- モジュール1件 -->
<div class="module-accordion" id="module-{moduleId}">
  <button class="module-trigger" onclick="toggleModule('{moduleId}')" aria-expanded="false" aria-controls="module-{moduleId}-body">
    <div style="display:flex; align-items:center; gap:0.75rem;">
      <span class="module-status-icon" id="status-{moduleId}">⬜</span>
      <div>
        <div style="font-weight:600;">{モジュール名}</div>
        <div style="font-size:0.75rem; color:var(--text-light);">約{X}分</div>
      </div>
    </div>
    <span class="accordion-icon">▼</span>
  </button>
  <div class="module-body" id="module-{moduleId}-body">
    <div class="learning-objectives">
      <strong>学習目標:</strong>
      <ul><li>{目標1}</li><li>{目標2}</li></ul>
    </div>
    <div class="module-content">
      {HTMLコンテンツ: 概念説明・コード例・図解}
    </div>
    <button class="btn btn-primary" onclick="completeModule('{moduleId}')" id="complete-btn-{moduleId}">✅ 完了にする</button>
    <div class="quiz-section">
      <h4>理解度チェック</h4>
      <div class="quiz-score" id="quiz-score-{moduleId}" style="display:none;">
        <span id="score-text-{moduleId}"></span>
      </div>
      {クイズ問題HTML × 3-5問}
    </div>
  </div>
</div>
```

**moduleId 命名規則**: フェーズ番号-モジュール番号（例: `1-1`, `1-2`, `2-1`）

### クイズ問題 HTMLパターン（1問分）

```html
<div class="quiz-question">
  <p class="question-text">{問題文}</p>
  <div class="quiz-options">
    <div class="quiz-option">
      <input type="radio" name="quiz-{moduleId}-q{index}" id="quiz-{moduleId}-q{index}-a" value="a" data-correct="false">
      <label for="quiz-{moduleId}-q{index}-a">{選択肢A}</label>
    </div>
    <div class="quiz-option">
      <input type="radio" name="quiz-{moduleId}-q{index}" id="quiz-{moduleId}-q{index}-b" value="b" data-correct="true">
      <label for="quiz-{moduleId}-q{index}-b">{選択肢B（正答）}</label>
    </div>
    <!-- 選択肢C, D も同様 -->
  </div>
  <button class="quiz-submit-btn" onclick="submitQuiz('{moduleId}', {index})">回答する</button>
  <div class="quiz-feedback correct" id="feedback-correct-{moduleId}-q{index}">
    ✅ 正解！{なぜ正しいかの説明。関連知識の補足}
  </div>
  <div class="quiz-feedback incorrect" id="feedback-incorrect-{moduleId}-q{index}">
    ❌ 不正解。{正答の説明。誤答が間違いである理由。正しい理解への道筋}
  </div>
</div>
```

**重要**: `name` 属性は `quiz-{moduleId}-q{index}` 形式。`index` は 0 始まり整数。`data-correct="true"` は各問に正答1つのみ。

### `{{INTERLEAVING_CONTENT}}` HTMLパターン

```html
<div class="card" style="margin-bottom: 2rem;">
  <h3>{セッション名（例: フェーズ1 インターリービング練習）}</h3>
  <p style="color:var(--text-light); font-size:0.875rem;">{対象フェーズと混合概念の説明}</p>
  <!-- クイズ問題 10-15問（moduleId に "interleaving-1" 等を使用） -->
  {クイズ問題HTML × 10-15問}
</div>
```

### `{{PROJECTS_CONTENT}}` HTMLパターン

```html
<div class="project-card" id="project-{projectId}">
  <div class="project-header">
    <h3>{プロジェクト名}</h3>
    <span class="project-level">{レベル表記（例: レベル1）}</span>
  </div>
  <p>{プロジェクト説明}</p>
  <ul class="project-checklist">
    <li>
      <input type="checkbox" id="project-{projectId}-m0" onchange="toggleProjectMilestone('{projectId}', 0)">
      <label for="project-{projectId}-m0">{マイルストーン1}</label>
    </li>
    <li>
      <input type="checkbox" id="project-{projectId}-m1" onchange="toggleProjectMilestone('{projectId}', 1)">
      <label for="project-{projectId}-m1">{マイルストーン2}</label>
    </li>
    <!-- 追加マイルストーン... -->
  </ul>
</div>
```

**projectId 命名規則**: 英数字・ハイフン（例: `project-1`, `project-2`）

### `{{RESOURCES_CONTENT}}` HTMLパターン

```html
<div class="resource-category">
  <h3>{カテゴリ名（例: 公式ドキュメント）}</h3>
  <ul class="resource-list">
    <li><a href="{URL}" target="_blank" rel="noopener">{リソース名}</a> - {説明・公開年}</li>
    <!-- 追加リソース... -->
  </ul>
</div>
```

## 段階的生成ワークフロー

### Stage 1: 要件収集 + WebSearch（コンテキスト: 低）

1. 現在年を取得（`new Date().getFullYear()` 相当、システム日付から判断）
2. ユーザーから以下を収集:

| 項目 | 必須 | デフォルト値 |
|------|------|------------|
| トピック | ✅ | - |
| 現在のレベル | ❌ | 初心者 |
| 週あたりの学習時間 | ❌ | 5-10時間 |
| 学習目標 | ❌ | トピックの基礎から応用まで習得 |
| 言語 | ❌ | 日本語 |

3. WebSearch で最新リソースを検索（現在年を動的使用）:
   - `"{topic} tutorial {year}"`
   - `"learn {topic} roadmap {year-1}"`
   - `"{topic} beginner guide {year}"`
   - リソース検証: 3年以内を優先。それ以上は「クラシックリソース」として注記

### Stage 2: コンテンツ生成（コンテキスト: 中）

テンプレートは **読み込み不要**（上記パターン仕様で代替）。以下を生成:

1. **メタ情報**: ROADMAP_TITLE, ROADMAP_ID, ESTIMATED_DURATION, WEEKLY_HOURS, DIFFICULTY
2. **前提条件** (`{{PREREQUISITES}}`): `<li>` リスト
3. **学習目標** (`{{LEARNING_OBJECTIVES}}`): `<li>` リスト
4. **モジュール** (`{{MODULES_CONTENT}}`): 上記パターンに従い全フェーズのHTML生成
   - フェーズ1: 基礎（3-5モジュール）
   - フェーズ2: 中級（5-8モジュール）
   - フェーズ3: 応用（5-8モジュール）
5. **インターリービング** (`{{INTERLEAVING_CONTENT}}`): フェーズ間の混合クイズ
6. **プロジェクト** (`{{PROJECTS_CONTENT}}`): 3-5個のプロジェクトカード
7. **リソース** (`{{RESOURCES_CONTENT}}`): 検索結果から最新リソース

**大規模ロードマップの場合**（モジュール12個以上）:
- Stage 2 をフェーズ単位で分割（フェーズ1→2→3と順次生成）
- 各フェーズHTMLを一時ファイル（`/tmp/claude/phase-{n}.html`）に書き出し
- Stage 3 で結合してテンプレートに挿入

### Stage 3: テンプレート組立（コンテキスト: 一時的に高）

```
1. Read ツールで `template/roadmap-template.html` を読み込み
2. 11個のプレースホルダーを Stage 2 で生成したコンテンツで置換
3. Write ツールでユーザー指定パス（またはデフォルト: `~/learning-roadmap-{topic}.html`）に出力
```

### Stage 4: 品質チェック（コンテキスト: 低）

出力ファイルに対して Grep で `{{` を検索し、未置換プレースホルダーがないことを確認後、レポートを作成:

**チェック項目**:
- [ ] 全プレースホルダーが置換済み（`{{` が残っていない）
- [ ] 各モジュールに3-5問のクイズがある
- [ ] `quiz-{moduleId}-q{index}` の命名が一貫している
- [ ] `data-correct="true"` が各問に1つだけある
- [ ] プロジェクトIDが `project-{id}` 形式
- [ ] リソースが現在年から3年以内

## 出力テンプレート

```
## 学習ロードマップ生成完了

**トピック**: {topic}
**ファイル**: {output_path}

### ロードマップ概要
- **推定期間**: {duration}
- **フェーズ数**: 3（基礎・中級・応用）
- **モジュール数**: {module_count}
- **クイズ問題数**: {quiz_count}
- **プロジェクト数**: {project_count}

### 使い方
1. ブラウザで `{output_path}` を開いてください
2. ダッシュボードで全体の進捗を確認できます
3. 各モジュールをクリックして学習を開始してください
4. クイズに回答して理解度を確認してください
5. 復習カレンダーで次の復習日を確認してください
6. 進捗はブラウザに自動保存されます

### 品質レポート
{quality_report}
```

## 注意事項

- **テンプレートは Stage 3 まで不要**: パターン仕様を参照してコンテンツを生成すること
- **最新性**: WebSearch では必ず現在年を動的に取得して使用
- **アクセシビリティ**: WCAG 2.1 AA基準（コントラスト比4.5:1以上、キーボードナビ対応）
- **マイクロラーニング**: 各モジュールは5-10分で完了可能なサイズを厳守
- **セルフコンテインド**: 生成されるHTMLは外部依存を持たない単一ファイル
