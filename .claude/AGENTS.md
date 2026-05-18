# 프로젝트: SpaceManager
> 가제: StudioChance

Firebase, Riverpod, GoRouter, Clean Architecture, MVVM을 사용하는 공간대여업 예약 관리 크로스플랫폼(iOS, Android) 앱입니다.
- Firebase 서비스: Firestore, Authentication, Crashlytics, Cloud Message, Analytics, App Check
- 소셜 로그인: Google, Apple
  - 정식 출시 후 Naver, Kakao 추가 예정

## 코드 스타일
- Flutter/Dart 사용
- Dart 컨벤션 사용
- 콘솔 출력 시 `logger` 라이브러리 사용
- 한국어로 커밋 메시지, 주석 작성

## 아키텍처
- `/lib/common`: 모든 계층에서 사용되는 로직
  - `/utils/exception_utils.dart`: `toException()` — catch 블록 Object → Exception 변환 헬퍼
- `/lib/constants`: 모든 계층에서 사용되는 상수값
- `/lib/data`: Data 계층
  - `/data_sources`: DB 연결 로직
  - `/models`: Data 모델
  - `/repositories`: Data 로직 구현체
- `/lib/domain`: Domain(비즈니스 로직) 계층
  - `/entities`: Domain 엔티티
  - `/enums`: Domain 관련 enum
  - `/repository_interfaces`: Domain에서 필요로 하는 Data 로직 인터페이스
  - `/use_cases`: 비즈니스 로직 단위
    - `use_case_helpers.dart`: `getCurrentUserOrThrow(UserRepository)` 공통 헬퍼
- `/lib/presentation`: UI 계층
  - `/commons`: 여러 곳에서 사용되는 UI
  - `/home`: 홈 화면
  - `/my_page`: 마이페이지 화면
  - `/onboarding`: 온보딩 화면
  - `/providers`: UI 상태 관리 (위젯 액션이 UseCase 호출을 필요로 하면 여기에 전용 Controller 생성)
  - `/sign_in`: 로그인 화면
  - `/splash`: 스플래시 화면
- `/lib/router`: 화면 전환 로직

## 코드 생성
- `freezed` + `json_serializable` + `riverpod_generator` 사용
- Domain Entity: `@freezed` (JSON 없음), Data Model: `@freezed` + `fromJson`
- Provider: `@riverpod` 또는 `@Riverpod(keepAlive: true)` 어노테이션 사용
- 생성 파일(`*.g.dart`, `*.freezed.dart`)은 분석에서 제외됨
- 코드 생성 명령어: `dart run build_runner build --delete-conflicting-outputs`

## 에러 핸들링
- `fpdart`의 `Either<Exception, T>` 패턴 사용 (Use Case 반환 타입)
- `left()` = 실패, `right()` = 성공

## 아키텍처 설계 결정

### 권한 검증 위치 (D2)
Firestore Security Rules가 주 보안 레이어. UseCase 레벨 검증은 현재 미구현.
- `approveMember`, `updateMemberRole` 등 관리자 전용 작업: Firestore Rules에서 검증
- UseCase 레벨 검증은 UX 향상(더 나은 에러 메시지) 목적으로 필요 시 추가 가능
- 보안 경계는 Firestore Rules, 도메인 규칙 명시는 UseCase

### ReservationUseCase → StoreRepository 의존성 (D3)
현행 유지: `ReservationUseCaseImpl`이 `StoreRepository`를 주입받아 가격 계산에 사용.
- `_applyCalculatedPrice`: 예약 생성/수정 전 점포 요금 설정 기반 계산 (필수 비즈니스 로직)
- PricingService 분리는 과도한 추상화 — 현재 규모에서 허용

### Common Exceptions 레이어 배치 (D4)
`common/exceptions/` 를 모든 레이어 공유 위치로 유지.
- Firebase 에러 코드 기반이지만 도메인 의미를 가진 경계 예외
- Domain Entity가 직접 참조하지 않는 한 Data→Domain 의존 발생하지 않음
- 예외 추가 시 도메인별 파일 분리 유지 (`auth_exceptions.dart`, `store_exceptions.dart` 등)

### UseCase-Provider 파일 분리 (D5)
`lib/domain/use_cases/*_use_case_provider.dart`: DI 배선 파일로 data layer import 허용.
- `*_use_case.dart`: 순수 Domain (interface + impl), data import 금지
- `*_use_case_provider.dart`: `@riverpod` 팩토리만 포함, data import 허용

## Either / TaskEither 패턴

- 기본 패턴: `result.fold((error) => left(error), (value) => ...)` (함수형)
- `isLeft()` / `isRight()` + `getLeft().toNullable()!` 명령형 스타일 사용 금지
- `TaskEither` 체이닝: `.flatMap()` → `.run()` 순서
- 불가피한 예외 (FCM 토큰 제거처럼 실패를 허용해야 하는 경우): `fold` 내에서 try-catch 허용

## Git 컨벤션
- 브랜치: `feat/#<이슈번호>-<설명>`, `fix/#<이슈번호>-<설명>`
- 커밋: `<type>: #<이슈번호> - <한국어 설명>`
- 기본 브랜치: `develop` (PR 대상)

## 빌드 및 실행
- `flutter run` - 앱 실행
- `dart run build_runner build --delete-conflicting-outputs` - 코드 생성
- `dart run build_runner watch` - 코드 생성 (watch 모드)
- `flutter test` - 테스트 실행
- `dart analyze` - 정적 분석

## 폰트 및 디자인
- 기본 폰트: Pretendard (400, 500, 600, 700)
- Material 3 디자인 시스템 사용

## 성능 규칙
- `ref.watch(provider)` → 필요한 필드만 `select` 사용 (`ref.watch(provider.select((s) => s.field))`)
- `build()` 내 루프에서 `DateTime.now()` 등 반복 호출 금지 → 루프 밖 `final` 변수로 1회만
- 복수 `ScrollController`를 Map으로 관리 시: `hasClients = false` 감지 → dispose 후 재생성

## Reservation 도메인 구조

- **Firestore 경로**: `stores/{storeId}/reservations/{reservationId}` (서브컬렉션)
- `platform: ReservationPlatform` enum (`lib/domain/enums/reservation_platform.dart`)
- `paymentMethod: PaymentMethod` enum (`lib/domain/enums/payment_method.dart`)
- Repository 조회 시 `currentUid` 필요 — StoreSummary의 color를 user의 `storeById[storeId].color`에서 조회
- color 폴백: `StoreColor.red` (currentUser가 storeById에 해당 점포 없을 때)

## 중요 사항
- API Key 관련 문자열은 gitignore 처리되어있는 별도 파일로 분리하고 import하여 사용
- `Future.wait([f1, f2])` — f1, f2의 **반환 타입이 다르면** `List<Object?>`로 추론됨 → 타입별 별도 Future 변수로 분리할 것
  ```dart
  // ❌ Future.wait([StoreModel?, UserModel?]) → List<Object?>
  // ✅ 별도 Future 변수로 시작 후 순차 await (실제로는 병렬 실행)
  final storeF = _storeDataSource.getStore(id);
  final userF = _userDataSource.getUser(uid);
  final store = await storeF;
  final user = await userF;
  ```

## 모달 시트 패턴

- `DraggableScrollableSheet` 사용 금지 — 내부 gesture tracking이 `BottomSheet.onClosing → Navigator.pop`을 독립 호출, `GestureDetector`/`Listener` 우회 불가
- 두 detent 시트: `showModalBottomSheet(isScrollControlled: true, enableDrag: false)` + `LayoutBuilder` + `AnimationController(lowerBound: initialSize, upperBound: 1.0)`
  - 드래그: `Listener.onPointerMove` → `_controller.value = clamp(...)` 직접 조작
  - 스냅: `onPointerUp` → `_controller.animateTo(target)`
  - dismiss: `Navigator.pop()` 직접 호출 (route 기본 exit 애니메이션 활용)
  - `lowerBound`는 반드시 `initialSize`로 설정 — `0.0`이면 dismiss 중 Column overflow 발생
- 모드 전환 간 스크롤 위치 보존: `Stack + Positioned.fill + Offstage` × 2 + 모드별 독립 `ScrollController`
  - 전환 전 `_syncScrollPosition()` 호출 필수 (setState 이전에)

## Presentation → Domain 접근 규칙

- 위젯(`ConsumerWidget`, `ConsumerStatefulWidget`)에서 `*_use_case_provider.dart` 직접 `ref.read/watch` 금지
- 위젯 액션이 UseCase 호출을 필요로 하면 `lib/presentation/providers/`에 전용 `@riverpod` Controller(Notifier) 생성하여 위임
- 예: `HomeReservationActionsController` — `TimeGrid`/`AllDayCell`의 예약 수정 액션을 위임

## Agent Working Rules

- 관련 파일 먼저 읽고 수정
- 최소 수정 우선
- 여러 파일 수정 시 계획 먼저 설명
- 빌드 깨지면 즉시 복구
- 기존 패턴 우선
