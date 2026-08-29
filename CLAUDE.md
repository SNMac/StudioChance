# 프로젝트: SpaceManager
> 가제: StudioChance

Firebase, Riverpod, GoRouter, Clean Architecture, MVVM을 사용하는 공간대여업 예약 관리 크로스플랫폼(iOS, Android) 앱입니다.
- Firebase 서비스: Firestore, Authentication, Crashlytics, Cloud Message, Analytics, App Check
- 소셜 로그인: Google, Apple
  - 정식 출시 후 Naver, Kakao 추가 예정
- **배포 예정 시점**: 2026-08 말 ~ 2026-09 초 (아직 정식 출시 전, 프로덕션 데이터 없음)

## 코드 스타일
- Flutter/Dart 사용
- Dart 컨벤션 사용
- 콘솔 출력 시 `logger` 라이브러리 사용
- 한국어로 커밋 메시지, 주석 작성
- 앱 내에서 ID를 자체 생성할 때는 `uuid` 패키지의 `const Uuid().v4()` 사용 (`DateTime.now().millisecondsSinceEpoch` 금지)

## 라이브러리 문서 조회
- 라이브러리/API 문서 확인, 코드 생성, 설정·구성 단계가 필요할 때는 명시적으로 요청하지 않아도 항상 Context7 MCP로 최신 문서를 조회할 것
- Deprecated API 사용은 지양 — 항상 최신 권장 API/패턴으로 구현할 것
- Context7 MCP가 응답하지 않거나 사용량 초과 등으로 사용 불가한 상태여도 작업을 멈추지 말고, 기존 지식으로 진행할 것. 단, 기존 지식만으로 해결이 어려우면 공식 문서를 별도로 확인할 것

## 아키텍처
- `/lib/common`: 모든 계층에서 사용되는 로직
  - `/utils/exception_utils.dart`: `toException()` — catch 블록 Object → Exception 변환 헬퍼
  - `/converters/timestamp_converter.dart`: `TimestampConverter` — Firestore `Timestamp` ↔ `DateTime` 변환. Data Model에 `@TimestampConverter()` 어노테이션으로 사용
  - `/enums`: 모든 계층에서 사용되는 enum (`@JsonEnum`/`@JsonValue`로 Firestore 직렬화 값 포함)
- `/lib/constants`: 모든 계층에서 사용되는 상수값
- `/lib/data`: Data 계층
  - `/data_sources`: DB 연결 로직
    - `firestore_data_source_base.dart`: `FirestoreDataSourceBase` — 모든 Firestore DataSource 기반 클래스. `errorLogTag`, `isDomainException`, `buildParsingException`, `mapFirebaseCode` 4개 멤버 구현 필요
    - `gemini_data_source.dart`: 예약 스크린샷 OCR — Firebase AI Vertex AI `gemini-2.5-flash-lite` 사용
  - `/models`: Data 모델
  - `/repositories`: Data 로직 구현체
- `/lib/domain`: Domain(비즈니스 로직) 계층
  - `/entities`: Domain 엔티티
  - `/repository_interfaces`: Domain에서 필요로 하는 Data 로직 인터페이스
  - `/use_cases`: 비즈니스 로직 단위
    - `use_case_helpers.dart`: `getCurrentUserOrThrow(UserRepository)` 공통 헬퍼
- `/lib/presentation`: UI 계층
  - `/commons`: 온보딩·마이페이지가 공유하는 플로우 화면 및 공통 위젯
    - `admin_store_registration/`: 관리자 점포 등록 화면
    - `invite_code/`: 초대 코드 입력/확인 화면
    - `nickname_input/`: 닉네임 입력 (온보딩/마이페이지 공유)
    - `role_selection/`: 역할 선택
    - `store_input/`: 점포 생성·수정 폼 화면
    - `extensions/`: UI 관련 extension 메서드 (포맷터, colors 등)
    - `widgets/`: 재사용 공통 위젯
  - `/home`: 홈 화면
  - `/my_page`: 마이페이지 화면 (미구현)
  - `/onboarding`: 닉네임 입력 화면 (온보딩 진입점만 포함, 나머지 플로우는 `/commons`에 위치)
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

### 점포 폼 컨트롤러 패턴 (D7)
`abstract interface class StoreFormControllerable` + `mixin StoreFormMixin` 조합으로 생성/수정 컨트롤러가 공통 인터페이스를 구현.
- `StoreFormControllerable`: 생성/수정 컨트롤러가 구현해야 할 메서드 계약 정의
- `StoreFormMixin`: 공통 로직(setter, SpaceOption/DayGroup/TimeSlot CRUD)을 Mixin으로 재사용
- 신규 점포 폼 컨트롤러 추가 시 두 파일 모두 참고: `store_form_controllerable.dart`

### 공휴일 요금 — isHoliday 콜백 패턴 (D8)
`PriceSetting.calculatePrice(isHoliday: bool Function(DateTime date)?)`로 날짜별 공휴일 판단을 호출부 콜백에 위임 (다일 예약 시 날짜별로 다른 공휴일 여부를 반영하기 위함, #15 [C-1]).
- `Weekday.holiday`(JsonValue=8)는 `DateTime.weekday`(max=7)로 절대 매칭 불가 — 외부 판단 필수
- 현재 모든 호출부(`_applyCalculatedPrice`, 두 예약 모달)는 `isHoliday: (date) => false` 고정 (TODO 주석)
- 향후 공공데이터포털 특일 정보 API 연동 시 `HolidayRepository`를 주입해 날짜별 판단 결과를 콜백으로 전달

### 앱 최초 실행 인증 데이터 삭제 (D9)
`SharedPreferences` `hasLaunchedBefore` 플래그로 앱 최초 설치 실행을 감지하여 기존 인증 데이터 삭제.
- iOS Keychain은 앱 삭제 후에도 인증 토큰이 잔존 → 재설치 후 로그인 없이 진입하는 문제 방지
- `main_dev.dart`, `main_prod.dart`의 `_checkFirstLaunchAndClearData()`에 구현

### 단순 위임 UseCase 허용 (D10)
`UserUseCaseImpl`처럼 모든 메서드가 Repository에 단일 라인으로 위임하는 UseCase도 의도적으로 허용.
- 목적: Presentation → UseCase → Repository 계층 규칙을 지키기 위함 (Presentation이 Repository를 직접 호출하지 않도록 강제)
- 현재 비즈니스 로직이 없다는 이유로 UseCase 계층 자체를 생략하지 않음 — 향후 검증/가공 로직이 필요해지면 이 계층에 추가
- 관련 이슈: [#15](https://github.com/SNMac/StudioChance/issues/15) [M-3]

### stores read 최소 권한 (D11)
`stores` read는 `isMember()` 전용. 비멤버의 초대 코드 조회는 Callable `lookupInviteCode`가 대신한다.
- 새 컬렉션(`inviteCodes`) 분리 대신 Callable을 고른 이유: 표시용 필드 비정규화가 없어 점포 정보가 낡지 않고,
  만료 판정이 서버 시각으로 이뤄지며, 발급 경로(`createInviteCode`, ADMIN이므로 이미 멤버)를 건드리지 않는다.
- 대가는 `cloud_functions` 의존성과 cold start. 초대 코드 입력은 온보딩 1회성이라 감내한다.
- `stores`를 읽는 클라이언트 경로는 `getStore` 하나뿐이며 호출부는 전부 멤버 전제다
  (마이페이지 ADMIN 행, 예약 상세, 승인 대기 모달, 예약 가격 계산).

## Either / TaskEither 패턴

- 기본 패턴: `result.fold((error) => left(error), (value) => ...)` (함수형)
- `isLeft()` / `isRight()` + `getLeft().toNullable()!` 명령형 스타일 사용 금지
- `TaskEither` 체이닝: `.flatMap()` → `.run()` 순서
- 불가피한 예외 (FCM 토큰 제거처럼 실패를 허용해야 하는 경우): `fold` 내에서 try-catch 허용

## Git 컨벤션
- 브랜치: `feat/#<이슈번호>-<설명>`, `bug/#<이슈번호>-<설명>`
- 커밋: `<type>: #<이슈번호> - <한국어 설명>`
- 포맷 전용 변경(`dart format`이 손대지 않은 기존 파일까지 재배치한 결과)은 기능 커밋에 섞지 말고 별도 `style:` 커밋으로 분리 — 리뷰 시 실제 변경을 가려내기 어려워짐
  - `dart format`은 디렉터리 전체가 아니라 **수정한 파일만** 지정해서 실행할 것
- 기본 브랜치: `develop` (PR 대상)
- PR 제목: `<Type>/#<이슈번호> <한국어 설명>` — 커밋 메시지 형식(`<type>: #N - ...`)과 다름에 주의
  - Type: `Feature`, `Bug`, `Refactor` (첫 글자 대문자)
  - 예: `Feature/#17 OCR 점포·공간 자동 선택`, `Bug/#35 시스템 글자 크기 설정에 따른 레이아웃 깨짐 방지`
- PR 본문: `.github/PULL_REQUEST_TEMPLATE.md` 형식을 따를 것 (연관된 이슈 / 작업 내용 / 스크린샷)
- 이슈 본문: `.github/ISSUE_TEMPLATE/issue_template.md` 형식을 따를 것 (이슈 내용 / 상세 내용 / 체크리스트)
- 이슈는 GitHub Issues에서 생성 (GitHub ↔ Linear 자동 연동)

## 빌드 및 실행
- `flutter run --flavor dev --target lib/main_dev.dart` - dev 플레이버 실행 (App Check 항상 Debug Provider)
- `flutter run --flavor prod --target lib/main_prod.dart` - prod 플레이버 실행 (릴리즈: Play Integrity / App Attest)
  - `--flavor` 생략 시 Android 빌드가 APK를 찾지 못하고 실패한다 (productFlavors 정의됨)
- `dart run build_runner build --delete-conflicting-outputs` - 코드 생성
- `dart run build_runner watch` - 코드 생성 (watch 모드)
- `flutter test` - 테스트 실행
- `dart analyze` - 정적 분석

## 테스트 작성 규칙
- 위젯 테스트는 픽셀 크기·색상 hex·폰트 스타일·레이아웃 구조 등 UI 구현 디테일을 직접 assert하지 않음 — 상태 전이·콜백 호출·크래시 방지 등 동작(behavior)만 검증 (UI 리팩터링 시 무관한 테스트가 깨지는 것 방지)
- 예외: 테스트 대상 자체가 색상 팔레트 등 디자인 토큰 lookup table인 경우(`store_color_extensions_test.dart`)는 정확한 값 검증이 불가피하므로 허용

## 폰트 및 디자인
- 기본 폰트: Pretendard (400, 500, 600, 700)
- Material 3 디자인 시스템 사용

## 성능 규칙
- `ref.watch(provider)` → 필요한 필드만 `select` 사용 (`ref.watch(provider.select((s) => s.field))`)
- `build()` 내 루프에서 `DateTime.now()` 등 반복 호출 금지 → 루프 밖 `final` 변수로 1회만
- 복수 `ScrollController`를 Map으로 관리 시: `hasClients = false` 감지 → dispose 후 재생성

## Reservation 도메인 구조

- **Firestore 경로**: `stores/{storeId}/reservations/{reservationId}` (서브컬렉션)
- `platform: ReservationPlatform` enum (`lib/common/enums/reservation_platform.dart`)
- `paymentMethod: PaymentMethod` enum (`lib/common/enums/payment_method.dart`)
- Repository 조회 시 `currentUid` 필요 — StoreSummary의 color를 user의 `storeById[storeId].color`에서 조회
- color 폴백: `StoreColor.red` (currentUser가 storeById에 해당 점포 없을 때)

## 중요 사항
- 정식 출시 전(배포 예정 2026-08 말 ~ 2026-09 초)이므로 Firestore 스키마 변경 시 기존 데이터 마이그레이션은 고려하지 않아도 됨
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

## FCM 푸시 알림

- **토큰 저장 위치**: `users/{uid}/private/fcm` 문서의 `tokens: string[]`.
  `users/{uid}` 본문은 멤버 이름 표시 때문에 인증 사용자 전체에 읽기가 열려 있어 토큰을 둘 수 없다.
  클라이언트는 `UserFirestoreDataSource._fcmDocRef`를 통해서만 접근하고, 항상 `set(..., merge: true)`를 쓴다
  (`update`는 문서가 없으면 실패한다).
- **발송**: Cloud Functions v2 (`functions/`, TypeScript, Node 22, 리전 `asia-northeast3`)
  - `notifyAdminsOnJoinRequest`: `stores/{storeId}` 문서의 `waitingMemberById`에 키가 추가되면 해당 점포 ADMIN 전원에게 발송
  - 발송 실패 응답에서 폐기된 토큰을 감지해 `users/{uid}/private/fcm`의 `tokens`에서 자동 제거 — 클라이언트는 토큰 추가만 하면 된다
  - 배포: `firebase deploy --only functions -P dev` / `-P prod` (Blaze 요금제 필요)
  - 테스트: `cd functions && npm test` (Node 내장 `node:test`)
  - `firebase.json`/`.firebaserc`는 gitignore 처리되어 저장소에 없음 — 새로 clone한 환경에서 배포하려면 아래 내용을 직접 만들어야 한다
    ```json
    // firebase.json (functions 배포에 필요한 부분만)
    {
      "functions": [
        {
          "source": "functions",
          "codebase": "default",
          "ignore": ["node_modules", ".git", "firebase-debug.log", "firebase-debug.*.log"],
          "predeploy": ["npm --prefix \"$RESOURCE_DIR\" run build"]
        }
      ]
    }
    ```
    ```json
    // .firebaserc (-P dev / -P prod 별칭)
    {
      "projects": {
        "default": "studio-chance",
        "dev": "studio-chance",
        "prod": "studio-chance-prod"
      }
    }
    ```
- **수신**: `NotificationController`(`lib/presentation/providers/`)가 `MyApp`에서 watch되어 권한 요청·토큰 등록·스트림 구독·딥링크를 담당
  - **포그라운드 표시는 플랫폼별로 경로가 다르다**
    - Android: FCM SDK가 표시하지 않으므로 `flutter_local_notifications`로 직접 표시
    - iOS: `setForegroundNotificationPresentationOptions(alert·badge·sound)`를 **켜고** 시스템이 표시하게 한다. 로컬 알림은 **띄우지 않는다** (`NotificationController`의 `Platform.isIOS` 분기)
  - iOS에서 위 옵션을 끄면 알림이 **아예 보이지 않는다.** `UNUserNotificationCenterDelegate`가 `presentationOptions=0`을 반환하는데, 이 delegate는 수신 푸시뿐 아니라 앱이 `flutter_local_notifications`로 만든 알림까지 함께 억제한다 (배너 없이 알림 센터에만 쌓임)
    - 시뮬레이터 로그로 확인 가능: 꺼진 상태 `Received response 0` / `shouldPresentAlert: 0`, 켜진 상태 `Received response 7` / `shouldPresentAlert: YES`
    - 검증 방법: `xcrun simctl push <device> <bundleId> payload.apns` (APNs·FCM을 우회하므로 전달 경로가 아닌 **표시·탭 처리만** 검증됨)
- **값이 반드시 일치해야 하는 상수**
  - 채널 ID `sc_default`: `AndroidManifest.xml`의 `default_notification_channel_id`, Functions의 `ANDROID_CHANNEL_ID`, `lib/constants/notification_constants.dart`의 `notificationChannelId`
  - `data.type` `joinRequest`: Functions의 `JOIN_REQUEST_TYPE`, `joinRequestNotificationType`
  - 초대 코드 유효 시간 15분: `lib/constants/data_constants.dart`의 `storeInviteCodeAvailableMin`,
    `functions/src/invite/invite_code.ts`의 `INVITE_CODE_AVAILABLE_MIN`
- **알려진 제약**: FCM Admin SDK가 registration token을 deprecated 처리하고 FID를 권장한다. 현행은 token 기반이며 FID 마이그레이션은 별도 이슈.

## Callable Cloud Function

- `lookupInviteCode` (`functions/src/invite/`): 초대 코드로 **가입 전 표시 정보만** 조회.
  리전 `asia-northeast3`, `enforceAppCheck: true`, 인증 필수.
  - `stores` read가 멤버 전용이라 아직 멤버가 아닌 사용자가 넘어야 하는 유일한 경계다.
    계좌 정보·`memberById`·`waitingMemberById`·`inviteInfo`는 **절대 응답에 넣지 않는다.**
  - 도메인 실패는 `HttpsError`가 아니라 `{ok: false, reason}` 판별 값으로 반환한다.
    `mapFirebaseCode`가 DataSource의 모든 Firestore 호출과 공유되므로 `not-found`·
    `deadline-exceeded`에 초대 코드 전용 의미를 얹을 수 없다. 매핑은 `inviteLookupFailureOf`.
  - 브루트포스 카운터 `inviteLookupAttempts/{uid}`: 10분/10회. 성공해도 삭제하지 않는다
    (자기 코드로 리셋하는 우회 차단). Rules를 정의하지 않아 클라이언트는 접근 불가.
  - 클라이언트: `cloud_functions` 패키지, `FirebaseFunctions.instanceFor(region: 'asia-northeast3')`.

## Firestore Rules 테스트

- `functions/src/rules/*.test.ts` + `@firebase/rules-unit-testing`.
  실행: `cd functions && npm run test:rules` (에뮬레이터 필요) / `npm run test:unit` (불필요) / `npm test` (둘 다).
- `firebase.json`은 gitignore되어 있으므로 테스트 전용 최소 설정 `firebase.emulator.json`을 별도로 추적한다.
- `createTestEnv(suffix)`는 **파일마다 고유한 projectId**를 쓴다 —
  `node --test`가 파일을 병렬 실행해 `clearFirestore()`가 서로의 시드를 지우기 때문.
- Rules를 고쳤으면 이 테스트를 반드시 돌린다. `fake_cloud_firestore`는 Rules를 적용하지 않는다.

## Firestore Rules / Functions 배포 순서

`firebase deploy --only functions` → `--only firestore:rules` → 앱 배포.
반대로 하면 Rules만 조여진 구간에서 초대 코드 조회가 실패한다.

## 마이페이지 / 하단 탭바

- `HomeTabBar`(`lib/presentation/home/widgets/`)는 홈·마이페이지가 **공유**한다. 선택 인덱스는 로컬 state가 아니라 `GoRouterState.of(context).uri.path`에서 파생하므로 두 화면의 표시가 어긋나지 않는다.
- 예약 통계(`stats`) 탭은 화면이 없어 탭해도 아무 동작도 하지 않는다 (`_onTabTapped`의 TODO).
- `/my-page` 하위는 온보딩과 동일한 `_roleSubRoutes()`를 재사용한다 — 점포 추가 플로우를 중복 구현하지 않는다.
- 승인 대기 멤버 관리는 `showPendingMemberModal(context, storeId)` 모달이며, 마이페이지의 ADMIN 점포 행과 FCM 알림 딥링크 두 곳에서 같은 모달을 연다.
- 승인 시 역할은 **신청자가 초대 코드 단계에서 고른 값을 그대로** 쓴다. 관리자가 역할을 바꾸려면 승인 후 `updateMemberRole`을 쓴다 (해당 UI는 미구현).

## 모달 시트 패턴

- `DraggableScrollableSheet` 사용 금지 — 내부 gesture tracking이 `BottomSheet.onClosing → Navigator.pop`을 독립 호출, `GestureDetector`/`Listener` 우회 불가
- 두 detent 시트: `showModalBottomSheet(isScrollControlled: true, enableDrag: false)` + `LayoutBuilder` + `AnimationController(lowerBound: initialSize, upperBound: 1.0)`
  - 드래그: `Listener.onPointerMove` → `_controller.value = clamp(...)` 직접 조작
  - 스냅: `onPointerUp` → `_controller.animateTo(target)`
  - dismiss: `Navigator.pop()` 직접 호출 (route 기본 exit 애니메이션 활용)
  - `lowerBound`는 반드시 `initialSize`로 설정 — `0.0`이면 dismiss 중 Column overflow 발생
- 모드 전환 간 스크롤 위치 보존: `Stack + Positioned.fill + Offstage` × 2 + 모드별 독립 `ScrollController`
  - 전환 전 `_syncScrollPosition()` 호출 필수 (setState 이전에)

## 화면 전환 전 데이터 로딩 패턴

화면/모달 전환 전에 데이터를 미리 조회해야 할 때 (예: 예약 등록 모달 오픈 전 공간 옵션 조회):
- `ConsumerStatefulWidget`으로 로컬 상태(`_isLoading`, `_showOverlay`) + `Timer` 관리
- 버튼 탭 즉시 `_isLoading = true`로 중복 호출 차단
- fetch 시작과 동시에 1초 `Timer`를 시작하고, 타이머 콜백에서 `_showOverlay = true`로 `LoadingOverlay` 표시
- fetch가 완료되거나 오류가 수신되면 `finally`에서 즉시 타이머 취소 + 두 플래그 모두 reset — 모달/화면 전환은 `finally` 이후에 수행
- `LoadingOverlay`는 `Stack`의 최상단 레이어로 Scaffold 전체를 덮음
- `dispose()`에서 반드시 타이머 취소
- 구현 예시: `home_screen.dart` `_onAddReservation`

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
- superpowers 플랜 문서(`writing-plans`/`executing-plans`)대로 작업할 때: 각 스텝 구현 완료 시 해당 스텝 커밋 → 플랜 문서의 체크리스트 항목 체크 표시 후 별도 `docs:` 커밋 (예: `docs: #17 - Task 1 플랜 체크리스트 완료 표시`), 스텝 단위로 반복

