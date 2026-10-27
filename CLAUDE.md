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
- UI 위젯은 `package:material_ui/material_ui.dart`·`package:cupertino_ui/cupertino_ui.dart`에서 import한다. `package:flutter/material.dart`·`cupertino.dart`는 CI가 막는다 (이유는 `ci.yml`의 해당 단계 주석)
  - 아직 `flutter/material`을 쓰는 서드파티 위젯(현재 `kpostal`)은 `MaterialUiCompatibilityBridge`로 그 위젯만 감싼다
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
  - `deprecated_member_use`는 warning이라 `dart analyze`와 CI가 실패한다
  - 의존성은 Dependabot(`.github/dependabot.yml`)이 분기마다 PR을 연다. PR 처리와 분기 수동 점검: `docs/operations.md`
- Context7 MCP가 응답하지 않거나 사용량 초과 등으로 사용 불가한 상태여도 작업을 멈추지 말고, 기존 지식으로 진행할 것. 단, 기존 지식만으로 해결이 어려우면 공식 문서를 별도로 확인할 것

## 아키텍처
Clean Architecture + MVVM. 폴더별 세부 구성은 `lib/`를 직접 본다.
- `lib/common`: 모든 계층이 공유하는 enum·예외·변환기·유틸. 예외는 `common/exceptions/`에 도메인별 파일로 둔다 (D4)
- `lib/constants`: 모든 계층이 공유하는 상수
- `lib/data`: DataSource(Firestore·Gemini 연결)·Data Model·Repository 구현체. Firestore DataSource는 `FirestoreDataSourceBase`를 상속한다
- `lib/domain`: Entity·Repository 인터페이스·UseCase
  - `*_use_case.dart`는 data 계층을 import하지 않는다. data를 import하는 DI 배선은 `*_use_case_provider.dart`에만 둔다 (D5)
  - Repository에 위임만 하는 UseCase도 생략하지 않는다 — Presentation이 Repository를 직접 부르지 않게 한다 (D10)
- `lib/presentation`: 화면별 폴더와 `providers/`(UI 상태). 온보딩·마이페이지가 공유하는 플로우와 공통 위젯은 `commons/`
- `lib/router`: 화면 전환
- 권한의 보안 경계는 Firestore Rules다. UseCase 검증은 더 나은 오류 메시지를 위한 것이다 (D2)
- 코드 주석의 `(D12)` 같은 번호는 ADR 도입 전 설계 결정이다 → `docs/adr/legacy-decisions.md`. 번호가 붙은 코드의 동작을 바꾸기 전에 그 항목을 읽는다

## 코드 생성
- `freezed` + `json_serializable` + `riverpod_generator` 사용
- Domain Entity: `@freezed` (JSON 없음), Data Model: `@freezed` + `fromJson`
- Provider: `@riverpod` 또는 `@Riverpod(keepAlive: true)` 어노테이션 사용
- 생성 파일(`*.g.dart`, `*.freezed.dart`)은 분석에서 제외됨
- 코드 생성 명령어: `dart run build_runner build --delete-conflicting-outputs`

## 에러 핸들링
- `fpdart`의 `Either<Exception, T>` 패턴 사용 (Use Case 반환 타입)
- `left()` = 실패, `right()` = 성공

## Either / TaskEither 패턴

- 기본 패턴: `result.fold((error) => left(error), (value) => ...)` (함수형)
- `isLeft()` / `isRight()` + `getLeft().toNullable()!` 명령형 스타일 사용 금지
- `TaskEither` 체이닝: `.flatMap()` → `.run()` 순서
- 불가피한 예외 (FCM 토큰 제거처럼 실패를 허용해야 하는 경우): `fold` 내에서 try-catch 허용

## Git 컨벤션
- 브랜치: `feat/#<이슈번호>-<설명>`, `bug/#<이슈번호>-<설명>`, `refactor/#<이슈번호>-<설명>` — 이슈 Type(`Feature`/`Bug`/`Refactor`)에 맞춰 고른다
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
- Dependabot PR은 이슈 없이 열리므로 위 커밋·브랜치·PR 제목 컨벤션의 예외다

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
  클라이언트는 `UserFirestoreDataSource._fcmDocRef`를 통해서만 접근한다 (쓰기 규칙은 그 주석 참고)
- **발송**: Cloud Functions v2 (`functions/`, TypeScript, Node 24, 리전 `asia-northeast3`)
  - `notifyAdminsOnJoinRequest`: `stores/{storeId}` 문서의 `waitingMemberById`에 키가 추가되면 해당 점포 ADMIN 전원에게 발송
  - `notifyOnMembershipChange`: 멤버 구성 변화(관리자 위임·나가기·추방·승인·거절·점포 삭제)를 당사자에게 발송. 분류 규칙은 `functions/src/notifications/membership_change.ts`
  - 발송 실패 응답에서 폐기된 토큰을 감지해 `users/{uid}/private/fcm`의 `tokens`에서 자동 제거 — 클라이언트는 토큰 추가만 하면 된다
  - 테스트: `cd functions && npm test` (Node 내장 `node:test`)
  - 배포와 `firebase.json`/`.firebaserc` 준비: `docs/operations.md`
- **수신**: `NotificationController`(`lib/presentation/providers/`)가 `MyApp`에서 watch되어 권한 요청·토큰 등록·스트림 구독·딥링크를 담당
  - **포그라운드 표시는 플랫폼별로 경로가 다르다** — Android는 FCM SDK가 표시하지 않으므로 `flutter_local_notifications`로 직접 표시하고, iOS는 시스템이 표시하게 하며 로컬 알림을 띄우지 않는다
  - iOS의 포그라운드 표시 옵션을 끄면 알림이 **아예 보이지 않는다** (이유는 `NotificationController` 주석, 확인 방법은 `docs/operations.md`)
- **Functions와 앱이 공유하는 값**(알림 `data.type`, 채널 ID, 초대 코드 유효 시간 등)은 계약 테스트 `functions/src/contract/shared_constants.test.ts`가 검사한다. 새 공유 값을 만들면 이 테스트에 추가한다
- **알려진 제약**: FCM Admin SDK가 registration token을 deprecated 처리하고 FID를 권장한다. 현행은 token 기반이며 FID 마이그레이션은 별도 이슈.

## Callable Cloud Function

- `lookupInviteCode` (`functions/src/invite/`): 초대 코드로 **가입 전 표시 정보만** 조회한다 (D11).
  리전 `asia-northeast3`, `enforceAppCheck: true`, 인증 필수. 응답에 넣으면 안 되는 필드, 실패를 판별 값으로 돌려주는 이유,
  브루트포스 카운터 규칙은 `lookup_invite_code.ts`와 `store_data_source.dart`의 주석에 있다
  - 클라이언트: `cloud_functions` 패키지, `FirebaseFunctions.instanceFor(region: 'asia-northeast3')`.
  - **dev 실기기에서 초대 코드 조회가 전부 "권한이 없습니다"로 실패하면** App Check 디버그 토큰 미등록을 의심한다 → `docs/operations.md`

## Firestore 에뮬레이터 테스트

- Rules: `functions/src/rules/*.test.ts` + `@firebase/rules-unit-testing`.
- Functions 쿼리: `functions/src/queries/*.test.ts` + Admin SDK. 실제 Firestore와 결과가 갈릴 수 있는 쿼리와 `recursiveDelete` 동작을 검증한다
  - 대상 파일 옆이 아니라 `queries/`에 둔다. `test:unit`이 `invite/` 등의 테스트를 에뮬레이터 없이 통째로 돌리기 때문이다
- 실행: `cd functions && npm run test:emulator` (에뮬레이터 필요) / `npm run test:unit` (불필요) / `npm test` (둘 다).
- Rules를 고쳤으면 `npm run test:emulator`를 반드시 돌린다. `fake_cloud_firestore`는 Rules를 적용하지 않는다.
- 앱 DataSource 테스트는 `fake_cloud_firestore`를 쓴다. 에뮬레이터로 옮기지 않은 이유와 다시 판단할 시점은 `test/helpers/fake_firestore_helper.dart` 주석

## 공휴일 달력

- 설계: `docs/adr/0001`(Functions 동기화) · `0002`(예측 공휴일, 연도째 교체) · `0003`(공휴일 스냅샷)
- **`syncHolidays`** (`functions/src/holidays/`): 매일 04:00 KST. 연도는 KST로 계산
  - 공식: 특일 정보 API `getRestDeInfo` 작년\~+2년, 월 단위 12회 호출. 한 달이라도 실패하면 그 연도는 건너뛴다
  - 예측: 올해\~2050년 중 공식이 없는 연도. `korean-lunar-calendar`가 2050년까지만 지원해 그 이후는 문서가 없다 (해가 지날수록 범위가 줄어든다 — ADR-0002)
    — 중국 음력 라이브러리(`lunar-javascript` 등)는 설날이 하루 어긋나는 해가 있어 쓰면 안 된다
  - 문서 `holidays/{year} = { days: {'yyyy-MM-dd': [이름...]}, source, syncedAt }`. `source`는 덮어쓰기 판단용이며 앱은 읽지 않는다
- **법령이 바뀌면 `predict_holidays.ts`를 고친다** (고칠 곳과 주의할 점은 그 파일 주석)
- 날짜 키 `yyyy-MM-dd` 형식은 서버(`HolidayDays`)·앱(`holidayDateKey`)·스냅샷이 공유한다
- 배포 전 Secret 설정과 첫 배포 직후 수동 실행: `docs/operations.md`

## 만료 문서 자동 정리

- **TTL 정책**은 `firestore.indexes.json`의 `fieldOverrides`(`ttl: true`)에 있다. 만료 후 최대 24시간 안에 지워진다
  - `stores.expiresAt`: 점포 삭제 후 7일(`storeSoftDeleteDays`, 운영자 수동 복구 여유). 계정 삭제로 지운 점포는 바로 만료된다
  - `inviteLookupAttempts.expiresAt`: 시도 창이 끝나는 시각(`expiresAtOf`)
- **`cascadeStoreDelete`** (`functions/src/stores/`): 점포 문서가 지워지면 `recursiveDelete`로 예약 등 서브컬렉션을 지운다. TTL은 서브컬렉션을 지우지 않는다
- **`purgeDeletedUsers`** (`functions/src/users/`): 매주 월요일 04:30 KST. 삭제한 지 7일(`PURGE_GRACE_DAYS`)이 지났고 작성한 예약이 하나도 남지 않은 삭제된 계정의 문서를 지운다 (ADR-0005)
- 지워지기 전까지 만료 문서가 쿼리에 잡히므로 `getStore` 등의 `deletedAt` 가드는 유지한다
- dev 동작 확인 절차: `docs/operations.md`

## Firestore Rules / Functions 배포 순서

`firebase deploy --only functions` → `--only firestore:indexes` → `--only firestore:rules` → 앱 배포.
- Rules보다 Functions가 먼저여야 한다. 반대로 하면 Rules만 조여진 구간에서 초대 코드 조회가 실패한다
- TTL(`firestore:indexes`)보다 `cascadeStoreDelete`가 먼저여야 한다. 반대로 하면 그 사이 지워진 점포의 예약이 고아가 된다

## 마이페이지 / 하단 탭바

- 예약 통계(`stats`) 탭은 화면이 없어 탭해도 아무 동작도 하지 않는다 (`_onTabTapped`의 TODO).
- `/my-page` 하위는 온보딩과 동일한 `_roleSubRoutes()`를 재사용한다 — 점포 추가 플로우를 중복 구현하지 않는다.
- 승인 대기 멤버 관리는 `showPendingMemberModal(context, storeId)` 모달이며, 마이페이지의 ADMIN 점포 행과 FCM 알림 딥링크 두 곳에서 같은 모달을 연다.
- 점포 수정은 최상위 `/store-edit` 라우트(`pushStoreEdit`)다. 마이페이지 ADMIN 행의 연필 버튼과 예약 계산 내역 시트의 '요금 설정' 버튼이 `StoreEditLauncher` mixin으로 연다. 시트에서 열 때는 예약 모달을 닫지 않고 그 위에 쌓는다.
- 승인 시 역할은 **신청자가 초대 코드 단계에서 고른 값을 그대로** 쓴다. 관리자가 역할을 바꾸려면 승인 후 `updateMemberRole`을 쓴다 (해당 UI는 미구현).

## 토스트 알림

- 짧은 알림은 `showAppToast(context, message)`(`commons/widgets/app_toast.dart`)를 쓴다. `ScaffoldMessenger.showSnackBar`를 직접 부르면 화면 위에 열린 바텀시트에 가려진다 (구조는 `ToastHost` 주석)

## 모달 시트 패턴

- `DraggableScrollableSheet`는 쓰지 않는다 — 내부 gesture tracking이 `BottomSheet.onClosing → Navigator.pop`을 독립 호출해 `GestureDetector`/`Listener`로 막을 수 없다
- 두 detent 시트: `showModalBottomSheet(isScrollControlled: true, enableDrag: false)` + `LayoutBuilder` + `AnimationController(lowerBound: initialSize, upperBound: 1.0)` (구현 예시: `reservation_detail_modal.dart`)
  - 드래그는 `Listener.onPointerMove`에서 `_controller.value`를 직접 조작, 스냅은 `onPointerUp`에서 `animateTo`, dismiss는 `Navigator.pop()` 직접 호출
  - `lowerBound`는 반드시 `initialSize` — `0.0`이면 dismiss 중 Column overflow가 난다
- 모드 전환 간 스크롤 위치 보존: `Stack + Positioned.fill + Offstage` × 2 + 모드별 독립 `ScrollController`. 전환 전(setState 이전) `_syncScrollPosition()` 호출

## 화면 전환 전 데이터 로딩 패턴

화면/모달을 열기 전에 데이터를 조회할 때 (구현 예시: `home_screen.dart` `_onAddReservation`):
- 탭 즉시 `_isLoading = true`로 중복 호출을 막고, fetch와 동시에 1초 `Timer`를 시작해 만료되면 `_showOverlay = true`로 `LoadingOverlay`(Stack 최상단, Scaffold 전체를 덮음)를 띄운다
- 1초를 기다리는 이유: 바로 띄우면 캐시 히트처럼 빠른 응답에서도 오버레이가 깜빡인다. 느릴 때만 보이게 한다
- 완료·오류 모두 `finally`에서 타이머 취소와 두 플래그 reset. 화면 전환은 `finally` 이후에 한다
- `dispose()`에서 타이머를 취소한다

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
