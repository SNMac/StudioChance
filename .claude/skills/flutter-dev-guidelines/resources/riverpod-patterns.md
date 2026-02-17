# Riverpod 패턴 상세

## 목차
- [프로바이더 타입별 사용 기준](#프로바이더-타입별-사용-기준)
- [함수형 프로바이더](#함수형-프로바이더)
- [클래스 기반 Notifier](#클래스-기반-notifier)
- [파라미터 프로바이더 (family)](#파라미터-프로바이더-family)
- [상태 갱신 패턴](#상태-갱신-패턴)
- [ref.listen vs ref.watch](#reflisten-vs-refwatch)
- [프로바이더 무효화](#프로바이더-무효화)
- [keepAlive 기준](#keepalive-기준)

---

## 프로바이더 타입별 사용 기준

| 용도 | 타입 | keepAlive |
|------|------|-----------|
| DataSource | 함수형 | `true` |
| Repository | 함수형 | `true` |
| Use Case | 함수형 | `false` |
| Stream (auth 등) | 함수형 | `false` |
| UI Controller (동기 초기값) | 클래스 (Notifier) | `false` |
| UI Controller (비동기 초기값) | 클래스 (AsyncNotifier) | `false` |
| 앱 전역 상태 | 클래스 (AsyncNotifier) | `true` |

---

## 함수형 프로바이더

단순 값 제공. 의존성 주입에 사용.

```dart
// DataSource (keepAlive)
@Riverpod(keepAlive: true)
AuthDataSource authDataSource(Ref ref) {
  return FirebaseAuthDataSource(FirebaseAuth.instance);
}

// Repository (keepAlive)
@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  final authDataSource = ref.watch(authDataSourceProvider);
  return AuthRepositoryImpl(authDataSource: authDataSource);
}

// Use Case (autoDispose)
@riverpod
AuthUseCase authUseCase(Ref ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final userRepository = ref.watch(userRepositoryProvider);
  return AuthUseCaseImpl(
    authRepository: authRepository,
    userRepository: userRepository,
  );
}

// Stream
@riverpod
Stream<AuthInfo?> authStateChanges(Ref ref) {
  return ref.watch(authUseCaseProvider).authStateChanges();
}

// Future
@Riverpod(keepAlive: true)
Future<User?> currentUser(Ref ref) async {
  final useCase = ref.watch(userUseCaseProvider);
  final result = await useCase.getCurrentUser();
  return result.fold((l) => throw l, (r) => r);
}
```

---

## 클래스 기반 Notifier

### 동기 초기값 (AsyncValue로 래핑)

비동기 작업을 수행하지만 초기 상태는 동기적으로 설정:

```dart
@riverpod
class SignInController extends _$SignInController {
  @override
  AsyncValue<User?> build() => const AsyncData(null);

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    final useCase = ref.read(authUseCaseProvider);
    final result = await useCase.signInWithGoogle();
    result.fold(
      (exception) {
        if (exception is AuthException && exception.isSilentable) {
          state = const AsyncData(null);
        } else {
          state = AsyncError(exception, StackTrace.current);
        }
      },
      (user) => state = AsyncData(user),
    );
  }
}
```

### 순수 동기 상태

```dart
@riverpod
class RoleSelectionController extends _$RoleSelectionController {
  @override
  UserRole build() => UserRole.none;

  void setRole(UserRole role) => state = role;
}
```

### FutureOr<void> 패턴

폼 제출 등 결과값이 필요 없는 비동기 작업:

```dart
@riverpod
class OnboardingNicknameController extends _$OnboardingNicknameController {
  @override
  FutureOr<void> build() {}

  Future<void> saveNicknameToRemote(String nickname) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final useCase = ref.read(userUseCaseProvider);
      final result = await useCase.updateNickname(nickname);
      if (result.isLeft()) throw result.getLeft().toNullable()!;
    });
  }
}
```

### Freezed 상태 객체를 가진 Controller

복잡한 폼 상태 등:

```dart
@riverpod
class StoreCreationController extends _$StoreCreationController
    with StoreFormMixin
    implements StoreFormControllerable {
  @override
  StoreFormState build() => const StoreFormState();

  @override
  Future<void> submit() async {
    state = state.copyWith(status: const AsyncLoading());
    // ... 비동기 작업
    state = state.copyWith(status: const AsyncData(null));
  }
}
```

---

## 파라미터 프로바이더 (family)

`build()` 메서드에 파라미터를 추가하면 자동으로 family 프로바이더가 됨:

```dart
@riverpod
class NicknameFormController extends _$NicknameFormController {
  @override
  NicknameFormState build(String? initialValue) {
    return NicknameFormState(nickname: initialValue ?? '');
  }

  void setNickname(String nickname) {
    state = state.copyWith(nickname: nickname);
  }
}

// 사용
final provider = nicknameFormControllerProvider(widget.initialNickname);
final state = ref.watch(provider);
final notifier = ref.read(provider.notifier);
```

---

## 상태 갱신 패턴

```dart
// 1. AsyncValue.guard - 가장 간결
state = await AsyncValue.guard(() async {
  final result = await useCase.doSomething();
  if (result.isLeft()) throw result.getLeft().toNullable()!;
});

// 2. 수동 AsyncValue 관리 - 세밀한 제어 필요 시
state = const AsyncLoading();
try {
  final result = await useCase.doSomething();
  state = AsyncData(result);
} catch (e, st) {
  state = AsyncError(e, st);
}

// 3. Freezed 상태 내 status 필드
state = state.copyWith(status: const AsyncLoading());
// ...
state = state.copyWith(status: const AsyncData(null));
```

---

## ref.listen vs ref.watch

| 메서드 | 용도 | 위치 |
|--------|------|------|
| `ref.watch` | 프로바이더 값 읽기 + 리빌드 | `build()` 내부 |
| `ref.read` | 프로바이더 값 1회 읽기 (이벤트 핸들러) | 콜백/메서드 내부 |
| `ref.listen` | 상태 변경 시 사이드 이펙트 | `build()` 초반부 |

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  // listen - 다이얼로그, 네비게이션 등 사이드 이펙트
  ref.listen(controllerProvider, (previous, next) {
    next.whenOrNull(error: (e, _) => showDialog(...));
  });

  // watch - UI 리빌드
  final state = ref.watch(controllerProvider);

  return ElevatedButton(
    // read - 이벤트 핸들러에서 1회 호출
    onPressed: () => ref.read(controllerProvider.notifier).doSomething(),
  );
}
```

---

## 프로바이더 무효화

```dart
// 데이터 새로고침 강제
ref.invalidate(currentUserProvider);

// 앱 상태 재평가
ref.invalidate(appAuthControllerProvider);
```

`invalidate` 호출 시 프로바이더가 다음에 watch/read될 때 `build()`가 재실행됨.

---

## keepAlive 기준

| keepAlive | 사용 대상 | 이유 |
|-----------|----------|------|
| `true` | DataSource, Repository, 앱 전역 상태 | 앱 생명주기 동안 유지 필요 |
| `false` (기본) | UseCase, UI Controller, Stream | 화면 이탈 시 자동 해제 |
