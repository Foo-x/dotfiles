# コードスメルカタログ

コードの問題を示す兆候（コードスメル）を体系的に分類したカタログです。

## Bloaters（肥大化）

コードやクラスが大きくなりすぎて扱いにくくなっている状態。

### Long Method（長すぎるメソッド）

**定義**: メソッドやファンクションが長すぎる。

**検出基準**:
- 50行以上のメソッド
- スクロールしないと全体が見えないメソッド
- 複数の責任を持つメソッド

**問題点**:
- 理解が困難
- テストが困難
- 再利用が困難
- バグが混入しやすい

**リファクタリング手法**:
- Extract Method（メソッドの抽出）
- Replace Temp with Query（一時変数のクエリへの置き換え）
- Introduce Parameter Object（パラメータオブジェクトの導入）

**例**:
```python
# 悪い例
def process_order(order_data):
    # 100行以上のコード
    # バリデーション
    if not order_data.get('customer_id'):
        raise ValueError("customer_id is required")
    if not order_data.get('items'):
        raise ValueError("items is required")
    # 在庫チェック
    for item in order_data['items']:
        stock = db.get_stock(item['product_id'])
        if stock < item['quantity']:
            raise ValueError("Not enough stock")
    # 価格計算
    subtotal = sum(item['price'] * item['quantity'] for item in order_data['items'])
    tax = subtotal * 0.1
    shipping = calculate_shipping(order_data['address'])
    total = subtotal + tax + shipping
    # 支払い処理
    payment_result = payment_gateway.charge(order_data['payment_method'], total)
    # 在庫更新
    for item in order_data['items']:
        db.update_stock(item['product_id'], -item['quantity'])
    # メール送信
    send_confirmation_email(order_data['customer_id'], total)
    return {'order_id': generate_id(), 'total': total}

# 良い例
def process_order(order_data):
    validate_order(order_data)
    check_stock(order_data['items'])
    total = calculate_total(order_data)
    process_payment(order_data['payment_method'], total)
    update_inventory(order_data['items'])
    send_confirmation(order_data['customer_id'], total)
    return create_order_result(total)
```

---

### Large Class（大きすぎるクラス）

**定義**: 1つのクラスが多すぎる責任を持っている。

**検出基準**:
- 500行以上のクラス
- 20個以上のフィールド
- 30個以上のメソッド
- 複数の異なる概念を扱っている

**問題点**:
- 単一責任原則の違反
- 理解が困難
- テストが困難
- 変更の影響範囲が大きい

**リファクタリング手法**:
- Extract Class（クラスの抽出）
- Extract Subclass（サブクラスの抽出）
- Extract Interface（インターフェースの抽出）

**例**:
```java
// 悪い例
public class User {
    // ユーザー情報
    private String name;
    private String email;

    // 認証関連
    private String passwordHash;
    private String salt;

    // プロファイル関連
    private String bio;
    private String avatarUrl;

    // 通知設定
    private boolean emailNotifications;
    private boolean pushNotifications;

    // 統計情報
    private int loginCount;
    private Date lastLogin;

    // メソッドも多数...
    public void authenticate(String password) { }
    public void sendEmail(String message) { }
    public void updateProfile(String bio) { }
    public void trackLogin() { }
    // ... 30個以上のメソッド
}

// 良い例
public class User {
    private String name;
    private String email;
    private Authentication authentication;
    private Profile profile;
    private NotificationSettings notificationSettings;
    private UserStatistics statistics;
}

public class Authentication {
    private String passwordHash;
    private String salt;
    public void authenticate(String password) { }
}

public class Profile {
    private String bio;
    private String avatarUrl;
    public void update(String bio) { }
}

// ... 他のクラスも同様に分離
```

---

### Long Parameter List（長すぎる引数リスト）

**定義**: メソッドの引数が多すぎる。

**検出基準**:
- 4個以上の引数
- 同じ型の引数が連続している
- 引数の順序を覚えにくい

**問題点**:
- 呼び出しが複雑
- 引数の順序を間違えやすい
- 引数追加のたびにシグネチャ変更

**リファクタリング手法**:
- Introduce Parameter Object（パラメータオブジェクトの導入）
- Preserve Whole Object（オブジェクト全体の保存）

**例**:
```typescript
// 悪い例
function createUser(
  name: string,
  email: string,
  age: number,
  address: string,
  city: string,
  country: string,
  zipCode: string,
  phoneNumber: string
) {
  // ...
}

createUser("John", "john@example.com", 30, "123 Main St", "Tokyo", "Japan", "100-0001", "090-1234-5678");

// 良い例
interface UserData {
  name: string;
  email: string;
  age: number;
  address: Address;
  contact: Contact;
}

interface Address {
  street: string;
  city: string;
  country: string;
  zipCode: string;
}

interface Contact {
  phoneNumber: string;
}

function createUser(userData: UserData) {
  // ...
}

createUser({
  name: "John",
  email: "john@example.com",
  age: 30,
  address: {
    street: "123 Main St",
    city: "Tokyo",
    country: "Japan",
    zipCode: "100-0001"
  },
  contact: {
    phoneNumber: "090-1234-5678"
  }
});
```

---

### Primitive Obsession（プリミティブ型への執着）

**定義**: ドメイン概念を表現するのに独自の型ではなくプリミティブ型を使用している。

**検出基準**:
- 文字列や数値で複雑な概念を表現
- 電話番号、郵便番号、メールアドレスが単なるstring
- 金額が単なるnumberやfloat

**問題点**:
- バリデーションが分散する
- ビジネスロジックが漏れる
- 型安全性が低い

**リファクタリング手法**:
- Replace Data Value with Object（データ値のオブジェクト化）
- Introduce Value Object（値オブジェクトの導入）

**例**:
```csharp
// 悪い例
public class Order {
    private string phoneNumber;  // 単なる文字列
    private decimal price;       // 単なる数値

    public void SetPhoneNumber(string phone) {
        // バリデーションが各所に散在
        if (!Regex.IsMatch(phone, @"^\d{3}-\d{4}-\d{4}$")) {
            throw new ArgumentException("Invalid phone number");
        }
        this.phoneNumber = phone;
    }

    public void SetPrice(decimal price) {
        if (price < 0) {
            throw new ArgumentException("Price cannot be negative");
        }
        this.price = price;
    }
}

// 良い例
public class PhoneNumber {
    private string value;

    public PhoneNumber(string number) {
        if (!Regex.IsMatch(number, @"^\d{3}-\d{4}-\d{4}$")) {
            throw new ArgumentException("Invalid phone number");
        }
        this.value = number;
    }

    public string Value => value;
}

public class Money {
    private decimal amount;
    private string currency;

    public Money(decimal amount, string currency = "JPY") {
        if (amount < 0) {
            throw new ArgumentException("Amount cannot be negative");
        }
        this.amount = amount;
        this.currency = currency;
    }

    public Money Add(Money other) {
        if (this.currency != other.currency) {
            throw new InvalidOperationException("Cannot add different currencies");
        }
        return new Money(this.amount + other.amount, this.currency);
    }
}

public class Order {
    private PhoneNumber phoneNumber;
    private Money price;

    public void SetPhoneNumber(PhoneNumber phone) {
        this.phoneNumber = phone;  // バリデーションは型に含まれる
    }

    public void SetPrice(Money price) {
        this.price = price;  // バリデーションは型に含まれる
    }
}
```

---

### Data Clumps（データの群れ）

**定義**: 常に一緒に現れるデータのグループ。

**検出基準**:
- 複数のメソッドで同じ引数セットが繰り返される
- 複数のクラスで同じフィールドセットが繰り返される
- 3つ以上のデータが常にセットで現れる

**問題点**:
- 重複したコード
- 変更時の修正箇所が多い
- 概念が明確でない

**リファクタリング手法**:
- Extract Class（クラスの抽出）
- Introduce Parameter Object（パラメータオブジェクトの導入）

**例**:
```ruby
# 悪い例
class Customer
  def initialize(first_name, last_name, street, city, state, zip)
    @first_name = first_name
    @last_name = last_name
    @street = street
    @city = city
    @state = state
    @zip = zip
  end
end

class Order
  def initialize(customer_first_name, customer_last_name,
                 shipping_street, shipping_city, shipping_state, shipping_zip)
    @customer_first_name = customer_first_name
    @customer_last_name = customer_last_name
    @shipping_street = shipping_street
    @shipping_city = shipping_city
    @shipping_state = shipping_state
    @shipping_zip = shipping_zip
  end
end

# 良い例
class Name
  attr_reader :first, :last

  def initialize(first, last)
    @first = first
    @last = last
  end

  def full_name
    "#{first} #{last}"
  end
end

class Address
  attr_reader :street, :city, :state, :zip

  def initialize(street, city, state, zip)
    @street = street
    @city = city
    @state = state
    @zip = zip
  end

  def full_address
    "#{street}, #{city}, #{state} #{zip}"
  end
end

class Customer
  attr_reader :name, :address

  def initialize(name, address)
    @name = name
    @address = address
  end
end

class Order
  attr_reader :customer_name, :shipping_address

  def initialize(customer_name, shipping_address)
    @customer_name = customer_name
    @shipping_address = shipping_address
  end
end
```

---

## Object-Orientation Abusers（オブジェクト指向の濫用）

オブジェクト指向の原則が正しく適用されていない状態。

### Switch Statements（switch文の乱用）

**定義**: 型コードやタイプチェックに基づく複雑なswitch文やif-else連鎖。

**検出基準**:
- 同じ型チェックが複数箇所に存在
- switch文が3箇所以上で繰り返される
- 新しい型追加のたびに複数箇所を修正

**問題点**:
- Open/Closed原則の違反
- 変更の影響範囲が広い
- 重複したコード

**リファクタリング手法**:
- Replace Conditional with Polymorphism（条件分岐のポリモーフィズムへの置き換え）
- Replace Type Code with State/Strategy（型コードのState/Strategyへの置き換え）

**例**:
```go
// 悪い例
type Animal struct {
    Type string
    Name string
}

func (a Animal) MakeSound() string {
    switch a.Type {
    case "dog":
        return "Woof!"
    case "cat":
        return "Meow!"
    case "cow":
        return "Moo!"
    default:
        return ""
    }
}

func (a Animal) Move() string {
    switch a.Type {
    case "dog":
        return "Running"
    case "cat":
        return "Stalking"
    case "cow":
        return "Walking"
    default:
        return ""
    }
}

// 良い例
type Animal interface {
    MakeSound() string
    Move() string
}

type Dog struct {
    Name string
}

func (d Dog) MakeSound() string {
    return "Woof!"
}

func (d Dog) Move() string {
    return "Running"
}

type Cat struct {
    Name string
}

func (c Cat) MakeSound() string {
    return "Meow!"
}

func (c Cat) Move() string {
    return "Stalking"
}

type Cow struct {
    Name string
}

func (c Cow) MakeSound() string {
    return "Moo!"
}

func (c Cow) Move() string {
    return "Walking"
}
```

---

### Temporary Field（一時的なフィールド）

**定義**: 特定の状況でのみ値が設定されるフィールド。

**検出基準**:
- nullや空値が多いフィールド
- 特定のメソッド実行時のみ使用されるフィールド
- フィールドの使用が条件付き

**問題点**:
- クラスの理解が困難
- null参照エラーのリスク
- 不要な状態管理

**リファクタリング手法**:
- Extract Class（クラスの抽出）
- Replace Method with Method Object（メソッドのメソッドオブジェクト化）

**例**:
```python
# 悪い例
class Order:
    def __init__(self):
        self.items = []
        self.discount = None  # 一時的にしか使わない
        self.shipping_cost = None  # 一時的にしか使わない

    def calculate_total(self):
        subtotal = sum(item.price for item in self.items)

        # discountは計算時のみ設定される
        if self.has_coupon():
            self.discount = subtotal * 0.1

        # shipping_costも計算時のみ設定される
        self.shipping_cost = self._calculate_shipping()

        total = subtotal - (self.discount or 0) + self.shipping_cost
        return total

# 良い例
class Order:
    def __init__(self):
        self.items = []

    def calculate_total(self):
        subtotal = sum(item.price for item in self.items)
        calculator = PriceCalculator(subtotal, self.items, self.has_coupon())
        return calculator.calculate()

class PriceCalculator:
    def __init__(self, subtotal, items, has_coupon):
        self.subtotal = subtotal
        self.items = items
        self.has_coupon = has_coupon

    def calculate(self):
        discount = self._calculate_discount()
        shipping = self._calculate_shipping()
        return self.subtotal - discount + shipping

    def _calculate_discount(self):
        return self.subtotal * 0.1 if self.has_coupon else 0

    def _calculate_shipping(self):
        # shipping calculation logic
        return 500
```

---

### Refused Bequest（親クラスの拒絶）

**定義**: サブクラスが親クラスのメソッドやフィールドの一部しか使用しない、または例外をスローする。

**検出基準**:
- 親クラスのメソッドをオーバーライドして例外をスロー
- 親クラスの機能の大部分が未使用
- 継承関係が「is-a」ではなく「has-a」

**問題点**:
- リスコフの置換原則の違反
- 継承の誤用
- 予期しない動作

**リファクタリング手法**:
- Replace Inheritance with Delegation（継承の委譲への置き換え）
- Extract Subclass（サブクラスの抽出）

**例**:
```java
// 悪い例
class Rectangle {
    protected int width;
    protected int height;

    public void setWidth(int width) {
        this.width = width;
    }

    public void setHeight(int height) {
        this.height = height;
    }

    public int getArea() {
        return width * height;
    }
}

class Square extends Rectangle {
    @Override
    public void setWidth(int width) {
        this.width = width;
        this.height = width;  // 親の動作を拒絶
    }

    @Override
    public void setHeight(int height) {
        this.width = height;  // 親の動作を拒絶
        this.height = height;
    }
}

// 良い例
interface Shape {
    int getArea();
}

class Rectangle implements Shape {
    private int width;
    private int height;

    public Rectangle(int width, int height) {
        this.width = width;
        this.height = height;
    }

    public int getArea() {
        return width * height;
    }
}

class Square implements Shape {
    private int side;

    public Square(int side) {
        this.side = side;
    }

    public int getArea() {
        return side * side;
    }
}
```

---

## Change Preventers（変更の妨害者）

変更を困難にするコード構造。

### Divergent Change（発散的変更）

**定義**: 1つのクラスが異なる理由で頻繁に変更される。

**検出基準**:
- 1つのクラスが複数の異なる理由で変更される
- 変更履歴で頻繁に修正されるクラス
- 異なるチームが同じクラスを修正する

**問題点**:
- 単一責任原則の違反
- マージコンフリクトの増加
- テストの影響範囲が広い

**リファクタリング手法**:
- Extract Class（クラスの抽出）
- Extract Module（モジュールの抽出）

---

### Shotgun Surgery（散弾銃手術）

**定義**: 1つの変更が複数のクラスに影響する。

**検出基準**:
- 1つの機能追加で10個以上のファイルを修正
- 同じパターンの変更が複数箇所で必要
- 関連するコードが分散している

**問題点**:
- 変更漏れのリスク
- 保守コストが高い
- テストが困難

**リファクタリング手法**:
- Move Method（メソッドの移動）
- Move Field（フィールドの移動）
- Inline Class（クラスのインライン化）

---

## Dispensables（不要なもの）

存在しなくてもコードがより綺麗になるもの。

### Dead Code（デッドコード）

**定義**: 使用されていないコード。

**検出基準**:
- 呼び出されていないメソッド
- 参照されていない変数
- 到達不可能なコードブロック

**問題点**:
- コードベースの肥大化
- 保守コストの増加
- 混乱の原因

**リファクタリング手法**:
- 削除

**例**:
```javascript
// 悪い例
function processData(data) {
  const result = transform(data);

  // この関数は使われていない
  function oldTransform(data) {
    // 古い実装
  }

  return result;
}

const UNUSED_CONSTANT = 42;  // 使われていない定数

// 良い例
function processData(data) {
  return transform(data);
}
```

---

### Duplicate Code（重複コード）

**定義**: 同じまたは類似したコードが複数箇所に存在する。

**検出基準**:
- 同一のコードブロックが2箇所以上
- 類似したロジックの繰り返し
- コピー&ペーストの痕跡

**リファクタリング手法**:
- Extract Method（メソッドの抽出）
- Pull Up Method（メソッドの引き上げ）
- Form Template Method（テンプレートメソッドの形成）

---

### Speculative Generality（投機的一般化）

**定義**: 将来必要になるかもしれないという理由だけで作られた抽象化。

**検出基準**:
- 使用されていない抽象化レイヤー
- 単一の実装しかないインターフェース
- 使われていない引数やフック

**リファクタリング手法**:
- Collapse Hierarchy（階層の平坦化）
- Inline Class（クラスのインライン化）
- Remove Parameter（引数の削除）

---

## Couplers（結合の問題）

クラス間の過度な結合。

### Feature Envy（機能への羨望）

**定義**: メソッドが自分のクラスよりも他のクラスのデータに興味を持っている。

**検出基準**:
- 他のクラスのgetterを多用
- 他のクラスのメソッドを頻繁に呼び出す
- 自クラスのデータよりも他クラスのデータを多く使用

**リファクタリング手法**:
- Move Method（メソッドの移動）
- Extract Method（メソッドの抽出）

**例**:
```ruby
# 悪い例
class Order
  attr_reader :customer

  def total_discount
    # customerのデータばかり使っている
    if customer.loyalty_points > 1000
      customer.total_purchases * 0.1
    elsif customer.loyalty_points > 500
      customer.total_purchases * 0.05
    else
      0
    end
  end
end

# 良い例
class Customer
  attr_reader :loyalty_points, :total_purchases

  def calculate_discount
    if loyalty_points > 1000
      total_purchases * 0.1
    elsif loyalty_points > 500
      total_purchases * 0.05
    else
      0
    end
  end
end

class Order
  attr_reader :customer

  def total_discount
    customer.calculate_discount
  end
end
```

---

### Inappropriate Intimacy（不適切な関係）

**定義**: 2つのクラスが互いの内部実装に深く依存している。

**検出基準**:
- 双方向の依存関係
- protectedメンバーへの頻繁なアクセス
- 内部構造の深い知識

**リファクタリング手法**:
- Move Method/Field（メソッド/フィールドの移動）
- Extract Class（クラスの抽出）
- Change Bidirectional Association to Unidirectional（双方向関連の単方向化）

---

### Message Chains（メッセージチェーン）

**定義**: 長い呼び出しチェーン（Law of Demeter違反）。

**検出基準**:
- `a.b().c().d()`のような連鎖
- 3つ以上の「.」が連続
- 中間オブジェクトの構造への依存

**リファクタリング手法**:
- Hide Delegate（委譲の隠蔽）
- Extract Method（メソッドの抽出）

---

### Middle Man（仲介者）

**定義**: クラスが単に他のクラスへの委譲しかしていない。

**検出基準**:
- メソッドの大部分が委譲のみ
- 独自のロジックがほとんどない
- ラッパークラスとして機能しているだけ

**リファクタリング手法**:
- Remove Middle Man（仲介者の削除）
- Inline Method（メソッドのインライン化）

**例**:
```python
# 悪い例
class Department:
    def __init__(self, manager):
        self._manager = manager

    def get_manager(self):
        return self._manager

class Person:
    def __init__(self, name, department):
        self.name = name
        self._department = department

    def get_manager(self):
        # 単なる委譲
        return self._department.get_manager()

# 使用例
person = Person("Alice", department)
manager = person.get_manager()  # 不要な仲介

# 良い例
class Person:
    def __init__(self, name, department):
        self.name = name
        self.department = department  # 直接アクセス可能に

# 使用例
person = Person("Alice", department)
manager = person.department.get_manager()  # 直接アクセス
```
