# 프로젝트: SpaceManager
> 가제: StudioChance

Firebase, Riverpod, GoRouter, Clean Architecture, MVVM을 사용하는 공간대여업 예약 관리 크로스플랫폼(iOS, Android) 앱입니다.
- Firebase 서비스: Firestore, Authentication, Crashlytics, Cloud Message, Analytics, App Check
- 소셜 로그인: Google, Apple
  - 정식 출시 후 Naver, Kakao 추가 예정
- **출시 상태**: 아직 정식 출시 전 (시점 미정). prod 프로젝트에 실사용자·실데이터가 없다

## 코드 스타일
- Flutter/Dart 사용
- Dart 컨벤션 사용
- 콘솔 출력 시 `logger` 라이브러리 사용
- 한국어로 커밋 메시지, 주석 작성
- 앱 내에서 ID를 자체 생성할 때는 `uuid` 패키지의 `const Uuid().v4()` 사용 (`DateTime.now().millisecondsSinceEpoch` 금지)

## 마크다운 작성
- 마크다운으로 쓰는 모든 글(저장소 문서, PR·이슈 본문 등)에서 범위를 물결표로 쓸 때는 `\~`로 이스케이프한다
  - GitHub 등 여러 마크다운 렌더러가 `~`로 감싼 부분을 취소선으로 바꾸므로, 한 문단에 `~`가 두 번 나오면 그 사이가 취소선이 된다
  - 렌더러마다 다르게 보이지 않도록 GitHub에 올리지 않는 문서도 같은 규칙을 따른다
  - 예: `약 11~13회, 약 25~30회`는 "13회, 약 25"에 취소선이 그어진다. `약 11\~13회`로 쓴다
  - 백틱 코드 표기 안의 `~`는 그대로 둔다

## 라이브러리 문서 조회
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
  - `/my_page`: 마이페이지 화면 (점포 목록, 승인 대기 모달 `widgets/pending_member_modal.dart`)
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
- `_applyCurrentPrice`: 점포의 현재 요금표로 계산하고 그 요금표를 예약에 스냅샷(`Reservation.priceSetting`)으로 저장 (필수 비즈니스 로직)
- PricingService 분리는 과도한 추상화 — 현재 규모에서 허용

### 예약 요금표 스냅샷 (D12)
예약 수정 시 점포의 현재 요금이 아니라 **예약에 저장된 요금표**로 재계산한다. 점포 요금이 바뀌어도 기존 예약 가격이 저절로 바뀌지 않게 하기 위함.
- 현재 요금표를 쓰는 경우: 사용자가 상세 모달의 '현재 요금 적용'을 누름(`applyCurrentPrice`), 점포·공간이 바뀜, 저장된 스냅샷이 없음
- 비교 기준은 UseCase가 조회한 저장된 예약이다 — 화면이 보낸 스냅샷은 신뢰하지 않는다 (D3)
- 판단 규칙은 `Reservation.keepsPriceSettingFor`(엔티티 extension) 하나를 상세 모달과 `ReservationUseCaseImpl.updateReservation`이 공유한다 — 규칙이 갈라지면 화면 가격과 저장 가격이 어긋난다
- **공휴일 스냅샷도 같은 원칙** (`Reservation.holidayDates`, ADR-0003): 저장된 예약 기간 안의 날짜는 스냅샷, 밖으로 옮긴 날짜는 현재 공휴일 달력으로 판정(`holidayCheckerFor`). '현재 요금 적용'은 요금표 또는 공휴일 판정(`holidaysDifferFromCurrent`)이 다를 때 노출

### 점포 수정 동시 수정 감지 (D13)
점포 수정은 트랜잭션에서 **편집 가능 필드**(`StoreModel.toEditableJson`)를 폼을 연 시점의 값과 비교하고, 다르면 `StoreUpdateConflictException`으로 실패한다. 화면은 안내 후 최신 점포로 폼을 다시 채운다(사용자 수정분은 버림 — 요금표는 중첩 구조라 병합하면 상대 변경이 조용히 사라진다).
- `updatedAt`·문서 갱신 시각으로 비교하지 않는다 — 가입 승인·역할 변경도 바꾸므로 멤버가 들어올 때마다 오탐한다
- 버전 필드 + Rules 검증 대신 필드 비교를 고른 이유: 클라이언트가 이 앱 하나뿐이라 서버 강제의 가치가 작고, 스키마·Rules·배포 순서가 늘지 않는다
- 비교는 Repository가 한다(`StoreRepositoryImpl._comparableEditableJson`). 폼의 점포는 legacy fallback(`legacy_default` 공간)을 거친 엔티티이므로 저장 직전 문서도 같은 fallback·변환을 거쳐야 한다. DataSource는 `isUnchanged` 콜백만 실행한다
- 수정 화면에 넘기는 점포는 진입 직전에 새로 조회한다(`StoreEditController.loadStoreForEdit`) — 캐시된 `storeDetailProvider` 값이면 저장할 때마다 충돌한다
- 점포명 캐시(`users/{uid}.storeById.{storeId}.name`)는 같은 트랜잭션에서 사용자 문서를 먼저 읽어 **그 점포 항목이 이미 있는 사용자에게만** 쓴다. 점포 문서에는 대기 멤버로 남았는데 사용자 문서에는 항목이 없는 어긋난 데이터에 점 경로 update를 하면 role 없는 `{name}` 항목이 생겨, 그 사용자를 읽는 점포 조회(멤버 hydrate)가 전부 파싱에 실패한다

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
`PriceSetting.calculatePrice(isHoliday: bool Function(DateTime date)?)`로 날짜별 공휴일 판단을 호출부 콜백에 위임 (다일 예약 시 날짜별로 다른 공휴일 여부를 반영하기 위함).
- `Weekday.holiday`(JsonValue=8)는 `DateTime.weekday`(max=7)로 절대 매칭 불가 — 외부 판단 필수
- 판단 근거는 공휴일 달력(`HolidayCalendar`, `holidays/{year}`) — 아래 "공휴일 달력" 섹션 참고
  - UseCase: `HolidayRepository`를 주입받아 직접 판정. 읽기 실패 시 공휴일이 아닌 것으로 계산(저장을 막지 않음)
  - "모르는 연도는 공휴일 아님" 규칙은 `HolidayCalendar.isHolidayForPricing` 하나로 UseCase·두 모달이 공유한다
  - 모달을 열 때 `refreshYears`로 그 연도를 다시 조회한다 — 앱을 켜둔 사이 달력이 바뀌면 화면 가격과 저장 가격이 어긋나기 때문
  - 모달: keepAlive `HolidayCalendarController`의 동기 조회. 홈 진입 시 올해·내년분 선로딩
- 공휴일 요일 그룹이 없는 요금표는 공휴일에 **실제 요일 요금**을 받는다 (`PriceSetting._dayGroupFor`)
- 판정한 날짜 범위는 `pricedDatesOf` 하나로 정한다 (하루종일=각 날짜, 시간 지정=예약이 걸친 모든 날짜 — 자정을 넘으면 날짜별 요일 그룹으로 나눠 계산). 계산과 공휴일 스냅샷이 이 함수를 공유해야 어긋나지 않는다

### 앱 최초 실행 인증 데이터 삭제 (D9)
`SharedPreferences` `hasLaunchedBefore` 플래그로 앱 최초 설치 실행을 감지하여 기존 인증 데이터 삭제.
- iOS Keychain은 앱 삭제 후에도 인증 토큰이 잔존 → 재설치 후 로그인 없이 진입하는 문제 방지
- `main_dev.dart`, `main_prod.dart`의 `_checkFirstLaunchAndClearData()`에 구현

### 단순 위임 UseCase 허용 (D10)
`UserUseCaseImpl`처럼 모든 메서드가 Repository에 단일 라인으로 위임하는 UseCase도 의도적으로 허용.
- 목적: Presentation → UseCase → Repository 계층 규칙을 지키기 위함 (Presentation이 Repository를 직접 호출하지 않도록 강제)
- 현재 비즈니스 로직이 없다는 이유로 UseCase 계층 자체를 생략하지 않음 — 향후 검증/가공 로직이 필요해지면 이 계층에 추가

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
- 기본 브랜치: `develop` (PR 대상). 모든 작업은 `develop`에서 분기해 `develop`으로 머지한다
- `main`은 **출시 브랜치**다. 정식 출시 시점에 `develop`을 `main`에 머지하며, 그 전까지는 건드리지 않는다
  (현재 `main`은 `develop`보다 한참 뒤처져 있는 것이 정상이다)
- Type(이슈·PR 공통): `Feature`, `Bug`, `Refactor` (첫 글자 대문자)
- 이슈 제목: `<Type>/<한국어 설명>` — **이슈번호를 넣지 않는다**(생성 시점엔 번호가 없다)
  - 예: `Feature/마이페이지 실제 디자인으로 재구현`, `Bug/iOS APNs 키 미설정으로 푸시 알림 전부 실패`
- PR 제목: `<Type>/#<이슈번호> <한국어 설명>` — 이슈 제목과 달리 **번호가 들어가고**, 커밋 메시지 형식(`<type>: #N - ...`)과도 다르다
  - 예: `Feature/#41 가입 신청 제출 UI 배선 (점포 확인 화면)`, `Bug/#35 시스템 글자 크기 설정에 따른 레이아웃 깨짐 방지`
- 이슈 본문: `.github/ISSUE_TEMPLATE/issue_template.md`의 **섹션 구성을 그대로 따를 것**
  — `## 📄 이슈 내용`(인용구 한 문단 요약) / `## 📝 상세 내용`(불릿) / `## ✅ 체크리스트`(`- [ ]`), 섹션 사이 `<br>`
- PR 본문: `.github/PULL_REQUEST_TEMPLATE.md`의 **섹션 구성을 그대로 따를 것**
  — `## #️⃣ 연관된 이슈`(`- #N`) / `## 📝 작업 내용`(불릿) / `## 📸 스크린샷`(표), 섹션 사이 `<br>`
  - **UI 변경이 없는 작업이면 스크린샷 섹션을 통째로 생략한다** — 빈 표나 "해당 없음" 같은 문구를 남기지 않는다. 서버·Rules·리팩터링처럼 보여줄 화면이 없는 PR이 적지 않다
- **PR·이슈 본문에 Claude Code 생성 표기를 넣지 않는다** — `🤖 Generated with [Claude Code]...` 꼬리말과 세션 링크 모두. 템플릿에 없는 섹션이고, 세션 링크는 저장소 바깥을 가리켜 리뷰어에게 쓸모가 없다
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
- Either 결과는 `test/helpers/either_expectations.dart`의 `expectRight`·`expectLeft`로 검증한다 — 테스트에서도 `isRight()`·`getRight().toNullable()` 명령형 스타일을 쓰지 않는다 (실패 시 실제 예외·값이 메시지에 찍힌다)

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
- **점포 이동**: 예약은 점포 서브컬렉션에 있으므로 점포를 바꾸면 `update`가 아니라 **이동**이다.
  `updateReservation(fromStoreId:)`가 다르면 `moveReservation`이 트랜잭션으로 원래 문서를 지우고 새 점포에 같은 id로 만든다
  - 작성자(`writerId`/`writerRole`)는 옮긴 사람과 새 점포에서의 역할로 바뀐다. 새 점포 멤버가 아니면 `ReservationPermissionDeniedException`
  - `createdAt`은 원래 값 유지, 요금은 새 점포의 현재 요금표 적용 (D12)
  - 상세 모달은 모달을 연 채 이동할 수 있으므로 삭제·안내문·권한 판단에 `widget.reservation`이 아니라 마지막 저장값(`_saved`)을 쓴다

## 중요 사항
- 정식 출시 전이라 prod에 실데이터가 없다 — Firestore 스키마 변경 시 기존 데이터 마이그레이션은 고려하지 않아도 됨
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
  클라이언트는 `UserFirestoreDataSource._fcmDocRef`를 통해서만 접근한다. 토큰을 추가·교체·제거하는
  경로(`recordLogin`, `addFcmToken`, `replaceFcmToken`, `removeFcmToken`)는 반드시
  `set(..., merge: true)`를 쓴다 — `update`는 문서가 없으면 실패하는데 첫 로그인 기기에는 서브문서가 없다.
  문서를 처음 만드는 `createUser`와 전체를 비우는 `softDeleteUser`는 `SetOptions` 없이 쓰는 것이 맞다.
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
  - **dev 실기기 테스트 전 App Check 디버그 토큰 등록이 필요하다.** 이 앱에서 App Check를
    실제로 강제하는 첫 경로라, 등록하지 않으면 초대 코드 조회가 전부 "권한이 없습니다"로
    떨어진다(`mapFirebaseCode`가 `unauthenticated` → `StorePermissionDeniedException`).
    화면에는 원인이 드러나지 않으므로 반드시 서버 로그로 판별한다 —
    `firebase functions:log --only lookupInviteCode -P dev`에
    `{"verifications":{"auth":"VALID","app":"INVALID"}}`가 찍히면 이 경우다.
    토큰은 **기기·앱 설치 단위**라 기기를 바꾸거나 앱을 재설치하면 새로 발급된다.
    - Android: 앱 시작 시 logcat의 `DebugAppCheckProvider`에 출력
    - iOS: Xcode 콘솔에 `App Check debug token:`으로 출력. 안 보이면 스킴의
      Arguments Passed on Launch에 `-FIRDebugEnabled`를 추가한다
      (`main_dev.dart`는 Android·Apple **양쪽** 디버그 Provider를 켠다)
    - 등록: Firebase 콘솔 **Security > App Check > Apps** 탭에서 해당 앱의 ⋮ 메뉴 →
      **Manage debug tokens**. Android 앱과 iOS 앱은 **각각 따로** 등록해야 한다.
      (Firebase CLI에는 `appcheck` 명령이 없다 — 자동화가 필요하면 App Check REST API의
      `projects.apps.debugTokens`를 쓴다)
    prod는 Play Integrity / App Attest를 쓰므로 이 절차가 필요 없다.

## Firestore Rules 테스트

- `functions/src/rules/*.test.ts` + `@firebase/rules-unit-testing`.
  실행: `cd functions && npm run test:rules` (에뮬레이터 필요) / `npm run test:unit` (불필요) / `npm test` (둘 다).
- `firebase.json`은 gitignore되어 있으므로 테스트 전용 최소 설정 `firebase.emulator.json`을 별도로 추적한다.
- `createTestEnv(suffix)`는 **파일마다 고유한 projectId**를 쓴다 —
  `node --test`가 파일을 병렬 실행해 `clearFirestore()`가 서로의 시드를 지우기 때문.
- Rules를 고쳤으면 이 테스트를 반드시 돌린다. `fake_cloud_firestore`는 Rules를 적용하지 않는다.

## 공휴일 달력

- 설계: `docs/adr/0001`(Functions 동기화) · `0002`(예측 공휴일, 연도째 교체) · `0003`(공휴일 스냅샷)
- **`syncHolidays`** (`functions/src/holidays/`): 매일 04:00 KST. 연도는 KST로 계산
  - 공식: 특일 정보 API `getRestDeInfo` 작년\~+2년, 월 단위 12회 호출. 한 달이라도 실패하면 그 연도는 건너뛴다
  - 예측: 올해\~2050년 중 공식이 없는 연도. `korean-lunar-calendar`가 2050년까지만 지원해 그 이후는 문서가 없다 (해가 지날수록 범위가 줄어든다 — ADR-0002)
    — 중국 음력 라이브러리(`lunar-javascript` 등)는 설날이 하루 어긋나는 해가 있어 쓰면 안 된다
  - 문서 `holidays/{year} = { days: {'yyyy-MM-dd': [이름...]}, source, syncedAt }`. `source`는 덮어쓰기 판단용이며 앱은 읽지 않는다
- **법령이 바뀌면 `predict_holidays.ts`를 고친다**: 대체공휴일 대상(관공서 공휴일 규정 제3조), 선거 임기 기준일 상수 `ELECTIONS`(궐위·조기 선거 시)
  - 「공휴일에 관한 법률」과 「관공서의 공휴일에 관한 규정」은 선거일·임시공휴일의 **호 번호가 다르다** — 주석에 번호를 적을 때 섞지 말 것
- **배포 전 Secret 설정**(dev·prod 각각): `firebase functions:secrets:set DATA_GO_KR_SERVICE_KEY -P dev`
- **배포 직후 1회 수동 실행**: 스케줄 첫 실행이 다음 날 새벽이므로 Cloud Scheduler 콘솔에서 `syncHolidays` 작업을 "강제 실행"
- 날짜 키 `yyyy-MM-dd` 형식은 서버(`HolidayDays`)·앱(`holidayDateKey`)·스냅샷이 공유한다

## Firestore Rules / Functions 배포 순서

`firebase deploy --only functions` → `--only firestore:rules` → 앱 배포.
반대로 하면 Rules만 조여진 구간에서 초대 코드 조회가 실패한다.

## 마이페이지 / 하단 탭바

- `HomeTabBar`(`lib/presentation/home/widgets/`)는 홈·마이페이지가 **공유**한다. 선택 인덱스는 로컬 state가 아니라 `GoRouterState.of(context).uri.path`에서 파생하므로 두 화면의 표시가 어긋나지 않는다.
- 예약 통계(`stats`) 탭은 화면이 없어 탭해도 아무 동작도 하지 않는다 (`_onTabTapped`의 TODO).
- `/my-page` 하위는 온보딩과 동일한 `_roleSubRoutes()`를 재사용한다 — 점포 추가 플로우를 중복 구현하지 않는다.
- 승인 대기 멤버 관리는 `showPendingMemberModal(context, storeId)` 모달이며, 마이페이지의 ADMIN 점포 행과 FCM 알림 딥링크 두 곳에서 같은 모달을 연다.
- 점포 수정은 최상위 `/store-edit` 라우트(`pushStoreEdit`)다. 마이페이지 ADMIN 행의 연필 버튼과 예약 계산 내역 시트의 '요금 설정' 버튼이 `StoreEditLauncher` mixin으로 연다. 시트에서 열 때는 예약 모달을 닫지 않고 그 위에 쌓는다.
- 승인 시 역할은 **신청자가 초대 코드 단계에서 고른 값을 그대로** 쓴다. 관리자가 역할을 바꾸려면 승인 후 `updateMemberRole`을 쓴다 (해당 UI는 미구현).

## 토스트 알림

- 짧은 알림은 `showAppToast(context, message)`(`commons/widgets/app_toast.dart`)를 쓴다. `ScaffoldMessenger.showSnackBar`를 직접 부르지 않는다
  - 화면 Scaffold의 SnackBar는 그 화면 위에 열린 바텀시트에 가려진다. 예약 모달 위에서 점포 수정을 저장하고 돌아오면 알림이 보이지 않았다
- `MyApp`의 `MaterialApp.builder`가 Navigator를 `ToastHost`(바깥 Scaffold)로 감싼다. ScaffoldMessenger는 중첩된 Scaffold 중 가장 바깥 것에만 SnackBar를 그리므로 토스트는 모든 route 위에 뜬다
- 캡슐은 글자 폭만큼만 차지해 바깥 터치를 막지 않는다. 화면 크기·키보드 높이는 앱 최상단 MediaQuery 기준으로 읽는다 (화면 Scaffold 안쪽에서는 키보드 높이가 지워진다)

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

- 최소 수정 우선
- 여러 파일 수정 시 계획 먼저 설명

## Agent skills

### Issue tracker

GitHub Issues(`SNMac/StudioChance`), `gh` CLI 사용. Linear는 자동 연동되므로 직접 쓰지 않는다. See `docs/agents/issue-tracker.md`.

### Triage labels

기본 5개 라벨 그대로 사용 (`needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`). See `docs/agents/triage-labels.md`.

### Domain docs

Single-context (루트 `CONTEXT.md` + `docs/adr/`). See `docs/agents/domain.md`.
