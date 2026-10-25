# ADR 도입 전 설계 결정 (D2\~D13)

`docs/adr/`가 생기기 전에 CLAUDE.md에 기록했던 결정들이다. ADR과 같은 무게로 취급한다.
코드 주석의 `(D12)` 같은 번호가 이 문서의 항목을 가리킨다. 번호는 바꾸지 않는다 (D1·D6은 결번).
새 결정은 이 문서가 아니라 번호를 붙인 ADR(`docs/adr/NNNN-*.md`)로 남긴다.

## 권한 검증 위치 (D2)
Firestore Security Rules가 주 보안 레이어. UseCase 레벨 검증은 UX 향상(더 나은 에러 메시지) 목적으로 필요 시 추가한다.
- `approveMember`, `updateMemberRole` 등 관리자 전용 작업: Firestore Rules에서 검증
- 점포 관리자 1명 불변식은 Rules가 멤버 값의 모양으로 센다 (`docs/adr/0004-single-admin-counted-in-rules.md`). UseCase도 관리자 역할을 주거나 빼앗는 요청을 거부한다
- 보안 경계는 Firestore Rules, 도메인 규칙 명시는 UseCase

## ReservationUseCase → StoreRepository 의존성 (D3)
현행 유지: `ReservationUseCaseImpl`이 `StoreRepository`를 주입받아 가격 계산에 사용.
- `_applyCurrentPrice`: 점포의 현재 요금표로 계산하고 그 요금표를 예약에 스냅샷(`Reservation.priceSetting`)으로 저장 (필수 비즈니스 로직)
- PricingService 분리는 과도한 추상화 — 현재 규모에서 허용

## Common Exceptions 레이어 배치 (D4)
`common/exceptions/` 를 모든 레이어 공유 위치로 유지.
- Firebase 에러 코드 기반이지만 도메인 의미를 가진 경계 예외
- Domain Entity가 직접 참조하지 않는 한 Data→Domain 의존 발생하지 않음
- 예외 추가 시 도메인별 파일 분리 유지 (`auth_exceptions.dart`, `store_exceptions.dart` 등)

## UseCase-Provider 파일 분리 (D5)
`lib/domain/use_cases/*_use_case_provider.dart`: DI 배선 파일로 data layer import 허용.
- `*_use_case.dart`: 순수 Domain (interface + impl), data import 금지
- `*_use_case_provider.dart`: `@riverpod` 팩토리만 포함, data import 허용

## 점포 폼 컨트롤러 패턴 (D7)
`abstract interface class StoreFormControllerable` + `mixin StoreFormMixin` 조합으로 생성/수정 컨트롤러가 공통 인터페이스를 구현.
- `StoreFormControllerable`: 생성/수정 컨트롤러가 구현해야 할 메서드 계약 정의
- `StoreFormMixin`: 공통 로직(setter, SpaceOption/DayGroup/TimeSlot CRUD)을 Mixin으로 재사용
- 신규 점포 폼 컨트롤러 추가 시 두 파일 모두 참고: `store_form_controllerable.dart`

## 공휴일 요금 — isHoliday 콜백 패턴 (D8)
`PriceSetting.calculatePrice(isHoliday: bool Function(DateTime date)?)`로 날짜별 공휴일 판단을 호출부 콜백에 위임 (다일 예약 시 날짜별로 다른 공휴일 여부를 반영하기 위함).
- `Weekday.holiday`(JsonValue=8)는 `DateTime.weekday`(max=7)로 절대 매칭 불가 — 외부 판단 필수
- 판단 근거는 공휴일 달력(`HolidayCalendar`, `holidays/{year}`) — ADR-0001\~0003 참고
  - UseCase: `HolidayRepository`를 주입받아 직접 판정. 읽기 실패 시 공휴일이 아닌 것으로 계산(저장을 막지 않음)
  - "모르는 연도는 공휴일 아님" 규칙은 `HolidayCalendar.isHolidayForPricing` 하나로 UseCase·두 모달이 공유한다
  - 모달을 열 때 `refreshYears`로 그 연도를 다시 조회한다 — 앱을 켜둔 사이 달력이 바뀌면 화면 가격과 저장 가격이 어긋나기 때문
  - 모달: keepAlive `HolidayCalendarController`의 동기 조회. 홈 진입 시 올해·내년분 선로딩
- 공휴일 요일 그룹이 없는 요금표는 공휴일에 **실제 요일 요금**을 받는다 (`PriceSetting._dayGroupFor`)
- 판정한 날짜 범위는 `pricedDatesOf` 하나로 정한다 (하루종일=각 날짜, 시간 지정=예약이 걸친 모든 날짜 — 자정을 넘으면 날짜별 요일 그룹으로 나눠 계산). 계산과 공휴일 스냅샷이 이 함수를 공유해야 어긋나지 않는다

## 앱 최초 실행 인증 데이터 삭제 (D9)
`SharedPreferences` `hasLaunchedBefore` 플래그로 앱 최초 설치 실행을 감지하여 기존 인증 데이터 삭제.
- iOS Keychain은 앱 삭제 후에도 인증 토큰이 잔존 → 재설치 후 로그인 없이 진입하는 문제 방지
- `main_dev.dart`, `main_prod.dart`의 `_checkFirstLaunchAndClearData()`에 구현

## 단순 위임 UseCase 허용 (D10)
`UserUseCaseImpl`처럼 모든 메서드가 Repository에 단일 라인으로 위임하는 UseCase도 의도적으로 허용.
- 목적: Presentation → UseCase → Repository 계층 규칙을 지키기 위함 (Presentation이 Repository를 직접 호출하지 않도록 강제)
- 현재 비즈니스 로직이 없다는 이유로 UseCase 계층 자체를 생략하지 않음 — 향후 검증/가공 로직이 필요해지면 이 계층에 추가

## stores read 최소 권한 (D11)
`stores` read는 `isMember()` 전용. 비멤버의 초대 코드 조회는 Callable `lookupInviteCode`가 대신한다.
- 새 컬렉션(`inviteCodes`) 분리 대신 Callable을 고른 이유: 표시용 필드 비정규화가 없어 점포 정보가 낡지 않고,
  만료 판정이 서버 시각으로 이뤄지며, 발급 경로(`createInviteCode`, ADMIN이므로 이미 멤버)를 건드리지 않는다.
- 대가는 `cloud_functions` 의존성과 cold start. 초대 코드 입력은 온보딩 1회성이라 감내한다.
- `stores`를 읽는 클라이언트 경로는 `getStore` 하나뿐이며 호출부는 전부 멤버 전제다
  (마이페이지 ADMIN 행, 예약 상세, 승인 대기 모달, 예약 가격 계산).

## 예약 요금표 스냅샷 (D12)
예약 수정 시 점포의 현재 요금이 아니라 **예약에 저장된 요금표**로 재계산한다. 점포 요금이 바뀌어도 기존 예약 가격이 저절로 바뀌지 않게 하기 위함.
- 현재 요금표를 쓰는 경우: 사용자가 상세 모달의 '현재 요금 적용'을 누름(`applyCurrentPrice`), 점포·공간이 바뀜, 저장된 스냅샷이 없음
- 비교 기준은 UseCase가 조회한 저장된 예약이다 — 화면이 보낸 스냅샷은 신뢰하지 않는다 (D3)
- 판단 규칙은 `Reservation.keepsPriceSettingFor`(엔티티 extension) 하나를 상세 모달과 `ReservationUseCaseImpl.updateReservation`이 공유한다 — 규칙이 갈라지면 화면 가격과 저장 가격이 어긋난다
- **공휴일 스냅샷도 같은 원칙** (`Reservation.holidayDates`, ADR-0003): 저장된 예약 기간 안의 날짜는 스냅샷, 밖으로 옮긴 날짜는 현재 공휴일 달력으로 판정(`holidayCheckerFor`). '현재 요금 적용'은 요금표 또는 공휴일 판정(`holidaysDifferFromCurrent`)이 다를 때 노출

## 점포 수정 동시 수정 감지 (D13)
점포 수정은 트랜잭션에서 **편집 가능 필드**(`StoreModel.toEditableJson`)를 폼을 연 시점의 값과 비교하고, 다르면 `StoreUpdateConflictException`으로 실패한다. 화면은 안내 후 최신 점포로 폼을 다시 채운다(사용자 수정분은 버림 — 요금표는 중첩 구조라 병합하면 상대 변경이 조용히 사라진다).
- `updatedAt`·문서 갱신 시각으로 비교하지 않는다 — 가입 승인·역할 변경도 바꾸므로 멤버가 들어올 때마다 오탐한다
- 버전 필드 + Rules 검증 대신 필드 비교를 고른 이유: 클라이언트가 이 앱 하나뿐이라 서버 강제의 가치가 작고, 스키마·Rules·배포 순서가 늘지 않는다
- 비교는 Repository가 한다(`StoreRepositoryImpl._comparableEditableJson`). 폼의 점포는 legacy fallback(`legacy_default` 공간)을 거친 엔티티이므로 저장 직전 문서도 같은 fallback·변환을 거쳐야 한다. DataSource는 `isUnchanged` 콜백만 실행한다
- 수정 화면에 넘기는 점포는 진입 직전에 새로 조회한다(`StoreEditController.loadStoreForEdit`) — 캐시된 `storeDetailProvider` 값이면 저장할 때마다 충돌한다
- 점포명 캐시(`users/{uid}.storeById.{storeId}.name`)는 같은 트랜잭션에서 사용자 문서를 먼저 읽어 **그 점포 항목이 이미 있는 사용자에게만** 쓴다. 점포 문서에는 승인 대기자로 남았는데 사용자 문서에는 항목이 없는 어긋난 데이터에 점 경로 update를 하면 role 없는 `{name}` 항목이 생겨, 그 사용자를 읽는 점포 조회(멤버 hydrate)가 전부 파싱에 실패한다
