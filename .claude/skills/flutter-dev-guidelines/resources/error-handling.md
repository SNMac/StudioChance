# 에러 처리 패턴 상세

## 목차
- [Exception 계층 구조](#exception-계층-구조)
- [Exception 정의 방법](#exception-정의-방법)
- [UI 메시지 매핑 (Extension)](#ui-메시지-매핑-extension)
- [레이어별 에러 처리 흐름](#레이어별-에러-처리-흐름)
- [Either 소비 패턴](#either-소비-패턴)
- [무음 에러 (isSilentable)](#무음-에러-isilentable)

---

## Exception 계층 구조

```
AppException (abstract)
├── AuthException (abstract)
│   ├── AuthCancelledException
│   ├── AuthRequiresRecentLoginException
│   ├── AuthUserNotFoundException
│   ├── AuthNetworkException
│   ├── AuthUnknownException
│   └── ...
├── UserException (abstract)
│   ├── UserPermissionDeniedException
│   ├── UserNotFoundException
│   ├── UserDataParsingException
│   ├── UserUnknownException
│   └── ...
├── StoreException (abstract)
│   ├── StoreNotFoundException
│   ├── StoreValidationException
│   ├── StoreAlreadyExistsException
│   └── ...
└── NotificationException (abstract)
    └── ...
```

---

## Exception 정의 방법

### 기본 클래스

```dart
// lib/common/exceptions/app_exception.dart
abstract class AppException implements Exception {
  final String message;
  final String? code;

  AppException(this.message, {this.code});

  String get title => '오류가 발생했습니다';
  String get content => message;

  @override
  String toString() =>
    '[$runtimeType] $message ${code != null ? '(Code: $code)' : ''}';
}
```

### 도메인별 Exception 그룹

```dart
// lib/common/exceptions/auth_exceptions.dart
abstract class AuthException extends AppException {
  AuthException(super.message, {super.code});
}

class AuthCancelledException extends AuthException {
  AuthCancelledException({required String message, String? code})
    : super(message, code: code);
}

class AuthNetworkException extends AuthException {
  AuthNetworkException({required String message, String? code})
    : super(message, code: code);
}
// ... 도메인별로 필요한 만큼 정의
```

---

## UI 메시지 매핑 (Extension)

사용자에게 보여줄 메시지는 Extension으로 분리:

```dart
// lib/common/exceptions/extensions/auth_exception_extension.dart
extension AuthExceptionExtension on AuthException {
  @override
  String get title {
    return switch (this) {
      AuthCancelledException() => '로그인이 취소되었습니다',
      AuthNetworkException() => '네트워크 오류',
      AuthUserNotFoundException() => '계정을 찾을 수 없습니다',
      _ => '로그인에 실패했습니다',
    };
  }

  @override
  String get content {
    return switch (this) {
      AuthNetworkException() => '인터넷 연결 상태를 확인해주세요.',
      AuthCancelledException() => '로그인 과정이 중단되었습니다.',
      _ => '일시적인 오류가 발생했습니다.\n잠시 후 다시 시도해주세요.',
    };
  }

  bool get isSilentable {
    return switch (this) {
      AuthCancelledException() => true,
      _ => false,
    };
  }
}
```

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
      if (exception is AuthException && exception.isSilentable) {
        state = const AsyncData(null); // 무시
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
        showCustomAlertDialog(
          context: context,
          title: error.title,
          content: error.content,
          showCancel: false,
        );
      } else {
        showCustomAlertDialog(
          context: context,
          title: '오류가 발생했습니다',
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

사용자 취소 등 다이얼로그를 보여주지 않아야 하는 에러:

```dart
// Extension에서 정의
bool get isSilentable {
  return switch (this) {
    AuthCancelledException() => true,
    _ => false,
  };
}

// Controller에서 사용
if (exception is AuthException && exception.isSilentable) {
  state = const AsyncData(null); // 에러 상태가 아닌 기본 상태로 복원
  return;
}
state = AsyncError(exception, StackTrace.current);
```
