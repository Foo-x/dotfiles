# プログラミング原則

コード品質を評価する際の基本的な原則とガイドラインを提供します。

## SOLID原則

オブジェクト指向設計における5つの基本原則。

### 1. Single Responsibility Principle（単一責任原則）

**定義**: クラスは変更の理由を1つだけ持つべきである。

**違反の兆候**:
- クラス名に「Manager」「Handler」「Utility」「Helper」が含まれる
- クラスが複数の異なるインターフェースを実装している
- メソッド名が「and」「or」で繋がれている
- クラスのフィールドが論理的なグループに分かれている
- テストを書く際に多数のモックが必要

**検出方法**:
```
1. クラスの責任をリストアップ
2. 各責任が独立して変更される可能性があるか確認
3. 2つ以上の変更理由があれば違反
```

**悪い例**:
```python
class UserService:
    def authenticate(self, username, password):
        # 認証ロジック
        pass

    def send_email(self, user_id, message):
        # メール送信ロジック
        pass

    def generate_report(self, user_id):
        # レポート生成ロジック
        pass

    def update_profile(self, user_id, data):
        # プロファイル更新ロジック
        pass
```

**改善例**:
```python
class AuthenticationService:
    def authenticate(self, username, password):
        # 認証のみに集中
        pass

class EmailService:
    def send_email(self, user_id, message):
        # メール送信のみに集中
        pass

class ReportService:
    def generate_report(self, user_id):
        # レポート生成のみに集中
        pass

class ProfileService:
    def update_profile(self, user_id, data):
        # プロファイル管理のみに集中
        pass
```

**改善の効果**:
- 各クラスが単一の変更理由を持つ
- テストが容易になる
- 再利用性が向上する
- 理解が容易になる

---

### 2. Open/Closed Principle（オープン・クローズドの原則）

**定義**: ソフトウェアエンティティは拡張に対して開いており、修正に対して閉じているべきである。

**違反の兆候**:
- 新機能追加のたびに既存コードを修正する必要がある
- 長いif-elseやswitch文
- 型チェックによる分岐処理
- ハードコーディングされた依存関係

**検出方法**:
```
1. 新しいバリエーションを追加する際の変更箇所を確認
2. 既存コードの修正が必要なら違反
```

**悪い例**:
```typescript
class PaymentProcessor {
  processPayment(type: string, amount: number) {
    if (type === 'credit_card') {
      // クレジットカード処理
    } else if (type === 'paypal') {
      // PayPal処理
    } else if (type === 'bitcoin') {
      // Bitcoin処理
    }
    // 新しい決済方法を追加するたびにこのメソッドを修正
  }
}
```

**改善例**:
```typescript
interface PaymentMethod {
  process(amount: number): void;
}

class CreditCardPayment implements PaymentMethod {
  process(amount: number) {
    // クレジットカード処理
  }
}

class PayPalPayment implements PaymentMethod {
  process(amount: number) {
    // PayPal処理
  }
}

class BitcoinPayment implements PaymentMethod {
  process(amount: number) {
    // Bitcoin処理
  }
}

class PaymentProcessor {
  processPayment(method: PaymentMethod, amount: number) {
    method.process(amount);
    // 新しい決済方法を追加してもこのクラスは変更不要
  }
}
```

**改善の効果**:
- 既存コードを修正せずに新機能を追加できる
- テストの影響範囲が限定される
- バグ混入のリスクが低減する

---

### 3. Liskov Substitution Principle（リスコフの置換原則）

**定義**: 派生クラスは基底クラスと置換可能でなければならない。

**違反の兆候**:
- サブクラスがスーパークラスのメソッドで例外をスローする
- サブクラスがメソッドの前提条件を強化する
- サブクラスがメソッドの事後条件を弱める
- サブクラスで親のメソッドが空実装される

**検出方法**:
```
1. 基底クラスを使用している箇所を確認
2. 派生クラスで置き換えても正常に動作するか検証
3. 動作が変わる、または例外が発生する場合は違反
```

**悪い例**:
```java
class Bird {
    void fly() {
        // 飛ぶ実装
    }
}

class Penguin extends Bird {
    @Override
    void fly() {
        throw new UnsupportedOperationException("ペンギンは飛べません");
    }
}

// 使用例
void makeBirdFly(Bird bird) {
    bird.fly(); // Penguinが渡されると例外が発生
}
```

**改善例**:
```java
interface Bird {
    void eat();
}

interface FlyingBird extends Bird {
    void fly();
}

class Sparrow implements FlyingBird {
    public void eat() { /* 実装 */ }
    public void fly() { /* 実装 */ }
}

class Penguin implements Bird {
    public void eat() { /* 実装 */ }
    // flyメソッドを持たない
}

// 使用例
void makeBirdFly(FlyingBird bird) {
    bird.fly(); // 飛べる鳥のみ受け付ける
}
```

**改善の効果**:
- 予期しない例外が発生しない
- 型階層が論理的に正しい
- ポリモーフィズムが正しく機能する

---

### 4. Interface Segregation Principle（インターフェース分離の原則）

**定義**: クライアントは使用しないメソッドに依存すべきではない。

**違反の兆候**:
- インターフェースの一部のメソッドしか使用しない実装が多い
- 空実装やNotImplementedExceptionが多い
- 単一のインターフェースが多数のメソッドを持つ（God Interface）

**検出方法**:
```
1. インターフェースの全メソッドを確認
2. 各実装クラスで使用されていないメソッドを特定
3. 使用されていないメソッドがあれば違反
```

**悪い例**:
```typescript
interface Worker {
  work(): void;
  eat(): void;
  sleep(): void;
}

class HumanWorker implements Worker {
  work() { console.log("人間が働く"); }
  eat() { console.log("人間が食べる"); }
  sleep() { console.log("人間が寝る"); }
}

class RobotWorker implements Worker {
  work() { console.log("ロボットが働く"); }
  eat() { throw new Error("ロボットは食べない"); }
  sleep() { throw new Error("ロボットは寝ない"); }
}
```

**改善例**:
```typescript
interface Workable {
  work(): void;
}

interface Eatable {
  eat(): void;
}

interface Sleepable {
  sleep(): void;
}

class HumanWorker implements Workable, Eatable, Sleepable {
  work() { console.log("人間が働く"); }
  eat() { console.log("人間が食べる"); }
  sleep() { console.log("人間が寝る"); }
}

class RobotWorker implements Workable {
  work() { console.log("ロボットが働く"); }
  // 不要なメソッドを実装する必要がない
}
```

**改善の効果**:
- 不要な依存関係が削減される
- インターフェースが明確になる
- 実装が簡潔になる

---

### 5. Dependency Inversion Principle（依存性逆転の原則）

**定義**: 上位モジュールは下位モジュールに依存すべきではない。両者は抽象に依存すべきである。

**違反の兆候**:
- 具象クラスへの直接的な依存
- `new`演算子の多用
- グローバル変数への依存
- ハードコーディングされた依存関係

**検出方法**:
```
1. クラスの依存関係を確認
2. 具象クラスに直接依存している箇所を特定
3. 抽象（インターフェース）を介していない場合は違反
```

**悪い例**:
```python
class MySQLDatabase:
    def save(self, data):
        # MySQL固有の保存処理
        pass

class UserService:
    def __init__(self):
        self.database = MySQLDatabase()  # 具象クラスに直接依存

    def save_user(self, user):
        self.database.save(user)
```

**改善例**:
```python
from abc import ABC, abstractmethod

class Database(ABC):
    @abstractmethod
    def save(self, data):
        pass

class MySQLDatabase(Database):
    def save(self, data):
        # MySQL固有の保存処理
        pass

class PostgreSQLDatabase(Database):
    def save(self, data):
        # PostgreSQL固有の保存処理
        pass

class UserService:
    def __init__(self, database: Database):
        self.database = database  # 抽象に依存

    def save_user(self, user):
        self.database.save(user)

# 使用例
db = MySQLDatabase()
service = UserService(db)  # 依存性注入
```

**改善の効果**:
- データベース実装を変更しやすい
- テストが容易（モックの注入が簡単）
- 疎結合な設計

---

## DRY原則（Don't Repeat Yourself）

**定義**: 知識の重複を避け、単一の信頼できる情報源を持つべきである。

**違反の兆候**:
- 同じコードブロックが複数箇所に存在
- 同じロジックを異なる方法で実装
- コピー&ペーストされたコード
- 同じ定数が複数箇所で定義されている

**検出方法**:
```
1. 類似したコードパターンを検索
2. 同一または類似のロジックを特定
3. 2箇所以上に同じ知識があれば違反
```

**悪い例**:
```javascript
function calculatePriceWithTax(price) {
  return price * 1.1; // 消費税10%
}

function calculateDiscountedPriceWithTax(price, discount) {
  const discounted = price * (1 - discount);
  return discounted * 1.1; // 消費税10%が重複
}

function calculateBulkPriceWithTax(unitPrice, quantity) {
  const total = unitPrice * quantity;
  return total * 1.1; // 消費税10%が重複
}
```

**改善例**:
```javascript
const TAX_RATE = 0.1;

function applyTax(price) {
  return price * (1 + TAX_RATE);
}

function calculatePriceWithTax(price) {
  return applyTax(price);
}

function calculateDiscountedPriceWithTax(price, discount) {
  const discounted = price * (1 - discount);
  return applyTax(discounted);
}

function calculateBulkPriceWithTax(unitPrice, quantity) {
  const total = unitPrice * quantity;
  return applyTax(total);
}
```

**改善の効果**:
- 税率変更時の修正が1箇所で済む
- バグのリスクが減少
- コードが読みやすくなる

---

## KISS原則（Keep It Simple, Stupid）

**定義**: 設計はできるだけシンプルに保つべきである。

**違反の兆候**:
- 過度に抽象化されたコード
- 使われていない機能の実装
- 複雑なデザインパターンの不適切な使用
- 深いネストや複雑な条件式

**検出方法**:
```
1. コードを読んで理解に時間がかかる箇所を特定
2. 同じ目的をより簡単に達成できる方法を検討
3. より簡単な方法がある場合は違反
```

**悪い例**:
```python
class AbstractAnimalFactory:
    @abstractmethod
    def create_animal(self):
        pass

class DogFactory(AbstractAnimalFactory):
    def create_animal(self):
        return Dog()

class CatFactory(AbstractAnimalFactory):
    def create_animal(self):
        return Cat()

class AnimalCreator:
    def __init__(self, factory: AbstractAnimalFactory):
        self.factory = factory

    def get_animal(self):
        return self.factory.create_animal()

# 単にDogを作りたいだけなのに...
factory = DogFactory()
creator = AnimalCreator(factory)
dog = creator.get_animal()
```

**改善例**:
```python
# シンプルに
dog = Dog()
cat = Cat()

# もし柔軟性が必要なら
def create_animal(animal_type):
    if animal_type == 'dog':
        return Dog()
    elif animal_type == 'cat':
        return Cat()
```

**改善の効果**:
- コードが理解しやすい
- 保守が容易
- バグが減少

---

## YAGNI原則（You Aren't Gonna Need It）

**定義**: 現在必要でない機能は実装すべきではない。

**違反の兆候**:
- 使われていない抽象化レイヤー
- 「将来必要になるかも」という理由だけで実装されたコード
- 過剰な設定オプション
- 未使用の引数やフィールド

**検出方法**:
```
1. 各機能の使用箇所を確認
2. 現在使われていない機能を特定
3. 明確な将来計画がなければ違反
```

**悪い例**:
```java
public class User {
    private String name;
    private String email;
    private String phoneNumber;
    private String address;
    private String city;
    private String country;
    private String zipCode;
    // 将来必要かもしれないフィールド
    private String secondaryEmail;
    private String alternativePhone;
    private String faxNumber;
    private String linkedInProfile;
    private String twitterHandle;
    // ... 実際には使われない
}
```

**改善例**:
```java
public class User {
    private String name;
    private String email;
    // 現在必要なフィールドのみ
}

// 将来必要になったら追加する
```

**改善の効果**:
- コードが簡潔になる
- 保守コストが削減される
- 実装時間が短縮される

---

## 関心の分離（Separation of Concerns）

**定義**: プログラムを異なる関心事に分割し、各部分が1つの関心事のみを扱うようにする。

**違反の兆候**:
- ビジネスロジックとプレゼンテーションロジックの混在
- データアクセスとビジネスロジックの混在
- 複数の責任を持つ関数/クラス

**悪い例**:
```javascript
function processOrder(orderId) {
  // データベースアクセス
  const order = db.query(`SELECT * FROM orders WHERE id = ${orderId}`);

  // ビジネスロジック
  const total = order.items.reduce((sum, item) => sum + item.price, 0);
  const tax = total * 0.1;
  const finalPrice = total + tax;

  // プレゼンテーション
  console.log(`Order #${orderId}`);
  console.log(`Total: $${finalPrice}`);

  // 外部サービス呼び出し
  emailService.send(order.customerEmail, `Your order total is $${finalPrice}`);
}
```

**改善例**:
```javascript
// データアクセス層
class OrderRepository {
  getById(orderId) {
    return db.query(`SELECT * FROM orders WHERE id = ?`, [orderId]);
  }
}

// ビジネスロジック層
class OrderService {
  calculateTotal(order) {
    const subtotal = order.items.reduce((sum, item) => sum + item.price, 0);
    const tax = subtotal * 0.1;
    return subtotal + tax;
  }
}

// プレゼンテーション層
class OrderPresenter {
  display(order, total) {
    console.log(`Order #${order.id}`);
    console.log(`Total: $${total}`);
  }
}

// 通知層
class NotificationService {
  sendOrderConfirmation(email, total) {
    emailService.send(email, `Your order total is $${total}`);
  }
}

// オーケストレーション
function processOrder(orderId) {
  const order = orderRepository.getById(orderId);
  const total = orderService.calculateTotal(order);
  orderPresenter.display(order, total);
  notificationService.sendOrderConfirmation(order.customerEmail, total);
}
```

**改善の効果**:
- 各レイヤーが独立してテスト可能
- 変更の影響範囲が限定される
- コードの再利用性が向上

---

## デメテルの法則（Law of Demeter）

**定義**: オブジェクトは直接の知り合いとのみ会話すべきである（「最小知識の原則」とも呼ばれる）。

**違反の兆候**:
- メソッドチェーンの乱用（`a.getB().getC().doSomething()`）
- 「.」が連続する呼び出し
- 他のオブジェクトの内部構造への深い依存

**検出方法**:
```
1. メソッドチェーンを確認
2. 2つ以上の「.」が連続している箇所を特定
3. 直接の知り合い以外にアクセスしている場合は違反
```

**悪い例**:
```java
class OrderProcessor {
    void processOrder(Order order) {
        // 3つのオブジェクトを通過している
        String city = order.getCustomer().getAddress().getCity();

        if (city.equals("Tokyo")) {
            // 処理
        }
    }
}
```

**改善例**:
```java
class Order {
    Customer customer;

    // カプセル化されたメソッドを提供
    String getCustomerCity() {
        return customer.getCity();
    }
}

class Customer {
    Address address;

    String getCity() {
        return address.getCity();
    }
}

class OrderProcessor {
    void processOrder(Order order) {
        // 直接の知り合い（Order）とのみ会話
        String city = order.getCustomerCity();

        if (city.equals("Tokyo")) {
            // 処理
        }
    }
}
```

**改善の効果**:
- 疎結合な設計
- 内部構造の変更が容易
- カプセル化が保たれる

---

## Composition over Inheritance（継承よりコンポジション）

**定義**: クラスの再利用は継承よりもコンポジションを優先すべきである。

**違反の兆候**:
- 深い継承階層（3階層以上）
- 継承関係が「is-a」ではなく「has-a」の関係
- 親クラスの一部の機能しか使わない子クラス
- フラジャイル・ベースクラス問題（親の変更が子に影響）

**検出方法**:
```
1. 継承階層を確認
2. 各継承関係が本当に「is-a」関係か検証
3. 「has-a」関係の場合は違反
```

**悪い例**:
```typescript
class Animal {
  eat() { console.log("食べる"); }
  sleep() { console.log("寝る"); }
}

class Dog extends Animal {
  bark() { console.log("吠える"); }
}

class Robot {
  // Robotはanimalではないが、動く機能が欲しい
}

// 無理に継承を使うと...
class RobotDog extends Dog {
  // Dogの機能を継承したいが、RobotはAnimalではない
  eat() { throw new Error("ロボットは食べない"); }
  sleep() { throw new Error("ロボットは寝ない"); }
}
```

**改善例**:
```typescript
// 機能をインターフェースとして分離
interface Movable {
  move(): void;
}

interface Soundable {
  makeSound(): void;
}

// コンポジションを使用
class Dog {
  private movement: Movable;
  private sound: Soundable;

  constructor(movement: Movable, sound: Soundable) {
    this.movement = movement;
    this.sound = sound;
  }

  move() { this.movement.move(); }
  bark() { this.sound.makeSound(); }
}

class RobotDog {
  private movement: Movable;
  private sound: Soundable;

  constructor(movement: Movable, sound: Soundable) {
    this.movement = movement;
    this.sound = sound;
  }

  move() { this.movement.move(); }
  bark() { this.sound.makeSound(); }
}

// 実装
class WalkingMovement implements Movable {
  move() { console.log("歩く"); }
}

class BarkSound implements Soundable {
  makeSound() { console.log("ワンワン"); }
}

class RoboticSound implements Soundable {
  makeSound() { console.log("ピピピ"); }
}

// 使用例
const dog = new Dog(new WalkingMovement(), new BarkSound());
const robotDog = new RobotDog(new WalkingMovement(), new RoboticSound());
```

**改善の効果**:
- 柔軟な機能の組み合わせが可能
- 継承の制約から解放される
- テストが容易になる
- 変更の影響範囲が限定される

---

## 純粋関数（Pure Functions）

**定義**: 関数は副作用を持たず、同じ入力に対して常に同じ出力を返すべきである（参照透過性）。

**違反の兆候**:
- グローバル変数や外部状態の読み書き
- 引数の変更（ミューテーション）
- ファイルI/O、ネットワーク通信、データベースアクセス
- 現在時刻やランダム値への直接的な依存
- `console.log`等の出力操作
- 例外のスロー（関数型プログラミングの観点から）
- DOM操作やブラウザAPI呼び出し

**検出方法**:
```
1. 関数が外部状態を参照・変更しているか確認
2. 引数が変更されていないか確認
3. I/O操作が含まれていないか確認
4. 同じ入力で異なる結果が返る可能性がないか確認
```

**悪い例**:
```javascript
// グローバル変数への依存
let taxRate = 0.1;

function calculateTotal(price) {
  return price * (1 + taxRate); // 外部状態に依存
}

// 引数の変更
function addItem(cart, item) {
  cart.push(item); // 引数を変更
  return cart;
}

// I/O操作
function getUser(userId) {
  const user = database.query(`SELECT * FROM users WHERE id = ${userId}`);
  console.log(`Fetched user: ${userId}`); // 副作用（出力）
  return user;
}

// 現在時刻への依存
function isBusinessHours() {
  const hour = new Date().getHours(); // 実行時刻により結果が変わる
  return hour >= 9 && hour < 18;
}

// ランダム値への依存
function generateId() {
  return Math.random().toString(36).substr(2, 9); // 実行ごとに異なる結果
}
```

**改善例**:
```javascript
// 外部状態を引数として受け取る
function calculateTotal(price, taxRate) {
  return price * (1 + taxRate);
}

// 元の配列を変更せず、新しい配列を返す
function addItem(cart, item) {
  return [...cart, item]; // イミュータブルな操作
}

// I/O操作を分離
function getUser(userId) {
  // この関数は純粋な処理のみ
  return database.query(`SELECT * FROM users WHERE id = ${userId}`);
}

function logUser(userId) {
  // 副作用は別の関数に分離
  console.log(`Fetched user: ${userId}`);
}

// 時刻を引数として受け取る
function isBusinessHours(currentHour) {
  return currentHour >= 9 && currentHour < 18;
}

// 使用例: const result = isBusinessHours(new Date().getHours());

// ランダム値を引数として受け取る
function generateId(randomValue) {
  return randomValue.toString(36).substr(2, 9);
}

// 使用例: const id = generateId(Math.random());
```

**より複雑な例**:
```typescript
// 悪い例: 複数の副作用が混在
class ShoppingCart {
  private items: Item[] = [];
  private discount = 0;

  addItem(item: Item) {
    this.items.push(item); // 内部状態の変更
    console.log(`Added ${item.name}`); // 副作用

    if (this.items.length > 5) {
      this.discount = 0.1; // 内部状態の変更
      this.sendDiscountNotification(); // 副作用
    }

    this.saveToDatabase(); // 副作用
  }

  private sendDiscountNotification() {
    // 通知処理
  }

  private saveToDatabase() {
    // DB保存処理
  }
}

// 改善例: 純粋関数とI/O処理を分離
interface CartState {
  items: Item[];
  discount: number;
}

// 純粋関数: 新しい状態を計算
function addItemToCart(state: CartState, item: Item): CartState {
  const newItems = [...state.items, item];
  const discount = newItems.length > 5 ? 0.1 : state.discount;

  return {
    items: newItems,
    discount: discount
  };
}

// 副作用を扱う層（純粋関数を使用）
class CartService {
  private state: CartState = { items: [], discount: 0 };

  addItem(item: Item) {
    const oldState = this.state;
    this.state = addItemToCart(this.state, item); // 純粋関数を使用

    // 副作用は明示的に実行
    console.log(`Added ${item.name}`);

    if (oldState.discount !== this.state.discount) {
      this.sendDiscountNotification();
    }

    this.saveToDatabase();
  }

  private sendDiscountNotification() {
    // 通知処理
  }

  private saveToDatabase() {
    // DB保存処理
  }
}
```

**改善の効果**:
- **テスト容易性の向上**: 外部依存がなく、モックが不要
- **予測可能な動作**: 同じ入力に対して常に同じ結果が保証される
- **並行処理での安全性**: 状態を共有しないため、競合状態が発生しない
- **キャッシュ・メモ化の適用可能性**: 結果が一定なため、キャッシュが有効
- **デバッグの容易性**: 入力と出力の関係が明確で、トレースが容易
- **リファクタリングの安全性**: 他の部分への影響を心配せずに変更できる
- **関数合成の可能性**: 純粋関数同士を組み合わせて新しい純粋関数を作成できる

**注意事項**:
- すべてのコードを純粋にする必要はない
- I/O操作など本質的に副作用を持つ処理は必要
- 重要なのは**副作用を持つ部分と持たない部分を明確に分離すること**
- ビジネスロジックはなるべく純粋関数として実装し、I/O操作は境界で行う

---

## パッケージ設計の原則

Robert C. Martin（Uncle Bob）が提唱したパッケージ設計の6つの原則。モジュール（パッケージ、コンポーネント、ライブラリ）レベルでの凝集度と結合度を管理し、保守性の高いアーキテクチャを実現します。

### パッケージ凝集度の原則（Package Cohesion Principles）

#### 1. REP: Release Reuse Equivalency Principle（再利用・リリース等価の原則）

**定義**: 再利用の単位はリリースの単位と一致すべきである。

**違反の兆候**:
- パッケージ内に関連性のないクラス/モジュールが混在
- パッケージのバージョン管理が適切でない
- 一部の機能だけを使いたいのにパッケージ全体が必要
- パッケージの一部だけが頻繁に更新される
- リリースノートが「その他の変更」ばかり

**検出方法**:
```
1. パッケージ内のクラス/モジュールの関連性を確認
2. パッケージの変更履歴を確認
3. パッケージの一部のみを使用しているクライアントを特定
4. 関連性が低い、または独立して変更される要素があれば違反
```

**悪い例**:
```python
# utils パッケージ（何でも詰め込まれている）
utils/
  __init__.py
  string_helper.py      # 文字列操作
  date_helper.py        # 日付操作
  http_client.py        # HTTP通信
  crypto_helper.py      # 暗号化
  email_sender.py       # メール送信
  file_parser.py        # ファイル解析

# 使用例
from utils import string_helper, date_helper
# HTTPクライアントが欲しいだけなのに、
# メール送信やファイル解析の依存関係も含まれてしまう
```

**改善例**:
```python
# 機能ごとにパッケージを分離
text_processing/
  __init__.py
  string_ops.py
  text_formatter.py

datetime_utils/
  __init__.py
  date_ops.py
  timezone_helper.py

http_toolkit/
  __init__.py
  client.py
  request_builder.py

security/
  __init__.py
  crypto.py
  hash.py

messaging/
  __init__.py
  email.py
  notification.py

# 使用例
from http_toolkit import client
# 必要な機能だけを依存関係として追加
```

**改善の効果**:
- パッケージの目的が明確になる
- 依存関係が最小化される
- バージョン管理が容易になる
- 再利用性が向上する

---

#### 2. CRP: Common Reuse Principle（共通再利用の原則）

**定義**: パッケージ内のクラスは一緒に再利用される。一緒に再利用されないクラスを同じパッケージに含めるべきではない。

**違反の兆候**:
- パッケージの一部の機能しか使わないクライアントが多い
- パッケージの依存関係が多岐にわたる
- インポート文で特定のクラスのみを使用するパターンが多い
- パッケージ内の一部のクラスだけがテストされる

**検出方法**:
```
1. パッケージを使用している全クライアントを確認
2. 各クライアントが使用しているクラスの組み合わせを分析
3. 常に一緒に使われるクラスと、単独で使われるクラスを特定
4. 再利用パターンが異なる場合は違反
```

**悪い例**:
```typescript
// データアクセス層（関連性の低いものが混在）
// data-access/index.ts
export class UserRepository { /* ... */ }
export class ProductRepository { /* ... */ }
export class OrderRepository { /* ... */ }
export class DatabaseConnection { /* ... */ }
export class QueryBuilder { /* ... */ }
export class CacheManager { /* ... */ }
export class Logger { /* ... */ }  // ログは独立した関心事

// クライアント1: ユーザー管理
import { UserRepository, DatabaseConnection, Logger } from './data-access';

// クライアント2: 商品管理
import { ProductRepository, QueryBuilder, CacheManager } from './data-access';

// クライアント3: 注文処理
import { OrderRepository, DatabaseConnection, Logger } from './data-access';
// → 各クライアントが異なる組み合わせで使用している
```

**改善例**:
```typescript
// 共通して再利用されるものでパッケージを分離

// database-core/index.ts（常に一緒に使われる基盤）
export class DatabaseConnection { /* ... */ }
export class QueryBuilder { /* ... */ }

// repositories/user/index.ts
import { DatabaseConnection, QueryBuilder } from '../database-core';
export class UserRepository { /* ... */ }

// repositories/product/index.ts
import { DatabaseConnection, QueryBuilder } from '../database-core';
export class ProductRepository { /* ... */ }

// repositories/order/index.ts
import { DatabaseConnection, QueryBuilder } from '../database-core';
export class OrderRepository { /* ... */ }

// caching/index.ts（独立した機能）
export class CacheManager { /* ... */ }

// logging/index.ts（独立した機能）
export class Logger { /* ... */ }

// クライアント1: ユーザー管理
import { UserRepository } from './repositories/user';
import { Logger } from './logging';

// クライアント2: 商品管理（キャッシュが必要な場合のみ）
import { ProductRepository } from './repositories/product';
import { CacheManager } from './caching';
```

**改善の効果**:
- 不要な依存関係が削減される
- パッケージの責任が明確になる
- 変更の影響範囲が限定される
- ビルド時間の短縮

---

#### 3. CCP: Common Closure Principle（共通閉鎖の原則）

**定義**: 同じ理由、同じタイミングで変更されるクラスを同じパッケージにまとめるべきである。

**違反の兆候**:
- 1つの機能追加で複数のパッケージを変更する必要がある
- ビジネスルール変更時に広範囲の修正が必要
- 関連する変更が散在している
- コミット履歴で常に一緒に変更されるファイルが別パッケージにある

**検出方法**:
```
1. 過去の変更履歴（Git履歴）を分析
2. 同時に変更される頻度が高いクラスを特定
3. それらが別々のパッケージにあれば違反
4. または、ビジネス要求の変更シナリオをシミュレート
```

**悪い例**:
```java
// 支払い処理が複数パッケージに分散
// models/Payment.java
public class Payment {
    private BigDecimal amount;
    private PaymentStatus status;
    // ...
}

// validators/PaymentValidator.java
public class PaymentValidator {
    public boolean validate(Payment payment) {
        // 支払い金額の検証ロジック
        return payment.getAmount().compareTo(BigDecimal.ZERO) > 0;
    }
}

// services/PaymentService.java
public class PaymentService {
    public void processPayment(Payment payment) {
        // 支払い処理
    }
}

// notifications/PaymentNotification.java
public class PaymentNotification {
    public void notifyPaymentComplete(Payment payment) {
        // 支払い完了通知
    }
}

// 問題: 支払いのビジネスルール変更（例: 最低金額の追加）で
// Payment, PaymentValidator, PaymentService, PaymentNotification
// の4つのパッケージを修正する必要がある
```

**改善例**:
```java
// 支払い関連を1つのパッケージにまとめる
// payment/domain/Payment.java
package com.example.payment.domain;

public class Payment {
    private BigDecimal amount;
    private PaymentStatus status;
    // ...
}

// payment/validation/PaymentValidator.java
package com.example.payment.validation;

import com.example.payment.domain.Payment;

public class PaymentValidator {
    public boolean validate(Payment payment) {
        return payment.getAmount().compareTo(BigDecimal.ZERO) > 0;
    }
}

// payment/service/PaymentService.java
package com.example.payment.service;

import com.example.payment.domain.Payment;
import com.example.payment.validation.PaymentValidator;

public class PaymentService {
    private final PaymentValidator validator;

    public void processPayment(Payment payment) {
        if (validator.validate(payment)) {
            // 処理
        }
    }
}

// payment/notification/PaymentNotification.java
package com.example.payment.notification;

import com.example.payment.domain.Payment;

public class PaymentNotification {
    public void notifyPaymentComplete(Payment payment) {
        // 通知
    }
}

// ビジネスルール変更時の影響がpaymentパッケージ内に限定される
```

**改善の効果**:
- 変更の影響範囲が限定される（Shotgun Surgery の回避）
- リリース管理が容易になる
- 機能の追加・変更がパッケージ単位で完結する
- チーム分割が明確になる

---

### パッケージ結合度の原則（Package Coupling Principles）

#### 4. ADP: Acyclic Dependencies Principle（非循環依存関係の原則）

**定義**: パッケージの依存関係グラフに循環があってはならない。

**違反の兆候**:
- ビルドの順序が定まらない
- 特定のパッケージを単独でテストできない
- 変更の影響が予測不可能
- デバッグ時に無限ループのような状況
- モジュールの置き換えが困難

**検出方法**:
```
1. パッケージの依存関係をグラフ化
2. 循環参照を検出（A→B→C→A）
3. ツール使用: madge（JavaScript）、jdeps（Java）、go mod graph（Go）
```

**悪い例**:
```typescript
// user-management/UserService.ts
import { OrderRepository } from '../order-management';  // A → B

export class UserService {
  constructor(private orderRepo: OrderRepository) {}

  getUserOrders(userId: string) {
    return this.orderRepo.findByUserId(userId);
  }
}

// order-management/OrderRepository.ts
import { User } from '../user-management';  // B → A (循環!)

export class OrderRepository {
  findByUserId(userId: string): Order[] {
    const user = new User(userId);  // Userに依存
    // ...
  }
}

// 依存関係: user-management ⇄ order-management
// ビルドやテストが困難になる
```

**改善例1: 依存性逆転の原則を使用**:
```typescript
// shared/interfaces/IUser.ts（抽象層）
export interface IUser {
  id: string;
  name: string;
}

// user-management/UserService.ts
import { OrderRepository } from '../order-management';

export class UserService {
  constructor(private orderRepo: OrderRepository) {}

  getUserOrders(userId: string) {
    return this.orderRepo.findByUserId(userId);
  }
}

// order-management/OrderRepository.ts
import { IUser } from '../shared/interfaces';  // 抽象に依存

export class OrderRepository {
  findByUserId(userId: string): Order[] {
    // IUserインターフェースを使用
    // 具象のUserクラスには依存しない
  }
}

// 依存関係: user-management → order-management → shared
// 循環が解消される
```

**改善例2: 中間層の導入**:
```typescript
// domain/User.ts（ドメインモデル）
export class User {
  constructor(public id: string, public name: string) {}
}

// domain/Order.ts（ドメインモデル）
export class Order {
  constructor(public id: string, public userId: string) {}
}

// user-management/UserService.ts
import { User } from '../domain';

export class UserService {
  getUser(userId: string): User {
    // User取得
  }
}

// order-management/OrderRepository.ts
import { Order } from '../domain';

export class OrderRepository {
  findByUserId(userId: string): Order[] {
    // Order取得
  }
}

// 依存関係:
// user-management → domain
// order-management → domain
// 両方がdomainに依存するが、相互依存はない
```

**改善の効果**:
- ビルドとテストの独立性が保たれる
- 変更の影響範囲が明確になる
- パッケージの再利用が容易になる
- デバッグが容易になる

---

#### 5. SDP: Stable Dependencies Principle（安定依存の原則）

**定義**: 不安定なパッケージから安定したパッケージへの方向に依存すべきである。

**用語**:
- **安定性（Stability）**: パッケージの変更しにくさ。多くのパッケージから依存されているほど安定している。
- **不安定性メトリクス（I）**: `I = Ce / (Ca + Ce)`
  - Ce（Efferent Coupling）: 外向きの依存（このパッケージが依存する他のパッケージ数）
  - Ca（Afferent Coupling）: 内向きの依存（このパッケージに依存する他のパッケージ数）
  - I = 0: 完全に安定（依存されるだけ）
  - I = 1: 完全に不安定（依存するだけ）

**違反の兆候**:
- 安定したパッケージが頻繁に変更される不安定なパッケージに依存
- 低レベルの変更が高レベルのパッケージに影響
- 基盤となるパッケージが上位層に依存

**検出方法**:
```
1. 各パッケージのCaとCeを測定
2. 不安定性メトリクスIを計算
3. 依存関係の方向とI値の関係を確認
4. I値が高いパッケージがI値が低いパッケージに依存していれば違反
```

**悪い例**:
```python
# core/database.py（多くのパッケージから依存される基盤、I=0に近い）
from analytics.tracker import AnalyticsTracker  # 不安定なパッケージに依存!

class Database:
    def __init__(self):
        self.tracker = AnalyticsTracker()  # アナリティクスに依存

    def execute_query(self, query):
        self.tracker.track_query(query)  # 依存!
        # クエリ実行

# analytics/tracker.py（頻繁に変更される、I=1に近い）
class AnalyticsTracker:
    def track_query(self, query):
        # 分析ロジック（頻繁に変更される）
        pass

# 問題:
# - Databaseは安定すべき基盤だが、不安定なAnalyticsに依存
# - Analytics変更のたびにDatabaseの再ビルド・再テストが必要
```

**改善例**:
```python
# core/database.py（安定、I=0に近い）
from abc import ABC, abstractmethod

class QueryObserver(ABC):  # 抽象インターフェース
    @abstractmethod
    def on_query_executed(self, query):
        pass

class Database:
    def __init__(self):
        self.observers: list[QueryObserver] = []

    def register_observer(self, observer: QueryObserver):
        self.observers.append(observer)

    def execute_query(self, query):
        # クエリ実行
        for observer in self.observers:
            observer.on_query_executed(query)

# analytics/tracker.py（不安定、I=1に近い）
from core.database import QueryObserver

class AnalyticsTracker(QueryObserver):
    def on_query_executed(self, query):
        # 分析ロジック
        pass

# 依存関係の逆転:
# Database（安定） ← QueryObserver（抽象）
# QueryObserver（抽象） ← AnalyticsTracker（不安定）
# 不安定なものが安定なものに依存する方向に修正
```

**改善の効果**:
- 安定したパッケージが変更されにくくなる
- 変更の影響が一方向に伝播する
- アーキテクチャの堅牢性が向上する
- テストの安定性が向上する

---

#### 6. SAP: Stable Abstractions Principle（安定抽象化の原則）

**定義**: パッケージの抽象度は安定度に比例すべきである。安定したパッケージほど抽象的であるべきで、不安定なパッケージは具象的であるべきである。

**用語**:
- **抽象度（A）**: `A = 抽象クラス・インターフェース数 / 全クラス数`
  - A = 0: 完全に具象的
  - A = 1: 完全に抽象的

**違反の兆候**:
- 安定したパッケージに具象クラスのみが含まれる（変更が困難）
- 不安定なパッケージに抽象クラスのみが含まれる（使われない抽象化）
- 多くのパッケージから依存されているが、拡張ポイントがない

**検出方法**:
```
1. 各パッケージの安定度I（不安定性メトリクス）を計算
2. 各パッケージの抽象度Aを計算
3. Main Sequence（理想的な関係: A + I = 1）からの距離Dを計算
   D = |A + I - 1|
4. D値が大きい（> 0.3程度）場合は違反の可能性
```

**悪い例**:
```java
// payment-gateway パッケージ（多くのパッケージから依存、I=0.1、安定）
// しかし、全て具象クラス（A=0.0）

public class StripePaymentGateway {  // 具象クラス
    public void processPayment(double amount) {
        // Stripe固有の処理
    }
}

public class PayPalPaymentGateway {  // 具象クラス
    public void processPayment(double amount) {
        // PayPal固有の処理
    }
}

// 問題:
// - 安定したパッケージだが抽象化されていない（A=0）
// - 新しい決済方法の追加時にパッケージを変更する必要がある
// - 多くのクライアントが具象に直接依存している
// Main Sequence距離: D = |0.0 + 0.1 - 1| = 0.9（大きく逸脱）
```

**改善例**:
```java
// payment-gateway パッケージ（安定、I=0.1、抽象度も向上）

// 抽象化
public interface PaymentGateway {  // インターフェース
    void processPayment(double amount);
    PaymentStatus getStatus(String transactionId);
}

public interface PaymentGatewayFactory {  // インターフェース
    PaymentGateway createGateway(String type);
}

// 具象実装
public class StripePaymentGateway implements PaymentGateway {
    public void processPayment(double amount) {
        // Stripe固有の処理
    }

    public PaymentStatus getStatus(String transactionId) {
        // 実装
    }
}

public class PayPalPaymentGateway implements PaymentGateway {
    public void processPayment(double amount) {
        // PayPal固有の処理
    }

    public PaymentStatus getStatus(String transactionId) {
        // 実装
    }
}

public class DefaultPaymentGatewayFactory implements PaymentGatewayFactory {
    public PaymentGateway createGateway(String type) {
        switch (type) {
            case "stripe": return new StripePaymentGateway();
            case "paypal": return new PayPalPaymentGateway();
            default: throw new IllegalArgumentException();
        }
    }
}

// 抽象度: A = 2インターフェース / 5クラス = 0.4
// Main Sequence距離: D = |0.4 + 0.1 - 1| = 0.5（改善）
```

**より良い改善例（パッケージ分離）**:
```java
// payment-core パッケージ（非常に安定、I≈0、抽象的、A≈1）
public interface PaymentGateway {
    void processPayment(double amount);
    PaymentStatus getStatus(String transactionId);
}

public interface PaymentGatewayFactory {
    PaymentGateway createGateway(String type);
}

// Main Sequence距離: D = |1.0 + 0.0 - 1| = 0.0（理想的）

// payment-providers パッケージ（不安定、I≈0.8、具象的、A≈0）
public class StripePaymentGateway implements PaymentGateway { /* ... */ }
public class PayPalPaymentGateway implements PaymentGateway { /* ... */ }
public class DefaultPaymentGatewayFactory implements PaymentGatewayFactory { /* ... */ }

// Main Sequence距離: D = |0.0 + 0.8 - 1| = 0.2（許容範囲）
```

**Main Sequenceグラフ**:
```
抽象度(A)
   1.0 |     理想         Zone of Pain
       |       ↘         (抽象的だが安定)
       |         ↘
   0.5 |           ↘
       |             ↘
   0.0 |_______________↘_____________
     0.0             0.5           1.0  不安定性(I)
       Zone of Uselessness
       (具象的で安定 = 変更困難)
```

**改善の効果**:
- 安定したパッケージが拡張可能になる（OCP遵守）
- 不安定なパッケージは具象的で変更しやすい
- アーキテクチャのバランスが保たれる
- 依存性逆転の原則（DIP）との一貫性

---

## パッケージ設計原則の活用

### 原則の組み合わせ

6つの原則は相互に補完し合います:

1. **REP + CRP + CCP**: パッケージの凝集度を高める
   - REP: 再利用単位の明確化
   - CRP: 共通再利用の確保
   - CCP: 変更の局所化

2. **ADP + SDP + SAP**: パッケージの結合度を管理する
   - ADP: 循環依存の排除
   - SDP: 依存方向の制御
   - SAP: 抽象化レベルの適切化

### 適用のバランス

- **CRP vs CCP**: トレードオフが存在
  - CRP: 一緒に再利用されるものをまとめる
  - CCP: 一緒に変更されるものをまとめる
  - 両者が一致しない場合、プロジェクトの状況に応じて判断

- **抽象度と安定度**: SAP + SDP
  - 安定したパッケージは抽象的にする（SAP）
  - 不安定なパッケージから安定したパッケージへ依存する（SDP）
  - 結果的に抽象に依存し、具象は変更しやすくなる（DIP）

### 検出ツール

- **JavaScript/TypeScript**: madge, dependency-cruiser
- **Java**: jdepend, ArchUnit, Structure101
- **Python**: pydeps, snakefood
- **Go**: go mod graph + 独自スクリプト
- **C#**: NDepend

### プロジェクトへの適用

1. **既存コードの分析**:
   - 依存関係グラフを可視化
   - 循環依存を検出（ADP）
   - 安定度と抽象度を測定（SDP, SAP）

2. **問題箇所の特定**:
   - Main Sequenceから大きく外れているパッケージ
   - 循環依存が存在する箇所
   - 頻繁に変更されるが多くから依存されているパッケージ

3. **段階的なリファクタリング**:
   - 循環依存の解消を最優先（ADP）
   - パッケージの分割/統合（REP, CRP, CCP）
   - 抽象化の導入（SAP）
