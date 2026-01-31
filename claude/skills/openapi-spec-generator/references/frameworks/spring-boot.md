# Spring Boot (Java) パターン

## フレームワーク検出

### 検出条件

1. `pom.xml` に `spring-boot-starter-web` の依存関係
2. `build.gradle` に `spring-boot-starter-web` の依存関係
3. `@RestController`, `@Controller` アノテーション

### 検出用 Grep パターン

```bash
Grep: "spring-boot-starter-web" in pom.xml, build.gradle
Grep: "@(RestController|Controller|RequestMapping)" in "*.java"
```

## ルーティング定義パターン

### 1. @RestController と @RequestMapping

```java
@RestController
@RequestMapping("/api/users")
public class UserController {

    @GetMapping
    public List<User> getUsers() {
        return userService.findAll();
    }

    @GetMapping("/{id}")
    public User getUser(@PathVariable Long id) {
        return userService.findById(id);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public User createUser(@RequestBody UserCreateRequest request) {
        return userService.create(request);
    }

    @PutMapping("/{id}")
    public User updateUser(@PathVariable Long id, @RequestBody UserUpdateRequest request) {
        return userService.update(id, request);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteUser(@PathVariable Long id) {
        userService.delete(id);
    }
}
```

**Grep パターン:**
```
pattern: "@(GetMapping|PostMapping|PutMapping|PatchMapping|DeleteMapping|RequestMapping)\\s*\\(\\s*\"([^\"]*)\""
pattern: "@(GetMapping|PostMapping|PutMapping|PatchMapping|DeleteMapping)\\s*$"
pattern: "@RequestMapping\\s*\\([^)]*value\\s*=\\s*\"([^\"]+)\""
```

### 2. コントローラーファイルの典型的な場所

```
src/main/java/com/example/app/
├── controller/
│   ├── UserController.java
│   ├── PostController.java
│   └── AuthController.java
├── api/
│   └── v1/
│       ├── UserApiController.java
│       └── PostApiController.java
```

**Glob パターン:**
```
src/main/java/**/controller/**/*.java
src/main/java/**/api/**/*.java
```

## パラメータ抽出

### 1. パスパラメータ (@PathVariable)

```java
@GetMapping("/{id}")
public User getUser(@PathVariable Long id) {
    return userService.findById(id);
}

@GetMapping("/posts/{postId}/comments/{commentId}")
public Comment getComment(
    @PathVariable Long postId,
    @PathVariable Long commentId
) {
    return commentService.find(postId, commentId);
}

// 名前指定
@GetMapping("/{userId}")
public User getUser(@PathVariable("userId") Long id) {
    return userService.findById(id);
}
```

### 2. クエリパラメータ (@RequestParam)

```java
@GetMapping
public Page<User> getUsers(
    @RequestParam(defaultValue = "0") int page,
    @RequestParam(defaultValue = "20") int size,
    @RequestParam(required = false) String search
) {
    return userService.findAll(page, size, search);
}

// バリデーション付き
@GetMapping
public List<User> getUsers(
    @RequestParam @Min(1) @Max(100) int limit
) {
    return userService.findAll(limit);
}
```

### 3. リクエストボディ (@RequestBody)

```java
@PostMapping
public User createUser(@RequestBody @Valid UserCreateRequest request) {
    return userService.create(request);
}

// ネストしたオブジェクト
@PostMapping("/batch")
public List<User> createUsers(@RequestBody @Valid List<UserCreateRequest> requests) {
    return userService.createBatch(requests);
}
```

### 4. ヘッダーパラメータ (@RequestHeader)

```java
@GetMapping
public List<User> getUsers(@RequestHeader("X-API-Key") String apiKey) {
    return userService.findAll();
}

@GetMapping
public ResponseEntity<?> getData(
    @RequestHeader(value = "Authorization", required = false) String auth
) {
    // 処理
}
```

## DTOとバリデーションからのスキーマ抽出

### 1. javax.validation / jakarta.validation

```java
import javax.validation.constraints.*;
import lombok.Data;

@Data
public class UserCreateRequest {

    @NotBlank
    @Size(min = 1, max = 100)
    private String name;

    @NotNull
    @Email
    private String email;

    @Min(0)
    @Max(150)
    private Integer age;

    @Pattern(regexp = "^[a-zA-Z0-9_]+$")
    private String username;

    @Size(min = 8, max = 100)
    private String password;
}

@Data
public class UserResponse {
    private Long id;
    private String name;
    private String email;
    private Integer age;

    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss")
    private LocalDateTime createdAt;
}
```

**Java型 → OpenAPI型マッピング:**

| Java型 | OpenAPI |
|-------|---------|
| `String` | `type: string` |
| `Integer`, `int`, `Long`, `long` | `type: integer` |
| `Float`, `float`, `Double`, `double` | `type: number` |
| `Boolean`, `boolean` | `type: boolean` |
| `LocalDate` | `type: string, format: date` |
| `LocalDateTime`, `ZonedDateTime` | `type: string, format: date-time` |
| `UUID` | `type: string, format: uuid` |
| `List<T>`, `Set<T>` | `type: array` |
| `Map<K,V>` | `type: object, additionalProperties: {...}` |

**バリデーションアノテーション → OpenAPI制約:**

| アノテーション | OpenAPI |
|-------------|---------|
| `@NotNull`, `@NotBlank` | `required` に追加 |
| `@Size(min=1, max=100)` | `minLength: 1, maxLength: 100` |
| `@Min(0)`, `@Max(150)` | `minimum: 0, maximum: 150` |
| `@Email` | `format: email` |
| `@Pattern(regexp="...")` | `pattern: "..."` |
| `@Positive` | `minimum: 1` |
| `@PositiveOrZero` | `minimum: 0` |

### 2. Lombok

```java
@Data  // getter, setter, toString, equals, hashCode
@Builder  // ビルダーパターン
@NoArgsConstructor
@AllArgsConstructor
public class User {
    private Long id;
    private String name;
    private String email;
}
```

## レスポンススキーマ推定

### 1. 戻り値の型から推定

```java
// 単一オブジェクト
@GetMapping("/{id}")
public UserResponse getUser(@PathVariable Long id) {
    return userService.findById(id);
}

// リスト
@GetMapping
public List<UserResponse> getUsers() {
    return userService.findAll();
}

// Page
@GetMapping
public Page<UserResponse> getUsers(Pageable pageable) {
    return userService.findAll(pageable);
}

// ResponseEntity
@GetMapping("/{id}")
public ResponseEntity<UserResponse> getUser(@PathVariable Long id) {
    return ResponseEntity.ok(userService.findById(id));
}

// Optional
@GetMapping("/{id}")
public Optional<UserResponse> getUser(@PathVariable Long id) {
    return userService.findById(id);
}
```

### 2. @ResponseStatus

```java
@PostMapping
@ResponseStatus(HttpStatus.CREATED)  // 201
public User createUser(@RequestBody UserCreateRequest request) {
    return userService.create(request);
}

@DeleteMapping("/{id}")
@ResponseStatus(HttpStatus.NO_CONTENT)  // 204
public void deleteUser(@PathVariable Long id) {
    userService.delete(id);
}
```

### 3. ResponseEntity でのステータスコード

```java
@GetMapping("/{id}")
public ResponseEntity<UserResponse> getUser(@PathVariable Long id) {
    User user = userService.findById(id);
    if (user == null) {
        return ResponseEntity.notFound().build();  // 404
    }
    return ResponseEntity.ok(user);  // 200
}

@PostMapping
public ResponseEntity<UserResponse> createUser(@RequestBody UserCreateRequest request) {
    User user = userService.create(request);
    return ResponseEntity.status(HttpStatus.CREATED).body(user);  // 201
}
```

## 例外処理とエラーレスポンス

### @ControllerAdvice / @ExceptionHandler

```java
@ControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(ResourceNotFoundException.class)
    @ResponseStatus(HttpStatus.NOT_FOUND)
    public ErrorResponse handleNotFound(ResourceNotFoundException ex) {
        return new ErrorResponse(404, ex.getMessage());
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public ErrorResponse handleValidationError(MethodArgumentNotValidException ex) {
        return new ErrorResponse(400, "Validation failed", ex.getBindingResult());
    }

    @ExceptionHandler(Exception.class)
    @ResponseStatus(HttpStatus.INTERNAL_SERVER_ERROR)
    public ErrorResponse handleGenericError(Exception ex) {
        return new ErrorResponse(500, "Internal server error");
    }
}

@Data
@AllArgsConstructor
public class ErrorResponse {
    private int code;
    private String message;
    private List<FieldError> errors;
}
```

## Spring Security による認証

### 1. JWT認証

```java
@Configuration
@EnableWebSecurity
public class SecurityConfig {
    // JWT設定
}

@RestController
@RequestMapping("/api/users")
public class UserController {

    @GetMapping("/me")
    @PreAuthorize("isAuthenticated()")
    public UserResponse getCurrentUser(@AuthenticationPrincipal User user) {
        return new UserResponse(user);
    }

    @GetMapping("/admin")
    @PreAuthorize("hasRole('ADMIN')")
    public List<UserResponse> getAdminData() {
        return adminService.getData();
    }
}
```

**OpenAPI セキュリティスキーム:**
```yaml
components:
  securitySchemes:
    bearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT
```

### 2. @Secured, @PreAuthorize

```java
@Secured("ROLE_ADMIN")
@GetMapping("/admin")
public List<User> getAdminUsers() {
    return userService.findAdmins();
}
```

## Springdoc OpenAPI (自動生成)

Spring Bootプロジェクトで既に `springdoc-openapi` を使用している場合:

```java
import io.swagger.v3.oas.annotations.*;
import io.swagger.v3.oas.annotations.media.*;
import io.swagger.v3.oas.annotations.responses.*;

@RestController
@RequestMapping("/api/users")
@Tag(name = "users", description = "ユーザー管理API")
public class UserController {

    @Operation(summary = "ユーザー一覧取得", description = "ページネーション対応")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "成功",
            content = @Content(schema = @Schema(implementation = UserResponse.class)))
    })
    @GetMapping
    public List<UserResponse> getUsers() {
        return userService.findAll();
    }

    @Operation(summary = "ユーザー作成")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "201", description = "作成成功"),
        @ApiResponse(responseCode = "400", description = "バリデーションエラー")
    })
    @PostMapping
    public UserResponse createUser(
        @io.swagger.v3.oas.annotations.parameters.RequestBody(
            description = "ユーザー作成データ",
            required = true,
            content = @Content(schema = @Schema(implementation = UserCreateRequest.class))
        )
        @RequestBody @Valid UserCreateRequest request
    ) {
        return userService.create(request);
    }
}
```

**注意:** `springdoc-openapi` がある場合、`/v3/api-docs` エンドポイントから
完全なOpenAPI仕様を取得できます。

## 実装例

```java
@RestController
@RequestMapping("/api/users")
@Tag(name = "users", description = "ユーザー管理API")
public class UserController {

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    @GetMapping
    public Page<UserResponse> getUsers(
        @RequestParam(defaultValue = "0") @Min(0) int page,
        @RequestParam(defaultValue = "20") @Min(1) @Max(100) int size,
        @RequestParam(required = false) String search
    ) {
        return userService.findAll(PageRequest.of(page, size), search);
    }

    @GetMapping("/{id}")
    public ResponseEntity<UserResponse> getUser(@PathVariable @Min(1) Long id) {
        return userService.findById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public UserResponse createUser(@RequestBody @Valid UserCreateRequest request) {
        return userService.create(request);
    }

    @PutMapping("/{id}")
    public UserResponse updateUser(
        @PathVariable Long id,
        @RequestBody @Valid UserUpdateRequest request
    ) {
        return userService.update(id, request);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteUser(@PathVariable Long id) {
        userService.delete(id);
    }
}
```

## 検出優先順位

1. **Springdoc OpenAPI アノテーション** (最優先)
2. **戻り値の型 + javax.validation**
3. **ResponseEntity のジェネリック型**
4. **@RequestBody, @PathVariable の型**
5. **メソッド名からの推測** (最終手段)
