# Data 레이어 패턴 상세

## 목차
- [Repository 패턴](#repository-패턴)
- [Use Case 패턴](#use-case-패턴)
- [DataSource 패턴](#datasource-패턴)
- [Model / Entity 변환](#model--entity-변환)
- [Firestore 규칙](#firestore-규칙)
- [Freezed 컨벤션](#freezed-컨벤션)
- [Enum 패턴](#enum-패턴)

---

## Repository 패턴

### 인터페이스 (Domain 레이어)

```dart
// lib/domain/repository_interfaces/auth_repository.dart
abstract interface class AuthRepository {
  Stream<AuthInfo?> authStateChanges();
  Future<Either<Exception, AuthInfo>> signInWithGoogle();
  Future<void> signOut();
}
```

### 구현체 (Data 레이어)

```dart
// lib/data/repositories/auth_repository_impl.dart
class AuthRepositoryImpl implements AuthRepository {
  final Logger _logger = Logger();
  final AuthDataSource _authDataSource;

  AuthRepositoryImpl({required AuthDataSource authDataSource})
    : _authDataSource = authDataSource;

  @override
  Future<Either<Exception, AuthInfo>> signInWithGoogle() async {
    try {
      final authModel = await _authDataSource.signInWithGoogle();
      return right(authModel.toEntity()); // Model → Entity 변환
    } catch (e) {
      _logger.e('Google 로그인 실패');
      return left(e is Exception ? e : Exception(e.toString()));
    }
  }
}

// 프로바이더 (파일 하단)
@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  final authDataSource = ref.watch(authDataSourceProvider);
  return AuthRepositoryImpl(authDataSource: authDataSource);
}
```

**핵심 규칙**:
- try-catch로 모든 예외 포착 → `left(exception)` 반환
- 예외를 절대 전파하지 않음
- Model → Entity 변환은 Repository에서 수행

---

## Use Case 패턴

### 구조

```dart
// 1. 인터페이스
abstract interface class AuthUseCase {
  Future<Either<Exception, User>> signInWithGoogle();
}

// 2. 구현체
class AuthUseCaseImpl implements AuthUseCase {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  const AuthUseCaseImpl({
    required AuthRepository authRepository,
    required UserRepository userRepository,
  }) : _authRepository = authRepository, _userRepository = userRepository;

  @override
  Future<Either<Exception, User>> signInWithGoogle() async {
    final authResult = await _authRepository.signInWithGoogle();
    return authResult.fold(
      (error) => left(error),
      (authInfo) async => await _userRepository.fetchOrCreateUser(authInfo),
    );
  }
}

// 3. 프로바이더
@riverpod
AuthUseCase authUseCase(Ref ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final userRepository = ref.watch(userRepositoryProvider);
  return AuthUseCaseImpl(
    authRepository: authRepository,
    userRepository: userRepository,
  );
}
```

### TaskEither 체이닝 (복합 연산)

```dart
Future<Either<Exception, Store>> createStore({...}) {
  return _getCurrentUser().flatMap((currentUser) {
    return TaskEither(() => _storeRepository.createStore(store: storeWithAdmin));
  }).run();
}

TaskEither<Exception, User> _getCurrentUser() {
  return TaskEither.tryCatch(
    () async {
      final result = await _userRepository.getCurrentUser();
      return result.fold(
        (left) => throw left,
        (right) {
          if (right == null) throw AuthUserNotFoundException(message: '...');
          return right;
        },
      );
    },
    (error, stackTrace) => error is Exception ? error : Exception(error),
  );
}
```

---

## DataSource 패턴

### Firebase Auth

```dart
abstract interface class AuthDataSource {
  Future<AuthModel> signInWithGoogle();
}

class FirebaseAuthDataSource implements AuthDataSource {
  final Logger _logger = Logger();
  final FirebaseAuth _auth;
  FirebaseAuthDataSource(this._auth);

  @override
  Future<AuthModel> signInWithGoogle() async {
    try {
      final credential = await _getGoogleCredential();
      final userCredential = await _auth.signInWithCredential(credential);
      if (userCredential.user == null) throw AuthUnknownException(message: '...');
      return AuthModel.fromFirebase(userCredential.user!);
    } catch (e) {
      throw _handleFirebaseError(e);
    }
  }

  Exception _handleFirebaseError(Object e) {
    if (e is AuthException) return e;
    if (e is FirebaseAuthException) {
      return switch (e.code) {
        'user-not-found' => AuthUserNotFoundException(message: e.message ?? ''),
        'network-request-failed' => AuthNetworkException(message: e.message ?? ''),
        _ => AuthUnknownException(message: e.message ?? '', code: e.code),
      };
    }
    return AuthUnknownException(message: e.toString());
  }
}
```

### Firestore

```dart
class UserFirestoreDataSource implements UserDataSource {
  final Logger _logger = Logger();
  final FirebaseFirestore _firestore;
  UserFirestoreDataSource(this._firestore);

  @override
  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        data['id'] = doc.id;                      // ID 주입
        if (data['deletedAt'] != null) return null; // Soft delete 체크
        return UserModel.fromJson(data);
      }
      return null;
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }

  @override
  Future<void> createUser(UserModel userModel) async {
    try {
      final json = userModel.toJson();
      json['createdAt'] = FieldValue.serverTimestamp();
      json['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('users').doc(userModel.id).set(json);
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }
}
```

---

## Model / Entity 변환

### Entity (Domain) - JSON 없음

```dart
@freezed
abstract class User with _$User {
  const User._(); // 커스텀 getter용
  const factory User({
    required String id,
    required String name,
    required String? nickname,
  }) = _User;

  bool get isNewUser => nickname == null;
}
```

### Model (Data) - JSON 직렬화 포함

```dart
@freezed
abstract class UserModel with _$UserModel {
  const UserModel._();
  const factory UserModel({
    @JsonKey(includeToJson: false) required String id,
    required String name,
    String? nickname,
    @Default([]) List<String> authProviders,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

  // Model → Entity
  User toEntity() => User(id: id, name: name, nickname: nickname);

  // Entity → Model
  factory UserModel.fromEntity(User entity) =>
    UserModel(id: entity.id, name: entity.name, nickname: entity.nickname);
}
```

---

## Firestore 규칙

| 패턴 | 코드 |
|------|------|
| Document ID 주입 | `data['id'] = docSnapshot.id` |
| 서버 타임스탬프 | `FieldValue.serverTimestamp()` |
| Soft delete 체크 | `if (data['deletedAt'] != null) return null` |
| 배열 추가 | `FieldValue.arrayUnion([value])` |
| 배열 제거 | `FieldValue.arrayRemove([value])` |
| 필드 삭제 | `FieldValue.delete()` |
| 중첩 맵 업데이트 | `'storeById.$storeId.$key': value` |
| 배치 작업 | `_firestore.batch()` → `batch.commit()` |
| 타임스탬프 변환 | `@TimestampConverter()` 어노테이션 |
| 서브컬렉션 | `collection('stores').doc(id).collection('reservations')` |

### TimestampConverter

```dart
class TimestampConverter implements JsonConverter<DateTime, Timestamp> {
  const TimestampConverter();
  @override
  DateTime fromJson(Timestamp timestamp) => timestamp.toDate();
  @override
  Timestamp toJson(DateTime date) => Timestamp.fromDate(date);
}

// 모델에서 사용
@TimestampConverter()
required DateTime createdAt,
```

---

## Freezed 컨벤션

| 항목 | Entity | Model |
|------|--------|-------|
| `part '*.freezed.dart'` | O | O |
| `part '*.g.dart'` | X | O |
| `fromJson` | X | O |
| `toEntity()` | X | O |
| `fromEntity()` | X | O |
| `const ClassName._()` | 커스텀 getter 있을 때 | 변환 메서드용 |
| `@JsonKey(includeToJson: false)` | X | ID 필드에 사용 |
| `@Default(value)` | 선택 | 선택 |

---

## Enum 패턴

```dart
@JsonEnum()
enum UserRole {
  @JsonValue('ADMIN') admin,
  @JsonValue('STAFF') staff,
  @JsonValue('VIEWER') viewer,
  @JsonValue('NONE') none;

  String get displayName => switch (this) {
    UserRole.admin => '관리자',
    UserRole.staff => '스태프',
    UserRole.viewer => '뷰어',
    UserRole.none => '',
  };
}
```

- `@JsonEnum()` + `@JsonValue()`: Firestore 저장용
- `displayName` getter: UI 표시용
- 추가 getter 자유 정의 (`displayDescription`, `colorValue` 등)
- **const List&lt;String&gt; 상수 대신 enum 선호** — Firestore 저장값과 UI 표시 텍스트 분리, 타입 안전성 확보

---

## Future.wait 타입 주의

```dart
// ❌ 반환 타입이 다른 Future를 Future.wait에 넣으면 List<Object?>로 추론
final results = await Future.wait([
  _storeDataSource.getStore(id),   // Future<StoreModel?>
  _userDataSource.getUser(uid),    // Future<UserModel?>
]);
// results[0]은 Object? → .name, .memberById 등 접근 불가

// ✅ 별도 Future 변수로 병렬 실행
final storeF = _storeDataSource.getStore(id);
final userF = _userDataSource.getUser(uid);
final store = await storeF;   // StoreModel?
final user = await userF;     // UserModel?
// 두 Future는 동시에 시작되어 병렬 실행됨
```

같은 타입의 Future라면 `Future.wait` 사용 가능:
```dart
// ✅ 같은 타입이므로 OK
final userModels = await Future.wait(
  writerIds.map((uid) => _userDataSource.getUser(uid)),
); // List<UserModel?>
```
