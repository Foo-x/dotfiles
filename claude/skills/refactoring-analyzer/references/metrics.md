# 品質メトリクス

コード品質を定量的に評価するための指標と測定方法を提供します。

## 結合度（Coupling）

モジュール間の相互依存の度合いを示す指標。結合度が低いほど、モジュールの独立性が高く、保守性が向上します。

### 結合度の種類（弱い順）

#### 1. データ結合（Data Coupling）- 最も弱い
**定義**: モジュール間でプリミティブなデータのみを受け渡す。

**特徴**:
- 引数として単純なデータ型を渡す
- グローバル変数を使用しない
- 構造体やオブジェクトの内部構造に依存しない

**評価**: 良好（推奨される結合）

**例**:
```python
def calculate_tax(amount: float, rate: float) -> float:
    return amount * rate

total = calculate_tax(1000.0, 0.1)  # プリミティブなデータのみ
```

---

#### 2. スタンプ結合（Stamp Coupling）
**定義**: モジュール間で構造化データ（構造体、オブジェクト）を受け渡すが、その一部のみを使用する。

**特徴**:
- オブジェクト全体を渡すが、一部のフィールドしか使わない
- データ構造の変更が影響する可能性がある

**評価**: 許容可能（状況に応じて使用）

**例**:
```java
class Order {
    private String id;
    private double amount;
    private String customerName;
    // ... 他のフィールド
}

// amountしか使わないのにOrder全体を渡している
double calculateTax(Order order) {
    return order.getAmount() * 0.1;
}

// 改善: データ結合に変更
double calculateTax(double amount) {
    return amount * 0.1;
}
```

---

#### 3. 制御結合（Control Coupling）
**定義**: 呼び出し元が呼び出し先の制御フローを決定する。

**特徴**:
- フラグやモード引数で動作を制御
- 呼び出し先の内部ロジックを呼び出し元が知っている

**評価**: 避けるべき

**例**:
```typescript
// 悪い例: 制御結合
function processData(data: any[], mode: string) {
  if (mode === 'sort') {
    return data.sort();
  } else if (mode === 'filter') {
    return data.filter(x => x > 0);
  } else if (mode === 'map') {
    return data.map(x => x * 2);
  }
}

// 良い例: 別々の関数に分離
function sortData(data: any[]) {
  return data.sort();
}

function filterData(data: any[]) {
  return data.filter(x => x > 0);
}

function mapData(data: any[]) {
  return data.map(x => x * 2);
}
```

---

#### 4. 外部結合（External Coupling）
**定義**: モジュールが外部データフォーマット、プロトコル、デバイスに依存する。

**特徴**:
- 外部ファイル形式に依存
- 特定のプロトコルに依存
- ハードウェアに依存

**評価**: 必要に応じて使用（抽象化で緩和）

**例**:
```go
// 悪い例: 直接依存
func SaveData(data string) error {
    return ioutil.WriteFile("/tmp/data.json", []byte(data), 0644)
}

// 良い例: 抽象化
type Storage interface {
    Save(data string) error
}

type FileStorage struct {
    path string
}

func (f *FileStorage) Save(data string) error {
    return ioutil.WriteFile(f.path, []byte(data), 0644)
}

func SaveData(storage Storage, data string) error {
    return storage.Save(data)
}
```

---

#### 5. 共通結合（Common Coupling）
**定義**: 複数のモジュールがグローバルデータを共有する。

**特徴**:
- グローバル変数の使用
- シングルトンの過度な使用
- 変更の影響が予測困難

**評価**: 強く避けるべき

**例**:
```javascript
// 悪い例: グローバル変数
let globalCounter = 0;

function incrementCounter() {
  globalCounter++;
}

function getCounter() {
  return globalCounter;
}

// 良い例: カプセル化
class Counter {
  constructor() {
    this.value = 0;
  }

  increment() {
    this.value++;
  }

  getValue() {
    return this.value;
  }
}

const counter = new Counter();
```

---

#### 6. 内容結合（Content Coupling）- 最も強い
**定義**: モジュールが他のモジュールの内部実装を直接参照・変更する。

**特徴**:
- 他クラスのprivateフィールドへのアクセス
- 内部状態の直接操作
- リフレクションの濫用

**評価**: 絶対に避けるべき

**例**:
```python
# 悪い例: 内部実装への直接アクセス
class BankAccount:
    def __init__(self):
        self.__balance = 0  # プライベート

class AccountHacker:
    def steal_money(self, account):
        # プライベートフィールドに直接アクセス（Pythonでは可能）
        account._BankAccount__balance = 0

# 良い例: 公開インターフェースを使用
class BankAccount:
    def __init__(self):
        self.__balance = 0

    def withdraw(self, amount):
        if amount <= self.__balance:
            self.__balance -= amount
            return True
        return False

    def get_balance(self):
        return self.__balance
```

---

### 結合度の測定方法

**結合度スコア（0-10）**:
- 0-2: データ結合のみ（優秀）
- 3-4: スタンプ結合が少し含まれる（良好）
- 5-6: 制御結合が存在する（改善推奨）
- 7-8: 共通結合が存在する（要改善）
- 9-10: 内容結合が存在する（緊急改善）

**測定観点**:
1. モジュールAが変更されたときに影響を受けるモジュール数
2. グローバル変数の使用数
3. 引数の型の複雑度
4. 制御フラグの使用数

---

## コナーセンス(Connascence)

モジュール間の依存関係を分類・測定するための概念。Meilir Page-Jonesによって提唱され、結合度(Coupling)を補完してより細かい粒度で依存関係の問題を特定できます。

### コナーセンスの3つの属性

#### 1. 強度(Strength)
依存関係の変更の困難さ。静的コナーセンスより動的コナーセンスの方が強い。

#### 2. 度合い(Degree)
その依存関係に影響される要素の数。度合いが高いほど変更の影響範囲が大きい。

#### 3. 局所性(Locality)
依存関係がどれだけ近くにあるか。同一モジュール内、隣接モジュール、遠隔モジュールの順に局所性が低くなる。

### 静的コナーセンス(Static Connascence)

ソースコードを見れば検出できる依存関係。弱い順に:

#### 1. 名前のコナーセンス(CoN: Connascence of Name)- 最も弱い

**定義**: 複数の要素が同じ名前に依存する。

**特徴**:
- メソッド名、変数名、型名の一致
- 最も基本的で避けられない依存関係
- リファクタリングツールで簡単に変更可能

**評価**: 許容される(最も弱い依存)

**例**:
```python
# 名前のコナーセンス
class Customer:
    def calculate_total(self):
        pass

# calculate_totalという名前に依存
customer = Customer()
total = customer.calculate_total()  # メソッド名が変わると壊れる
```

---

#### 2. 型のコナーセンス(CoT: Connascence of Type)

**定義**: 複数の要素が同じ型に依存する。

**特徴**:
- データ型の一致が必要
- 静的型付け言語で強制される
- 型安全性を提供

**評価**: 許容可能(型システムによる保護)

**例**:
```typescript
// 型のコナーセンス
interface User {
  id: number;
  name: string;
}

// Userという型に依存
function greetUser(user: User): string {
  return `Hello, ${user.name}`;
}

function saveUser(user: User): void {
  // User型の構造が変わると影響を受ける
}
```

---

#### 3. 意味のコナーセンス(CoM: Connascence of Meaning)

**定義**: 複数の要素が値の意味を暗黙的に共有する。

**特徴**:
- マジックナンバー
- 暗黙の規約
- 列挙型で改善可能

**評価**: 避けるべき(列挙型や定数で改善)

**例**:
```java
// 悪い例: 意味のコナーセンス
public class Order {
    public void setStatus(int status) {
        this.status = status;  // 1=pending, 2=shipped, 3=delivered
    }
}

order.setStatus(1);  // 1の意味を知っている必要がある
order.setStatus(2);  // 2の意味を知っている必要がある

// 良い例: 列挙型で改善
public enum OrderStatus {
    PENDING,
    SHIPPED,
    DELIVERED
}

public class Order {
    public void setStatus(OrderStatus status) {
        this.status = status;
    }
}

order.setStatus(OrderStatus.PENDING);  // 明示的
order.setStatus(OrderStatus.SHIPPED);  // 自己文書化
```

---

#### 4. 位置のコナーセンス(CoP: Connascence of Position)

**定義**: 複数の要素が順序に依存する。

**特徴**:
- 関数の引数の順序
- 配列の要素の位置
- 順序が変わると壊れる

**評価**: 改善推奨(名前付き引数やオブジェクトで改善)

**例**:
```javascript
// 悪い例: 位置のコナーセンス
function createUser(name, age, email, phone) {
  return { name, age, email, phone };
}

// 引数の順序を覚えている必要がある
const user = createUser("Alice", 30, "alice@example.com", "123-4567");

// 良い例: オブジェクトで改善
function createUser({ name, age, email, phone }) {
  return { name, age, email, phone };
}

// 順序に依存しない
const user = createUser({
  email: "alice@example.com",
  name: "Alice",
  phone: "123-4567",
  age: 30
});
```

---

#### 5. アルゴリズムのコナーセンス(CoA: Connascence of Algorithm)

**定義**: 複数の要素が同じアルゴリズムに依存する。

**特徴**:
- エンコード/デコード
- ハッシュ関数
- 暗号化/復号化
- アルゴリズムの変更が困難

**評価**: 強く避けるべき(共通モジュールに集約)

**例**:
```python
# 悪い例: アルゴリズムのコナーセンス
class Encoder:
    def encode(self, data):
        # 特定のアルゴリズムでエンコード
        return base64.b64encode(data.encode()).decode()

class Decoder:
    def decode(self, data):
        # 同じアルゴリズムを知っている必要がある
        return base64.b64decode(data.encode()).decode()

# 良い例: 共通モジュールに集約
class Codec:
    @staticmethod
    def encode(data):
        return base64.b64encode(data.encode()).decode()

    @staticmethod
    def decode(data):
        return base64.b64decode(data.encode()).decode()

# 単一の場所でアルゴリズムを管理
encoder = Codec()
encoded = encoder.encode("Hello")
decoded = encoder.decode(encoded)
```

---

### 動的コナーセンス(Dynamic Connascence)

実行時にのみ検出できる依存関係。静的コナーセンスより強い。

#### 1. 実行順序のコナーセンス(CoE: Connascence of Execution)

**定義**: 要素の実行順序に依存する。

**特徴**:
- 初期化の順序
- メソッド呼び出しの順序
- 順序を間違えるとエラー

**評価**: 避けるべき(依存性注入で改善)

**例**:
```ruby
# 悪い例: 実行順序のコナーセンス
class Database
  def initialize
    @connection = nil
  end

  def connect
    @connection = create_connection()
  end

  def query(sql)
    # connectを先に呼ぶ必要がある
    @connection.execute(sql)
  end
end

db = Database.new
db.connect  # この順序を守る必要がある
db.query("SELECT * FROM users")

# 良い例: 初期化時に接続
class Database
  def initialize
    @connection = create_connection()
  end

  def query(sql)
    @connection.execute(sql)
  end
end

db = Database.new
db.query("SELECT * FROM users")  # 順序を気にする必要がない
```

---

#### 2. タイミングのコナーセンス(CoTiming: Connascence of Timing)

**定義**: 要素の実行タイミングに依存する。

**特徴**:
- レースコンディション
- タイムアウト
- 非同期処理の順序

**評価**: 強く避けるべき(同期化機構で改善)

**例**:
```go
// 悪い例: タイミングのコナーセンス
var counter int

func increment() {
    counter++  // レースコンディション
}

go increment()
go increment()

// 良い例: ミューテックスで同期
var (
    counter int
    mutex   sync.Mutex
)

func increment() {
    mutex.Lock()
    defer mutex.Unlock()
    counter++
}

go increment()
go increment()
```

---

#### 3. 値のコナーセンス(CoV: Connascence of Value)

**定義**: 複数の値が互いに関連して変更される必要がある。

**特徴**:
- 不変条件(invariant)
- データの整合性
- トランザクション境界

**評価**: 避けるべき(トランザクションやイベントで改善)

**例**:
```csharp
// 悪い例: 値のコナーセンス
public class Rectangle {
    public int Width { get; set; }
    public int Height { get; set; }
    public int Area { get; set; }  // Width * Heightと一致する必要がある

    public void SetDimensions(int width, int height) {
        Width = width;
        Height = height;
        // Areaも更新する必要がある(忘れやすい)
        Area = width * height;
    }
}

// 良い例: 計算プロパティ
public class Rectangle {
    public int Width { get; set; }
    public int Height { get; set; }
    public int Area => Width * Height;  // 自動的に整合性が保たれる
}
```

---

#### 4. アイデンティティのコナーセンス(CoI: Connascence of Identity)

**定義**: 複数の要素が同じオブジェクトインスタンスを参照する。

**特徴**:
- 参照の共有
- シングルトン
- グローバルな状態

**評価**: 最も強い(最も避けるべき)

**例**:
```java
// 悪い例: アイデンティティのコナーセンス
public class ConfigManager {
    private static ConfigManager instance;
    private Map<String, String> config;

    public static ConfigManager getInstance() {
        if (instance == null) {
            instance = new ConfigManager();
        }
        return instance;
    }

    // 全てのコードが同じインスタンスに依存
}

// 良い例: 依存性注入
public class ConfigManager {
    private final Map<String, String> config;

    public ConfigManager(Map<String, String> config) {
        this.config = new HashMap<>(config);
    }
}

// 各コンポーネントが独自のインスタンスを受け取る
ConfigManager config1 = new ConfigManager(defaultConfig);
ConfigManager config2 = new ConfigManager(testConfig);
```

---

### コナーセンスの評価と改善指針

#### 原則1: 強度を下げる

強いコナーセンスを弱いコナーセンスに変換する。

```
動的 → 静的
アイデンティティ → 値 → 実行順序 → アルゴリズム → 位置 → 意味 → 型 → 名前
```

**例**:
```kotlin
// 意味のコナーセンス → 名前のコナーセンス
// 悪い例
fun setStatus(status: Int) { }  // 1, 2, 3の意味を知る必要がある

// 良い例
enum class Status { PENDING, ACTIVE, COMPLETED }
fun setStatus(status: Status) { }  // 名前で明示
```

---

#### 原則2: 度合いを下げる

影響を受ける要素の数を減らす。

**例**:
```python
# 悪い例: 高い度合い
GLOBAL_CONFIG = {}  # 多くのモジュールが依存

def module1():
    return GLOBAL_CONFIG['key1']

def module2():
    return GLOBAL_CONFIG['key2']

def module3():
    return GLOBAL_CONFIG['key3']

# 良い例: 低い度合い
class Config:
    def __init__(self, settings):
        self._settings = settings

    def get(self, key):
        return self._settings[key]

# 各モジュールが独自のConfigインスタンスを持つ
```

---

#### 原則3: 局所性を高める

依存関係を近くに配置する。

**例**:
```typescript
// 悪い例: 低い局所性(異なるファイル)
// file1.ts
export const MAGIC_NUMBER = 42;

// file2.ts
import { MAGIC_NUMBER } from './file1';
export function calculate(x: number) {
  return x * MAGIC_NUMBER;
}

// file3.ts
import { MAGIC_NUMBER } from './file1';
export function validate(x: number) {
  return x < MAGIC_NUMBER;
}

// 良い例: 高い局所性(同一クラス内)
class Calculator {
  private readonly MAGIC_NUMBER = 42;

  calculate(x: number) {
    return x * this.MAGIC_NUMBER;
  }

  validate(x: number) {
    return x < this.MAGIC_NUMBER;
  }
}
```

---

### コナーセンスの測定方法

**コナーセンス強度スコア(0-10)**:
- 0-2: 名前・型のコナーセンスのみ(優秀)
- 3-4: 意味・位置のコナーセンスあり(良好)
- 5-6: アルゴリズム・実行順序のコナーセンスあり(改善推奨)
- 7-8: タイミング・値のコナーセンスあり(要改善)
- 9-10: アイデンティティのコナーセンスあり(緊急改善)

**測定観点**:
1. 静的コナーセンスの種類と数
2. 動的コナーセンスの存在
3. 各コナーセンスの度合い(影響範囲)
4. 各コナーセンスの局所性(距離)

---

## 凝集度(Cohesion)

### 凝集度の種類（強い順）

#### 1. 機能的凝集（Functional Cohesion）- 最も強い
**定義**: モジュールの全要素が単一の明確に定義された機能を実現する。

**特徴**:
- 単一責任原則に従う
- メソッドが1つの目的のために協力
- 高い再利用性

**評価**: 理想的（目指すべき凝集度）

**例**:
```csharp
// 良い例: 機能的凝集
public class PasswordValidator {
    private const int MinLength = 8;
    private const string SpecialChars = "!@#$%^&*";

    public bool IsValid(string password) {
        return HasMinimumLength(password) &&
               ContainsUpperCase(password) &&
               ContainsLowerCase(password) &&
               ContainsDigit(password) &&
               ContainsSpecialChar(password);
    }

    private bool HasMinimumLength(string password) {
        return password.Length >= MinLength;
    }

    private bool ContainsUpperCase(string password) {
        return password.Any(char.IsUpper);
    }

    private bool ContainsLowerCase(string password) {
        return password.Any(char.IsLower);
    }

    private bool ContainsDigit(string password) {
        return password.Any(char.IsDigit);
    }

    private bool ContainsSpecialChar(string password) {
        return password.Any(c => SpecialChars.Contains(c));
    }
}
```

---

#### 2. 順次的凝集（Sequential Cohesion）
**定義**: 出力が次の処理の入力となる一連の処理。

**特徴**:
- データフローが明確
- パイプライン処理
- 処理順序が重要

**評価**: 良好

**例**:
```python
class DataProcessor:
    def process(self, raw_data):
        # 順次処理
        cleaned = self.clean_data(raw_data)
        validated = self.validate_data(cleaned)
        transformed = self.transform_data(validated)
        return transformed

    def clean_data(self, data):
        # クリーニング処理
        return data.strip()

    def validate_data(self, data):
        # バリデーション処理
        if not data:
            raise ValueError("Empty data")
        return data

    def transform_data(self, data):
        # 変換処理
        return data.upper()
```

---

#### 3. 情報的凝集（Informational Cohesion）
**定義**: 同じデータ構造を操作する複数の機能をグループ化。

**特徴**:
- 同じデータを扱う
- 複数の独立した機能
- クラスの基本パターン

**評価**: 良好

**例**:
```java
// 良い例: 同じデータ（Order）を扱う関連機能
public class OrderService {
    private OrderRepository repository;

    public Order create(OrderData data) {
        Order order = new Order(data);
        return repository.save(order);
    }

    public Order findById(String id) {
        return repository.findById(id);
    }

    public void cancel(String id) {
        Order order = repository.findById(id);
        order.cancel();
        repository.save(order);
    }

    public List<Order> findByCustomer(String customerId) {
        return repository.findByCustomerId(customerId);
    }
}
```

---

#### 4. 手続き的凝集（Procedural Cohesion）
**定義**: 特定の順序で実行される処理をグループ化。

**特徴**:
- 実行順序が決まっている
- データの関連性は弱い
- 制御フローで結びついている

**評価**: 許容可能（改善の余地あり）

**例**:
```ruby
# 手続き的凝集
class UserRegistration
  def register(user_data)
    validate_input(user_data)
    create_user(user_data)
    send_welcome_email(user_data[:email])
    log_registration(user_data[:email])
  end

  private

  def validate_input(data)
    # バリデーション
  end

  def create_user(data)
    # ユーザー作成
  end

  def send_welcome_email(email)
    # メール送信
  end

  def log_registration(email)
    # ログ記録
  end
end

# 改善: 機能的凝集に分離
class UserRegistrationService
  def initialize(validator, user_repo, email_service, logger)
    @validator = validator
    @user_repo = user_repo
    @email_service = email_service
    @logger = logger
  end

  def register(user_data)
    @validator.validate(user_data)
    user = @user_repo.create(user_data)
    @email_service.send_welcome(user.email)
    @logger.log_registration(user.email)
    user
  end
end
```

---

#### 5. 時間的凝集（Temporal Cohesion）
**定義**: 特定のタイミングで実行される処理をグループ化。

**特徴**:
- 初期化処理
- クリーンアップ処理
- 関連性は時間のみ

**評価**: 避けるべき（改善推奨）

**例**:
```javascript
// 悪い例: 時間的凝集
class SystemInitializer {
  initialize() {
    this.connectDatabase();
    this.loadConfiguration();
    this.startWebServer();
    this.initializeCache();
    this.registerEventHandlers();
  }
}

// 良い例: 責任ごとに分離
class DatabaseInitializer {
  initialize() {
    this.connectDatabase();
  }
}

class ConfigurationLoader {
  load() {
    this.loadConfiguration();
  }
}

class WebServerStarter {
  start() {
    this.startWebServer();
  }
}

// コーディネーター
class ApplicationBootstrapper {
  constructor(dbInit, configLoader, serverStarter, cacheInit, eventRegistry) {
    this.dbInit = dbInit;
    this.configLoader = configLoader;
    this.serverStarter = serverStarter;
    this.cacheInit = cacheInit;
    this.eventRegistry = eventRegistry;
  }

  bootstrap() {
    this.dbInit.initialize();
    this.configLoader.load();
    this.serverStarter.start();
    this.cacheInit.initialize();
    this.eventRegistry.register();
  }
}
```

---

#### 6. 論理的凝集（Logical Cohesion）
**定義**: 論理的に似ているが関連性のない処理をグループ化。

**特徴**:
- スイッチ文で処理を選択
- 関数名に「or」や「and」
- ユーティリティクラスの兆候

**評価**: 避けるべき

**例**:
```go
// 悪い例: 論理的凝集
type DataHandler struct{}

func (h *DataHandler) Handle(data interface{}, mode string) interface{} {
    switch mode {
    case "save":
        return h.save(data)
    case "load":
        return h.load(data)
    case "delete":
        return h.delete(data)
    case "validate":
        return h.validate(data)
    }
    return nil
}

// 良い例: 別々のハンドラーに分離
type DataSaver struct{}
func (s *DataSaver) Save(data interface{}) error { /* ... */ }

type DataLoader struct{}
func (l *DataLoader) Load(id string) (interface{}, error) { /* ... */ }

type DataDeleter struct{}
func (d *DataDeleter) Delete(id string) error { /* ... */ }

type DataValidator struct{}
func (v *DataValidator) Validate(data interface{}) error { /* ... */ }
```

---

#### 7. 偶発的凝集（Coincidental Cohesion）- 最も弱い
**定義**: 関連性のない要素が偶然グループ化されている。

**特徴**:
- ユーティリティクラス
- ヘルパークラス
- 共通のテーマがない

**評価**: 絶対に避けるべき

**例**:
```python
# 悪い例: 偶発的凝集
class Utilities:
    @staticmethod
    def format_date(date):
        pass

    @staticmethod
    def send_email(to, subject, body):
        pass

    @staticmethod
    def calculate_tax(amount):
        pass

    @staticmethod
    def validate_password(password):
        pass

# 良い例: 責任ごとに分離
class DateFormatter:
    @staticmethod
    def format(date):
        pass

class EmailSender:
    def send(self, to, subject, body):
        pass

class TaxCalculator:
    @staticmethod
    def calculate(amount):
        pass

class PasswordValidator:
    @staticmethod
    def validate(password):
        pass
```

---

### 凝集度の測定方法

**LCOM (Lack of Cohesion of Methods)**:
クラスのメソッド間でフィールドがどれだけ共有されているかを測定。

```
LCOM = 1 - (sum(MF) / (M * F))

M: メソッド数
F: フィールド数
MF: 各メソッドが使用するフィールド数の合計
```

**判定基準**:
- LCOM < 0.3: 高凝集（優秀）
- 0.3 ≤ LCOM < 0.5: 中凝集（許容可能）
- 0.5 ≤ LCOM < 0.7: 低凝集（改善推奨）
- LCOM ≥ 0.7: 非常に低凝集（要分割）

---

## 循環的複雑度（Cyclomatic Complexity）

制御フローの複雑さを測定する指標。独立した実行パスの数を表します。

### 計算方法

```
CC = E - N + 2P

E: エッジ数（制御フローグラフの辺）
N: ノード数（制御フローグラフの節点）
P: 連結成分数（通常は1）
```

**簡易計算**:
```
CC = 判定ポイント数 + 1

判定ポイント: if, while, for, case, &&, ||, ?:
```

### 評価基準

| CC値 | 評価 | リスク | 推奨アクション |
|------|------|--------|----------------|
| 1-10 | 低複雑度 | 低 | 問題なし |
| 11-20 | 中複雑度 | 中 | レビュー推奨 |
| 21-50 | 高複雑度 | 高 | リファクタリング推奨 |
| 51+ | 極めて高い | 極めて高い | 即座にリファクタリング |

### 例

```typescript
// CC = 8（高複雑度）
function processOrder(order: Order): boolean {
  if (!order) return false;  // +1

  if (order.items.length === 0) return false;  // +1

  for (const item of order.items) {  // +1
    if (item.quantity <= 0) return false;  // +1

    if (item.price < 0) return false;  // +1
  }

  if (order.total < 100 && order.shippingMethod === 'express') {  // +2 (&&)
    return false;
  }

  return true;  // base = 1
}
// CC = 1 + 1 + 1 + 1 + 1 + 1 + 2 = 8

// リファクタリング後: CC = 2
function processOrder(order: Order): boolean {
  if (!isValidOrder(order)) return false;  // +1
  if (!hasValidItems(order.items)) return false;  // +1
  if (!isValidShipping(order)) return false;  // base = 1
  return true;
}

// 各関数はCC = 3-4程度に抑えられる
```

---

## 認知的複雑度（Cognitive Complexity）

コードの理解しやすさを測定する指標。人間がコードを読むときの精神的負荷を表します。

### 循環的複雑度との違い

循環的複雑度は機械的な測定ですが、認知的複雑度は人間の理解の難しさに焦点を当てます。

### 計算方法

以下の構造に対してペナルティを加算:

1. **+1**: 制御フロー構造（if, else if, switch, for, while, catch）
2. **+1**: ネストごと（ネストが深いほど増加）
3. **+1**: 論理演算子の連鎖（&&, ||）
4. **+0**: else（elseは複雑度を増やさない）

### 評価基準

| 値 | 評価 | 推奨アクション |
|----|------|----------------|
| 0-5 | 低 | 問題なし |
| 6-10 | 中 | レビュー推奨 |
| 11-15 | 高 | リファクタリング推奨 |
| 16+ | 極めて高い | 即座にリファクタリング |

### 例

```java
// 認知的複雑度 = 8
public boolean checkEligibility(User user) {
    if (user != null) {  // +1
        if (user.getAge() >= 18) {  // +2 (ネスト+1)
            if (user.hasValidId()) {  // +3 (ネスト+1)
                return true;
            }
        } else if (user.hasParentalConsent()) {  // +2 (ネスト+1)
            return true;
        }
    }
    return false;
}
// 合計: 1 + 2 + 3 + 2 = 8

// リファクタリング後: 認知的複雑度 = 3
public boolean checkEligibility(User user) {
    if (user == null) return false;  // +1 (早期リターン)

    if (isAdultWithId(user)) return true;  // +1
    if (isMinorWithConsent(user)) return true;  // +1

    return false;
}

private boolean isAdultWithId(User user) {
    return user.getAge() >= 18 && user.hasValidId();
}

private boolean isMinorWithConsent(User user) {
    return user.getAge() < 18 && user.hasParentalConsent();
}
```

---

## その他の有用なメトリクス

### ネストの深さ（Nesting Depth）

**定義**: 制御構造のネストの最大深さ。

**推奨値**:
- 最大3階層まで
- 4階層以上は要リファクタリング

**改善方法**:
- 早期リターン
- メソッド抽出
- Guard Clauses

---

### 行数（Lines of Code）

**LOC (Lines of Code)**:
- 関数: 20-50行が理想
- クラス: 200-500行が理想
- ファイル: 500行以下が理想

**SLOC (Source Lines of Code)**:
- コメントと空行を除く

---

### コメント密度

**計算**:
```
コメント密度 = (コメント行数 / SLOC) * 100
```

**推奨値**:
- 10-30%が理想
- 0%: コメント不足
- 50%以上: コードが複雑すぎる可能性

---

## メトリクスの総合評価

### コード品質スコア（0-100）

```
品質スコア = 40 * (1 - 結合度正規化) +
             30 * 凝集度正規化 +
             20 * (1 - CC正規化) +
             10 * (1 - 認知的複雑度正規化)
```

**評価基準**:
- 80-100: 優秀
- 60-79: 良好
- 40-59: 改善推奨
- 0-39: 要改善
