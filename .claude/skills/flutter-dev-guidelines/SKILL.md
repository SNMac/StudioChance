---
name: flutter-dev-guidelines
description: Flutter/Dart 개발 가이드라인. Clean Architecture, Riverpod, GoRouter, Firebase, Freezed 패턴. widget, provider, repository, use case, data source, entity, model, route, screen, 화면, 위젯, 상태관리, 라우트, 에러 처리 관련 작업 시 활성화.
---

# Flutter 개발 가이드라인 - StudioChance

## 프로젝트 개요

공간대여업 예약 관리 크로스플랫폼(iOS, Android) 앱.
Flutter + Firebase + Riverpod(코드 생성) + GoRouter + Clean Architecture + MVVM.

---

## 아키텍처 레이어 및 의존성 흐름

```
Presentation → Domain ← Data
(UI, 상태)    (비즈니스)   (Firebase)
```

| 레이어 | 위치 | 포함 항목 |
|--------|------|----------|
| **Presentation** | `lib/presentation/` | Screen, Controller(Provider), Widget |
| **Domain** | `lib/domain/` | Entity, Enum, Repository Interface, Use Case |
| **Data** | `lib/data/` | DataSource, Model, Repository 구현체 |
| **Common** | `lib/common/` | Exception, Converter, Extension |
| **Constants** | `lib/constants/` | UI/Data 상수 |
| **Router** | `lib/router/` | GoRouter, Route 정의 |

**핵심 규칙**: Domain 레이어는 Data/Presentation에 의존하지 않음.

**위젯 규칙**: 위젯(`ConsumerWidget`/`ConsumerStatefulWidget`)은 UseCase Provider를 직접 `ref.read/watch` 금지.
UseCase 호출이 필요하면 `lib/presentation/providers/`에 전용 `@riverpod` Controller(Notifier)를 생성하여 위임.

```dart
// ❌ 위젯에서 UseCase 직접 참조
class TimeGrid extends ConsumerStatefulWidget {
  void _onSaved(Reservation r) {
    ref.read(reservationUseCaseProvider).updateReservation(reservation: r); // 금지
  }
}

// ✅ 전용 Controller 위임
// lib/presentation/providers/home_reservation_actions_controller.dart
@riverpod
class HomeReservationActionsController extends _$HomeReservationActionsController {
  @override void build() {}
  Future<void> updateReservation(Reservation r) async {
    final result = await ref.read(reservationUseCaseProvider).updateReservation(reservation: r);
    result.fold((e) => ..., (_) => ref.invalidate(homeReservationsProvider));
  }
}

// 위젯에서는 Controller만 참조
void _onSaved(Reservation r) {
  ref.read(homeReservationActionsControllerProvider.notifier).updateReservation(r);
}
```

### UseCase 파일 분리 패턴

UseCase는 두 파일로 분리한다:

| 파일 | 역할 | data import |
|------|------|-------------|
| `*_use_case.dart` | interface + impl (순수 Domain) | ❌ 금지 |
| `*_use_case_provider.dart` | `@riverpod` 팩토리 (DI 배선) | ✅ 허용 |

```dart
// auth_use_case.dart — data import 없음
import 'package:studio_chance/domain/repository_interfaces/auth_repository.dart';
class AuthUseCaseImpl implements AuthUseCase { ... }

// auth_use_case_provider.dart — DI 배선 파일
import 'package:studio_chance/data/repositories/auth_repository_impl.dart';
import 'package:studio_chance/domain/use_cases/auth_use_case.dart';

@riverpod
AuthUseCase authUseCase(Ref ref) { ... }
```

Presentation에서는 `*_use_case_provider.dart`를 import해야 `authUseCaseProvider`에 접근 가능.

---

## Riverpod 프로바이더 패턴

모든 프로바이더는 **코드 생성** 사용. 반드시 `part 'filename.g.dart';` 포함.

### 함수형 프로바이더

```dart
@riverpod                          // autoDispose
AuthUseCase authUseCase(Ref ref) { ... }

@Riverpod(keepAlive: true)         // 영구 유지 (DataSource, Repository)
AuthDataSource authDataSource(Ref ref) { ... }
```

### 클래스 기반 Notifier

```dart
// 동기 초기값 - UI 상태 제어
@riverpod
class SignInController extends _$SignInController {
  @override
  AsyncValue<User?> build() => const AsyncData(null);
}

// 비동기 초기값 - 앱 상태
@Riverpod(keepAlive: true)
class AppAuthController extends _$AppAuthController {
  @override
  Future<AppStatus> build() async { ... }
}

// void 비동기 - 폼 제출 등
@riverpod
class OnboardingNicknameController extends _$OnboardingNicknameController {
  @override
  FutureOr<void> build() {}
}
```

### 파라미터 프로바이더 (family)

```dart
@riverpod
class NicknameFormController extends _$NicknameFormController {
  @override
  NicknameFormState build(String? initialValue) { ... }
}
// 사용: ref.watch(nicknameFormControllerProvider(initialNickname))
```

### 상태 갱신 패턴

```dart
// AsyncValue.guard
state = await AsyncValue.guard(() async { ... });

// 수동 관리
state = const AsyncLoading();
state = AsyncError(exception, StackTrace.current);
state = AsyncData(value);

// 프로바이더 무효화 (재요청)
ref.invalidate(currentUserProvider);
```

자세한 내용: [riverpod-patterns.md](resources/riverpod-patterns.md)

---

## 위젯 패턴

### 위젯 타입 선택

| 타입 | 사용 시점 |
|------|----------|
| `ConsumerWidget` | Riverpod 상태만 필요 (기본값) |
| `ConsumerStatefulWidget` | Riverpod + TextEditingController/FocusNode 등 |
| `StatelessWidget` | 순수 재사용 위젯 (상태 없음) |
| `StatefulWidget` | Flutter 로컬 상태만 필요 (Riverpod 불필요) |

### 화면 구성 공식

```dart
Scaffold(
  appBar: CustomAppBar(title: '제목', leading: ..., actions: [...]),
  body: PopScope(
    canPop: !isLoading,
    child: Stack(children: [
      SafeAreaWithPadding(child: Column(children: [...])),
      LoadingOverlay(isLoading: isLoading),
    ]),
  ),
)
```

### ref.listen - 사이드 이펙트

다이얼로그, 네비게이션 등은 반드시 `ref.listen`에서 처리:

```dart
ref.listen(controllerProvider, (previous, next) {
  next.whenOrNull(
    error: (error, _) {
      if (error is AppException) {
        showCustomAlertDialog(context: context, title: error.title, content: error.content);
      }
    },
  );
});
```

자세한 내용: [widget-patterns.md](resources/widget-patterns.md)

---

## 에러 처리

### Either 패턴 (fpdart)

```dart
// Repository / Use Case 반환 타입
Future<Either<Exception, User>> signInWithGoogle();

// ✅ 기본 패턴: fold (함수형)
result.fold(
  (error) => left(error),   // UseCase 체이닝
  (value) => right(value),
);

// ✅ Controller에서 소비
result.fold(
  (exception) => state = AsyncError(exception, StackTrace.current),
  (user) => state = AsyncData(user),
);

// ❌ 금지 패턴: 명령형 isLeft/isRight
if (result.isLeft()) return left(result.getLeft().toNullable()!); // null-force-unwrap 위험
```

**fold 비동기 처리**: 양쪽 람다 반환 타입을 `async`로 통일하면 `FutureOr` 추론 혼동 방지:

```dart
return result.fold(
  (error) async => left(error),     // ✅ 둘 다 async로 명시
  (value) async { ... return ...; },
);
```

**TaskEither 체이닝** (여러 단계 UseCase):

```dart
return _getCurrentUser().flatMap((user) {
  return TaskEither(() => _repository.someAction(user.id));
}).run();
```

### Exception 계층

```
AppException (abstract) → title/content 추상 getter, isSilentable 기본값 false
├── AuthException (sealed) → title/content/isSilentable switch 오버라이드
│   ├── AuthCancelledException, AuthNetworkException, ...
├── UserException (sealed) → 동일
│   ├── UserNotFoundException, UserPermissionDeniedException, ...
├── StoreException (sealed) → 동일
│   ├── StoreNotFoundException, StoreValidationException, ...
└── NotificationException (sealed) → 동일 (isSilentable 항상 true)
```

- DataSource: Firebase 에러 → 타입된 Exception으로 변환 (switch)
- Repository: try-catch → `left(exception)` 반환, 절대 예외 전파 금지 / `toException()` 헬퍼(`common/utils/exception_utils.dart`) 활용
- Use Case: `result.fold()` 함수형 / `TaskEither.flatMap().run()` 체이닝 / `isLeft()/isRight()` 명령형 금지
- Controller: `result.fold()`로 상태 갱신 + `isSilentable` 체크 (`AppException` 타입 체크만으로 충분)

### UseCase 공통 헬퍼

현재 로그인 유저가 필요한 UseCase에서 반복 구현 대신 헬퍼 사용:

```dart
// lib/domain/use_cases/use_case_helpers.dart
TaskEither<Exception, User> getCurrentUserOrThrow(UserRepository userRepository)
```

```dart
// 사용 예 (StoreUseCaseImpl, ReservationUseCaseImpl)
return getCurrentUserOrThrow(_userRepository).flatMap((user) {
  return TaskEither(() => _repository.someAction(user.id));
}).run();
```

자세한 내용: [error-handling.md](resources/error-handling.md)

---

## Data 레이어 패턴

### Model ↔ Entity 변환

```dart
// Model (Data) - JSON 직렬화 포함
@freezed
abstract class UserModel with _$UserModel {
  const UserModel._();
  const factory UserModel({ @JsonKey(includeToJson: false) required String id, ... }) = _UserModel;
  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

  User toEntity() { ... }
  factory UserModel.fromEntity(User entity) { ... }
}

// Entity (Domain) - 순수 Dart, JSON 없음
@freezed
abstract class User with _$User {
  const User._();
  const factory User({ required String id, ... }) = _User;
  bool get isNewUser => nickname == null;
}
```

### Firestore 규칙

- Document ID 주입: `data['id'] = docSnapshot.id`
- 서버 타임스탬프: `FieldValue.serverTimestamp()`
- Soft delete: `deletedAt` 필드 체크
- 배치 작업: `_firestore.batch()` + `batch.commit()`
- 타임스탬프 변환: `@TimestampConverter()`

자세한 내용: [data-layer-patterns.md](resources/data-layer-patterns.md)

---

## 네비게이션 (GoRouter)

### 라우트 이동 방식

```dart
// 최상위 라우트 (splash, signIn, home, onboardingNickname)
context.go(SCRoute.home.fullPath);

// 공유 서브 라우트 (role, storeCreation, invitation 등)
SCRoute.role.pushChild(context);

// 뒤로 가기
if (context.canPop()) context.pop();
```

### 인증 리다이렉트

`AppAuthController`의 `AppStatus`에 따라 자동 라우팅:
- `unauthenticated` → 로그인 화면
- `onboarding` → 닉네임 설정
- `authenticated` → 홈 화면

자세한 내용: [navigation-patterns.md](resources/navigation-patterns.md)

---

## UI 공통 컴포넌트

### 색상

```dart
context.label           // 기본 텍스트
context.secondaryLabel  // 보조 텍스트
context.systemBackground // 배경
context.separator       // 구분선
```

### 공통 위젯

| 위젯 | 용도 |
|------|------|
| `CustomAppBar` | iOS/Android 높이 대응 앱바 |
| `AppBarNaviBackButton` | 네비게이션 뒤로가기 `<` |
| `AppBarModalBackButton` | 모달 닫기 `×` |
| `AppBarActionButton` | 앱바 우측 텍스트 버튼 |
| `SafeAreaWithPadding` | SafeArea + 표준 패딩 |
| `LoadingOverlay` | 로딩 오버레이 (AnimatedSwitcher) |
| `GroupedFormContainer` | iOS 스타일 그룹 폼 |
| `BodyTextField` | 텍스트 입력 필드 (clear 버튼 포함) |
| `showCustomAlertDialog` | 적응형 알림 다이얼로그 |

자세한 내용: [ui-commons.md](resources/ui-commons.md)

---

## 코드 생성

```bash
dart run build_runner build --delete-conflicting-outputs
```

- `*.freezed.dart` - Freezed 불변 클래스
- `*.g.dart` - JSON 직렬화 + Riverpod 프로바이더

**Entity**: `part 'filename.freezed.dart';`만 필요
**Model**: `part 'filename.freezed.dart';` + `part 'filename.g.dart';` 둘 다 필요

---

## 컨벤션 요약

| 항목 | 규칙 |
|------|------|
| 로깅 | `logger` 패키지, `final Logger _logger = Logger()` |
| 상수 | `lib/constants/` 최상위 `const` 값 |
| Enum | `@JsonEnum()` + `@JsonValue()` + `displayName` getter |
| 키보드 해제 | `MyApp`에서 `GestureDetector.onTap` → `unfocus()` |
| 폰트 | Pretendard (400, 500, 600, 700) |
| 디자인 | Material 3, `ThemeMode.system` |
| Collection 탐색 | `firstWhere + try-catch` 금지 → `.where(...).firstOrNull` 사용 (Dart 3 네이티브) |

---

## 성능 가이드라인

### watch vs select

`ref.watch(provider)`는 상태 객체 전체를 구독 → 관련 없는 필드 변경에도 rebuild 발생.
필요한 필드만 구독하려면 `select` 사용:

```dart
// ❌ 전체 상태 구독 → hourHeight/selectedStartDate 변경 시에도 rebuild
final isVisible = ref.watch(homeCalendarControllerProvider).isMonthlyCalendarVisible;

// ✅ 필요한 필드만 구독
final isVisible = ref.watch(
  homeCalendarControllerProvider.select((s) => s.isMonthlyCalendarVisible),
);

// 여러 필드가 필요하면 각각 select
final month = ref.watch(homeCalendarControllerProvider.select((s) => s.displayedMonth));
final isVisible = ref.watch(homeCalendarControllerProvider.select((s) => s.isMonthlyCalendarVisible));
```

**기준**: 위젯에서 사용하는 필드가 상태 객체 전체 필드의 일부라면 select 사용.

### build() 내 연산 주의사항

build()는 flutter 프레임워크가 빈번하게 호출하므로, 무거운 연산이나 반복 호출은 루프 밖으로 이동:

```dart
// ❌ 루프 내 반복 호출 (35회)
for (int i = 0; i < 35; i++) {
  final today = DateTime.now(); // 매 셀마다 새 DateTime 객체 생성
}

// ✅ 루프 밖에서 한 번만 계산
final today = DateTime.now();
for (int i = 0; i < 35; i++) {
  final isToday = cellDate.year == today.year && ...;
}
```

### ScrollController 관리 (복수 컨트롤러)

Map으로 여러 ScrollController를 관리할 때:
- `dispose()`에서 맵의 모든 컨트롤러를 해제할 것
- 범위 밖 컨트롤러는 주기적으로 evict하여 메모리 관리
- `hasClients = false`인 컨트롤러는 re-attach 시 `initialScrollOffset`(stale) 사용 → unmount 감지 후 재생성 필요

```dart
// unmount 감지 → 재생성 패턴
final existing = _controllers[page];
if (existing != null && !existing.hasClients) {
  existing.dispose();
  _controllers.remove(page);
}
return _controllers.putIfAbsent(page, () => ScrollController(
  initialScrollOffset: _currentOffset, // 현재 offset으로 생성
));
```

---

## 참조 문서

| 문서 | 내용 |
|------|------|
| [riverpod-patterns.md](resources/riverpod-patterns.md) | 프로바이더 상세 패턴, 상태 관리, select 최적화 |
| [widget-patterns.md](resources/widget-patterns.md) | 위젯 구성, ref.listen, PopScope |
| [data-layer-patterns.md](resources/data-layer-patterns.md) | Repository, DataSource, Model, Firestore |
| [error-handling.md](resources/error-handling.md) | Exception 계층, Either 체이닝, UI 매핑 |
| [navigation-patterns.md](resources/navigation-patterns.md) | GoRouter, SCRoute, 리다이렉트 |
| [ui-commons.md](resources/ui-commons.md) | 공통 위젯, 색상, 테마 |
