# 에러 처리 패턴 상세

## 목차
- [Exception 계층 구조](#exception-계층-구조)
- [Exception 정의 방법](#exception-정의-방법)
- [레이어별 에러 처리 흐름](#레이어별-에러-처리-흐름)
- [Either 소비 패턴](#either-소비-패턴)
- [무음 에러 (isSilentable)](#무음-에러-isilentable)

---

## Exception 계층 구조

```
AppException (abstract)
│   title/content: 추상 getter (하위 클래스 구현 강제)
│   isSilentable: false (기본값)
│
├── AuthException (sealed)
│   ├── AuthCancelledException
│   ├── AuthRequiresRecentLoginException
│   ├── AuthUserNotFoundException
│   ├── AuthNetworkException
│   ├── AuthUnknownException
│   └── ...
├── UserException (sealed)
│   ├── UserPermissionDeniedException
│   ├── UserNotFoundException
│   ├── UserDataParsingException
│   ├── UserUnknownException
│   └── ...
├── StoreException (sealed)
│   ├── StoreNotFoundException
│   ├── StoreValidationException
│   ├── StoreAlreadyExistsException
│   └── ...
└── NotificationException (sealed)
    │   isSilentable: 항상 true
    └── ...
```

**sealed class 규칙**: 각 중간 클래스의 직접 하위 타입은 반드시 같은 파일 안에 정의해야 함.
새 Exception 추가 시 `title`/`content`/`isSilentable` switch에 case를 추가하지 않으면 컴파일 에러 발생.

---

## Exception 정의 방법

### 기본 클래스

```dart
// lib/common/exceptions/app_exception.dart
abstract class AppException implements Exception {
  final String message; // 개발자/로그용 원본 메시지
  final String? code;   // 개발자/로그용 원본 에러 코드

  AppException(this.message, {this.code});

  String get title;   // 추상 getter - 하위 클래스 구현 필수
  String get content; // 추상 getter - 하위 클래스 구현 필수
  bool get isSilentable => false; // 기본값

  @override
  String toString() =>
    '[$runtimeType] $message ${code != null ? '(Code: $code)' : ''}';
}
```

### 도메인별 Exception 그룹 (sealed class 패턴)

```dart
// lib/common/exceptions/auth_exceptions.dart
sealed class AuthException extends AppException {
  AuthException(super.message, {super.code});

  @override
  String get title => switch (this) {
    AuthCancelledException() => '로그인이 취소되었습니다',
    AuthNetworkException() => '네트워크 에러가 발생했습니다',
    AuthUserNotFoundException() => '계정을 찾을 수 없습니다',
    // ... 모든 케이스 명시 (_ 사용 불가 → exhaustive 강제)
    AuthUnknownException() => '로그인에 실패했습니다',
  };

  @override
  String get content => switch (this) { ... };

  @override
  bool get isSilentable => switch (this) {
    AuthCancelledException() => true,
    AuthNetworkException() || AuthUserNotFoundException() || ... => false,
  };
}

// 구체 클래스들은 반드시 같은 파일 안에 정의
class AuthCancelledException extends AuthException {
  AuthCancelledException({String message = 'Auth cancelled', String? code})
    : super(message, code: code);
}
// ...
```

### 새 Exception 추가 절차

1. 같은 파일(예: `auth_exceptions.dart`)에 구체 클래스 추가
2. `AuthException.title` switch에 케이스 추가
3. `AuthException.content` switch에 케이스 추가
4. `AuthException.isSilentable` switch에 케이스 추가
5. → 누락 시 컴파일 에러 발생

---

## 레이어별 에러 처리 흐름

### DataSource → Firebase 에러를 타입된 Exception으로 변환

```dart
Exception _handleFirebaseError(Object e) {
  _logger.e('Auth Error', error: e);
  if (e is AuthException) return e; // 이미 타입됨 → 통과
  if (e is FirebaseAuthException) {
    return switch (e.code) {
      'requires-recent-login' => AuthRequiresRecentLoginException(...),
      'user-not-found' => AuthUserNotFoundException(...),
      'network-request-failed' => AuthNetworkException(...),
      _ => AuthUnknownException(message: e.message ?? '', code: e.code),
    };
  }
  return AuthUnknownException(message: e.toString());
}
```

### Repository → try-catch → Either 반환

```dart
@override
Future<Either<Exception, AuthInfo>> signInWithGoogle() async {
  try {
    final model = await _authDataSource.signInWithGoogle();
    return right(model.toEntity());
  } catch (e) {
    _logger.e('Google 로그인 실패');
    return left(e is Exception ? e : Exception(e.toString()));
  }
}
```

### Use Case → Either 체이닝

```dart
@override
Future<Either<Exception, User>> signInWithGoogle() async {
  final authResult = await _authRepository.signInWithGoogle();
  return authResult.fold(
    (error) => left(error),
    (authInfo) async => await _userRepository.fetchOrCreateUser(authInfo),
  );
}
```

### Controller → fold로 상태 갱신

```dart
void _handleAuthResult(Either<Exception, User> result) {
  result.fold(
    (exception) {
      // AppException 타입 체크만으로 isSilentable 접근 가능
      if (exception is AppException && exception.isSilentable) {
        state = const AsyncData(null);
      } else {
        state = AsyncError(exception, StackTrace.current);
      }
    },
    (user) => state = AsyncData(user),
  );
}
```

### UI → ref.listen에서 다이얼로그 표시

```dart
ref.listen(controllerProvider, (previous, next) {
  next.whenOrNull(
    error: (error, _) {
      if (error is AppException) {
        // AppException 타입만으로 구체적 메시지 접근 가능 (sealed class 덕분)
        showCustomAlertDialog(
          context: context,
          title: error.title,
          content: error.content,
          showCancel: false,
        );
      } else {
        showCustomAlertDialog(
          context: context,
          title: '에러가 발생했습니다',
          content: '개발자에게 문의해 주세요.\n(${error.toString()})',
        );
      }
    },
  );
});
```

---

## Either 소비 패턴

```dart
// 패턴 A: fold (가장 일반적)
result.fold(
  (exception) => state = AsyncError(exception, StackTrace.current),
  (value) => state = AsyncData(value),
);

// 패턴 B: isLeft 체크 + throw (AsyncValue.guard 내부에서)
state = await AsyncValue.guard(() async {
  final result = await useCase.doSomething();
  if (result.isLeft()) throw result.getLeft().toNullable()!;
  return result.getRight().toNullable()!;
});

// 패턴 C: TaskEither 체이닝 (복합 연산)
return _getUser().flatMap((user) {
  return TaskEither(() => _repository.createStore(user: user));
}).run();
```

---

## 무음 에러 (isSilentable)

사용자 취소 등 다이얼로그를 보여주지 않아야 하는 에러.
`AppException` 기본값은 `false`, 각 sealed class에서 switch로 케이스별 정의.

```dart
// sealed class 내 정의 (예: AuthException)
@override
bool get isSilentable => switch (this) {
  AuthCancelledException() => true,      // 사용자가 직접 취소 → silent
  AuthNetworkException() || ... => false,
};

// Controller에서 사용 - AppException 타입으로 충분
if (exception is AppException && exception.isSilentable) {
  state = const AsyncData(null); // 에러 상태가 아닌 기본 상태로 복원
  return;
}
state = AsyncError(exception, StackTrace.current);
```
