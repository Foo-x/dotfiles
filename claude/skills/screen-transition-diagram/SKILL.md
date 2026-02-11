---
name: screen-transition-diagram
description: >
  フロントエンドコードベースを解析し、Mermaid形式の画面遷移図（flowchart）とイベント表を生成するスキル。
  ルーティング設定・ナビゲーションコンポーネント・プログラム的遷移を自動検出し、
  画面間の遷移関係をドキュメント化する。
disable-model-invocation: true
---

# Screen Transition Diagram

フロントエンドコードベースを解析し、Mermaid形式の画面遷移図とイベント表を生成する。

## ワークフロー

以下の5ステップで画面遷移図を構築する。

---

### Step 1: フレームワーク・ルーティング方式の特定

`package.json` の依存関係とディレクトリ構成からフレームワークとルーティング方式を特定する。

**検出手順:**

1. `package.json` を読み、主要フレームワーク（React, Next.js, Vue, Nuxt, Angular, SvelteKit）を特定
2. ルーティングライブラリ（react-router-dom, vue-router 等）とバージョンを確認
3. ファイルベースルーティング（Next.js App Router / Pages Router, SvelteKit, Nuxt）か設定ベースルーティング（React Router, Vue Router, Angular）かを判定

---

### Step 2: 画面の列挙

フレームワークに応じた方法で全画面（ルート）を列挙し、各画面に短いIDを付与する。

**ファイルベースルーティングの場合（Next.js, SvelteKit, Nuxt）:**

- ルーティングディレクトリを再帰的に走査
- `page.tsx` / `+page.svelte` 等のルートファイルを検出
- ファイルパスからURLパスを導出

**設定ベースルーティングの場合（React Router, Vue Router, Angular）:**

- ルート設定ファイル（`routes.tsx`, `router/index.ts` 等）を検索
- `<Route>`, `createBrowserRouter`, `routes` 配列等のルート定義を解析
- ネストされたルートも含めて全パスを列挙

**ID付与ルール:**

- 各画面に `画面名` の短いIDを付与（例: `Login`, `Home`, `ProductDetail`）
- URLパスとIDの対応表を作成
- レイアウトルート（子ルートのラッパー）は画面として含めない

---

### Step 3: 遷移イベントの追跡

各画面のコンポーネントコードを読み、他の画面への遷移を検出する。

**検出対象:**

| 種別 | パターン例 |
|------|-----------|
| 宣言的ナビゲーション | `<Link to="...">`, `<router-link to="...">`, `<a routerLink="...">` |
| プログラム的ナビゲーション | `navigate()`, `router.push()`, `router.navigate()`, `goto()` |
| リダイレクト | `<Navigate to="...">`, `redirect()`, `$router.replace()` |
| フォーム送信後遷移 | `onSubmit` ハンドラ内の `navigate()` 等 |

**記録する情報:**

各遷移について以下を記録する:

- **イベント番号**: `E1`, `E2`, ... の連番
- **ソース画面**: 遷移元の画面ID
- **宛先画面**: 遷移先の画面ID
- **トリガーイベント**: ユーザー操作やイベント名（例: 「ログインボタン押下」「商品クリック」）
- **ガード条件**: 条件付き遷移の場合、その条件（Step 4で詳細化）

---

### Step 4: ガード条件の特定

遷移に付随する条件（認証チェック、権限チェック等）を検出する。

**検出対象:**

| レベル | パターン例 |
|--------|-----------|
| ルートレベルガード | Angular `canActivate` / `canDeactivate`, Vue `beforeEnter` / `beforeEach`, Next.js `middleware.ts` |
| コンポーネント内ガード | `if (!isAuthenticated) navigate('/login')`, `useEffect` 内のリダイレクト |
| HOC / ラッパー | `<ProtectedRoute>`, `withAuth()`, `requireAuth()` |

**記録ルール:**

- 簡潔なブール式で記録する（例: `isAuth`, `!isAdmin`, `cart.length > 0`）
- 条件が複雑な場合は要約する（例: `hasPermission('edit')` → `editPerm`）
- ガード条件がない遷移は空欄とする

---

### Step 5: 出力の生成

収集した情報をもとに、イベント表 → Mermaid図 の順で出力を構築する。

完成例は `references/output-example.md` を参照すること。

#### イベント表

Markdown テーブルで出力する。

**列構成:**

| 列名 | 説明 |
|------|------|
| `#` | イベント番号（`E1`, `E2`, ...） |
| `ソース` | 遷移元の画面ID |
| `イベント` | トリガーとなるユーザー操作やイベント |
| `ガード` | 条件式（ガード条件が1件もない場合はこの列自体を省略） |
| `遷移先` | 遷移先の画面ID |

#### Mermaid 図

**基本ルール:**

- **方向**: `flowchart TD`（上から下）
- **画面ノード**: 角丸ノードを使用 → `ScreenId([画面名])`
- **遷移矢印**: イベント番号をラベルとして付与 → `Source -->|E1| Dest`
- **論理グループ**: 関連する画面は `subgraph` で囲む（例: 認証系、商品系）
- **同一ソース・宛先で複数イベント**: ラベルをカンマ区切りで結合 → `Source -->|E1, E2| Dest`

**Mermaid記法の注意点:**

- ノードIDには英数字とアンダースコアのみ使用（日本語やハイフン不可）
- ラベル内に特殊文字（`(`, `)`, `[`, `]`）を含む場合は `"` で囲む
- `subgraph` のタイトルに日本語を使う場合は `["タイトル"]` の形式を使用

---

## エッジケース対応

| ケース | 対応方針 |
|--------|---------|
| 動的ルート `/products/:id` | 1つの画面として扱う（パラメータ部分は表記に含める） |
| モーダル / ダイアログ | ルート変更を伴う場合のみ画面として含める |
| 外部リンク (`https://...`) | 画面遷移図から除外する |
| 変数による動的遷移先 | 遷移先を `[動的]` と表記する |
| Catch-all / 404ページ | 1つの画面 `NotFound` として含める（個別の遷移矢印は不要） |
| ネストレイアウト | レイアウト自体は画面に含めず、子ルートのみを画面とする |

## Resources

### references/

- `output-example.md` — ECサイトを題材にした完成例（Mermaid図 + イベント表）
