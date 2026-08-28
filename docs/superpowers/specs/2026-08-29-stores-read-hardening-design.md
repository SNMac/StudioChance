# stores read 권한 강화 및 Rules 테스트 하네스 설계

- 작성일: 2026-08-29
- 관련 이슈: [#13](https://github.com/SNMac/StudioChance/issues/13), [#39](https://github.com/SNMac/StudioChance/issues/39)
- 브랜치: `feat/#13-stores-read-rules`

## 배경

`firestore.rules`의 `stores` read 규칙이 `request.auth != null`이다. 로그인한 사용자
누구나 모든 점포 문서 전체를 읽을 수 있고, 계좌 정보(`bankName`·`bankAccountNumber`·
`bankAccountHolder`), `memberById`, `waitingMemberById`, `inviteInfo`가 함께 노출된다.

규칙을 완화한 이유는 초대 코드 조회 때문이다. `getStoreByInviteCode`가
`where('inviteInfo.inviteCode', isEqualTo: code)` 쿼리를 클라이언트에서 실행하는데,
이 시점의 사용자는 아직 해당 점포의 멤버가 아니다.

코드를 조사해 확인한 사실:

- `stores` 문서를 읽는 경로는 `getStore`와 `getStoreByInviteCode` 둘뿐이다.
  `getStore`의 호출부(마이페이지 ADMIN 행, 예약 상세, 승인 대기 모달)는 **전부 이미
  멤버인 경우**이므로 `read: isMember()`로 조여도 깨지지 않는다.
- 대기(waiting) 상태 사용자는 `users.storeById`에 점포가 들어가지만, 마이페이지는
  ADMIN인 점포에 대해서만 점포 문서를 읽으므로 영향이 없다.
- 따라서 **비멤버가 넘어야 하는 경계는 초대 코드 조회 하나뿐이다.**
- 발급(`createInviteCode`)은 ADMIN이 수행하므로 이미 멤버다. 서버로 옮길 필요가 없다
  (이슈 본문의 "방안 1은 발급도 Functions로 이전해야 한다"는 전제는 아래 채택안에
  해당하지 않는다).

`fcmTokens`(#39)도 같은 파일과 같은 에뮬레이터 셋업을 공유하므로 한 브랜치에서 함께
처리한다.

## 채택안

이슈의 **방안 2** — 초대 코드 조회만 Callable Cloud Function으로 옮기고, Rules에서
`stores read`를 멤버로 제한한다.

`inviteCodes` 별도 컬렉션(방안 1) 대비 이점:

- 표시용 필드를 비정규화하지 않으므로 점포 정보가 낡을 여지가 없다
- 만료 판정이 서버 시각으로 이뤄져 `system/serverTime` 왕복이 이 경로에서 사라진다
- 새 컬렉션·새 Rules 표면이 늘지 않고, 발급 경로를 건드리지 않는다
- 브루트포스 제한을 붙일 자리가 생긴다 (현재 클라이언트 쿼리 방식에는 수단이 없다)

대가는 `cloud_functions` 패키지 추가와 cold start 레이턴시다. 초대 코드 입력은 온보딩
1회성·저빈도 동작이라 감내한다.

## 1. Firestore Rules

```javascript
match /stores/{storeId} {
  function isAdmin() { /* 기존 그대로 */ }
  function isMember() {
    return request.auth != null
        && request.auth.uid in resource.data.memberById;
  }

  allow read:   if isMember();            // 변경 (기존: request.auth != null)
  allow create: if request.auth != null;  // 유지
  allow update, delete: if isAdmin();     // 유지
  allow update: if /* 가입 신청 규칙 */;    // 유지 — read와 독립 평가되므로 계속 동작
}

match /users/{uid}/private/{docId} {      // 신규 (#39)
  allow read, write: if request.auth != null && request.auth.uid == uid;
}
```

`users/{uid}` read는 `request.auth != null`을 유지한다. 멤버 이름 표시를 위해 서로의
문서를 읽어야 하고, 민감했던 값은 `fcmTokens` 하나이므로 그것만 서브컬렉션으로 격리한다.

브루트포스 카운터 컬렉션 `inviteLookupAttempts`에는 **Rules를 추가하지 않는다.** 최상단
default-deny가 클라이언트 접근을 막고, Admin SDK는 Rules를 우회한다.

## 2. Callable Function `lookupInviteCode`

```
위치: functions/src/invite/
리전: asia-northeast3 (Firestore 리전과 일치)
enforceAppCheck: true, 인증 필수

요청: { code: string }        // 6자 [A-Z0-9], 서버에서 형식 검증
응답: { storeId, storeName, address, addressDetail, adminName }
```

`adminName`은 `memberById`에서 ADMIN 1명을 골라 그 사용자의 `users` 문서에서 조합한다.
찾지 못하면 빈 문자열을 반환한다(현행 클라이언트 동작과 동일). 계좌 정보·`memberById`·
`waitingMemberById`·`inviteInfo`는 응답에 포함하지 않는다.

에러 매핑:

| HttpsError | 조건 | 클라이언트 처리 |
|---|---|---|
| `unauthenticated` | 미로그인 | 인증 예외 |
| `invalid-argument` | 코드 형식 불량 | `StoreValidationException` |
| `not-found` | 코드 없음 / `deletedAt` 있음 | `right(null)` — 현행 "없으면 null" 계약 유지 |
| `deadline-exceeded` | 만료 (서버 시각으로 판정) | `StoreInviteCodeExpiredException` |
| `failed-precondition` | `inviteInfo.createdAt` 없음 | `StoreValidationException` |
| `resource-exhausted` | 시도 한도 초과 | `StoreInviteCodeRateLimitedException` (신규) |

`FirebaseFunctionsException`은 `FirebaseException`을 상속하므로 기존
`FirestoreDataSourceBase.handleFirestoreError` → `mapFirebaseCode(code, message)` 경로를
그대로 탄다. 새 에러 핸들링 기반 클래스는 필요 없다.

### 브루트포스 제한

```
컬렉션: inviteLookupAttempts/{uid}   → { count, windowStartAt }
창: 10분 / 한도: 실패 10회 → resource-exhausted
증가: 실패(not-found · deadline-exceeded)에만. 성공 시 문서 삭제
```

정상 사용자는 오타 몇 번이면 끝나므로 10회/10분에 걸리지 않는다. 공격자 기준으로는
계정당 1,440회/일인데 코드 공간이 32⁶ ≈ 10.7억이고 코드 수명이 15분이라 실질적으로
봉쇄된다.

알려진 한계 (`ponytail:` 주석으로 코드에 표기):

- 트랜잭션 없이 read → write이므로 동시 요청이 한도를 약간 넘길 수 있다. 정확한 쿼터가
  아니라 공격 비용 승수가 목적이다
- 계정을 여러 개 만들면 우회 가능하다. 로그인이 Google/Apple뿐이라 생성 비용이 있다
- 카운터 문서는 정리하지 않는다(오타 낸 사용자당 1개). 필요해지면 Firestore TTL 정책으로
  정리한다

## 3. Flutter 계층

### 신규

- `pubspec.yaml`: `cloud_functions` (firebase_core 4.x 호환 버전은 설치 시점에 확인)
- `domain/entities/invite_store_preview.dart` — `@freezed`,
  `{storeId, storeName, address, addressDetail, adminName}`
- `data/models/invite_store_preview_model.dart` — `@freezed` + `fromJson`
- `common/exceptions/store_exceptions.dart`에 `StoreInviteCodeRateLimitedException`
- `presentation/commons/extensions/address_formatter.dart`에 `InviteStorePreview`용
  `formattedAddress` extension (기존 두 개와 동일 패턴)

### 변경

| 위치 | 변경 |
|---|---|
| `StoreDataSource` | `getStoreByInviteCode → StoreModel?` 삭제, `lookupInviteCode(code) → InviteStorePreviewModel?` 추가 (`FirebaseFunctions.instanceFor(region: 'asia-northeast3')` 주입) |
| `StoreDataSource.mapFirebaseCode` | `deadline-exceeded`·`resource-exhausted`·`unauthenticated` 매핑 추가 |
| `StoreRepositoryImpl.getStoreByInviteCode` | 반환 타입 교체. **만료 검증·`getServerTime` 호출·`_fetchMembersWithRoles` 2회를 삭제** (서버가 대신한다) |
| `StoreRepository` / `StoreUseCase` | 시그니처 `Either<Exception, InviteStorePreview?>` |
| `InviteCodeVerificationState.status` | `AsyncValue<Store?>` → `AsyncValue<InviteStorePreview?>` |
| `invite_code_verification_controller` | `store?.name` → `preview?.storeName`, `store.id` → `preview.storeId` |
| `invite_code_verified_screen` | `memberInfos.where(admin)...` 조합 삭제 → `preview.adminName` 표시. 주소는 새 extension으로 동일 축약 |

`joinStore`(가입 신청 쓰기)는 `storeId`만 필요하므로 변경하지 않는다.

`createInviteCode`의 "유효 코드 재사용" 판정은 클라이언트에 남으므로 `system/serverTime`
규칙과 왕복 조회는 유지한다.

## 4. fcmTokens 격리 (#39)

```
users/{uid}.fcmTokens: string[]   →   users/{uid}/private/fcm  { tokens: string[] }
```

`fcmTokens`는 앱 로직에서 읽는 곳이 한 군데도 없는 순수 저장용 필드다(`User` 엔티티에도
없다). `UserModel`에서 필드 자체를 삭제하고 서브문서만 다룬다.

| 위치 | 변경 |
|---|---|
| `UserModel` | `fcmTokens` 필드 삭제 (freezed 재생성) |
| `createUser` | `json['fcmTokens']` 주입 삭제 → `{String? fcmToken}` 파라미터를 받아 WriteBatch로 user 문서 + `private/fcm` 동시 생성 |
| `recordLogin` | batch로 분리. 서브문서는 `set({tokens: arrayUnion([t])}, merge: true)` — **`update`는 문서가 없으면 실패**하므로 반드시 merge set |
| `addFcmToken` / `removeFcmToken` | 같은 merge set 패턴으로 서브문서 대상 |
| `replaceFcmToken` | 트랜잭션 대상을 서브문서로 |
| `softDeleteUser` | batch: user 문서 update + `private/fcm` `{tokens: []}` |
| `user_repository_impl.dart:59` | `UserModel(fcmTokens: ...)` → `createUser(model, fcmToken: token)` |
| `functions/src/index.ts` | `getAll(users/{uid})` → `getAll(users/{uid}/private/fcm)`. `doc.id`로 소유자를 되찾던 방식이 깨지므로 **인덱스로 `adminUids[i]`와 짝짓는다.** 폐기 토큰 정리도 서브문서 `tokens` arrayRemove로 |

부수 효과: 토큰 쓰기가 `users/{uid}.updatedAt`을 더 이상 건드리지 않는다(쓰기 감소).

## 5. Rules 테스트 하네스 (#39)

`functions/` 워크스페이스에 `@firebase/rules-unit-testing`을 추가한다. 테스트는
`functions/src/rules/*.test.ts`에 두고 빌드 결과 `lib/rules/`를 실행한다.

`firebase.json`과 `.firebaserc`는 gitignore되어 있어 CI에서 쓸 수 없다. 저장소 루트에
**테스트 전용 최소 설정 `firebase.emulator.json`을 추가로 추적**한다. 배포 정보(appId·
projectId)는 여전히 제외된 채로 남고, 추적되는 값은 포트 번호와 rules 경로뿐이다.

```json
{
  "firestore": { "rules": "firestore.rules" },
  "emulators": { "firestore": { "port": 8080 }, "ui": { "enabled": false } }
}
```

```
test:unit  : node --test "lib/notifications/**/*.test.js"
test:rules : firebase emulators:exec --config ../firebase.emulator.json \
             --only firestore --project demo-studio-chance \
             "node --test lib/rules/**/*.test.js"
test       : test:unit && test:rules
```

에뮬레이터 없이 도는 순수 단위 테스트와 스크립트를 분리해야 CI가 깨지지 않는다.
`functions/.gitignore`에 `firestore-debug.log`를 추가한다(에뮬레이터가 cwd에 남긴다).

### 실측 검증 (2026-08-29)

설계 확정 전에 위 구성을 실제로 실행해 확인했다. 현행 `firestore.rules` 그대로 3건 통과:

```
✔ 현행 규칙: 비멤버도 stores를 읽을 수 있다 (이슈 #13의 취약점)
✔ 비로그인은 stores를 읽지 못한다
✔ 멤버는 stores를 읽을 수 있다
```

- `--config`로 저장소 밖 경로를 줘도 동작하고, `firestore.rules` 상대 경로는 **config
  파일이 있는 디렉터리 기준**으로 풀린다
- `demo-` 프리픽스 프로젝트라 자격증명도 `.firebaserc`도 필요 없다
- exec가 실행하는 명령의 cwd는 호출 위치(`functions/`)가 유지되므로
  `node --test lib/rules/**/*.test.js`가 그대로 동작한다
- `initializeTestEnvironment`가 rules 파일을 직접 읽으므로 config의 역할은 에뮬레이터를
  켜는 것뿐이다

### 커버리지

- `users` 본인 / 타인 / 비로그인
- `users/{uid}/private/*` 본인만
- `stores` read — 멤버 / 비멤버 / 대기멤버
- `stores` 가입 신청 update — 자기 항목만 허용, 타 필드 차단
- `stores` update·delete — ADMIN만
- `stores/{storeId}/reservations` — ADMIN / STAFF / VIEWER / 비멤버
- `system/serverTime` — `probe == request.time` 검증
- `inviteLookupAttempts` — 클라이언트 완전 차단

## 6. 테스트 전략

| 대상 | 방식 |
|---|---|
| Callable 순수 로직 | 코드 형식 검증·만료 판정·rate limit 창 계산을 `functions/src/invite/`의 순수 함수로 분리해 `node:test` |
| onCall 본체 / Firestore I/O | 테스트 제외 — 기존 `index.ts` 트리거와 동일 방침 |
| `InviteStorePreviewModel.fromJson` | 단위 테스트 |
| `StoreDataSource.mapFirebaseCode` | 새 에러 코드 매핑 단위 테스트 |
| DataSource의 callable 래퍼 | **테스트 제외** — `HttpsCallable` 목킹 비용이 검증 가치를 넘는다. 파싱과 에러 매핑을 위 두 줄로 따로 덮는다 |
| Repository / UseCase / Controller | 기존 mocktail 테스트를 새 타입으로 갱신 |

영향받는 기존 테스트 파일:

```
test/data/data_sources/store_data_source_test.dart        # getStoreByInviteCode 블록 삭제
test/data/data_sources/user_data_source_test.dart         # fcmTokens 경로 갱신
test/data/repositories/store_repository_integration_test.dart
test/data/repositories/store_repository_invite_test.dart
test/domain/use_cases/store_use_case_test.dart
test/presentation/commons/invite_code/controllers/invite_code_verification_controller_test.dart
test/presentation/providers/invite_code_controller_test.dart
test/presentation/my_page/pending_member_modal_test.dart
```

## 7. 작업 순서

커밋 단위이자 TDD 순서다.

1. **하네스 구축** — `firebase.emulator.json`, devDeps, `test:unit`/`test:rules` 분리,
   `.gitignore`. 현행 Rules 기준 테스트를 먼저 작성해 **"비멤버가 stores를 읽을 수 있다"는
   현 상태를 테스트로 고정**한다
2. **fcmTokens 격리** — Rules에 `users/{uid}/private/*` 추가(실패 테스트 → 통과), Flutter
   DataSource·Model, `functions/index.ts` 조회 경로
3. **Callable `lookupInviteCode`** — 순수 함수 + 테스트 → onCall 조립 → rate limit
4. **Flutter 조회 경로 교체** — 엔티티·모델·DataSource·Repository·UseCase·State·화면
5. **`stores read` 조이기** — Rules 한 줄. 1단계에서 고정한 "비멤버 읽힘" 테스트를
   **"비멤버 차단"으로 뒤집는다**
6. CI 워크플로에 `test:rules` 추가, 이슈 체크리스트 정리

5를 마지막에 두는 이유는 4가 끝나기 전에 조이면 앱이 깨지기 때문이다.

## 8. 배포 및 마이그레이션

배포 순서(dev → prod): `firebase deploy --only functions` → `--only firestore:rules` →
앱 실행. 반대로 하면 Rules만 조여진 구간에서 초대 코드 조회가 실패한다.

마이그레이션은 없다. 정식 출시 전이므로 기존 `users.fcmTokens` 값은 버리고 재로그인 시 새
위치에 다시 쌓인다(CLAUDE.md 방침). dev 환경에서 재로그인 전까지 알림이 가지 않을 수 있다.

## 9. 이번 범위 밖

- 사용자 하드 삭제 시 `users/{uid}/private` 서브컬렉션 정리 — 하드 삭제 자체가 미구현이다.
  구현 시 서브컬렉션이 부모 문서와 함께 삭제되지 않는다는 점을 반영해야 한다
- `createInviteCode`의 "유효 코드 재사용" 판정을 서버로 이전 — 그래서
  `system/serverTime` 왕복이 유지된다
- FCM registration token → FID 마이그레이션 (별도 이슈)
