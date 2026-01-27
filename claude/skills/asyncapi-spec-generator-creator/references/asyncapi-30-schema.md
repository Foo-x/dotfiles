# AsyncAPI 3.0 スキーマリファレンス

## AsyncAPI 3.0 基本構造

### 必須フィールド

```yaml
asyncapi: 3.0.0  # 必須
info:            # 必須
  title: string
  version: string
  description: string (任意)
channels:        # 必須 (空オブジェクト可)
  <channelId>: Channel Object
operations:      # 必須 (空オブジェクト可)
  <operationId>: Operation Object
```

### ルートレベルオブジェクト

| フィールド | 型 | 必須 | 説明 |
|-----------|-----|------|------|
| `asyncapi` | string | ✓ | AsyncAPIバージョン（"3.0.0"） |
| `info` | Info Object | ✓ | API情報 |
| `servers` | Map[string, Server Object] | - | サーバー定義 |
| `channels` | Map[string, Channel Object] | ✓ | チャネル定義 |
| `operations` | Map[string, Operation Object] | ✓ | オペレーション定義 |
| `components` | Components Object | - | 再利用可能コンポーネント |

### Info Object

```yaml
info:
  title: Order Processing Service
  version: 1.0.0
  description: Handles order lifecycle events
```

**除外フィールド（スキル生成時）:**
- `contact`
- `license`

### Servers Object

```yaml
servers:
  production:
    host: kafka.example.com:9092
    protocol: kafka
    description: Production Kafka cluster
  staging:
    host: rabbitmq.staging.example.com
    protocol: amqp
    description: Staging RabbitMQ broker
```

### Channels Object

```yaml
channels:
  orderCreated:
    address: orders.created
    messages:
      orderCreatedMessage:
        $ref: '#/components/messages/OrderCreated'
  orderUpdated:
    address: orders.updated
    messages:
      orderUpdatedMessage:
        payload:
          type: object
          properties:
            orderId:
              type: string
            status:
              type: string
```

### Operations Object

```yaml
operations:
  publishOrderCreated:
    action: send
    channel:
      $ref: '#/channels/orderCreated'
    summary: Publish order created event

  subscribeOrderUpdated:
    action: receive
    channel:
      $ref: '#/channels/orderUpdated'
    summary: Subscribe to order update events
```

### Messages Object

```yaml
components:
  messages:
    OrderCreated:
      contentType: application/json
      payload:
        type: object
        required:
          - orderId
          - customerId
          - amount
        properties:
          orderId:
            type: string
            format: uuid
          customerId:
            type: string
          amount:
            type: number
            format: double
          timestamp:
            type: string
            format: date-time
```

---

## フレームワーク別検出パターン

### JavaScript/TypeScript

#### NestJS (@nestjs/microservices)

**検出パターン:**
```typescript
// イベントパターン
@EventPattern('order.created')
handleOrderCreated(@Payload() data: OrderDto) {}

// メッセージパターン
@MessagePattern('get.order')
getOrder(@Payload() data: GetOrderDto) {}

// Kafkaデコレーター
@MessagePattern('order.created', Transport.KAFKA)
handleKafkaEvent(@Payload() message: KafkaMessage) {}
```

**AsyncAPI変換:**
```yaml
channels:
  orderCreated:
    address: order.created
operations:
  handleOrderCreated:
    action: receive
    channel:
      $ref: '#/channels/orderCreated'
```

#### Bull (Redis Queue)

**検出パターン:**
```typescript
@Process('order-processing')
async processOrder(job: Job<OrderData>) {}

@OnQueueCompleted()
onCompleted(job: Job) {}
```

**AsyncAPI変換:**
```yaml
channels:
  orderProcessing:
    address: order-processing
    bindings:
      redis:
        method: rpush
```

#### Moleculer

**検出パターン:**
```typescript
actions: {
  'orders.create': {
    handler(ctx) {
      return this.createOrder(ctx.params);
    }
  }
}

events: {
  'order.created': {
    handler(payload) {
      this.logger.info('Order created', payload);
    }
  }
}
```

**AsyncAPI変換:**
```yaml
operations:
  ordersCreate:
    action: receive
    channel:
      $ref: '#/channels/ordersCreate'

  subscribeOrderCreated:
    action: receive
    channel:
      $ref: '#/channels/orderCreated'
```

### Python

#### Celery

**検出パターン:**
```python
@app.task
def process_order(order_id):
    pass

@app.task(bind=True, name='orders.send_notification')
def send_order_notification(self, order_id):
    pass
```

**AsyncAPI変換:**
```yaml
channels:
  processOrder:
    address: celery.process_order
  ordersSendNotification:
    address: orders.send_notification
```

#### Faust (Kafka Streams)

**検出パターン:**
```python
@app.agent(orders_topic)
async def process_order(orders):
    async for order in orders:
        await process(order)

@app.command()
async def send_order(order_id: str):
    await orders_topic.send(value={'id': order_id})
```

**AsyncAPI変換:**
```yaml
servers:
  kafka:
    protocol: kafka
channels:
  orders:
    address: orders_topic
operations:
  processOrder:
    action: receive
  sendOrder:
    action: send
```

#### FastStream

**検出パターン:**
```python
@broker.subscriber("orders")
async def handle_order(msg: Order):
    pass

@broker.publisher("order-notifications")
async def send_notification(order_id: str):
    pass
```

**AsyncAPI変換:**
```yaml
channels:
  orders:
    address: orders
  orderNotifications:
    address: order-notifications
operations:
  handleOrder:
    action: receive
  sendNotification:
    action: send
```

### Java

#### Spring Cloud Stream

**検出パターン:**
```java
@StreamListener(Sink.INPUT)
public void handleOrder(Order order) {}

@SendTo(Source.OUTPUT)
public OrderConfirmation processOrder(Order order) {}

@Bean
public Consumer<Order> orderProcessor() {
    return order -> process(order);
}
```

**AsyncAPI変換:**
```yaml
channels:
  input:
    address: ${spring.cloud.stream.bindings.input.destination}
  output:
    address: ${spring.cloud.stream.bindings.output.destination}
```

#### Kafka Streams

**検出パターン:**
```java
builder.stream("orders")
    .filter((key, value) -> value.getAmount() > 100)
    .to("high-value-orders");

builder.table("customers", Materialized.as("customer-store"));
```

**AsyncAPI変換:**
```yaml
channels:
  orders:
    address: orders
  highValueOrders:
    address: high-value-orders
operations:
  processOrders:
    action: receive
    channel:
      $ref: '#/channels/orders'
  publishHighValueOrders:
    action: send
    channel:
      $ref: '#/channels/highValueOrders'
```

### Go

#### go-nats

**検出パターン:**
```go
nc.Subscribe("orders.created", func(m *nats.Msg) {
    // handle message
})

nc.QueueSubscribe("orders.process", "workers", func(m *nats.Msg) {
    // handle message
})
```

**AsyncAPI変換:**
```yaml
servers:
  nats:
    protocol: nats
channels:
  ordersCreated:
    address: orders.created
  ordersProcess:
    address: orders.process
```

#### sarama (Kafka)

**検出パターン:**
```go
func (h *Handler) Setup(sarama.ConsumerGroupSession) error {
    return nil
}

func (h *Handler) ConsumeClaim(session sarama.ConsumerGroupSession, claim sarama.ConsumerGroupClaim) error {
    for message := range claim.Messages() {
        // process message
    }
}
```

**AsyncAPI変換:**
```yaml
servers:
  kafka:
    protocol: kafka
operations:
  consumeOrders:
    action: receive
    bindings:
      kafka:
        groupId: order-consumer-group
```

#### watermill

**検出パターン:**
```go
messages, err := subscriber.Subscribe(ctx, "orders")
router.AddHandler("order.created", "orders", subscriber, "orders.processed", publisher,
    func(msg *message.Message) ([]*message.Message, error) {
        return []*message.Message{msg}, nil
    },
)
```

**AsyncAPI変換:**
```yaml
channels:
  orders:
    address: orders
  ordersProcessed:
    address: orders.processed
```

### Ruby

#### Sidekiq

**検出パターン:**
```ruby
class OrderProcessorWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'orders', retry: 5

  def perform(order_id)
    # process order
  end
end
```

**AsyncAPI変換:**
```yaml
channels:
  orders:
    address: orders
    bindings:
      redis:
        queue: orders
operations:
  processOrder:
    action: receive
```

#### Karafka (Kafka)

**検出パターン:**
```ruby
class OrdersConsumer < ApplicationConsumer
  def consume
    messages.each do |message|
      # process message
    end
  end
end
```

**AsyncAPI変換:**
```yaml
servers:
  kafka:
    protocol: kafka
channels:
  orders:
    address: orders_topic
```

#### lapin (AMQP)

**検出パターン:**
```ruby
channel.queue('orders', durable: true)
channel.default_exchange.publish(message, routing_key: 'orders.created')

queue.subscribe do |delivery_info, metadata, payload|
  # handle message
end
```

**AsyncAPI変換:**
```yaml
servers:
  rabbitmq:
    protocol: amqp
channels:
  orders:
    address: orders
  ordersCreated:
    address: orders.created
```

---

## プロトコル別バインディング

### Kafka

```yaml
servers:
  production:
    host: kafka.example.com:9092
    protocol: kafka
    bindings:
      kafka:
        schemaRegistryUrl: http://schema-registry:8081

channels:
  orders:
    address: orders.v1
    bindings:
      kafka:
        topic: orders.v1
        partitions: 10
        replicas: 3

operations:
  publishOrder:
    bindings:
      kafka:
        groupId: order-processor
        clientId: order-service
```

### AMQP (RabbitMQ)

```yaml
servers:
  rabbitmq:
    host: rabbitmq.example.com
    protocol: amqp
    bindings:
      amqp:
        exchange: orders
        vhost: /production

channels:
  orderCreated:
    address: order.created
    bindings:
      amqp:
        is: routingKey
        exchange:
          name: orders
          type: topic
          durable: true
          autoDelete: false
        queue:
          name: order-processing-queue
          durable: true
          exclusive: false
```

### MQTT

```yaml
servers:
  mqtt:
    host: mqtt.example.com:1883
    protocol: mqtt
    bindings:
      mqtt:
        clientId: order-service
        cleanSession: true

channels:
  sensors:
    address: sensors/temperature/{sensorId}
    bindings:
      mqtt:
        qos: 1
        retain: true
```

### WebSocket

```yaml
servers:
  websocket:
    host: ws.example.com
    protocol: ws
    bindings:
      ws:
        method: GET
        headers:
          type: object
          properties:
            Authorization:
              type: string

channels:
  orderUpdates:
    address: /orders/{orderId}/updates
    bindings:
      ws:
        method: GET
        query:
          type: object
          properties:
            token:
              type: string
```

### NATS

```yaml
servers:
  nats:
    host: nats.example.com:4222
    protocol: nats
    bindings:
      nats:
        clientId: order-service

channels:
  orders:
    address: orders.created
    bindings:
      nats:
        queue: order-workers

operations:
  subscribeOrders:
    bindings:
      nats:
        queue: order-workers
        deliverPolicy: all
```

---

## メッセージパターン

### Publish/Subscribe

```yaml
operations:
  publishOrderCreated:
    action: send
    channel:
      $ref: '#/channels/orderCreated'
    summary: Publish order created event to all subscribers

  subscribeOrderCreated:
    action: receive
    channel:
      $ref: '#/channels/orderCreated'
    summary: Receive order created events
```

### Request-Reply

```yaml
channels:
  orderRequest:
    address: orders.request
  orderReply:
    address: orders.reply

operations:
  requestOrder:
    action: send
    channel:
      $ref: '#/channels/orderRequest'
    reply:
      channel:
        $ref: '#/channels/orderReply'

  replyOrder:
    action: receive
    channel:
      $ref: '#/channels/orderRequest'
```

### Event Notification

```yaml
components:
  messages:
    OrderStatusChanged:
      summary: Lightweight notification of order status change
      payload:
        type: object
        required:
          - orderId
          - status
          - timestamp
        properties:
          orderId:
            type: string
          status:
            type: string
            enum: [pending, confirmed, shipped, delivered]
          timestamp:
            type: string
            format: date-time
```

### Event-Carried State Transfer

```yaml
components:
  messages:
    OrderSnapshot:
      summary: Complete order state snapshot
      payload:
        type: object
        required:
          - orderId
          - customerId
          - items
          - totalAmount
          - status
        properties:
          orderId:
            type: string
          customerId:
            type: string
          items:
            type: array
            items:
              type: object
              properties:
                productId:
                  type: string
                quantity:
                  type: integer
                price:
                  type: number
          totalAmount:
            type: number
          status:
            type: string
          shippingAddress:
            type: object
          billingAddress:
            type: object
```

---

## 型マッピング（プログラミング言語 → JSON Schema）

### TypeScript/JavaScript

| TypeScript型 | JSON Schema |
|-------------|-------------|
| `string` | `type: string` |
| `number` | `type: number` |
| `boolean` | `type: boolean` |
| `Date` | `type: string, format: date-time` |
| `string[]` | `type: array, items: {type: string}` |
| `enum Status { PENDING, ACTIVE }` | `type: string, enum: [PENDING, ACTIVE]` |
| `interface { name: string }` | `type: object, properties: {name: {type: string}}` |
| `string \| null` | `type: string, nullable: true` |
| `UUID` | `type: string, format: uuid` |

### Python

| Python型 | JSON Schema |
|----------|-------------|
| `str` | `type: string` |
| `int` | `type: integer` |
| `float` | `type: number` |
| `bool` | `type: boolean` |
| `datetime` | `type: string, format: date-time` |
| `List[str]` | `type: array, items: {type: string}` |
| `Enum` | `type: string, enum: [...]` |
| `Dict[str, Any]` | `type: object` |
| `Optional[str]` | `type: string, nullable: true` |
| `UUID` | `type: string, format: uuid` |
| `Decimal` | `type: string, format: decimal` |

### Java

| Java型 | JSON Schema |
|--------|-------------|
| `String` | `type: string` |
| `Integer`, `int` | `type: integer` |
| `Double`, `double` | `type: number` |
| `Boolean`, `boolean` | `type: boolean` |
| `LocalDateTime` | `type: string, format: date-time` |
| `List<String>` | `type: array, items: {type: string}` |
| `enum Status {}` | `type: string, enum: [...]` |
| `Map<String, Object>` | `type: object` |
| `UUID` | `type: string, format: uuid` |
| `BigDecimal` | `type: string, format: decimal` |

### Go

| Go型 | JSON Schema |
|------|-------------|
| `string` | `type: string` |
| `int`, `int64` | `type: integer` |
| `float64` | `type: number` |
| `bool` | `type: boolean` |
| `time.Time` | `type: string, format: date-time` |
| `[]string` | `type: array, items: {type: string}` |
| `map[string]interface{}` | `type: object` |
| `*string` | `type: string, nullable: true` |
| `uuid.UUID` | `type: string, format: uuid` |

---

## ベストプラクティス

### operationId命名規則

| アクション | 命名パターン | 例 |
|-----------|-------------|-----|
| Send/Publish | `publish<EventName>` | `publishOrderCreated` |
| Receive/Subscribe | `subscribe<EventName>` | `subscribeOrderUpdated` |
| Request | `request<ResourceName>` | `requestOrderDetails` |
| Reply | `reply<ResourceName>` | `replyOrderDetails` |

### チャネルアドレス命名規則

| パターン | 形式 | 例 |
|---------|------|-----|
| ドット区切り | `<domain>.<entity>.<event>` | `orders.order.created` |
| スラッシュ区切り | `<domain>/<entity>/<event>` | `orders/order/created` |
| ケバブケース | `<domain>-<entity>-<event>` | `orders-order-created` |

**推奨:** プロトコルに応じて選択
- Kafka/AMQP: ドット区切り
- MQTT: スラッシュ区切り
- Redis: コロン区切り

### Traits活用

```yaml
components:
  messageTraits:
    commonHeaders:
      headers:
        type: object
        properties:
          correlation-id:
            type: string
            format: uuid
          timestamp:
            type: string
            format: date-time

  operationTraits:
    kafka:
      bindings:
        kafka:
          groupId: ${spring.application.name}

messages:
  OrderCreated:
    traits:
      - $ref: '#/components/messageTraits/commonHeaders'
    payload:
      # ...

operations:
  subscribeOrders:
    traits:
      - $ref: '#/components/operationTraits/kafka'
```

### バージョニング戦略

#### チャネルアドレスにバージョン含める

```yaml
channels:
  ordersV1:
    address: orders.v1
  ordersV2:
    address: orders.v2
```

#### メッセージにバージョンフィールド

```yaml
components:
  messages:
    Order:
      payload:
        properties:
          schemaVersion:
            type: string
            const: "1.0.0"
```

### エラーハンドリング

```yaml
channels:
  orders:
    address: orders
  ordersDlq:
    address: orders.dlq
    description: Dead letter queue for failed order processing

operations:
  subscribeOrders:
    action: receive
    channel:
      $ref: '#/channels/orders'
    description: |
      Process orders. Failed messages are sent to DLQ after 3 retries.
    bindings:
      kafka:
        groupId: order-processor
        # DLQ設定はアプリケーション層で実装
```

---

## バリデーションチェックリスト

生成したAsyncAPI仕様書は以下の項目を確認してください:

### 必須フィールド

- [ ] `asyncapi: 3.0.0`が設定されている
- [ ] `info.title`と`info.version`が存在する
- [ ] 少なくとも1つの`channels`が定義されている
- [ ] 少なくとも1つの`operations`が定義されている

### チャネル定義

- [ ] 全チャネルに`address`が設定されている
- [ ] チャネルアドレスがプロトコルの命名規則に従っている
- [ ] 各チャネルに少なくとも1つの`messages`が関連付けられている

### オペレーション定義

- [ ] 全オペレーションに`action` (send/receive)が設定されている
- [ ] 全オペレーションが有効な`channel`を参照している
- [ ] operationIdがユニークで命名規則に従っている

### メッセージスキーマ

- [ ] ペイロードに`type`が指定されている
- [ ] 必須フィールドが`required`配列で宣言されている
- [ ] 適切な型マッピングが行われている
- [ ] 列挙型が`enum`で定義されている

### プロトコルバインディング

- [ ] サーバーに適切な`protocol`が設定されている
- [ ] プロトコル固有のバインディングが正しく設定されている
- [ ] Kafkaの場合、`groupId`が設定されている

### ベストプラクティス

- [ ] 複雑なメッセージスキーマが`components`で再利用されている
- [ ] 共通ヘッダーがTraitsで定義されている
- [ ] バージョニング戦略が実装されている
- [ ] エラーハンドリング戦略が文書化されている

---

## サンプル: 完全なAsyncAPI仕様書

```yaml
asyncapi: 3.0.0

info:
  title: Order Processing Service
  version: 1.0.0
  description: Manages order lifecycle events across the e-commerce platform

servers:
  production:
    host: kafka.example.com:9092
    protocol: kafka
    description: Production Kafka cluster
    bindings:
      kafka:
        schemaRegistryUrl: http://schema-registry:8081

channels:
  orderCreated:
    address: orders.created.v1
    messages:
      orderCreatedMessage:
        $ref: '#/components/messages/OrderCreated'
    bindings:
      kafka:
        topic: orders.created.v1
        partitions: 10
        replicas: 3

  orderStatusChanged:
    address: orders.status.changed.v1
    messages:
      orderStatusChangedMessage:
        $ref: '#/components/messages/OrderStatusChanged'

operations:
  publishOrderCreated:
    action: send
    channel:
      $ref: '#/channels/orderCreated'
    summary: Publish order created event when new order is placed
    traits:
      - $ref: '#/components/operationTraits/kafka'

  subscribeOrderCreated:
    action: receive
    channel:
      $ref: '#/channels/orderCreated'
    summary: Subscribe to order created events for processing
    bindings:
      kafka:
        groupId: order-processor

  publishOrderStatusChanged:
    action: send
    channel:
      $ref: '#/channels/orderStatusChanged'
    summary: Publish order status change events

  subscribeOrderStatusChanged:
    action: receive
    channel:
      $ref: '#/channels/orderStatusChanged'
    summary: Subscribe to order status changes for notifications
    bindings:
      kafka:
        groupId: notification-service

components:
  messages:
    OrderCreated:
      contentType: application/json
      traits:
        - $ref: '#/components/messageTraits/commonHeaders'
      payload:
        type: object
        required:
          - orderId
          - customerId
          - items
          - totalAmount
        properties:
          orderId:
            type: string
            format: uuid
            description: Unique order identifier
          customerId:
            type: string
            format: uuid
            description: Customer who placed the order
          items:
            type: array
            items:
              type: object
              required:
                - productId
                - quantity
                - price
              properties:
                productId:
                  type: string
                  format: uuid
                quantity:
                  type: integer
                  minimum: 1
                price:
                  type: number
                  format: double
                  minimum: 0
          totalAmount:
            type: number
            format: double
            minimum: 0
            description: Total order amount in USD
          timestamp:
            type: string
            format: date-time
            description: Order creation timestamp

    OrderStatusChanged:
      contentType: application/json
      traits:
        - $ref: '#/components/messageTraits/commonHeaders'
      payload:
        type: object
        required:
          - orderId
          - previousStatus
          - newStatus
          - timestamp
        properties:
          orderId:
            type: string
            format: uuid
          previousStatus:
            type: string
            enum: [pending, confirmed, shipped, delivered, cancelled]
          newStatus:
            type: string
            enum: [pending, confirmed, shipped, delivered, cancelled]
          timestamp:
            type: string
            format: date-time
          reason:
            type: string
            description: Optional reason for status change

  messageTraits:
    commonHeaders:
      headers:
        type: object
        required:
          - correlation-id
        properties:
          correlation-id:
            type: string
            format: uuid
            description: Correlation ID for distributed tracing
          causation-id:
            type: string
            format: uuid
            description: ID of the event that caused this event

  operationTraits:
    kafka:
      bindings:
        kafka:
          clientId: order-service
```

---

## 追加リソース

### 公式ドキュメント

- [AsyncAPI Specification 3.0.0](https://www.asyncapi.com/docs/reference/specification/v3.0.0)
- [AsyncAPI Studio](https://studio.asyncapi.com/) - オンラインエディター
- [AsyncAPI Generator](https://github.com/asyncapi/generator) - コード生成ツール

### ツール

- **AsyncAPI CLI**: `npm install -g @asyncapi/cli`
- **バリデーション**: `asyncapi validate <spec-file>`
- **HTML生成**: `asyncapi generate fromTemplate <spec-file> @asyncapi/html-template`

### ベストプラクティス参考資料

- [Event-Driven Architecture Patterns](https://www.enterpriseintegrationpatterns.com/patterns/messaging/)
- [CloudEvents Specification](https://cloudevents.io/)
- [Kafka Best Practices](https://kafka.apache.org/documentation/#design)
