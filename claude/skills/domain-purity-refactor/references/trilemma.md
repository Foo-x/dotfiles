# ドメインモデルのトリレンマ

出典: https://enterprisecraftsmanship.com/posts/domain-model-purity-completeness/

## 3つの性質

- **完全性**: アプリケーションのドメインロジックが全てドメイン層にある。漏れ出すとドメインロジックの断片化になる
- **純粋性**: ドメイン層がプロセス外依存（DB、外部サービス）を持たない。ドメインクラスはプリミティブ型と他のドメインクラスにのみ依存する
- **パフォーマンス**: プロセス外依存への不要な呼び出しを避ける

3つのうち2つしか満たせない。

## 3つの選択肢

| 選択肢 | 満たす | 犠牲 | 備考 |
|---|---|---|---|
| 選択肢1: 外部の読み書きを操作の端に寄せる | 完全性・純粋性 | パフォーマンス | read-decide-act。段階が分かれるなら理想。途中で追加データが要る場合は成立しない |
| 選択肢2: 依存をドメインへ注入する | 完全性・パフォーマンス | 純粋性 | ドメインがインフラと混ざり、テストと理解が難しくなる |
| 選択肢3: 判断をドメイン層とユースケースに分割する | 純粋性・パフォーマンス | 完全性 | 一部ロジックがユースケースに移る |

スキル本文の「①」は選択肢1、「②」は選択肢3に当たる。選択肢2は採らない。

## 判断フロー

1. 読み書きを全て操作の端に置いても性能上問題ないか
   - 問題ない → 選択肢1（スキルの①）
2. 途中で外部データが必要、または事前の取得が非現実的か
   - そうなら選択肢3（スキルの②）を選ぶ。注入（選択肢2）は選ばない
3. ドメイン層にドメインロジック以外の責務を残さない

## 例: ユーザーのメールアドレス変更

### 段階1: 完全で純粋

```
class User {
  changeEmail(newEmail, company) {
    if (!company.isEmailCorporate(newEmail)) throw ...
    this.email = newEmail
  }
}

// ユースケース
user = userRepo.get(id)
company = companyRepo.get()
user.changeEmail(newEmail, company)
userRepo.save(user)
```

### 段階2: 一意性の規則が加わる（ナイーブな修正）

```
// ユースケース
if (userRepo.findByEmail(newEmail) != null) throw ...   // ロジックが漏れる
user.changeEmail(newEmail, company)
```

純粋だが、呼び出し側が確認を忘れると不変条件が崩れる（完全性の喪失）。

### 段階3: ドメインにリポジトリを渡す（採らない）

```
class User {
  changeEmail(newEmail, company, userRepo) {   // 不純
    if (userRepo.findByEmail(newEmail) != null) throw ...
    ...
  }
}
```

インターフェースやデリゲートで包んでも、ドメインが外部へ問い合わせる点は変わらない。

### 段階4: 全ユーザーを渡す（採らない）

```
user.changeEmail(newEmail, company, allUsers)
```

完全で純粋だが、変更のたびに全件を取得するので現実的でない。

### 推奨: 判断の分割（②）

```
class User {
  canChangeEmail(newEmail, company, isEmailTaken) -> Result   // 純粋
  changeEmail(newEmail, company, isEmailTaken) { ... }        // isEmailTaken は値
}

// ユースケース
isEmailTaken = userRepo.findByEmail(newEmail) != null
user.changeEmail(newEmail, company, isEmailTaken)
userRepo.save(user)
```

外部への問い合わせはユースケースが担い、その結果（値）だけをドメインへ渡す。ドメインは純粋なまま、一意性の判定はドメインの規則として残る。

## 補足: 純粋性が他の指針と一致する理由

- DDD: ドメインモデルの複雑さを抑える
- 関数型: 純粋関数は隠れた入力（DB読み取りなど）を持たない
- 単体テスト: 純粋なロジックはモック・スタブ・やり取りの検証が要らない

## 関連する不純の要因

- 現在時刻・乱数・ID生成は隠れた入力なので、値として引数で渡す
- 遅延ロードはアクセス時にDBへ問い合わせるので不純。必要なデータをユースケースで取得して渡す
