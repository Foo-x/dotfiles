# WAI-ARIA ウィジェットパターン

よく使われるインタラクティブコンポーネントの正しいARIAパターン。
コードレビュー時に期待されるARIA属性・キーボード操作を照合するためのリファレンス。

## 目次
1. [ボタン](#ボタン)
2. [リンク](#リンク)
3. [ダイアログ (モーダル)](#ダイアログ-モーダル)
4. [タブ](#タブ)
5. [アコーディオン](#アコーディオン)
6. [ドロップダウンメニュー](#ドロップダウンメニュー)
7. [コンボボックス (オートコンプリート)](#コンボボックス-オートコンプリート)
8. [ツールチップ](#ツールチップ)
9. [アラートとステータス](#アラートとステータス)
10. [テーブル](#テーブル)

## ボタン

```html
<!-- ネイティブ（推奨） -->
<button type="button">アクション</button>

<!-- カスタム要素の場合 -->
<div role="button" tabindex="0">アクション</div>
```

**必須**: `role="button"`, `tabindex="0"`, Enter/Spaceキーハンドラ
**トグルボタン**: `aria-pressed="true|false"`
**よくある問題**: `<div onClick>`に`role`/`tabindex`/キーボードハンドラがない

## リンク

```html
<!-- ネイティブ（推奨） -->
<a href="/path">ページ名</a>

<!-- 新規タブ -->
<a href="/path" target="_blank" rel="noopener noreferrer">
  外部リンク<span class="sr-only">（新しいタブで開く）</span>
</a>
```

**よくある問題**: `<a href="#">`をボタン代わりに使用、`target="_blank"`の注記なし

## ダイアログ (モーダル)

```html
<div role="dialog" aria-modal="true" aria-labelledby="dialog-title">
  <h2 id="dialog-title">タイトル</h2>
  <!-- コンテンツ -->
  <button>閉じる</button>
</div>
```

**必須属性**: `role="dialog"`, `aria-modal="true"`, `aria-labelledby`
**キーボード**:
- Escape: ダイアログを閉じる
- Tab: ダイアログ内でフォーカスをトラップ
- 開閉時: フォーカスをダイアログ内/元の要素に移動

**よくある問題**: フォーカストラップなし、背景スクロール未抑制、Escapeで閉じない

## タブ

```html
<div role="tablist" aria-label="設定">
  <button role="tab" aria-selected="true" aria-controls="panel-1" id="tab-1">
    一般
  </button>
  <button role="tab" aria-selected="false" aria-controls="panel-2" id="tab-2" tabindex="-1">
    詳細
  </button>
</div>
<div role="tabpanel" id="panel-1" aria-labelledby="tab-1">
  <!-- コンテンツ -->
</div>
<div role="tabpanel" id="panel-2" aria-labelledby="tab-2" hidden>
  <!-- コンテンツ -->
</div>
```

**必須属性**: `role="tablist"`, `role="tab"`, `role="tabpanel"`, `aria-selected`, `aria-controls`, `aria-labelledby`
**キーボード**:
- 矢印キー: タブ間移動
- Home/End: 最初/最後のタブ
- 非選択タブは`tabindex="-1"`

**よくある問題**: `aria-selected`の更新漏れ、矢印キーナビゲーションなし

## アコーディオン

```html
<h3>
  <button aria-expanded="false" aria-controls="section-1">セクション名</button>
</h3>
<div id="section-1" role="region" aria-labelledby="accordion-btn-1" hidden>
  <!-- コンテンツ -->
</div>
```

**必須属性**: `aria-expanded`, `aria-controls`
**キーボード**: Enter/Space でトグル

**よくある問題**: `aria-expanded`の状態更新漏れ、`<div>`をトリガーに使用

## ドロップダウンメニュー

```html
<button aria-haspopup="true" aria-expanded="false" aria-controls="menu-1">
  メニュー
</button>
<ul role="menu" id="menu-1" hidden>
  <li role="menuitem">項目1</li>
  <li role="menuitem">項目2</li>
</ul>
```

**必須属性**: `aria-haspopup`, `aria-expanded`, `role="menu"`, `role="menuitem"`
**キーボード**:
- Enter/Space/下矢印: メニューを開く
- 矢印キー: 項目間移動
- Escape: メニューを閉じてトリガーにフォーカス
- Home/End: 最初/最後の項目

**よくある問題**: Escapeで閉じない、フォーカス管理なし、`aria-expanded`未更新

## コンボボックス (オートコンプリート)

```html
<label for="search">検索</label>
<input id="search" role="combobox"
  aria-expanded="false"
  aria-autocomplete="list"
  aria-controls="listbox-1"
  aria-activedescendant="">
<ul role="listbox" id="listbox-1" hidden>
  <li role="option" id="opt-1">候補1</li>
  <li role="option" id="opt-2">候補2</li>
</ul>
```

**必須属性**: `role="combobox"`, `aria-expanded`, `aria-autocomplete`, `aria-controls`, `aria-activedescendant`
**キーボード**: 矢印キーで候補選択、Escapeで閉じる、Enterで確定

## ツールチップ

```html
<button aria-describedby="tooltip-1">ヘルプ</button>
<div role="tooltip" id="tooltip-1">説明テキスト</div>
```

**必須属性**: `role="tooltip"`, トリガー要素に`aria-describedby`
**表示条件**: hover + focus の両方で表示、Escapeで非表示

**よくある問題**: hoverのみ（キーボードで表示不可）、`role="tooltip"`なし

## アラートとステータス

```html
<!-- 重要な警告（即座に読み上げ） -->
<div role="alert">エラーが発生しました</div>

<!-- ステータス更新（次の区切りで読み上げ） -->
<div role="status" aria-live="polite">3件の結果</div>

<!-- ライブリージョン -->
<div aria-live="polite" aria-atomic="true">更新されるコンテンツ</div>
```

**使い分け**:
- `role="alert"` (`aria-live="assertive"`): 緊急のエラー、警告
- `role="status"` (`aria-live="polite"`): 検索結果数、保存完了等
- `aria-live="polite"`: その他の動的コンテンツ更新

**よくある問題**: 動的コンテンツの追加に`aria-live`なし、すべてに`assertive`を使用

## テーブル

```html
<table>
  <caption>ユーザー一覧</caption>
  <thead>
    <tr>
      <th scope="col">名前</th>
      <th scope="col" aria-sort="ascending">登録日</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>山田太郎</td>
      <td>2024-01-01</td>
    </tr>
  </tbody>
</table>
```

**必須**: `<th>`にscope、ソート可能列に`aria-sort`
**よくある問題**: `<div>`でテーブルレイアウト、`<caption>`なし、`scope`なし
