# 점포 가입 신청 FCM 알림 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 멤버가 점포 가입을 신청하면 해당 점포 관리자(ADMIN)의 모든 기기에 FCM 푸시 알림이 도착하고, 알림을 탭하면 승인 대기 멤버 모달이 열려 그 자리에서 승인·거절할 수 있다. 알림을 놓쳐도 마이페이지에서 같은 모달에 접근할 수 있다.

**Architecture:** 발송은 Cloud Functions v2 Firestore 트리거(`onDocumentUpdated('stores/{storeId}')`)가 `waitingMemberById`에 새로 추가된 키를 감지해 Admin SDK로 직접 보낸다 — 클라이언트는 발송에 관여하지 않으므로 서비스 계정 키가 앱에 들어가지 않는다. 수신측은 현재 토큰 수집만 하고 있어 알림이 표시조차 되지 않으므로, 권한 요청·토큰 갱신 반영·포그라운드 로컬 알림·알림 탭 라우팅을 `NotificationRepository` → `NotificationUseCase` → `NotificationController` 계층으로 새로 배선한다. 착지점인 마이페이지는 `HomeTabBar`에 이미 그려져 있으나 라우팅이 없는 3번째 탭을 GoRouter에 연결해 신설하며, 점포 추가 플로우는 `_roleSubRoutes()`를, 닉네임 변경은 `NicknameFormScreen`을 그대로 재사용한다.

**Tech Stack:** Cloud Functions v2 (TypeScript, Node 22, `firebase-functions` ^7, `firebase-admin` ^14), Firestore, FCM HTTP v1(Admin SDK), Flutter (`firebase_messaging` ^16.1.3, `flutter_local_notifications` ^22.3.0), Riverpod, GoRouter, freezed

**Spec:** [GitHub Issue #19](https://github.com/SNMac/StudioChance/issues/19) — 아래 "이슈 요구사항 대조표" 참조

---

## 이슈 요구사항 대조표

| 이슈 체크리스트 | 담당 Task |
|---|---|
| FCM 발송 방식 결정 (Cloud Functions trigger vs. 클라이언트 HTTP v1 직접 호출) | **결정 완료**: Cloud Functions Firestore 트리거 (Task 1~4) |
| 관리자 FCM 토큰 조회 로직 구현 | Task 3 (`adminUidsOf`), Task 4 (`users/{uid}.fcmTokens` 수집) |
| 알림 페이로드(제목, 본문) 정의 | Task 3 (`buildJoinRequestMessages`) |
| `store_repository_impl.dart` TODO 위치에 발송 로직 연결 | Task 15 (트리거 방식이므로 코드 연결 대신 TODO를 설명 주석으로 대체) |
| 알림 수신 후 앱 내 이동 딥링크 처리 (선택) | Task 8, Task 9(홈 착지) → Task 14(승인 대기 모달 착지) |

**범위 확장 (이슈 본문 밖, 사용자 결정):** 딥링크 착지점을 실제로 쓸모 있게 만들기 위해 승인 대기 멤버 관리 UI와 그 진입점인 마이페이지를 이번 PR에 함께 포함한다 (Task 10~14). PR 규모가 커지는 점은 사전에 공유되었고 그대로 진행하기로 결정되었다.

---

## Global Constraints

- **Firestore 리전**: `asia-northeast3` (확인 완료). Cloud Functions도 **반드시 `asia-northeast3`** 로 배포한다.
- **Firebase 프로젝트**: `.firebaserc` 기준 dev = `studio-chance`, prod = `studio-chance-prod`. 두 프로젝트 모두에 배포 필요.
- **Blaze 요금제 필수**: Cloud Functions는 무료 Spark 플랜에서 배포 불가. Task 0에서 확인한다.
- **알림 채널 ID는 3곳이 반드시 동일**: `AndroidManifest.xml`의 `default_notification_channel_id`, Cloud Functions의 `android.notification.channelId`, Flutter의 `AndroidNotificationChannel` — 값은 `sc_default`.
- **`data.type` 값은 2곳이 동일**: Functions의 `JOIN_REQUEST_TYPE`, Flutter의 `joinRequestNotificationType` — 값은 `joinRequest`.
- **한국어**: 커밋 메시지, 주석, 알림 본문 모두 한국어.
- **커밋 형식**: `<type>: #19 - <한국어 설명>`
- **브랜치**: `feat/#19-fcm-join-request-notification` (이미 생성됨)
- **Dart 코드 생성**: freezed/riverpod 파일을 추가·수정한 뒤 반드시 `dart run build_runner build --delete-conflicting-outputs` 실행.
- **포맷**: `dart format`은 **수정한 파일만** 지정해 실행한다. 디렉터리 전체 실행 금지.
- **`token` 필드 deprecation**: FCM Admin SDK는 registration token 대신 FID(Firebase Installation ID)를 권장하며 `token`/`tokens` 필드를 deprecated로 표시했다. 현재 앱은 `users/{uid}.fcmTokens`에 registration token을 저장하므로 이번 이슈는 `token`으로 구현한다. FID 마이그레이션은 별도 이슈로 분리한다 (Task 10에서 후속 이슈 생성).

---

## 알려진 한계 (실행 전 확인)

1. **예약 통계(`stats`) 탭은 여전히 화면이 없다.** `HomeTabBar`의 2번째 탭은 이번 작업 범위 밖이므로 탭해도 아무 일도 일어나지 않는 현재 동작을 유지한다 (Task 12).
2. **Task 9는 홈에 착지하고, Task 14에서 모달 착지로 교체한다.** Task 9~13를 순차 실행하는 동안 딥링크는 홈까지만 동작하며 이는 의도된 중간 상태다.
3. **iOS 실기기 검증에는 APNs 인증 키가 필요하다.** Firebase 콘솔 → 프로젝트 설정 → 클라우드 메시징에 APNs 키(.p8)가 업로드되어 있지 않으면 iOS로는 한 건도 도착하지 않는다. Task 0에서 확인한다. iOS 시뮬레이터는 FCM 푸시를 받지 못하므로 실기기 필요.
4. **관리자가 자기 자신에게 알림을 받는 경우**: 관리자는 이미 `memberById`에 있어 `waitingMemberById`에 들어갈 수 없지만, 방어적으로 신청자 본인 토큰은 발송 대상에서 제외한다 (Task 4).

---

## File Structure

### 신규 생성 — Cloud Functions

| 파일 | 책임 |
|---|---|
| `functions/package.json` | Node 22, firebase-functions/admin 의존성, build·test 스크립트 |
| `functions/tsconfig.json` | TypeScript 컴파일 설정 (`src` → `lib`) |
| `functions/.gitignore` | `node_modules/`, `lib/` 제외 |
| `functions/src/index.ts` | `notifyAdminsOnJoinRequest` 트리거 배선 (조합만 담당) |
| `functions/src/notifications/waiting_member_diff.ts` | before/after에서 신규 신청자 uid만 추출 (순수 함수) |
| `functions/src/notifications/waiting_member_diff.test.ts` | 위 함수 테스트 |
| `functions/src/notifications/join_request_payload.ts` | ADMIN uid 추출 + FCM `Message[]` 생성 (순수 함수) |
| `functions/src/notifications/join_request_payload.test.ts` | 위 함수 테스트 |
| `functions/src/notifications/invalid_tokens.ts` | 전송 결과에서 폐기할 토큰 추출 (순수 함수) |
| `functions/src/notifications/invalid_tokens.test.ts` | 위 함수 테스트 |

### 신규 생성 — Flutter

| 파일 | 책임 |
|---|---|
| `lib/constants/notification_constants.dart` | 채널 ID/이름/설명, `data.type` 값 상수 |
| `lib/domain/entities/push_message.dart` | 푸시 메시지 도메인 엔티티 (freezed, JSON 없음) |
| `lib/data/models/push_message_mapper.dart` | `RemoteMessage` → `PushMessage` 변환 extension |
| `lib/data/data_sources/local_notification_data_source.dart` | `flutter_local_notifications` 래핑 (채널 생성 + 표시) |
| `lib/domain/repository_interfaces/notification_repository.dart` | 알림 Repository 인터페이스 |
| `lib/data/repositories/notification_repository_impl.dart` | 위 구현체 (`NotificationDataSource` + `LocalNotificationDataSource` + `UserDataSource` 주입) |
| `lib/domain/use_cases/notification_use_case.dart` | 순수 Domain UseCase (interface + impl, 단순 위임 — D10) |
| `lib/domain/use_cases/notification_use_case_provider.dart` | `@riverpod` DI 배선 (D5) |
| `lib/presentation/providers/notification_controller.dart` | 권한 요청·토큰 등록·스트림 구독·딥링크 라우팅 |
| `lib/presentation/providers/pending_member_controller.dart` | 승인/거절 액션을 UseCase에 위임 |
| `lib/presentation/my_page/screens/my_page_screen.dart` | 마이페이지 — 프로필·내 점포 목록·로그아웃 |
| `lib/presentation/my_page/widgets/pending_member_modal.dart` | 승인 대기 멤버 모달 (승인 시 역할 지정 / 거절) |

### 수정

| 파일 | 변경 내용 |
|---|---|
| `firebase.json` | `functions` 블록 추가 |
| `pubspec.yaml` | `flutter_local_notifications: ^22.3.0` 추가 |
| `android/app/build.gradle.kts` | core library desugaring 활성화 |
| `android/app/src/main/AndroidManifest.xml` | `POST_NOTIFICATIONS` 권한 + 기본 채널 meta-data |
| `lib/data/data_sources/notification_data_source.dart` | 메시지 스트림 3종 추가 |
| `lib/presentation/providers/home_store_filter_controller.dart` | `ensureSelected(storeId)` 추가 |
| `lib/my_app.dart` | `notificationControllerProvider` watch |
| `lib/data/repositories/store_repository_impl.dart:231` | TODO 주석 → 설명 주석 |
| `lib/domain/repository_interfaces/store_repository.dart` | `removeMember` 선언 추가 |
| `lib/data/repositories/store_repository_impl.dart` | `removeMember` 구현 추가 |
| `lib/domain/use_cases/store_use_case.dart` | `removeMember` 선언·구현 추가 |
| `lib/presentation/home/widgets/home_tab_bar.dart` | 로컬 `_selectedIndex` → 현재 라우트 기반 인덱스 + 실제 라우팅 |
| `lib/router/app_router.dart` | `/my-page` 라우트 + `_roleSubRoutes()` 하위 등록 |
| `CLAUDE.md` | FCM 알림 아키텍처 섹션 + 마이페이지 구조 추가 |

### 신규 테스트

| 파일 | 대상 |
|---|---|
| `test/data/models/push_message_mapper_test.dart` | `RemoteMessage` → `PushMessage` 변환 |
| `test/presentation/providers/notification_routing_test.dart` | `joinRequestStoreIdOf` 순수 함수 |
| `test/presentation/providers/home_store_filter_controller_test.dart` | `ensureSelected` 동작 |
| `test/data/repositories/store_repository_member_test.dart` | `removeMember` DataSource 위임 |
| `test/presentation/my_page/pending_member_modal_test.dart` | 대기 멤버 렌더링·승인/거절 콜백 호출 |

---

## Task 0: 사전 확인 (수동)

코드 변경 없음. 이후 모든 Task의 전제 조건이다. **하나라도 충족되지 않으면 사용자에게 알리고 중단한다.**

- [ ] **Step 1: Blaze 요금제 확인**

Cloud Functions는 무료 Spark 플랜에서 배포할 수 없다. 아래 명령이 실패하거나 결제 계정이 없다고 나오면 사용자에게 보고한다.

```bash
firebase projects:list
open "https://console.firebase.google.com/project/studio-chance/usage/details"
```

기대: `studio-chance`, `studio-chance-prod` 두 프로젝트가 모두 Blaze(종량제)여야 한다.

- [ ] **Step 2: APNs 인증 키 확인 (iOS 검증용)**

```bash
open "https://console.firebase.google.com/project/studio-chance/settings/cloudmessaging"
```

기대: "Apple 앱 구성" 섹션에 APNs 인증 키(.p8)가 등록되어 있다. 없으면 iOS 검증은 불가하므로 사용자에게 보고하고 Android로만 검증한다.

- [ ] **Step 3: Firebase CLI 로그인 확인**

```bash
firebase login:list
```

기대: 계정이 로그인되어 있다.

- [ ] **Step 4: Firestore 리전 재확인**

```bash
firebase firestore:databases:get "(default)" --project studio-chance
```

기대: `Location`이 `asia-northeast3`. 다르면 이후 Task의 `region` 값을 실제 값으로 바꾼다.

---

## Task 1: Cloud Functions 프로젝트 스캐폴딩 + 신규 신청자 추출 함수

**Files:**
- Create: `functions/package.json`
- Create: `functions/tsconfig.json`
- Create: `functions/.gitignore`
- Create: `functions/src/notifications/waiting_member_diff.ts`
- Test: `functions/src/notifications/waiting_member_diff.test.ts`
- Modify: `firebase.json`

**Interfaces:**
- Consumes: 없음
- Produces: `collectNewWaitingUids(before?: Record<string, unknown>, after?: Record<string, unknown>): string[]`

**설계 노트:** 테스트 러너는 Node 22 내장 `node:test`를 쓴다. jest/vitest를 추가하지 않는 이유는 순수 함수 3개를 검증하는 데 별도 러너가 필요 없기 때문이다. `npm test`는 TS를 컴파일한 뒤 `lib/`의 `*.test.js`를 실행한다.

- [ ] **Step 1: `functions/package.json` 생성**

```json
{
  "name": "studio-chance-functions",
  "private": true,
  "main": "lib/index.js",
  "engines": {
    "node": "22"
  },
  "scripts": {
    "build": "tsc",
    "test": "npm run build && node --test lib",
    "serve": "npm run build && firebase emulators:start --only functions",
    "logs": "firebase functions:log"
  },
  "dependencies": {
    "firebase-admin": "^14.3.0",
    "firebase-functions": "^7.3.2"
  },
  "devDependencies": {
    "@types/node": "^22.15.0",
    "typescript": "^5.9.3"
  }
}
```

- [ ] **Step 2: `functions/tsconfig.json` 생성**

```json
{
  "compilerOptions": {
    "module": "node16",
    "moduleResolution": "node16",
    "target": "es2023",
    "lib": ["es2023"],
    "outDir": "lib",
    "sourceMap": true,
    "strict": true,
    "noImplicitReturns": true,
    "noUnusedLocals": true,
    "skipLibCheck": true
  },
  "include": ["src"]
}
```

- [ ] **Step 3: `functions/.gitignore` 생성**

```gitignore
node_modules/
lib/
*.local
```

- [ ] **Step 4: `firebase.json`에 functions 블록 추가**

기존 `firebase.json`의 `"firestore"` 블록 **바로 뒤**에 아래 블록을 추가한다 (기존 `flutter`, `emulators` 블록은 그대로 둔다).

```json
  "functions": [
    {
      "source": "functions",
      "codebase": "default",
      "ignore": [
        "node_modules",
        ".git",
        "firebase-debug.log",
        "firebase-debug.*.log"
      ],
      "predeploy": [
        "npm --prefix \"$RESOURCE_DIR\" run build"
      ]
    }
  ],
```

또한 `"emulators"` 블록 안에 functions 에뮬레이터 포트를 추가한다.

```json
    "functions": {
      "port": 5001
    },
```

- [ ] **Step 5: 의존성 설치**

```bash
cd functions && npm install
```

기대: `node_modules/` 생성, 에러 없음.

- [ ] **Step 6: 실패하는 테스트 작성**

`functions/src/notifications/waiting_member_diff.test.ts`:

```typescript
import { test } from 'node:test';
import assert from 'node:assert/strict';

import { collectNewWaitingUids } from './waiting_member_diff.js';

test('새로 추가된 uid만 반환한다', () => {
  const before = { userA: { role: 'STAFF' } };
  const after = { userA: { role: 'STAFF' }, userB: { role: 'VIEWER' } };

  assert.deepEqual(collectNewWaitingUids(before, after), ['userB']);
});

test('기존 uid의 값만 바뀌면 신규로 보지 않는다', () => {
  const before = { userA: { role: 'STAFF' } };
  const after = { userA: { role: 'VIEWER' } };

  assert.deepEqual(collectNewWaitingUids(before, after), []);
});

test('대기 멤버가 제거되기만 하면 빈 배열을 반환한다', () => {
  assert.deepEqual(collectNewWaitingUids({ userA: {} }, {}), []);
});

test('before가 없으면 after의 모든 uid가 신규다', () => {
  assert.deepEqual(collectNewWaitingUids(undefined, { userA: {} }), ['userA']);
});

test('before/after가 모두 없으면 빈 배열을 반환한다', () => {
  assert.deepEqual(collectNewWaitingUids(undefined, undefined), []);
});

test('여러 명이 동시에 추가되면 모두 반환한다', () => {
  const after = { userA: {}, userB: {}, userC: {} };

  assert.deepEqual(collectNewWaitingUids({ userA: {} }, after), ['userB', 'userC']);
});
```

- [ ] **Step 7: 테스트가 실패하는지 확인**

```bash
cd functions && npm test
```

기대: FAIL — `Cannot find module './waiting_member_diff.js'` (컴파일 에러로 `npm run build` 단계에서 실패)

- [ ] **Step 8: 최소 구현**

`functions/src/notifications/waiting_member_diff.ts`:

```typescript
/**
 * 점포 문서의 `waitingMemberById` 변경분에서 "새로 추가된" 신청자 uid만 추출한다.
 *
 * 기존 키의 값만 바뀐 경우(역할 변경 등)나 키가 삭제된 경우(승인·거절)는
 * 신규 가입 신청이 아니므로 제외한다.
 */
export function collectNewWaitingUids(
  before: Record<string, unknown> | undefined,
  after: Record<string, unknown> | undefined,
): string[] {
  const beforeUids = new Set(Object.keys(before ?? {}));
  return Object.keys(after ?? {}).filter((uid) => !beforeUids.has(uid));
}
```

- [ ] **Step 9: 테스트 통과 확인**

```bash
cd functions && npm test
```

기대: PASS — 6개 테스트 모두 통과

- [ ] **Step 10: 커밋**

```bash
git add functions/ firebase.json
git commit -m "feat: #19 - Cloud Functions 스캐폴딩 및 신규 가입 신청자 추출 함수 추가"
```

---

## Task 2: 무효 토큰 추출 함수

**Files:**
- Create: `functions/src/notifications/invalid_tokens.ts`
- Test: `functions/src/notifications/invalid_tokens.test.ts`

**Interfaces:**
- Consumes: 없음
- Produces: `invalidTokensFrom(response: BatchResponse, tokens: string[]): string[]`

**설계 노트:** 앱 삭제·토큰 만료로 폐기된 토큰이 `fcmTokens` 배열에 계속 남으면 발송 실패가 누적된다. Admin SDK는 실패 응답에 에러 코드를 담아 주므로, "다시 쓸 수 없는" 코드만 골라 Firestore에서 제거한다. 네트워크 오류(`messaging/server-unavailable` 등)는 일시적이므로 제거 대상에서 제외한다.

- [ ] **Step 1: 실패하는 테스트 작성**

`functions/src/notifications/invalid_tokens.test.ts`:

```typescript
import { test } from 'node:test';
import assert from 'node:assert/strict';
import type { BatchResponse } from 'firebase-admin/messaging';

import { invalidTokensFrom } from './invalid_tokens.js';

/** 테스트용 BatchResponse 조립 헬퍼 */
function batchResponse(codes: (string | null)[]): BatchResponse {
  return {
    successCount: codes.filter((c) => c === null).length,
    failureCount: codes.filter((c) => c !== null).length,
    responses: codes.map((code) =>
      code === null
        ? { success: true, messageId: 'ok' }
        : { success: false, error: { code, message: code } },
    ),
  } as unknown as BatchResponse;
}

test('폐기된 토큰만 반환한다', () => {
  const response = batchResponse([
    null,
    'messaging/registration-token-not-registered',
    null,
  ]);

  assert.deepEqual(invalidTokensFrom(response, ['t1', 't2', 't3']), ['t2']);
});

test('일시적 오류는 제거 대상이 아니다', () => {
  const response = batchResponse(['messaging/server-unavailable']);

  assert.deepEqual(invalidTokensFrom(response, ['t1']), []);
});

test('형식이 잘못된 토큰도 제거 대상이다', () => {
  const response = batchResponse([
    'messaging/invalid-registration-token',
    'messaging/invalid-argument',
  ]);

  assert.deepEqual(invalidTokensFrom(response, ['t1', 't2']), ['t1', 't2']);
});

test('모두 성공하면 빈 배열을 반환한다', () => {
  assert.deepEqual(invalidTokensFrom(batchResponse([null, null]), ['t1', 't2']), []);
});
```

- [ ] **Step 2: 테스트가 실패하는지 확인**

```bash
cd functions && npm test
```

기대: FAIL — `Cannot find module './invalid_tokens.js'`

- [ ] **Step 3: 최소 구현**

`functions/src/notifications/invalid_tokens.ts`:

```typescript
import type { BatchResponse } from 'firebase-admin/messaging';

/**
 * 다시 사용할 수 없는 토큰을 나타내는 에러 코드.
 * 네트워크 오류·서버 일시 장애는 재시도 가능하므로 포함하지 않는다.
 */
const UNUSABLE_TOKEN_CODES = new Set([
  'messaging/registration-token-not-registered',
  'messaging/invalid-registration-token',
  'messaging/invalid-argument',
]);

/**
 * 전송 결과에서 `users/{uid}.fcmTokens`에서 제거해야 할 토큰만 골라낸다.
 *
 * `response.responses`의 순서는 입력 `tokens`의 순서와 1:1 대응한다.
 */
export function invalidTokensFrom(
  response: BatchResponse,
  tokens: string[],
): string[] {
  const invalid: string[] = [];
  response.responses.forEach((result, index) => {
    if (result.success) return;
    if (UNUSABLE_TOKEN_CODES.has(result.error?.code ?? '')) {
      invalid.push(tokens[index]);
    }
  });
  return invalid;
}
```

- [ ] **Step 4: 테스트 통과 확인**

```bash
cd functions && npm test
```

기대: PASS — 10개 테스트(Task 1의 6개 + 이번 4개) 모두 통과

- [ ] **Step 5: 커밋**

```bash
git add functions/src/notifications/invalid_tokens.ts functions/src/notifications/invalid_tokens.test.ts
git commit -m "feat: #19 - 폐기된 FCM 토큰 추출 함수 추가"
```

---

## Task 3: 관리자 추출 + 알림 페이로드 생성 함수

**Files:**
- Create: `functions/src/notifications/join_request_payload.ts`
- Test: `functions/src/notifications/join_request_payload.test.ts`

**Interfaces:**
- Consumes: 없음
- Produces:
  - `JOIN_REQUEST_TYPE: 'joinRequest'`
  - `ANDROID_CHANNEL_ID: 'sc_default'`
  - `adminUidsOf(memberById?: Record<string, { role?: string }>): string[]`
  - `buildJoinRequestBody(applicantName: string, storeName: string): string`
  - `buildJoinRequestMessages(params: { tokens: string[]; applicantName: string; applicantUid: string; storeId: string; storeName: string }): Message[]`

**설계 노트:** `UserRole` enum의 Firestore 직렬화 값은 `lib/common/enums/user_role.dart` 기준 `'ADMIN' | 'STAFF' | 'VIEWER' | 'NONE'` 이다. Functions는 Dart enum을 공유할 수 없으므로 문자열 `'ADMIN'`을 직접 비교한다.

- [ ] **Step 1: 실패하는 테스트 작성**

`functions/src/notifications/join_request_payload.test.ts`:

```typescript
import { test } from 'node:test';
import assert from 'node:assert/strict';

import {
  ANDROID_CHANNEL_ID,
  JOIN_REQUEST_TYPE,
  adminUidsOf,
  buildJoinRequestBody,
  buildJoinRequestMessages,
} from './join_request_payload.js';

test('ADMIN 역할 uid만 추출한다', () => {
  const memberById = {
    admin1: { role: 'ADMIN' },
    staff1: { role: 'STAFF' },
    viewer1: { role: 'VIEWER' },
    admin2: { role: 'ADMIN' },
  };

  assert.deepEqual(adminUidsOf(memberById), ['admin1', 'admin2']);
});

test('memberById가 없으면 빈 배열을 반환한다', () => {
  assert.deepEqual(adminUidsOf(undefined), []);
});

test('role이 없는 멤버는 관리자가 아니다', () => {
  assert.deepEqual(adminUidsOf({ ghost: {} }), []);
});

test('알림 본문은 "[닉네임]님이 [점포명] 가입을 신청했습니다." 형식이다', () => {
  assert.equal(
    buildJoinRequestBody('홍길동', '스튜디오 챈스'),
    '홍길동님이 스튜디오 챈스 가입을 신청했습니다.',
  );
});

test('토큰마다 메시지를 하나씩 만든다', () => {
  const messages = buildJoinRequestMessages({
    tokens: ['t1', 't2'],
    applicantName: '홍길동',
    applicantUid: 'applicant',
    storeId: 'store1',
    storeName: '스튜디오 챈스',
  });

  assert.equal(messages.length, 2);
  assert.equal(messages[0].token, 't1');
  assert.equal(messages[1].token, 't2');
});

test('메시지에 딥링크용 data와 Android 채널이 담긴다', () => {
  const [message] = buildJoinRequestMessages({
    tokens: ['t1'],
    applicantName: '홍길동',
    applicantUid: 'applicant',
    storeId: 'store1',
    storeName: '스튜디오 챈스',
  });

  assert.deepEqual(message.data, {
    type: JOIN_REQUEST_TYPE,
    storeId: 'store1',
    applicantUid: 'applicant',
  });
  assert.equal(message.notification?.title, '가입 신청');
  assert.equal(
    message.notification?.body,
    '홍길동님이 스튜디오 챈스 가입을 신청했습니다.',
  );
  assert.equal(message.android?.notification?.channelId, ANDROID_CHANNEL_ID);
});

test('토큰이 없으면 빈 배열을 반환한다', () => {
  const messages = buildJoinRequestMessages({
    tokens: [],
    applicantName: '홍길동',
    applicantUid: 'applicant',
    storeId: 'store1',
    storeName: '스튜디오 챈스',
  });

  assert.deepEqual(messages, []);
});
```

- [ ] **Step 2: 테스트가 실패하는지 확인**

```bash
cd functions && npm test
```

기대: FAIL — `Cannot find module './join_request_payload.js'`

- [ ] **Step 3: 최소 구현**

`functions/src/notifications/join_request_payload.ts`:

```typescript
import type { Message } from 'firebase-admin/messaging';

/** 푸시 payload의 `data.type` 값. Flutter의 `joinRequestNotificationType`과 동일해야 한다. */
export const JOIN_REQUEST_TYPE = 'joinRequest';

/**
 * Android 알림 채널 ID.
 * AndroidManifest의 `default_notification_channel_id`,
 * Flutter의 `notificationChannelId`와 반드시 동일해야 한다.
 */
export const ANDROID_CHANNEL_ID = 'sc_default';

type MemberInfo = { role?: string };

/**
 * 점포의 `memberById`에서 ADMIN 역할 uid만 추출한다.
 * 역할 문자열은 Dart `UserRole`의 `@JsonValue`와 동일한 대문자 값이다.
 */
export function adminUidsOf(
  memberById: Record<string, MemberInfo> | undefined,
): string[] {
  return Object.entries(memberById ?? {})
    .filter(([, info]) => info?.role === 'ADMIN')
    .map(([uid]) => uid);
}

/** 알림 본문 문구를 만든다. */
export function buildJoinRequestBody(
  applicantName: string,
  storeName: string,
): string {
  return `${applicantName}님이 ${storeName} 가입을 신청했습니다.`;
}

/**
 * 관리자 기기 토큰마다 가입 신청 알림 메시지를 만든다.
 *
 * NOTE: FCM Admin SDK는 registration token 대신 FID를 권장하며 `token` 필드를
 * deprecated로 표시했다. 현재 앱은 `users/{uid}.fcmTokens`에 registration token을
 * 저장하므로 `token`을 사용한다. FID 마이그레이션은 별도 이슈로 다룬다.
 */
export function buildJoinRequestMessages(params: {
  tokens: string[];
  applicantName: string;
  applicantUid: string;
  storeId: string;
  storeName: string;
}): Message[] {
  const body = buildJoinRequestBody(params.applicantName, params.storeName);

  return params.tokens.map((token) => ({
    token,
    notification: {
      title: '가입 신청',
      body,
    },
    data: {
      type: JOIN_REQUEST_TYPE,
      storeId: params.storeId,
      applicantUid: params.applicantUid,
    },
    android: {
      priority: 'high',
      notification: {
        channelId: ANDROID_CHANNEL_ID,
      },
    },
    apns: {
      payload: {
        aps: {
          sound: 'default',
          badge: 1,
        },
      },
    },
  }));
}
```

- [ ] **Step 4: 테스트 통과 확인**

```bash
cd functions && npm test
```

기대: PASS — 17개 테스트 모두 통과

- [ ] **Step 5: 커밋**

```bash
git add functions/src/notifications/join_request_payload.ts functions/src/notifications/join_request_payload.test.ts
git commit -m "feat: #19 - 가입 신청 알림 페이로드 생성 함수 추가"
```

---

## Task 4: Firestore 트리거 배선 및 배포

**Files:**
- Create: `functions/src/index.ts`

**Interfaces:**
- Consumes: `collectNewWaitingUids` (Task 1), `invalidTokensFrom` (Task 2), `adminUidsOf` / `buildJoinRequestMessages` (Task 3)
- Produces: 배포된 함수 `notifyAdminsOnJoinRequest`

**설계 노트:** 이 파일은 조합만 담당하므로 단위 테스트를 쓰지 않는다 (Firestore·FCM 실제 호출이 본질). 대신 Step 4~6의 실제 배포 후 수동 검증으로 확인한다. 관리자 문서는 신청자마다 다시 읽지 않고 루프 전에 한 번만 읽어 `토큰 → 소유 관리자 uid` 맵을 만든다.

- [ ] **Step 1: 트리거 구현**

`functions/src/index.ts`:

```typescript
import { initializeApp } from 'firebase-admin/app';
import { FieldValue, getFirestore } from 'firebase-admin/firestore';
import { getMessaging } from 'firebase-admin/messaging';
import { logger } from 'firebase-functions/v2';
import { onDocumentUpdated } from 'firebase-functions/v2/firestore';

import { adminUidsOf, buildJoinRequestMessages } from './notifications/join_request_payload.js';
import { invalidTokensFrom } from './notifications/invalid_tokens.js';
import { collectNewWaitingUids } from './notifications/waiting_member_diff.js';

initializeApp();

/**
 * 점포 대기 명단(`waitingMemberById`)에 새 신청자가 추가되면
 * 해당 점포 관리자(ADMIN)의 모든 기기에 푸시 알림을 보낸다.
 *
 * Firestore 리전(asia-northeast3)과 함수 리전을 반드시 일치시킨다.
 */
export const notifyAdminsOnJoinRequest = onDocumentUpdated(
  {
    document: 'stores/{storeId}',
    region: 'asia-northeast3',
  },
  async (event) => {
    const after = event.data?.after.data();
    if (!after) return;

    const newApplicantUids = collectNewWaitingUids(
      event.data?.before.data()?.waitingMemberById,
      after.waitingMemberById,
    );
    if (newApplicantUids.length === 0) return;

    const storeId = event.params.storeId;
    const storeName = (after.name as string | undefined) ?? '점포';

    const adminUids = adminUidsOf(after.memberById);
    if (adminUids.length === 0) {
      logger.warn('관리자가 없어 가입 신청 알림을 건너뜁니다', { storeId });
      return;
    }

    const db = getFirestore();

    // 토큰 → 소유 관리자 uid. 폐기 토큰 정리 시 어느 문서를 갱신할지 알기 위해 필요하다.
    const ownerUidByToken = new Map<string, string>();
    const adminDocs = await db.getAll(
      ...adminUids.map((uid) => db.doc(`users/${uid}`)),
    );
    for (const doc of adminDocs) {
      const tokens = (doc.get('fcmTokens') as string[] | undefined) ?? [];
      for (const token of tokens) {
        ownerUidByToken.set(token, doc.id);
      }
    }

    if (ownerUidByToken.size === 0) {
      logger.warn('관리자 FCM 토큰이 없어 알림을 건너뜁니다', { storeId, adminUids });
      return;
    }

    for (const applicantUid of newApplicantUids) {
      const applicantDoc = await db.doc(`users/${applicantUid}`).get();
      const applicantName =
        (applicantDoc.get('nickname') as string | undefined) ??
        (applicantDoc.get('name') as string | undefined) ??
        '알 수 없는 사용자';

      // 신청자 본인에게는 보내지 않는다 (정상 흐름에서는 발생하지 않지만 방어적으로 처리)
      const targetTokens = [...ownerUidByToken.entries()]
        .filter(([, ownerUid]) => ownerUid !== applicantUid)
        .map(([token]) => token);
      if (targetTokens.length === 0) continue;

      const response = await getMessaging().sendEach(
        buildJoinRequestMessages({
          tokens: targetTokens,
          applicantName,
          applicantUid,
          storeId,
          storeName,
        }),
      );

      logger.info('가입 신청 알림 발송 완료', {
        storeId,
        applicantUid,
        successCount: response.successCount,
        failureCount: response.failureCount,
      });

      const expiredTokens = invalidTokensFrom(response, targetTokens);
      if (expiredTokens.length === 0) continue;

      await Promise.all(
        expiredTokens.map((token) =>
          db.doc(`users/${ownerUidByToken.get(token)}`).update({
            fcmTokens: FieldValue.arrayRemove(token),
            updatedAt: FieldValue.serverTimestamp(),
          }),
        ),
      );
      for (const token of expiredTokens) {
        ownerUidByToken.delete(token);
      }
      logger.info('폐기된 FCM 토큰 정리', { storeId, count: expiredTokens.length });
    }
  },
);
```

- [ ] **Step 2: 빌드·테스트 통과 확인**

```bash
cd functions && npm test
```

기대: PASS — 기존 17개 테스트 통과 + 컴파일 에러 없음

- [ ] **Step 3: 커밋**

```bash
git add functions/src/index.ts
git commit -m "feat: #19 - 가입 신청 시 관리자 FCM 알림 발송 트리거 구현"
```

- [ ] **Step 4: dev 프로젝트에 배포**

```bash
firebase deploy --only functions -P dev
```

기대: `notifyAdminsOnJoinRequest(asia-northeast3)` 배포 성공. 최초 배포 시 Cloud Build·Artifact Registry·Eventarc API 활성화 프롬프트가 나오면 승인한다.

- [ ] **Step 5: 수동 검증 — 함수 실행 확인**

Firebase 콘솔에서 임의의 점포 문서에 대기 멤버를 직접 추가한다.

```bash
open "https://console.firebase.google.com/project/studio-chance/firestore/data/~2Fstores"
```

`stores/{임의 storeId}` 문서의 `waitingMemberById` 맵에 `{ 존재하는 uid: { role: "STAFF" } }` 항목을 추가하고 저장한 뒤 로그를 확인한다.

```bash
firebase functions:log --only notifyAdminsOnJoinRequest -P dev
```

기대: `가입 신청 알림 발송 완료` 로그가 남고 `successCount`가 1 이상. 관리자 토큰이 없다면 `관리자 FCM 토큰이 없어 알림을 건너뜁니다` — 이 경우 Task 6~9 완료 후 다시 확인한다.

검증 후 추가했던 `waitingMemberById` 항목을 삭제한다.

- [ ] **Step 6: prod 프로젝트에 배포**

```bash
firebase deploy --only functions -P prod
```

기대: 배포 성공.

---

## Task 5: Flutter 플랫폼 설정 (Android 채널 · 권한 · desugaring)

**Files:**
- Modify: `pubspec.yaml`
- Modify: `android/app/build.gradle.kts`
- Modify: `android/app/src/main/AndroidManifest.xml`
- Create: `lib/constants/notification_constants.dart`

**Interfaces:**
- Consumes: `ANDROID_CHANNEL_ID` (Task 3, 값 일치 필요)
- Produces: `notificationChannelId`, `notificationChannelName`, `notificationChannelDescription`, `joinRequestNotificationType`

**설계 노트:** `flutter_local_notifications` 22.x는 `java.time` API를 사용하므로 Android core library desugaring이 필요하다. 없으면 빌드가 아니라 런타임에서 깨질 수 있으므로 반드시 켠다.

- [ ] **Step 1: 의존성 추가**

`pubspec.yaml`의 `dependencies` 블록, `firebase_ai: ^3.12.1` 다음 줄에 추가한다.

```yaml
  flutter_local_notifications: ^22.3.0
```

```bash
flutter pub get
```

기대: 설치 성공, 버전 충돌 없음.

- [ ] **Step 2: Android desugaring 활성화**

`android/app/build.gradle.kts`의 `compileOptions` 블록을 아래로 교체한다.

```kotlin
    compileOptions {
        // flutter_local_notifications가 java.time API를 사용하므로 desugaring 필요
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
```

같은 파일 맨 아래, `flutter { source = "../.." }` 블록 **뒤에** 아래를 추가한다.

```kotlin
dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}
```

- [ ] **Step 3: AndroidManifest 수정**

`android/app/src/main/AndroidManifest.xml`의 `<uses-permission android:name="android.permission.INTERNET"/>` 바로 아래에 추가한다.

```xml
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

같은 파일의 `<meta-data android:name="flutterEmbedding" android:value="2" />` 바로 위에 추가한다.

```xml
        <!-- FCM 백그라운드 알림이 사용할 기본 채널.
             Cloud Functions의 ANDROID_CHANNEL_ID, Flutter의 notificationChannelId와 동일해야 한다. -->
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_channel_id"
            android:value="sc_default" />
```

- [ ] **Step 4: 알림 상수 파일 생성**

`lib/constants/notification_constants.dart`:

```dart
/// Android 알림 채널 ID
/// - AndroidManifest의 `default_notification_channel_id`
/// - Cloud Functions의 `ANDROID_CHANNEL_ID`
/// 세 곳의 값이 반드시 동일해야 알림이 정상 표시된다.
const String notificationChannelId = 'sc_default';

/// 알림 채널 이름 (기기 설정 화면에 노출)
const String notificationChannelName = '일반 알림';

/// 알림 채널 설명 (기기 설정 화면에 노출)
const String notificationChannelDescription = '가입 신청 등 점포 관련 알림';

/// 가입 신청 푸시의 `data.type` 값
/// - Cloud Functions의 `JOIN_REQUEST_TYPE`과 동일해야 한다.
const String joinRequestNotificationType = 'joinRequest';
```

- [ ] **Step 5: Android 빌드 확인**

```bash
flutter build apk --flavor dev --target lib/main_dev.dart --debug
```

기대: BUILD SUCCESSFUL

- [ ] **Step 6: 정적 분석 및 포맷**

```bash
dart format lib/constants/notification_constants.dart
dart analyze
```

기대: 에러 0건

- [ ] **Step 7: 커밋**

```bash
git add pubspec.yaml pubspec.lock android/app/build.gradle.kts android/app/src/main/AndroidManifest.xml lib/constants/notification_constants.dart
git commit -m "feat: #19 - 알림 채널·권한 플랫폼 설정 및 알림 상수 추가"
```

---

## Task 6: PushMessage 엔티티 및 RemoteMessage 변환

**Files:**
- Create: `lib/domain/entities/push_message.dart`
- Create: `lib/data/models/push_message_mapper.dart`
- Test: `test/data/models/push_message_mapper_test.dart`

**Interfaces:**
- Consumes: 없음
- Produces:
  - `class PushMessage { String type; String? title; String? body; Map<String, String> data; }`
  - `extension RemoteMessageMapper on RemoteMessage { PushMessage toEntity(); }`
  - `PushMessage pushMessageFromData(Map<String, String> data)`

**설계 노트:** `RemoteMessage`(firebase_messaging 타입)가 Domain·Presentation 계층으로 새지 않도록 경계에서 엔티티로 바꾼다. `pushMessageFromData`는 로컬 알림 payload(JSON 문자열)를 되돌릴 때 사용한다.

- [ ] **Step 1: 실패하는 테스트 작성**

`test/data/models/push_message_mapper_test.dart`:

```dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:studio_chance/data/models/push_message_mapper.dart';

void main() {
  group('RemoteMessageMapper', () {
    test('notification과 data를 엔티티로 옮긴다', () {
      const remoteMessage = RemoteMessage(
        notification: RemoteNotification(title: '가입 신청', body: '홍길동님이 신청했습니다.'),
        data: {'type': 'joinRequest', 'storeId': 'store1'},
      );

      final entity = remoteMessage.toEntity();

      expect(entity.type, 'joinRequest');
      expect(entity.title, '가입 신청');
      expect(entity.body, '홍길동님이 신청했습니다.');
      expect(entity.data['storeId'], 'store1');
    });

    test('type이 없으면 빈 문자열로 처리한다', () {
      const remoteMessage = RemoteMessage(data: {'storeId': 'store1'});

      expect(remoteMessage.toEntity().type, '');
    });

    test('notification이 없어도 변환된다', () {
      const remoteMessage = RemoteMessage(data: {'type': 'joinRequest'});

      final entity = remoteMessage.toEntity();

      expect(entity.title, isNull);
      expect(entity.body, isNull);
      expect(entity.type, 'joinRequest');
    });

    test('data가 비어 있어도 안전하다', () {
      const remoteMessage = RemoteMessage();

      final entity = remoteMessage.toEntity();

      expect(entity.type, '');
      expect(entity.data, isEmpty);
    });
  });

  group('pushMessageFromData', () {
    test('data 맵만으로 엔티티를 만든다', () {
      final entity = pushMessageFromData({
        'type': 'joinRequest',
        'storeId': 'store1',
      });

      expect(entity.type, 'joinRequest');
      expect(entity.data['storeId'], 'store1');
      expect(entity.title, isNull);
    });
  });
}
```

- [ ] **Step 2: 테스트가 실패하는지 확인**

```bash
flutter test test/data/models/push_message_mapper_test.dart
```

기대: FAIL — `Target of URI doesn't exist: 'package:studio_chance/data/models/push_message_mapper.dart'`

- [ ] **Step 3: 엔티티 작성**

`lib/domain/entities/push_message.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'push_message.freezed.dart';

/// 수신한 푸시 알림의 도메인 표현
///
/// firebase_messaging의 `RemoteMessage`가 Domain·Presentation 계층으로
/// 새지 않도록 Data 계층 경계에서 이 엔티티로 변환한다.
@freezed
abstract class PushMessage with _$PushMessage {
  const PushMessage._();

  const factory PushMessage({
    /// 푸시 종류. `joinRequestNotificationType` 등과 비교한다.
    required String type,
    String? title,
    String? body,
    @Default({}) Map<String, String> data,
  }) = _PushMessage;
}
```

- [ ] **Step 4: 매퍼 작성**

`lib/data/models/push_message_mapper.dart`:

```dart
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:studio_chance/domain/entities/push_message.dart';

/// FCM `RemoteMessage`를 도메인 엔티티로 변환한다.
extension RemoteMessageMapper on RemoteMessage {
  PushMessage toEntity() {
    return PushMessage(
      type: data['type']?.toString() ?? '',
      title: notification?.title,
      body: notification?.body,
      data: _stringifyValues(data),
    );
  }
}

/// 로컬 알림 payload 등 `data` 맵만 남은 상황에서 엔티티를 복원한다.
PushMessage pushMessageFromData(Map<String, dynamic> data) {
  return PushMessage(
    type: data['type']?.toString() ?? '',
    data: _stringifyValues(data),
  );
}

Map<String, String> _stringifyValues(Map<String, dynamic> data) {
  return data.map((key, value) => MapEntry(key, value?.toString() ?? ''));
}
```

- [ ] **Step 5: 코드 생성**

```bash
dart run build_runner build --delete-conflicting-outputs
```

기대: `lib/domain/entities/push_message.freezed.dart` 생성

- [ ] **Step 6: 테스트 통과 확인**

```bash
flutter test test/data/models/push_message_mapper_test.dart
```

기대: PASS — 5개 테스트 통과

- [ ] **Step 7: 정적 분석 및 포맷**

```bash
dart format lib/domain/entities/push_message.dart lib/data/models/push_message_mapper.dart test/data/models/push_message_mapper_test.dart
dart analyze
```

기대: 에러 0건

- [ ] **Step 8: 커밋**

```bash
git add lib/domain/entities/push_message.dart lib/domain/entities/push_message.freezed.dart lib/data/models/push_message_mapper.dart test/data/models/push_message_mapper_test.dart
git commit -m "feat: #19 - PushMessage 엔티티 및 RemoteMessage 변환 추가"
```

---

## Task 7: DataSource 확장 (메시지 스트림 + 로컬 알림)

**Files:**
- Modify: `lib/data/data_sources/notification_data_source.dart`
- Create: `lib/data/data_sources/local_notification_data_source.dart`

**Interfaces:**
- Consumes: `notificationChannelId` / `notificationChannelName` / `notificationChannelDescription` (Task 5)
- Produces:
  - `NotificationDataSource`에 추가: `Stream<RemoteMessage> get onMessage`, `Stream<RemoteMessage> get onMessageOpenedApp`, `Future<RemoteMessage?> getInitialMessage()`
  - `abstract interface class LocalNotificationDataSource { Future<void> initialize({required void Function(String? payload) onTap}); Future<void> show({required String title, required String body, String? payload}); }`
  - `localNotificationDataSourceProvider` (`@Riverpod(keepAlive: true)`)

**설계 노트:** FCM SDK는 앱이 포그라운드일 때 Android에서 알림을 표시하지 않는다. iOS도 기본적으로 표시하지 않는다. 두 플랫폼 모두 `flutter_local_notifications`로 직접 띄워 동작을 통일한다. 그래서 iOS의 `setForegroundNotificationPresentationOptions`는 켜지 않는다 — 켜면 시스템 배너와 로컬 알림이 중복 표시된다.

- [ ] **Step 1: `NotificationDataSource` 인터페이스에 스트림 추가**

`lib/data/data_sources/notification_data_source.dart`의 `abstract interface class NotificationDataSource` 안, `deleteToken()` 선언 **뒤에** 추가한다.

```dart
  /// 앱이 포그라운드일 때 수신한 메시지 스트림
  Stream<RemoteMessage> get onMessage;

  /// 앱이 백그라운드일 때 알림을 탭해 앱이 열린 경우의 메시지 스트림
  Stream<RemoteMessage> get onMessageOpenedApp;

  /// 앱이 종료된 상태에서 알림을 탭해 실행됐다면 그 메시지 (아니면 null)
  Future<RemoteMessage?> getInitialMessage();
```

- [ ] **Step 2: `FirebaseMessagingDataSource`에 구현 추가**

같은 파일의 `FirebaseMessagingDataSource` 안, `deleteToken()` 구현 **뒤에** 추가한다.

```dart
  @override
  Stream<RemoteMessage> get onMessage => FirebaseMessaging.onMessage;

  @override
  Stream<RemoteMessage> get onMessageOpenedApp =>
      FirebaseMessaging.onMessageOpenedApp;

  @override
  Future<RemoteMessage?> getInitialMessage() => _messaging.getInitialMessage();
```

- [ ] **Step 3: `LocalNotificationDataSource` 작성**

`lib/data/data_sources/local_notification_data_source.dart`:

```dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/common/exceptions/notification_exceptions.dart';
import 'package:studio_chance/constants/notification_constants.dart';

part 'local_notification_data_source.g.dart';

abstract interface class LocalNotificationDataSource {
  /// 플러그인 초기화 및 Android 알림 채널 생성
  ///
  /// [onTap]에는 알림 탭 시 payload 문자열이 전달된다.
  Future<void> initialize({required void Function(String? payload) onTap});

  /// 즉시 알림 표시 (포그라운드 수신 시 사용)
  Future<void> show({
    required String title,
    required String body,
    String? payload,
  });
}

class FlutterLocalNotificationDataSource implements LocalNotificationDataSource {
  final Logger _logger = Logger();
  final FlutterLocalNotificationsPlugin _plugin;

  /// 알림마다 다른 ID를 부여해 이전 알림을 덮어쓰지 않도록 한다.
  int _nextNotificationId = 0;

  FlutterLocalNotificationDataSource(this._plugin);

  @override
  Future<void> initialize({
    required void Function(String? payload) onTap,
  }) async {
    try {
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

      // 권한 요청은 firebase_messaging의 requestPermission()이 담당하므로
      // 여기서는 중복 요청하지 않는다.
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      await _plugin.initialize(
        settings: const InitializationSettings(
          android: androidSettings,
          iOS: darwinSettings,
        ),
        onDidReceiveNotificationResponse: (response) => onTap(response.payload),
      );

      await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(
            const AndroidNotificationChannel(
              notificationChannelId,
              notificationChannelName,
              description: notificationChannelDescription,
              importance: Importance.high,
            ),
          );
    } catch (e) {
      _logger.e('로컬 알림 초기화 실패', error: e);
      throw NotificationConfigException(message: e.toString());
    }
  }

  @override
  Future<void> show({
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      await _plugin.show(
        _nextNotificationId++,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            notificationChannelId,
            notificationChannelName,
            channelDescription: notificationChannelDescription,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        payload: payload,
      );
    } catch (e) {
      _logger.e('로컬 알림 표시 실패', error: e);
      throw NotificationUnknownException(message: e.toString());
    }
  }
}

@Riverpod(keepAlive: true)
LocalNotificationDataSource localNotificationDataSource(Ref ref) {
  return FlutterLocalNotificationDataSource(FlutterLocalNotificationsPlugin());
}
```

- [ ] **Step 4: 코드 생성**

```bash
dart run build_runner build --delete-conflicting-outputs
```

기대: `lib/data/data_sources/local_notification_data_source.g.dart` 생성

- [ ] **Step 5: 정적 분석 및 포맷**

```bash
dart format lib/data/data_sources/notification_data_source.dart lib/data/data_sources/local_notification_data_source.dart
dart analyze
```

기대: 에러 0건. `initialize`의 파라미터명(`settings:`)이 틀렸다는 에러가 나면 설치된 버전의 시그니처를 확인해 맞춘다.

- [ ] **Step 6: 기존 테스트 회귀 확인**

```bash
flutter test
```

기대: 기존 테스트 전부 통과

- [ ] **Step 7: 커밋**

```bash
git add lib/data/data_sources/notification_data_source.dart lib/data/data_sources/local_notification_data_source.dart lib/data/data_sources/local_notification_data_source.g.dart
git commit -m "feat: #19 - 푸시 메시지 스트림 및 로컬 알림 DataSource 추가"
```

---

## Task 8: NotificationRepository / NotificationUseCase 배선

**Files:**
- Create: `lib/domain/repository_interfaces/notification_repository.dart`
- Create: `lib/data/repositories/notification_repository_impl.dart`
- Create: `lib/domain/use_cases/notification_use_case.dart`
- Create: `lib/domain/use_cases/notification_use_case_provider.dart`

**Interfaces:**
- Consumes: `NotificationDataSource` / `LocalNotificationDataSource` (Task 7), `UserDataSource.addFcmToken` (기존), `PushMessage` / `RemoteMessageMapper` (Task 6)
- Produces:
  - `NotificationRepository` / `NotificationUseCase` (동일 시그니처):
    - `Future<Either<Exception, bool>> requestPermission()`
    - `Future<Either<Exception, void>> registerFcmToken({required String uid, String? token})`
    - `Stream<String> get onTokenRefresh`
    - `Stream<PushMessage> get foregroundMessages`
    - `Stream<PushMessage> get openedAppMessages`
    - `Future<PushMessage?> getInitialMessage()`
    - `Future<Either<Exception, void>> initLocalNotifications({required void Function(String? payload) onTap})`
    - `Future<Either<Exception, void>> showLocalNotification(PushMessage message)`
  - `notificationRepositoryProvider`, `notificationUseCaseProvider`

**설계 노트:**
- 토큰 갱신 시 이전 토큰을 알 수 없으므로 `replaceFcmToken` 대신 `addFcmToken`만 호출한다. 낡은 토큰은 Cloud Functions가 발송 실패 응답을 보고 정리한다(Task 2·4) — 클라이언트가 굳이 추적할 필요가 없다.
- `NotificationUseCase`는 전부 단순 위임이다. CLAUDE.md의 D10(단순 위임 UseCase 허용) 및 "Presentation → Domain 접근 규칙"에 따라 계층을 생략하지 않는다.

- [ ] **Step 1: Repository 인터페이스 작성**

`lib/domain/repository_interfaces/notification_repository.dart`:

```dart
import 'package:fpdart/fpdart.dart';

import 'package:studio_chance/domain/entities/push_message.dart';

abstract interface class NotificationRepository {
  /// 알림 권한 요청
  /// - 허용됨(authorized/provisional)이면 `true`
  Future<Either<Exception, bool>> requestPermission();

  /// 현재 기기의 FCM 토큰을 `users/{uid}.fcmTokens`에 추가한다.
  /// - [token]이 null이면 SDK에서 현재 토큰을 조회한다.
  Future<Either<Exception, void>> registerFcmToken({
    required String uid,
    String? token,
  });

  /// FCM 토큰 갱신 스트림
  Stream<String> get onTokenRefresh;

  /// 앱이 포그라운드일 때 수신한 메시지
  Stream<PushMessage> get foregroundMessages;

  /// 백그라운드에서 알림을 탭해 앱이 열린 경우의 메시지
  Stream<PushMessage> get openedAppMessages;

  /// 종료 상태에서 알림을 탭해 앱이 실행됐다면 그 메시지
  Future<PushMessage?> getInitialMessage();

  /// 로컬 알림 초기화 (Android 채널 생성 포함)
  Future<Either<Exception, void>> initLocalNotifications({
    required void Function(String? payload) onTap,
  });

  /// 포그라운드 수신 메시지를 로컬 알림으로 표시한다.
  Future<Either<Exception, void>> showLocalNotification(PushMessage message);
}
```

- [ ] **Step 2: Repository 구현체 작성**

`lib/data/repositories/notification_repository_impl.dart`:

```dart
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fpdart/fpdart.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/common/utils/exception_utils.dart';
import 'package:studio_chance/data/data_sources/local_notification_data_source.dart';
import 'package:studio_chance/data/data_sources/notification_data_source.dart';
import 'package:studio_chance/data/data_sources/user_data_source.dart';
import 'package:studio_chance/data/models/push_message_mapper.dart';
import 'package:studio_chance/domain/entities/push_message.dart';
import 'package:studio_chance/domain/repository_interfaces/notification_repository.dart';

part 'notification_repository_impl.g.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final Logger _logger = Logger();

  final NotificationDataSource _notificationDataSource;
  final LocalNotificationDataSource _localNotificationDataSource;
  final UserDataSource _userDataSource;

  NotificationRepositoryImpl({
    required NotificationDataSource notificationDataSource,
    required LocalNotificationDataSource localNotificationDataSource,
    required UserDataSource userDataSource,
  }) : _notificationDataSource = notificationDataSource,
       _localNotificationDataSource = localNotificationDataSource,
       _userDataSource = userDataSource;

  @override
  Future<Either<Exception, bool>> requestPermission() async {
    try {
      final settings = await _notificationDataSource.requestPermission();
      final granted =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;

      _logger.i('알림 권한 요청 결과: ${settings.authorizationStatus}');
      return right(granted);
    } catch (e) {
      _logger.e('알림 권한 요청 실패');
      return left(toException(e));
    }
  }

  @override
  Future<Either<Exception, void>> registerFcmToken({
    required String uid,
    String? token,
  }) async {
    try {
      final resolvedToken = token ?? await _notificationDataSource.getFcmToken();
      await _userDataSource.addFcmToken(uid, resolvedToken);

      _logger.i('FCM 토큰 등록 완료\nuid: $uid');
      return right(null);
    } catch (e) {
      _logger.e('FCM 토큰 등록 실패');
      return left(toException(e));
    }
  }

  @override
  Stream<String> get onTokenRefresh => _notificationDataSource.onTokenRefresh;

  @override
  Stream<PushMessage> get foregroundMessages =>
      _notificationDataSource.onMessage.map((message) => message.toEntity());

  @override
  Stream<PushMessage> get openedAppMessages => _notificationDataSource
      .onMessageOpenedApp
      .map((message) => message.toEntity());

  @override
  Future<PushMessage?> getInitialMessage() async {
    final message = await _notificationDataSource.getInitialMessage();
    return message?.toEntity();
  }

  @override
  Future<Either<Exception, void>> initLocalNotifications({
    required void Function(String? payload) onTap,
  }) async {
    try {
      await _localNotificationDataSource.initialize(onTap: onTap);
      return right(null);
    } catch (e) {
      _logger.e('로컬 알림 초기화 실패');
      return left(toException(e));
    }
  }

  @override
  Future<Either<Exception, void>> showLocalNotification(
    PushMessage message,
  ) async {
    try {
      await _localNotificationDataSource.show(
        title: message.title ?? '알림',
        body: message.body ?? '',
        payload: jsonEncode(message.data),
      );
      return right(null);
    } catch (e) {
      _logger.e('로컬 알림 표시 실패');
      return left(toException(e));
    }
  }
}

@Riverpod(keepAlive: true)
NotificationRepository notificationRepository(Ref ref) {
  return NotificationRepositoryImpl(
    notificationDataSource: ref.watch(notificationDataSourceProvider),
    localNotificationDataSource: ref.watch(localNotificationDataSourceProvider),
    userDataSource: ref.watch(userDataSourceProvider),
  );
}
```

- [ ] **Step 3: UseCase 작성 (순수 Domain — data import 금지)**

`lib/domain/use_cases/notification_use_case.dart`:

```dart
import 'package:fpdart/fpdart.dart';

import 'package:studio_chance/domain/entities/push_message.dart';
import 'package:studio_chance/domain/repository_interfaces/notification_repository.dart';

abstract interface class NotificationUseCase {
  Future<Either<Exception, bool>> requestPermission();

  Future<Either<Exception, void>> registerFcmToken({
    required String uid,
    String? token,
  });

  Stream<String> get onTokenRefresh;

  Stream<PushMessage> get foregroundMessages;

  Stream<PushMessage> get openedAppMessages;

  Future<PushMessage?> getInitialMessage();

  Future<Either<Exception, void>> initLocalNotifications({
    required void Function(String? payload) onTap,
  });

  Future<Either<Exception, void>> showLocalNotification(PushMessage message);
}

/// 현재는 모든 메서드가 Repository로 단순 위임한다.
/// Presentation이 Repository를 직접 호출하지 않도록 계층을 유지하기 위함이며,
/// 알림 정책(예: 방해 금지 시간)이 생기면 이 계층에 추가한다. (CLAUDE.md D10)
class NotificationUseCaseImpl implements NotificationUseCase {
  final NotificationRepository _notificationRepository;

  NotificationUseCaseImpl({
    required NotificationRepository notificationRepository,
  }) : _notificationRepository = notificationRepository;

  @override
  Future<Either<Exception, bool>> requestPermission() =>
      _notificationRepository.requestPermission();

  @override
  Future<Either<Exception, void>> registerFcmToken({
    required String uid,
    String? token,
  }) => _notificationRepository.registerFcmToken(uid: uid, token: token);

  @override
  Stream<String> get onTokenRefresh => _notificationRepository.onTokenRefresh;

  @override
  Stream<PushMessage> get foregroundMessages =>
      _notificationRepository.foregroundMessages;

  @override
  Stream<PushMessage> get openedAppMessages =>
      _notificationRepository.openedAppMessages;

  @override
  Future<PushMessage?> getInitialMessage() =>
      _notificationRepository.getInitialMessage();

  @override
  Future<Either<Exception, void>> initLocalNotifications({
    required void Function(String? payload) onTap,
  }) => _notificationRepository.initLocalNotifications(onTap: onTap);

  @override
  Future<Either<Exception, void>> showLocalNotification(PushMessage message) =>
      _notificationRepository.showLocalNotification(message);
}
```

- [ ] **Step 4: UseCase Provider 작성 (data import 허용 — D5)**

`lib/domain/use_cases/notification_use_case_provider.dart`:

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/data/repositories/notification_repository_impl.dart';
import 'package:studio_chance/domain/use_cases/notification_use_case.dart';

part 'notification_use_case_provider.g.dart';

@Riverpod(keepAlive: true)
NotificationUseCase notificationUseCase(Ref ref) {
  return NotificationUseCaseImpl(
    notificationRepository: ref.watch(notificationRepositoryProvider),
  );
}
```

- [ ] **Step 5: 코드 생성**

```bash
dart run build_runner build --delete-conflicting-outputs
```

기대: `notification_repository_impl.g.dart`, `notification_use_case_provider.g.dart` 생성

- [ ] **Step 6: 정적 분석 및 포맷**

```bash
dart format lib/domain/repository_interfaces/notification_repository.dart lib/data/repositories/notification_repository_impl.dart lib/domain/use_cases/notification_use_case.dart lib/domain/use_cases/notification_use_case_provider.dart
dart analyze
```

기대: 에러 0건. `custom_lint`가 `notification_use_case.dart`의 data import를 지적하면 잘못 넣은 것이므로 제거한다.

- [ ] **Step 7: 커밋**

```bash
git add lib/domain/repository_interfaces/notification_repository.dart lib/data/repositories/notification_repository_impl.dart lib/data/repositories/notification_repository_impl.g.dart lib/domain/use_cases/notification_use_case.dart lib/domain/use_cases/notification_use_case_provider.dart lib/domain/use_cases/notification_use_case_provider.g.dart
git commit -m "feat: #19 - NotificationRepository·UseCase 계층 추가"
```

---

## Task 9: NotificationController — 권한 요청 · 토큰 등록 · 딥링크

**Files:**
- Create: `lib/presentation/providers/notification_controller.dart`
- Modify: `lib/presentation/providers/home_store_filter_controller.dart`
- Modify: `lib/my_app.dart`
- Test: `test/presentation/providers/notification_routing_test.dart`
- Test: `test/presentation/providers/home_store_filter_controller_test.dart`

**Interfaces:**
- Consumes: `notificationUseCaseProvider` (Task 8), `joinRequestNotificationType` (Task 5), `currentUserProvider` / `appAuthControllerProvider` (기존), `goRouterProvider` (기존)
- Produces:
  - `String? joinRequestStoreIdOf(PushMessage message)` — 이동 대상 storeId, 처리 대상이 아니면 null
  - `notificationControllerProvider` (`@Riverpod(keepAlive: true)`)
  - `HomeStoreFilterController.ensureSelected(String storeId)`

**설계 노트:**
- 종료 상태에서 알림을 탭하면 인증 완료 전에 메시지가 도착한다. 그 상태로 `/home`으로 보내면 라우터 redirect에 다시 튕기므로, `AppStatus.authenticated`가 될 때까지 `_pendingMessage`에 보관했다가 소비한다.
- 승인 대기 멤버 관리 화면이 없어 착지점은 홈이다. 화면이 생기면 `_navigate`의 이동 대상만 바꾼다 (TODO 주석 명시).
- 사용자가 필터에서 꺼둔 점포라도 알림 대상이면 표시해야 하므로 `ensureSelected`로 선택에 **추가**만 한다. 다른 점포의 선택 상태는 건드리지 않는다.

- [ ] **Step 1: 실패하는 테스트 작성 (라우팅 판단)**

`test/presentation/providers/notification_routing_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';

import 'package:studio_chance/domain/entities/push_message.dart';
import 'package:studio_chance/presentation/providers/notification_controller.dart';

void main() {
  group('joinRequestStoreIdOf', () {
    test('가입 신청 메시지면 storeId를 반환한다', () {
      const message = PushMessage(
        type: 'joinRequest',
        data: {'type': 'joinRequest', 'storeId': 'store1'},
      );

      expect(joinRequestStoreIdOf(message), 'store1');
    });

    test('다른 종류의 메시지는 null을 반환한다', () {
      const message = PushMessage(
        type: 'reservationCreated',
        data: {'storeId': 'store1'},
      );

      expect(joinRequestStoreIdOf(message), isNull);
    });

    test('storeId가 없으면 null을 반환한다', () {
      const message = PushMessage(type: 'joinRequest', data: {});

      expect(joinRequestStoreIdOf(message), isNull);
    });

    test('storeId가 빈 문자열이면 null을 반환한다', () {
      const message = PushMessage(
        type: 'joinRequest',
        data: {'storeId': ''},
      );

      expect(joinRequestStoreIdOf(message), isNull);
    });
  });
}
```

- [ ] **Step 2: 실패하는 테스트 작성 (필터 선택 추가)**

`test/presentation/providers/home_store_filter_controller_test.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:studio_chance/presentation/providers/app_auth_controller.dart';
import 'package:studio_chance/presentation/providers/home_store_filter_controller.dart';

import '../../helpers/fake_entities.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  ProviderContainer buildContainer({required List<String> storeIds}) {
    final container = ProviderContainer(
      overrides: [
        currentUserProvider.overrideWith(
          (ref) async => fakeUserWithStores(storeIds),
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('선택되지 않은 점포를 선택에 추가한다', () async {
    final container = buildContainer(storeIds: ['s1', 's2']);
    await container.read(currentUserProvider.future);

    final notifier = container.read(homeStoreFilterControllerProvider.notifier);
    notifier.toggle('s1'); // s1 해제
    expect(container.read(homeStoreFilterControllerProvider), {'s2'});

    notifier.ensureSelected('s1');

    expect(container.read(homeStoreFilterControllerProvider), {'s1', 's2'});
  });

  test('이미 선택된 점포면 상태가 그대로다', () async {
    final container = buildContainer(storeIds: ['s1', 's2']);
    await container.read(currentUserProvider.future);

    final before = container.read(homeStoreFilterControllerProvider);
    container.read(homeStoreFilterControllerProvider.notifier).ensureSelected('s1');

    expect(container.read(homeStoreFilterControllerProvider), before);
  });
}
```

`test/helpers/fake_entities.dart` 맨 아래에 아래 헬퍼를 추가한다. (기존 `fakeUser`는 점포가 1개로 고정이라 필터 테스트에 쓸 수 없으므로 `copyWith`로 점포 목록만 바꾼다. 필요한 import는 파일 상단에 이미 모두 있다.)

```dart
/// 지정한 점포 ID 목록을 가진 사용자 (홈 점포 필터 테스트용)
User fakeUserWithStores(List<String> storeIds) {
  return fakeUser.copyWith(
    storeInfos: [
      for (final id in storeIds)
        UserStoreInfo(
          id: id,
          name: '점포 $id',
          role: UserRole.admin,
          color: StoreColor.red,
          memo: '',
        ),
    ],
  );
}
```

- [ ] **Step 3: 테스트가 실패하는지 확인**

```bash
flutter test test/presentation/providers/notification_routing_test.dart test/presentation/providers/home_store_filter_controller_test.dart
```

기대: FAIL — `notification_controller.dart` 없음, `ensureSelected` 메서드 없음

- [ ] **Step 4: `ensureSelected` 구현**

`lib/presentation/providers/home_store_filter_controller.dart`의 `toggleAll()` 메서드 **뒤에** 추가한다.

```dart
  /// 특정 점포를 표시 상태로 만든다 (푸시 알림 딥링크 등에서 사용).
  ///
  /// 이미 선택돼 있으면 아무것도 하지 않으며, 다른 점포의 선택 상태는 유지한다.
  void ensureSelected(String storeId) {
    if (state.contains(storeId)) return;
    state = {...state, storeId};
    _persistDeselected();
  }
```

- [ ] **Step 5: `NotificationController` 구현**

`lib/presentation/providers/notification_controller.dart`:

```dart
import 'dart:async';
import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/constants/notification_constants.dart';
import 'package:studio_chance/domain/entities/push_message.dart';
import 'package:studio_chance/domain/use_cases/notification_use_case_provider.dart';
import 'package:studio_chance/presentation/providers/app_auth_controller.dart';
import 'package:studio_chance/presentation/providers/home_store_filter_controller.dart';
import 'package:studio_chance/router/app_router.dart';
import 'package:studio_chance/router/router_path.dart';

part 'notification_controller.g.dart';

/// 푸시 메시지가 "가입 신청"이면 이동 대상 점포 ID를, 아니면 null을 반환한다.
String? joinRequestStoreIdOf(PushMessage message) {
  if (message.type != joinRequestNotificationType) return null;

  final storeId = message.data['storeId'];
  if (storeId == null || storeId.isEmpty) return null;

  return storeId;
}

/// 알림 권한 요청, FCM 토큰 등록, 수신 메시지 표시·딥링크를 담당한다.
///
/// `MyApp`에서 watch하여 앱 생명주기 동안 살아 있게 한다.
@Riverpod(keepAlive: true)
class NotificationController extends _$NotificationController {
  final _logger = Logger();

  StreamSubscription<String>? _tokenSubscription;
  StreamSubscription<PushMessage>? _foregroundSubscription;
  StreamSubscription<PushMessage>? _openedAppSubscription;

  /// 인증이 끝나기 전에 도착한 메시지 (종료 상태에서 알림 탭한 경우)
  PushMessage? _pendingMessage;

  @override
  Future<void> build() async {
    await _cancelSubscriptions();
    ref.onDispose(_cancelSubscriptions);

    final user = await ref.watch(currentUserProvider.future);
    if (user == null) return;

    final useCase = ref.read(notificationUseCaseProvider);

    // 인증이 늦게 끝나는 경우를 대비해 보류된 메시지를 소비한다.
    ref.listen(appAuthControllerProvider, (_, next) {
      if (next.valueOrNull != AppStatus.authenticated) return;

      final pending = _pendingMessage;
      if (pending == null) return;
      _pendingMessage = null;
      _handleMessage(pending);
    });

    await useCase.initLocalNotifications(onTap: _handlePayload);

    final permissionResult = await useCase.requestPermission();
    permissionResult.fold(
      (error) => _logger.w('알림 권한 요청 실패 (무시)', error: error),
      (granted) => _logger.i('알림 권한 허용 여부: $granted'),
    );

    final registerResult = await useCase.registerFcmToken(uid: user.id);
    registerResult.fold(
      (error) => _logger.w('FCM 토큰 등록 실패 (무시)', error: error),
      (_) {},
    );

    _tokenSubscription = useCase.onTokenRefresh.listen((token) {
      useCase.registerFcmToken(uid: user.id, token: token);
    });

    _foregroundSubscription = useCase.foregroundMessages.listen((message) {
      useCase.showLocalNotification(message);
    });

    _openedAppSubscription = useCase.openedAppMessages.listen(_handleMessage);

    final initialMessage = await useCase.getInitialMessage();
    if (initialMessage != null) _handleMessage(initialMessage);
  }

  /// 로컬 알림 payload(JSON 문자열)를 메시지로 되돌려 처리한다.
  void _handlePayload(String? payload) {
    if (payload == null || payload.isEmpty) return;

    try {
      final decoded = jsonDecode(payload) as Map<String, dynamic>;
      _handleMessage(
        PushMessage(
          type: decoded['type']?.toString() ?? '',
          data: decoded.map((k, v) => MapEntry(k, v?.toString() ?? '')),
        ),
      );
    } catch (e) {
      _logger.w('알림 payload 파싱 실패', error: e);
    }
  }

  void _handleMessage(PushMessage message) {
    final storeId = joinRequestStoreIdOf(message);
    if (storeId == null) return;

    final status = ref.read(appAuthControllerProvider).valueOrNull;
    if (status != AppStatus.authenticated) {
      // 스플래시·온보딩 중이면 홈으로 보낼 수 없으므로 보류한다.
      _pendingMessage = message;
      return;
    }

    // TODO: 승인 대기 멤버 관리 화면이 생기면 홈 대신 그 화면으로 이동할 것 (#19)
    ref.read(homeStoreFilterControllerProvider.notifier).ensureSelected(storeId);
    ref.read(goRouterProvider).go(SCRoute.home.path);
  }

  Future<void> _cancelSubscriptions() async {
    await _tokenSubscription?.cancel();
    await _foregroundSubscription?.cancel();
    await _openedAppSubscription?.cancel();
    _tokenSubscription = null;
    _foregroundSubscription = null;
    _openedAppSubscription = null;
  }
}
```

- [ ] **Step 6: 코드 생성**

```bash
dart run build_runner build --delete-conflicting-outputs
```

기대: `lib/presentation/providers/notification_controller.g.dart` 생성

- [ ] **Step 7: 테스트 통과 확인**

```bash
flutter test test/presentation/providers/notification_routing_test.dart test/presentation/providers/home_store_filter_controller_test.dart
```

기대: PASS — 6개 테스트 통과

- [ ] **Step 8: `MyApp`에서 컨트롤러 구독**

`lib/my_app.dart`의 import에 추가한다.

```dart
import 'package:studio_chance/presentation/providers/notification_controller.dart';
```

`build()` 안, `final GoRouter router = ref.watch(goRouterProvider);` **바로 아래**에 추가한다.

```dart
    // 알림 권한 요청·토큰 등록·딥링크 처리를 앱 생명주기 동안 유지한다.
    // (로그인 전에는 컨트롤러 내부에서 아무 동작도 하지 않는다)
    ref.watch(notificationControllerProvider);
```

- [ ] **Step 9: 전체 테스트 및 정적 분석**

```bash
dart format lib/presentation/providers/notification_controller.dart lib/presentation/providers/home_store_filter_controller.dart lib/my_app.dart test/presentation/providers/notification_routing_test.dart test/presentation/providers/home_store_filter_controller_test.dart
dart analyze
flutter test
```

기대: 에러 0건, 전체 테스트 통과

- [ ] **Step 10: 커밋**

```bash
git add lib/presentation/providers/notification_controller.dart lib/presentation/providers/notification_controller.g.dart lib/presentation/providers/home_store_filter_controller.dart lib/my_app.dart test/presentation/providers/notification_routing_test.dart test/presentation/providers/home_store_filter_controller_test.dart test/helpers/fake_entities.dart
git commit -m "feat: #19 - 알림 권한 요청·토큰 등록·딥링크 컨트롤러 추가"
```

---

## Task 10: 멤버 제거(거절) 도메인 배선

**Files:**
- Modify: `lib/domain/repository_interfaces/store_repository.dart`
- Modify: `lib/data/repositories/store_repository_impl.dart`
- Modify: `lib/domain/use_cases/store_use_case.dart`
- Test: `test/data/repositories/store_repository_member_test.dart`

**Interfaces:**
- Consumes: `StoreDataSource.removeMember(String storeId, String uid)` (이미 구현되어 있음)
- Produces:
  - `StoreRepository.removeMember({required String storeId, required String uid})`
  - `StoreUseCase.removeMember({required String storeId, required String targetUid})`

**설계 노트:** `StoreFirestoreDataSource.removeMember`는 이미 `memberById.$uid` / `waitingMemberById.$uid` / `users/{uid}.storeById.$storeId`를 한 배치로 지운다. 승인 대기자 거절에 그대로 쓸 수 있으므로 새 DataSource 메서드를 만들지 않고 Repository·UseCase 위임만 추가한다. UseCase 파라미터명은 기존 `approveMember` / `updateMemberRole`과 맞춰 `targetUid`를 쓴다.

- [ ] **Step 1: 실패하는 테스트 작성**

`test/data/repositories/store_repository_member_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:studio_chance/data/data_sources/store_data_source.dart';
import 'package:studio_chance/data/data_sources/user_data_source.dart';
import 'package:studio_chance/data/repositories/store_repository_impl.dart';

class MockStoreDataSource extends Mock implements StoreDataSource {}

class MockUserDataSource extends Mock implements UserDataSource {}

void main() {
  late StoreRepositoryImpl repository;
  late MockStoreDataSource mockStoreDataSource;
  late MockUserDataSource mockUserDataSource;

  setUp(() {
    mockStoreDataSource = MockStoreDataSource();
    mockUserDataSource = MockUserDataSource();
    repository = StoreRepositoryImpl(
      storeDataSource: mockStoreDataSource,
      userDataSource: mockUserDataSource,
    );
  });

  group('removeMember', () {
    test('StoreDataSource.removeMember에 storeId와 uid를 그대로 전달한다', () async {
      when(
        () => mockStoreDataSource.removeMember(any(), any()),
      ).thenAnswer((_) async {});

      final result = await repository.removeMember(
        storeId: 'store-123',
        uid: 'user-456',
      );

      expect(result.isRight(), isTrue);
      verify(
        () => mockStoreDataSource.removeMember('store-123', 'user-456'),
      ).called(1);
    });

    test('DataSource가 예외를 던지면 left를 반환한다', () async {
      when(
        () => mockStoreDataSource.removeMember(any(), any()),
      ).thenThrow(Exception('삭제 실패'));

      final result = await repository.removeMember(
        storeId: 'store-123',
        uid: 'user-456',
      );

      expect(result.isLeft(), isTrue);
    });
  });
}
```

- [ ] **Step 2: 테스트가 실패하는지 확인**

```bash
flutter test test/data/repositories/store_repository_member_test.dart
```

기대: FAIL — `The method 'removeMember' isn't defined for the type 'StoreRepositoryImpl'`

- [ ] **Step 3: Repository 인터페이스에 선언 추가**

`lib/domain/repository_interfaces/store_repository.dart`의 `approveMember` 선언 **뒤에**(`/// 멤버 권한 변경` 주석 앞에) 추가한다.

```dart

  /// 멤버 제거 (승인 대기자 거절 / 기존 멤버 추방)
  /// - `memberById`, `waitingMemberById`, `users/{uid}.storeById`에서 모두 제거된다.
  Future<Either<Exception, void>> removeMember({
    required String storeId,
    required String uid,
  });
```

- [ ] **Step 4: Repository 구현체에 구현 추가**

`lib/data/repositories/store_repository_impl.dart`의 `approveMember` 구현 **뒤에**(`@override` + `updateMemberRole` 앞에) 추가한다.

```dart

  @override
  Future<Either<Exception, void>> removeMember({
    required String storeId,
    required String uid,
  }) async {
    try {
      await _storeDataSource.removeMember(storeId, uid);

      _logger.i('멤버 제거 완료\nstoreId: $storeId, uid: $uid');
      return right(null);
    } catch (e) {
      _logger.e('멤버 제거 실패');
      return left(toException(e));
    }
  }
```

- [ ] **Step 5: UseCase 인터페이스에 선언 추가**

`lib/domain/use_cases/store_use_case.dart`의 `approveMember` 선언 **뒤에**(`/// 멤버 권한 수정 (관리자용)` 앞에) 추가한다.

```dart

  /// 멤버 제거 (관리자용) — 승인 대기자 거절 및 기존 멤버 추방에 사용
  Future<Either<Exception, void>> removeMember({
    required String storeId,
    required String targetUid,
  });
```

- [ ] **Step 6: UseCase 구현 추가**

같은 파일의 `approveMember` 구현 **뒤에**(`updateMemberRole` 구현 앞에) 추가한다.

```dart

  @override
  Future<Either<Exception, void>> removeMember({
    required String storeId,
    required String targetUid,
  }) {
    return TaskEither(
      () => _storeRepository.removeMember(storeId: storeId, uid: targetUid),
    ).run();
  }
```

- [ ] **Step 7: 테스트 통과 확인**

```bash
flutter test test/data/repositories/store_repository_member_test.dart
```

기대: PASS — 2개 테스트 통과

- [ ] **Step 8: 전체 테스트 및 정적 분석**

```bash
dart format lib/domain/repository_interfaces/store_repository.dart lib/data/repositories/store_repository_impl.dart lib/domain/use_cases/store_use_case.dart test/data/repositories/store_repository_member_test.dart
dart analyze
flutter test
```

기대: 에러 0건, 전체 테스트 통과

- [ ] **Step 9: 커밋**

```bash
git add lib/domain/repository_interfaces/store_repository.dart lib/data/repositories/store_repository_impl.dart lib/domain/use_cases/store_use_case.dart test/data/repositories/store_repository_member_test.dart
git commit -m "feat: #19 - 멤버 제거(거절) Repository·UseCase 배선 추가"
```

---

## Task 11: 승인 대기 멤버 모달

**Files:**
- Create: `lib/presentation/providers/pending_member_controller.dart`
- Create: `lib/presentation/my_page/widgets/pending_member_modal.dart`
- Test: `test/presentation/my_page/pending_member_modal_test.dart`

**Interfaces:**
- Consumes: `StoreUseCase.approveMember` / `removeMember` (Task 10), `storeDetailProvider(storeId)` (기존)
- Produces:
  - `pendingMemberControllerProvider` — `approve({storeId, uid, role})`, `reject({storeId, uid})`
  - `Future<void> showPendingMemberModal(BuildContext context, String storeId)`

**설계 노트:**
- **승인 시 역할을 다시 고르지 않는다.** 신청자가 초대 코드 입력 단계에서 이미 역할을 선택해 `waitingMemberById.{uid}.role`에 저장했으므로, 그 역할 그대로 승인한다. 관리자가 역할을 바꾸고 싶으면 승인 후 `updateMemberRole`로 처리하며, 그 UI는 이번 범위 밖이다.
- 모달 골격은 `lib/presentation/home/widgets/store_filter_modal.dart`를 그대로 따른다 (두 detent 시트, `Listener` 기반 드래그, `AnimationController(lowerBound: initialSize)`). CLAUDE.md "모달 시트 패턴" 준수 — `DraggableScrollableSheet` 금지.
- 승인/거절 후 `ref.invalidate(storeDetailProvider(storeId))`로 목록을 갱신한다. 현재 관리자 본인의 `storeById`는 바뀌지 않으므로 `currentUserProvider`는 건드리지 않는다.

- [ ] **Step 1: 실패하는 위젯 테스트 작성**

프로젝트 테스트 규칙상 픽셀·색상·폰트는 검증하지 않고 렌더링 내용과 콜백 호출만 확인한다.

`test/presentation/my_page/pending_member_modal_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:studio_chance/domain/entities/store.dart';
import 'package:studio_chance/domain/entities/store_member_info.dart';
import 'package:studio_chance/common/enums/user_role.dart';
import 'package:studio_chance/presentation/home/controllers/store_detail_provider.dart';
import 'package:studio_chance/presentation/my_page/widgets/pending_member_modal.dart';

import '../../helpers/fake_entities.dart';

Store storeWithWaiting(List<StoreMemberInfo> waiting) =>
    fakeStore.copyWith(waitingMemberInfos: waiting);

Widget wrap(Widget child, {required Store store}) {
  return ProviderScope(
    overrides: [
      storeDetailProvider(store.id).overrideWith((ref) async => store),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: LayoutBuilder(
          builder: (_, constraints) => child,
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('대기 중인 신청자의 닉네임과 신청 역할을 보여준다', (tester) async {
    final store = storeWithWaiting([
      StoreMemberInfo(
        user: fakeUser.copyWith(id: 'applicant-1', nickname: '홍길동'),
        role: UserRole.staff,
      ),
    ]);

    await tester.pumpWidget(
      wrap(
        PendingMemberModal(storeId: store.id, maxAvailableHeight: 600),
        store: store,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('홍길동'), findsOneWidget);
    expect(find.text(UserRole.staff.displayName), findsOneWidget);
  });

  testWidgets('대기자가 없으면 안내 문구를 보여준다', (tester) async {
    final store = storeWithWaiting([]);

    await tester.pumpWidget(
      wrap(
        PendingMemberModal(storeId: store.id, maxAvailableHeight: 600),
        store: store,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('대기 중인 가입 신청이 없습니다.'), findsOneWidget);
  });

  testWidgets('닉네임이 없으면 이름으로 대체 표시한다', (tester) async {
    final store = storeWithWaiting([
      StoreMemberInfo(
        user: fakeUser.copyWith(id: 'applicant-2', nickname: null, name: '김철수'),
        role: UserRole.viewer,
      ),
    ]);

    await tester.pumpWidget(
      wrap(
        PendingMemberModal(storeId: store.id, maxAvailableHeight: 600),
        store: store,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('김철수'), findsOneWidget);
  });
}
```

- [ ] **Step 2: 테스트가 실패하는지 확인**

```bash
flutter test test/presentation/my_page/pending_member_modal_test.dart
```

기대: FAIL — `Target of URI doesn't exist: '.../pending_member_modal.dart'`

- [ ] **Step 3: 컨트롤러 작성**

`lib/presentation/providers/pending_member_controller.dart`:

```dart
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/common/enums/user_role.dart';
import 'package:studio_chance/domain/use_cases/store_use_case_provider.dart';
import 'package:studio_chance/presentation/home/controllers/store_detail_provider.dart';

part 'pending_member_controller.g.dart';

/// 승인 대기 멤버의 승인·거절 액션을 UseCase에 위임한다.
///
/// 위젯이 `*_use_case_provider.dart`를 직접 읽지 않도록 하기 위한 계층이다.
/// (CLAUDE.md "Presentation → Domain 접근 규칙")
@riverpod
class PendingMemberController extends _$PendingMemberController {
  final _logger = Logger();

  @override
  FutureOr<void> build() {}

  /// 신청자를 승인한다. 역할은 신청 시 선택한 값을 그대로 사용한다.
  Future<void> approve({
    required String storeId,
    required String uid,
    required UserRole role,
  }) async {
    final result = await ref
        .read(storeUseCaseProvider)
        .approveMember(storeId: storeId, targetUid: uid, role: role);
    final stackTrace = StackTrace.current;

    result.fold(
      (e) {
        _logger.e('멤버 승인 실패', error: e);
        state = AsyncError(e, stackTrace);
      },
      (_) => ref.invalidate(storeDetailProvider(storeId)),
    );
  }

  /// 신청을 거절한다 (대기 명단 및 대상 사용자의 점포 정보에서 제거).
  Future<void> reject({required String storeId, required String uid}) async {
    final result = await ref
        .read(storeUseCaseProvider)
        .removeMember(storeId: storeId, targetUid: uid);
    final stackTrace = StackTrace.current;

    result.fold(
      (e) {
        _logger.e('가입 신청 거절 실패', error: e);
        state = AsyncError(e, stackTrace);
      },
      (_) => ref.invalidate(storeDetailProvider(storeId)),
    );
  }
}
```

- [ ] **Step 4: 모달 작성**

`lib/presentation/my_page/widgets/pending_member_modal.dart`:

```dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/domain/entities/store_member_info.dart';
import 'package:studio_chance/presentation/colors.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';
import 'package:studio_chance/presentation/commons/widgets/custom_alert_dialog.dart';
import 'package:studio_chance/presentation/commons/widgets/app_bar/modal_app_bar.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/grouped_form_container.dart';
import 'package:studio_chance/presentation/commons/widgets/modal_grabber.dart';
import 'package:studio_chance/presentation/commons/widgets/safe_area_with_padding.dart';
import 'package:studio_chance/presentation/home/controllers/store_detail_provider.dart';
import 'package:studio_chance/presentation/providers/pending_member_controller.dart';

const double _kModalInitialSize = 0.5;
const double _kModalMaxSize = 1.0;

/// 승인 대기 멤버 모달.
///
/// 각 항목: (닉네임) (신청 역할) (거절) (승인).
/// 승인 시 역할은 신청자가 초대 코드 단계에서 선택한 값을 그대로 사용한다.
///
/// 두 detent 시트 구조는 [StoreFilterModal]과 동일하다 (CLAUDE.md "모달 시트 패턴").
class PendingMemberModal extends ConsumerStatefulWidget {
  const PendingMemberModal({
    super.key,
    required this.storeId,
    required this.maxAvailableHeight,
  });

  final String storeId;
  final double maxAvailableHeight;

  @override
  ConsumerState<PendingMemberModal> createState() => _PendingMemberModalState();
}

class _PendingMemberModalState extends ConsumerState<PendingMemberModal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _sheetController;
  double _grabberDragStartSize = _kModalInitialSize;
  double _grabberDragStartY = 0;

  @override
  void initState() {
    super.initState();
    _sheetController = AnimationController(
      vsync: this,
      value: _kModalInitialSize,
      lowerBound: _kModalInitialSize,
      upperBound: _kModalMaxSize,
    );
  }

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  void _dismissModal() => Navigator.pop(context);

  void _animateTo(double target) {
    _sheetController.animateTo(
      target,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _snapToNearest() {
    const mid = (_kModalInitialSize + _kModalMaxSize) / 2;
    _animateTo(
      _sheetController.value >= mid ? _kModalMaxSize : _kModalInitialSize,
    );
  }

  String _displayName(StoreMemberInfo info) =>
      info.user.nickname ?? info.user.name;

  void _onApprove(StoreMemberInfo info) {
    showCustomAlertDialog(
      context: context,
      title: '${_displayName(info)}님을 승인할까요?',
      content: '${info.role.displayName} 역할로 점포에 참여하게 됩니다.',
      onConfirmAfterPop: () {
        ref
            .read(pendingMemberControllerProvider.notifier)
            .approve(
              storeId: widget.storeId,
              uid: info.user.id,
              role: info.role,
            );
      },
    );
  }

  void _onReject(StoreMemberInfo info) {
    showCustomAlertDialog(
      context: context,
      title: '${_displayName(info)}님의 신청을 거절할까요?',
      content: '거절한 신청은 되돌릴 수 없습니다.',
      confirmText: '거절',
      isDestructive: true,
      onConfirmAfterPop: () {
        ref
            .read(pendingMemberControllerProvider.notifier)
            .reject(storeId: widget.storeId, uid: info.user.id);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final storeAsync = ref.watch(storeDetailProvider(widget.storeId));
    final waitingInfos = storeAsync.asData?.value?.waitingMemberInfos ?? [];

    return AnimatedBuilder(
      animation: _sheetController,
      builder: (ctx, child) => SizedBox(
        height: widget.maxAvailableHeight * _sheetController.value,
        child: child,
      ),
      child: Material(
        color: context.systemGroupedBackground,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(modalTopCornerRadius),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Listener(
              behavior: HitTestBehavior.translucent,
              onPointerDown: (event) {
                _grabberDragStartSize = _sheetController.value;
                _grabberDragStartY = event.position.dy;
              },
              onPointerMove: (event) {
                final delta = -event.delta.dy / widget.maxAvailableHeight;
                _sheetController.value = (_sheetController.value + delta).clamp(
                  _kModalInitialSize,
                  _kModalMaxSize,
                );
              },
              onPointerUp: (event) {
                final totalDy = event.position.dy - _grabberDragStartY;
                if (totalDy.abs() < 10) return;
                if (totalDy > 30) {
                  if (_grabberDragStartSize <= _kModalInitialSize + 0.05) {
                    _dismissModal();
                  } else {
                    _animateTo(_kModalInitialSize);
                  }
                } else if (totalDy < -30) {
                  _animateTo(_kModalMaxSize);
                } else {
                  _snapToNearest();
                }
              },
              onPointerCancel: (_) => _snapToNearest(),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ModalGrabber(),
                  ModalAppBar(title: '가입 신청'),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: SafeAreaWithPadding(
                  top: false,
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    horizontalPadding,
                    16,
                    horizontalPadding,
                    8,
                  ),
                  child: waitingInfos.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Text(
                            '대기 중인 가입 신청이 없습니다.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: context.secondaryLabel),
                          ),
                        )
                      : GroupedFormContainer(
                          children: [
                            for (final info in waitingInfos)
                              _PendingMemberRow(
                                name: _displayName(info),
                                roleLabel: info.role.displayName,
                                onApprove: () => _onApprove(info),
                                onReject: () => _onReject(info),
                              ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 대기 멤버 한 줄: (닉네임) (신청 역할) (거절) (승인)
class _PendingMemberRow extends StatelessWidget {
  const _PendingMemberRow({
    required this.name,
    required this.roleLabel,
    required this.onApprove,
    required this.onReject,
  });

  final String name;
  final String roleLabel;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      height: inputFormComponentHeight,
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: horizontalPadding,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: textTheme.bodyLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              roleLabel,
              style: textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.normal,
                color: context.secondaryLabel,
              ),
            ),
            const SizedBox(width: 8),
            CupertinoButton(
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              onPressed: onReject,
              child: Text(
                '거절',
                style: textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
            CupertinoButton(
              minimumSize: Size.zero,
              padding: const EdgeInsets.only(left: 8),
              onPressed: onApprove,
              child: Text(
                '승인',
                style: textTheme.bodyLarge?.copyWith(color: context.systemBlue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 승인 대기 멤버 모달 표시.
Future<void> showPendingMemberModal(BuildContext context, String storeId) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    enableDrag: false,
    backgroundColor: Colors.transparent,
    barrierColor: modalBarrierColor,
    builder: (ctx) => LayoutBuilder(
      builder: (_, constraints) => PendingMemberModal(
        storeId: storeId,
        maxAvailableHeight: constraints.maxHeight,
      ),
    ),
  );
}
```

- [ ] **Step 5: 코드 생성**

```bash
dart run build_runner build --delete-conflicting-outputs
```

기대: `lib/presentation/providers/pending_member_controller.g.dart` 생성

- [ ] **Step 6: 테스트 통과 확인**

```bash
flutter test test/presentation/my_page/pending_member_modal_test.dart
```

기대: PASS — 3개 테스트 통과

`modalBarrierColor`를 찾지 못한다는 에러가 나면 `lib/presentation/colors.dart`에 정의되어 있는지 확인하고, `store_filter_modal.dart`의 import를 그대로 따른다.

- [ ] **Step 7: 정적 분석 및 포맷**

```bash
dart format lib/presentation/providers/pending_member_controller.dart lib/presentation/my_page/widgets/pending_member_modal.dart test/presentation/my_page/pending_member_modal_test.dart
dart analyze
```

기대: 에러 0건

- [ ] **Step 8: 커밋**

```bash
git add lib/presentation/providers/pending_member_controller.dart lib/presentation/providers/pending_member_controller.g.dart lib/presentation/my_page/widgets/pending_member_modal.dart test/presentation/my_page/pending_member_modal_test.dart
git commit -m "feat: #19 - 승인 대기 멤버 모달 및 승인·거절 컨트롤러 추가"
```

---

## Task 12: 마이페이지 라우트 등록 및 탭바 배선

**Files:**
- Modify: `lib/router/app_router.dart`
- Modify: `lib/presentation/home/widgets/home_tab_bar.dart`
- Create: `lib/presentation/my_page/screens/my_page_screen.dart` (이 Task에서는 뼈대만)

**Interfaces:**
- Consumes: `SCRoute.myPage` (이미 enum에 존재), `_roleSubRoutes()` (이미 app_router에 존재)
- Produces: `/my-page` 라우트, 탭 전환이 실제로 동작하는 `HomeTabBar`

**설계 노트:**
- `HomeTabBar`는 이미 3탭(홈 / 예약 통계 / 마이페이지)을 그리고 있으나 `_onTabTapped`이 로컬 `setState`만 하고 화면 전환이 없다. 로컬 상태를 없애고 **현재 라우트에서 인덱스를 파생**시키면 홈·마이페이지 두 화면이 같은 위젯을 공유하면서도 선택 상태가 어긋나지 않는다. `StatefulWidget` → `StatelessWidget`으로 바뀐다.
- 예약 통계(`stats`)는 화면이 없으므로 탭해도 아무 동작도 하지 않는 현재 상태를 유지한다.
- `_roleSubRoutes()`는 이미 온보딩에서 쓰는 재사용 함수다. `/my-page` 하위에 그대로 붙이면 점포 추가 플로우(역할 선택 → 점포 등록 / 초대 코드)가 완성된다. CLAUDE.md의 "`/commons`: 온보딩·마이페이지가 공유하는 플로우 화면" 설계 의도 그대로다.
- 탭 전환은 `context.go`를 쓴다 (스택을 쌓지 않고 교체).

- [ ] **Step 1: 마이페이지 화면 뼈대 작성**

`lib/presentation/my_page/screens/my_page_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';
import 'package:studio_chance/presentation/commons/widgets/app_bar/custom_app_bar.dart';
import 'package:studio_chance/presentation/commons/widgets/safe_area_with_padding.dart';
import 'package:studio_chance/presentation/home/widgets/home_tab_bar.dart';

class MyPageScreen extends ConsumerWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: context.systemGroupedBackground,
      appBar: const CustomAppBar(title: '마이페이지'),
      body: const SafeAreaWithPadding(
        top: false,
        child: SizedBox.shrink(),
      ),
      bottomNavigationBar: const HomeTabBar(),
    );
  }
}
```

- [ ] **Step 2: `HomeTabBar`를 라우트 기반으로 전환**

`lib/presentation/home/widgets/home_tab_bar.dart` 전체를 아래로 교체한다. 아이콘·라벨·크기·색상 값은 기존과 동일하게 유지한다.

```dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';
import 'package:studio_chance/router/router_path.dart';

/// 홈·마이페이지가 공유하는 하단 탭바
///
/// 선택 상태는 로컬 state가 아니라 현재 라우트에서 파생한다.
/// 두 화면이 같은 위젯을 쓰면서도 선택 표시가 어긋나지 않게 하기 위함이다.
class HomeTabBar extends StatelessWidget {
  const HomeTabBar({super.key});

  /// 탭 항목 정의
  static const List<_TabItem> _tabs = [
    _TabItem(
      label: '홈',
      icon: CupertinoIcons.house,
      activeIcon: CupertinoIcons.house_fill,
    ),
    _TabItem(
      label: '예약 통계',
      icon: CupertinoIcons.chart_bar,
      activeIcon: CupertinoIcons.chart_bar_fill,
    ),
    _TabItem(
      label: '마이페이지',
      icon: CupertinoIcons.person,
      activeIcon: CupertinoIcons.person_fill,
    ),
  ];

  /// 현재 라우트로부터 선택된 탭 인덱스를 구한다.
  int _selectedIndexOf(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith(SCRoute.myPage.path)) return 2;
    if (location.startsWith(SCRoute.stats.path)) return 1;
    return 0;
  }

  void _onTabTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(SCRoute.home.path);
      case 2:
        context.go(SCRoute.myPage.path);
      // TODO: 예약 통계(stats) 화면 구현 후 연결 (#19 범위 밖)
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = MediaQuery.of(context).padding.bottom;
    // 비선택 아이콘/텍스트 색상
    const Color inactiveColor = Color(0xFF999999);
    // 선택된 아이콘/텍스트 색상
    final Color activeColor = context.systemBlue;
    final int selectedIndex = _selectedIndexOf(context);

    return Container(
      height: tabBarHeight + bottomPadding,
      decoration: BoxDecoration(
        color: context.systemBackground,
        border: Border(
          top: BorderSide(color: context.separator, width: 0.5),
        ),
      ),
      child: Row(
        children: List.generate(_tabs.length, (index) {
          final tab = _tabs[index];
          final bool isSelected = index == selectedIndex;
          final Color color = isSelected ? activeColor : inactiveColor;

          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _onTabTapped(context, index),
              child: Padding(
                // 하단 safe area 높이만큼 아이콘/텍스트를 위로 올림
                padding: EdgeInsets.only(bottom: bottomPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isSelected ? tab.activeIcon : tab.icon,
                      size: 24,
                      color: color,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tab.label,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: color,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// 탭 항목 데이터 모델
class _TabItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;

  const _TabItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}
```

- [ ] **Step 3: 라우터에 `/my-page` 등록**

`lib/router/app_router.dart`의 import에 추가한다.

```dart
import 'package:studio_chance/presentation/my_page/screens/my_page_screen.dart';
```

`// 온보딩 섹션` 주석이 붙은 `GoRoute(path: '/onboarding', ...)` **바로 앞에** 아래 라우트를 추가한다.

```dart
      // 마이페이지
      GoRoute(
        path: SCRoute.myPage.path,
        name: SCRoute.myPage.name,
        pageBuilder: (context, state) =>
            _fadePage(state: state, child: const MyPageScreen()),
        routes: [
          // 점포 추가 — 온보딩과 동일한 역할 선택 → 등록/초대 코드 플로우 재사용
          GoRoute(
            path: SCRoute.role.path,
            builder: (context, state) => const RoleSelectionScreen(),
            routes: _roleSubRoutes(),
          ),
          // 닉네임 변경
          GoRoute(
            path: SCRoute.nickname.path,
            builder: (context, state) => const MyPageNicknameScreen(),
          ),
        ],
      ),
```

`MyPageNicknameScreen`은 Task 13에서 만든다. 이 Task에서는 컴파일을 위해 아래 임시 위젯을 `my_page_screen.dart` 하단에 함께 둔다 (Task 13에서 실제 구현으로 교체).

```dart
/// 닉네임 변경 화면 — Task 13에서 `NicknameFormScreen` 재사용 구현으로 교체된다.
class MyPageNicknameScreen extends ConsumerWidget {
  const MyPageNicknameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(body: SizedBox.shrink());
  }
}
```

`my_page_screen.dart`의 import에 위 위젯이 쓰는 것이 없으면 그대로 두고, `app_router.dart`에서 `MyPageNicknameScreen`을 import 하도록 한다 (같은 파일이므로 기존 import로 해결된다).

- [ ] **Step 4: `redirect`가 마이페이지를 막지 않는지 확인**

`app_router.dart`의 `redirect`는 `AppStatus.authenticated`일 때 `isSplash || isLoggingIn || isOnboarding`인 경우에만 홈으로 보낸다. `/my-page`는 셋 중 어느 것도 아니므로 통과한다. **코드 변경 불필요** — 확인만 한다.

- [ ] **Step 5: 빌드 및 정적 분석**

```bash
dart format lib/router/app_router.dart lib/presentation/home/widgets/home_tab_bar.dart lib/presentation/my_page/screens/my_page_screen.dart
dart analyze
flutter test
```

기대: 에러 0건, 전체 테스트 통과

- [ ] **Step 6: 수동 확인 — 탭 전환**

```bash
flutter run --flavor dev --target lib/main_dev.dart
```

홈 화면 하단 탭바에서 "마이페이지" 탭 → 빈 마이페이지 화면으로 이동하고 탭바의 선택 표시가 마이페이지로 바뀐다. "홈" 탭 → 홈으로 되돌아온다. "예약 통계" 탭 → 아무 일도 일어나지 않는다.

- [ ] **Step 7: 커밋**

```bash
git add lib/router/app_router.dart lib/presentation/home/widgets/home_tab_bar.dart lib/presentation/my_page/screens/my_page_screen.dart
git commit -m "feat: #19 - 마이페이지 라우트 등록 및 하단 탭바 라우팅 배선"
```

---

## Task 13: 마이페이지 화면 구현

**Files:**
- Modify: `lib/presentation/my_page/screens/my_page_screen.dart`

**Interfaces:**
- Consumes: `currentUserProvider` (기존), `storeDetailProvider` (기존), `showPendingMemberModal` (Task 11), `NicknameFormScreen` (기존), `SCRoute.role` / `SCRoute.nickname` (기존)
- Produces: 완성된 `MyPageScreen`, `MyPageNicknameScreen`

**설계 노트:**
- 구성: ① 프로필(닉네임·이메일, 탭하면 닉네임 변경) ② 내 점포 목록(색상 도트 + 점포명 + 역할, ADMIN 점포는 대기 인원 배지 → 탭하면 승인 대기 모달) ③ 점포 추가 ④ 로그아웃.
- 행 위젯은 `TitleNavigationButton`(title + contentLeading + content + chevron)을 그대로 쓴다. 색상 도트를 `contentLeading`에 넣으면 점포 필터 모달과 같은 모양이 된다.
- 대기 인원은 `storeDetailProvider(storeId)`를 ADMIN 점포에 대해서만 watch해 `waitingMemberInfos.length`로 구한다. VIEWER/STAFF 점포까지 조회하면 불필요한 Firestore 읽기가 발생하므로 역할로 먼저 거른다.
- 로그아웃은 `showCustomAlertDialog(isDestructive: true)` 확인 후 `AuthUseCase.signOut()`. 위젯이 UseCase를 직접 읽지 않도록 `AppAuthController`가 아닌 별도 경로가 필요한지 확인하고, 기존에 로그아웃을 수행하는 컨트롤러(`RoleSelectionController.skipOnboarding` 등)의 패턴을 따른다. 적절한 컨트롤러가 없으면 `lib/presentation/providers/`에 `SignOutController`를 만든다.

- [ ] **Step 1: 기존 로그아웃 경로 확인**

```bash
grep -rn "signOut" lib/presentation/ --include="*.dart" | grep -v "\.g\.dart"
```

이미 로그아웃을 수행하는 컨트롤러가 있으면 그것을 재사용한다. 없으면 Step 2에서 `SignOutController`를 만든다.

- [ ] **Step 2: 필요 시 `SignOutController` 작성**

Step 1에서 재사용할 컨트롤러를 찾지 못한 경우에만 `lib/presentation/providers/sign_out_controller.dart`를 만든다.

```dart
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/domain/use_cases/auth_use_case_provider.dart';

part 'sign_out_controller.g.dart';

/// 로그아웃 액션을 UseCase에 위임한다.
/// (CLAUDE.md "Presentation → Domain 접근 규칙")
@riverpod
class SignOutController extends _$SignOutController {
  final _logger = Logger();

  @override
  FutureOr<void> build() {}

  Future<void> signOut() async {
    try {
      await ref.read(authUseCaseProvider).signOut();
    } catch (e, stackTrace) {
      _logger.e('로그아웃 실패', error: e);
      state = AsyncError(e, stackTrace);
    }
  }
}
```

- [ ] **Step 3: 마이페이지 화면 구현**

`lib/presentation/my_page/screens/my_page_screen.dart` 전체를 아래로 교체한다.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/domain/entities/user_store_info.dart';
import 'package:studio_chance/common/enums/user_role.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';
import 'package:studio_chance/presentation/commons/extensions/store_color_extensions.dart';
import 'package:studio_chance/presentation/commons/nickname_input/screens/nickname_form_screen.dart';
import 'package:studio_chance/presentation/commons/widgets/app_bar/custom_app_bar.dart';
import 'package:studio_chance/presentation/commons/widgets/custom_alert_dialog.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/grouped_form_container.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/title_navigation_button.dart';
import 'package:studio_chance/presentation/commons/widgets/safe_area_with_padding.dart';
import 'package:studio_chance/presentation/home/controllers/store_detail_provider.dart';
import 'package:studio_chance/presentation/home/widgets/home_tab_bar.dart';
import 'package:studio_chance/presentation/my_page/widgets/pending_member_modal.dart';
import 'package:studio_chance/presentation/providers/app_auth_controller.dart';
import 'package:studio_chance/presentation/providers/sign_out_controller.dart';
import 'package:studio_chance/router/router_path.dart';

class MyPageScreen extends ConsumerWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).asData?.value;

    return Scaffold(
      backgroundColor: context.systemGroupedBackground,
      appBar: const CustomAppBar(title: '마이페이지'),
      bottomNavigationBar: const HomeTabBar(),
      body: SingleChildScrollView(
        child: SafeAreaWithPadding(
          top: false,
          bottom: false,
          padding: const EdgeInsetsDirectional.fromSTEB(
            horizontalPadding,
            16,
            horizontalPadding,
            16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 24,
            children: [
              // 프로필
              GroupedFormContainer(
                children: [
                  TitleNavigationButton(
                    title: '닉네임',
                    content: user?.nickname ?? '',
                    isChangeable: true,
                    onPressed: () => SCRoute.nickname.pushChild(context),
                  ),
                  TitleNavigationButton(
                    title: '이메일',
                    content: user?.email ?? '',
                    onPressed: () {},
                  ),
                ],
              ),

              // 내 점포
              GroupedFormContainer(
                header: _SectionHeader(title: '내 점포'),
                children: [
                  for (final info in user?.storeInfos ?? <UserStoreInfo>[])
                    _StoreRow(info: info),
                  TitleNavigationButton(
                    title: '점포 추가',
                    isChangeable: true,
                    onPressed: () => SCRoute.role.pushChild(context),
                  ),
                ],
              ),

              // 로그아웃
              GroupedFormContainer(
                children: [
                  TitleNavigationButton(
                    title: '로그아웃',
                    onPressed: () => showCustomAlertDialog(
                      context: context,
                      title: '로그아웃할까요?',
                      confirmText: '로그아웃',
                      isDestructive: true,
                      onConfirmAfterPop: () {
                        ref.read(signOutControllerProvider.notifier).signOut();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 그룹 상단 라벨
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(horizontalPadding, 0, 0, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: context.secondaryLabel,
        ),
      ),
    );
  }
}

/// 점포 한 줄. ADMIN 점포는 대기 인원을 함께 표시하고 탭하면 승인 대기 모달을 연다.
class _StoreRow extends ConsumerWidget {
  const _StoreRow({required this.info});

  final UserStoreInfo info;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = info.role == UserRole.admin;

    // 관리자인 점포만 대기 인원을 조회한다 (불필요한 Firestore 읽기 방지)
    final waitingCount = isAdmin
        ? ref
                  .watch(storeDetailProvider(info.id))
                  .asData
                  ?.value
                  ?.waitingMemberInfos
                  .length ??
              0
        : 0;

    final content = waitingCount > 0
        ? '${info.role.displayName} · 신청 $waitingCount'
        : info.role.displayName;

    return TitleNavigationButton(
      title: info.name,
      content: content,
      isChangeable: isAdmin,
      contentLeading: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color(info.color.foregroundColorValue),
        ),
      ),
      onPressed: isAdmin
          ? () => showPendingMemberModal(context, info.id)
          : () {},
    );
  }
}

/// 마이페이지 닉네임 변경 화면 — 온보딩과 동일한 폼을 재사용한다.
class MyPageNicknameScreen extends ConsumerWidget {
  const MyPageNicknameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).asData?.value;

    return NicknameFormScreen(
      initialNickname: user?.nickname,
      title: '닉네임 변경',
      onComplete: (nickname) async {
        if (context.mounted) context.pop();
      },
    );
  }
}
```

- [ ] **Step 4: 닉네임 저장 경로 확인 및 연결**

`NicknameFormScreen`의 `onComplete`는 닉네임 문자열만 넘겨준다. 실제 저장은 `NicknameFormController` 또는 `UserUseCase.updateUser`가 담당하므로, 온보딩(`OnboardingNicknameScreen`)이 어떻게 저장하는지 확인해 같은 방식으로 연결한다.

```bash
cat lib/presentation/onboarding/screens/onboarding_nickname_screen.dart
```

확인한 저장 호출을 Step 3의 `onComplete` 안, `context.pop()` **앞에** 넣는다. 저장 후 `ref.invalidate(currentUserProvider)`로 마이페이지 표시를 갱신한다.

- [ ] **Step 5: 코드 생성**

```bash
dart run build_runner build --delete-conflicting-outputs
```

기대: `sign_out_controller.g.dart` 생성 (Step 2를 수행한 경우)

- [ ] **Step 6: 정적 분석 및 전체 테스트**

```bash
dart format lib/presentation/my_page/screens/my_page_screen.dart lib/presentation/providers/sign_out_controller.dart
dart analyze
flutter test
```

기대: 에러 0건, 전체 테스트 통과. `_SectionHeader`가 `const` 생성자를 요구한다는 lint가 나면 `const _SectionHeader(title: '내 점포')`로 바꾼다.

- [ ] **Step 7: 수동 확인**

```bash
flutter run --flavor dev --target lib/main_dev.dart
```

1. 마이페이지 탭 → 닉네임·이메일·내 점포·로그아웃이 보인다
2. 관리자 점포 행을 탭 → 승인 대기 모달이 열린다 (대기자가 없으면 안내 문구)
3. 다른 계정으로 가입 신청 후 다시 열면 신청자가 보이고, 승인/거절이 동작하며 목록이 갱신된다
4. 닉네임 행 → 닉네임 변경 화면, 저장 후 마이페이지 표시가 갱신된다
5. 점포 추가 → 역할 선택 화면으로 이동한다
6. 로그아웃 → 확인 후 로그인 화면으로 이동한다

- [ ] **Step 8: 커밋**

```bash
git add lib/presentation/my_page/screens/my_page_screen.dart lib/presentation/providers/sign_out_controller.dart lib/presentation/providers/sign_out_controller.g.dart
git commit -m "feat: #19 - 마이페이지 화면 구현 (프로필·내 점포·승인 대기 진입·로그아웃)"
```

---

## Task 14: 딥링크 착지점을 승인 대기 모달로 교체

**Files:**
- Modify: `lib/presentation/providers/notification_controller.dart`

**Interfaces:**
- Consumes: `showPendingMemberModal` (Task 11), `/my-page` 라우트 (Task 12)
- Produces: 알림 탭 → 마이페이지 이동 + 승인 대기 모달 자동 오픈

**설계 노트:** Task 9에서는 홈으로 보내고 점포 필터만 켰다. 이제 착지점이 생겼으므로 마이페이지로 이동한 뒤 해당 점포의 승인 대기 모달을 연다. 모달을 열려면 `BuildContext`가 필요한데 컨트롤러에는 없으므로, `GoRouter.routerDelegate.navigatorKey.currentContext`를 라우팅 완료 후 사용한다. 프레임이 끝난 뒤에 열어야 이동 중 `Navigator` 조작 충돌이 없으므로 `WidgetsBinding.instance.addPostFrameCallback`으로 감싼다.

- [ ] **Step 1: import 교체**

`lib/presentation/providers/notification_controller.dart`의 import에서 아래 두 줄을 제거한다.

```dart
import 'package:studio_chance/presentation/providers/home_store_filter_controller.dart';
```

아래 두 줄을 추가한다.

```dart
import 'package:flutter/widgets.dart';
import 'package:studio_chance/presentation/my_page/widgets/pending_member_modal.dart';
```

- [ ] **Step 2: `_handleMessage` 교체**

`_handleMessage` 메서드를 아래로 교체한다.

```dart
  void _handleMessage(PushMessage message) {
    final storeId = joinRequestStoreIdOf(message);
    if (storeId == null) return;

    final status = ref.read(appAuthControllerProvider).valueOrNull;
    if (status != AppStatus.authenticated) {
      // 스플래시·온보딩 중이면 이동할 수 없으므로 보류한다.
      _pendingMessage = message;
      return;
    }

    final router = ref.read(goRouterProvider);
    router.go(SCRoute.myPage.path);

    // 라우팅이 반영된 다음 프레임에 모달을 연다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = router.routerDelegate.navigatorKey.currentContext;
      if (context == null || !context.mounted) return;
      showPendingMemberModal(context, storeId);
    });
  }
```

- [ ] **Step 3: 정적 분석**

```bash
dart format lib/presentation/providers/notification_controller.dart
dart analyze
```

기대: 에러 0건. `home_store_filter_controller.dart` import를 지운 뒤 `ensureSelected` 참조가 남아 있다는 에러가 나면 Step 2의 교체가 누락된 것이다.

`ensureSelected`는 이제 호출부가 없어지지만, 향후 다른 알림에서 재사용할 수 있으므로 **삭제하지 않는다.** `dart analyze`가 미사용을 지적하지 않는 public 메서드이므로 그대로 둔다. Task 9의 테스트도 유지된다.

- [ ] **Step 4: 전체 테스트**

```bash
flutter test
```

기대: 전체 통과 (`notification_routing_test.dart`의 `joinRequestStoreIdOf` 테스트는 변경 없음)

- [ ] **Step 5: 커밋**

```bash
git add lib/presentation/providers/notification_controller.dart
git commit -m "feat: #19 - 알림 딥링크 착지점을 승인 대기 모달로 연결"
```

---

## Task 15: 실기기 검증 및 마무리

**Files:**
- Modify: `lib/data/repositories/store_repository_impl.dart` (231행 부근 TODO)
- Modify: `CLAUDE.md`

**Interfaces:**
- Consumes: Task 1~14의 전체 결과
- Produces: 없음

- [ ] **Step 1: 실기기 검증 — 백그라운드 알림**

기기 2대(또는 계정 2개)가 필요하다.

1. 관리자 계정으로 dev 앱을 실행하고 알림 권한을 허용한다.
   ```bash
   flutter run --flavor dev --target lib/main_dev.dart
   ```
2. Firestore 콘솔에서 해당 관리자의 `users/{uid}.fcmTokens`에 토큰이 들어갔는지 확인한다.
3. 관리자 앱을 **백그라운드로 보낸다** (홈 버튼).
4. 다른 계정으로 초대 코드를 입력해 그 점포에 가입 신청한다.
5. 관리자 기기에 알림이 뜨는지 확인한다.

기대: `가입 신청 / [닉네임]님이 [점포명] 가입을 신청했습니다.` 알림이 표시된다.

실패 시:
```bash
firebase functions:log --only notifyAdminsOnJoinRequest -P dev
```
- `관리자 FCM 토큰이 없어...` → 2단계의 토큰 저장 실패. `registerFcmToken` 로그 확인
- `failureCount`가 1 이상 → 로그의 에러 코드 확인. iOS면 APNs 키 등록 여부 재확인

- [ ] **Step 2: 실기기 검증 — 포그라운드 알림**

관리자 앱을 **포그라운드에 둔 채** 다시 가입 신청을 발생시킨다.

기대: 로컬 알림 배너가 표시된다.

- [ ] **Step 3: 실기기 검증 — 딥링크**

1. 관리자 앱을 완전히 종료한다.
2. 가입 신청을 발생시킨다.
3. 도착한 알림을 탭한다.

기대: 앱이 실행되고 로그인/스플래시를 거쳐 마이페이지에 도착하며, 해당 점포의 승인 대기 모달이 자동으로 열리고 신청자가 목록에 보인다. 그 자리에서 승인·거절이 동작한다.

백그라운드 상태에서 탭하는 경우도 동일하게 확인한다.

- [ ] **Step 4: 폐기 토큰 정리 확인**

관리자 기기 중 하나에서 앱을 삭제한 뒤 다시 가입 신청을 발생시키고 로그를 확인한다.

```bash
firebase functions:log --only notifyAdminsOnJoinRequest -P dev
```

기대: `폐기된 FCM 토큰 정리` 로그가 남고, Firestore의 `users/{uid}.fcmTokens`에서 해당 토큰이 사라진다.

- [ ] **Step 5: TODO 주석 교체**

`lib/data/repositories/store_repository_impl.dart`의 `requestJoinStore` 안, 아래 줄을 찾는다.

```dart
      // TODO: FCM 알림
```

아래로 교체한다.

```dart
      // 관리자 FCM 알림은 Cloud Functions `notifyAdminsOnJoinRequest`가
      // stores/{storeId}.waitingMemberById 변경을 감지해 발송한다 (functions/src/index.ts).
```

- [ ] **Step 6: CLAUDE.md에 아키텍처 기록 추가**

`CLAUDE.md`의 `## 모달 시트 패턴` 섹션 **바로 앞**에 아래를 추가한다.

````markdown
## FCM 푸시 알림

- **발송**: Cloud Functions v2 (`functions/`, TypeScript, Node 22, 리전 `asia-northeast3`)
  - `notifyAdminsOnJoinRequest`: `stores/{storeId}` 문서의 `waitingMemberById`에 키가 추가되면 해당 점포 ADMIN 전원에게 발송
  - 발송 실패 응답에서 폐기된 토큰을 감지해 `users/{uid}.fcmTokens`에서 자동 제거 — 클라이언트는 토큰 추가만 하면 된다
  - 배포: `firebase deploy --only functions -P dev` / `-P prod` (Blaze 요금제 필요)
  - 테스트: `cd functions && npm test` (Node 내장 `node:test`)
- **수신**: `NotificationController`(`lib/presentation/providers/`)가 `MyApp`에서 watch되어 권한 요청·토큰 등록·스트림 구독·딥링크를 담당
  - 포그라운드는 FCM SDK가 알림을 표시하지 않으므로 `flutter_local_notifications`로 직접 표시
  - iOS `setForegroundNotificationPresentationOptions`는 켜지 않는다 — 켜면 시스템 배너와 로컬 알림이 중복된다
- **값이 반드시 일치해야 하는 상수**
  - 채널 ID `sc_default`: `AndroidManifest.xml`의 `default_notification_channel_id`, Functions의 `ANDROID_CHANNEL_ID`, `lib/constants/notification_constants.dart`의 `notificationChannelId`
  - `data.type` `joinRequest`: Functions의 `JOIN_REQUEST_TYPE`, `joinRequestNotificationType`
- **알려진 제약**: FCM Admin SDK가 registration token을 deprecated 처리하고 FID를 권장한다. 현행은 token 기반이며 FID 마이그레이션은 별도 이슈.

## 마이페이지 / 하단 탭바

- `HomeTabBar`(`lib/presentation/home/widgets/`)는 홈·마이페이지가 **공유**한다. 선택 인덱스는 로컬 state가 아니라 `GoRouterState.of(context).uri.path`에서 파생하므로 두 화면의 표시가 어긋나지 않는다.
- 예약 통계(`stats`) 탭은 화면이 없어 탭해도 아무 동작도 하지 않는다 (`_onTabTapped`의 TODO).
- `/my-page` 하위는 온보딩과 동일한 `_roleSubRoutes()`를 재사용한다 — 점포 추가 플로우를 중복 구현하지 않는다.
- 승인 대기 멤버 관리는 `showPendingMemberModal(context, storeId)` 모달이며, 마이페이지의 ADMIN 점포 행과 FCM 알림 딥링크 두 곳에서 같은 모달을 연다.
- 승인 시 역할은 **신청자가 초대 코드 단계에서 고른 값을 그대로** 쓴다. 관리자가 역할을 바꾸려면 승인 후 `updateMemberRole`을 쓴다 (해당 UI는 미구현).
````

- [ ] **Step 7: 최종 검증**

```bash
dart format lib/data/repositories/store_repository_impl.dart
dart analyze
flutter test
cd functions && npm test && cd ..
```

기대: 모두 통과

- [ ] **Step 8: 커밋**

```bash
git add lib/data/repositories/store_repository_impl.dart CLAUDE.md
git commit -m "docs: #19 - FCM 알림 아키텍처 문서화 및 TODO 주석 정리"
```

- [ ] **Step 9: FID 마이그레이션 후속 이슈 생성**

```bash
gh issue create --repo SNMac/StudioChance \
  --title "FCM 발송 대상을 registration token에서 FID로 마이그레이션" \
  --label enhancement \
  --body "$(cat <<'EOF'
## 📄 이슈 내용

> FCM Admin SDK가 registration token(`token`/`tokens` 필드)을 deprecated 처리하고 Firebase Installation ID(FID) 사용을 권장한다. 현행 구현(#19)은 token 기반이므로 제거 전에 마이그레이션이 필요하다.

<br>

## 📝 상세 내용

- 현재: `users/{uid}.fcmTokens`에 `FirebaseMessaging.getToken()` 결과를 저장하고, Cloud Functions가 `Message.token`으로 발송
- 목표: `firebase_app_installations`로 FID를 획득해 저장하고, Functions에서 `Message.fid`로 발송
- 관련 파일: `lib/data/repositories/notification_repository_impl.dart`, `functions/src/notifications/join_request_payload.ts`

<br>

## ✅ 체크리스트

- [ ] `firebase_app_installations` 패키지 도입 및 FID 획득
- [ ] `users/{uid}` 스키마에 FID 필드 추가
- [ ] Cloud Functions 발송 대상을 `fid`로 전환
- [ ] 폐기 FID 정리 로직 에러 코드 재확인
- [ ] 기존 `fcmTokens` 필드 제거
EOF
)"
```

- [ ] **Step 10: PR 생성**

```bash
git push -u origin feat/#19-fcm-join-request-notification
gh pr create --repo SNMac/StudioChance --base develop \
  --title "Feature/#19 점포 가입 신청 시 관리자 FCM 알림 발송" \
  --body "$(cat <<'EOF'
## #️⃣ 연관된 이슈
- #19

<br>

## 📝 작업 내용
- Cloud Functions v2 프로젝트(`functions/`) 신규 추가 — TypeScript, Node 22, 리전 `asia-northeast3`
- `notifyAdminsOnJoinRequest` 트리거: `stores/{storeId}.waitingMemberById`에 신규 신청자가 추가되면 해당 점포 ADMIN 전원에게 FCM 발송
- 발송 실패 응답에서 폐기된 토큰을 감지해 `users/{uid}.fcmTokens`에서 자동 제거
- 알림 권한 요청 / FCM 토큰 등록 / 토큰 갱신 반영 — 기존에 호출부가 없어 동작하지 않던 부분을 `NotificationController`로 배선
- 포그라운드 수신 시 `flutter_local_notifications`로 알림 표시 (FCM SDK는 포그라운드에서 표시하지 않음)
- 알림 탭 시 마이페이지 이동 + 해당 점포의 승인 대기 모달 자동 오픈
- 승인 대기 멤버 모달 신설 — 신청자 목록·승인·거절 (승인 역할은 신청 시 선택한 값 사용)
- 멤버 제거(거절) `StoreRepository`·`StoreUseCase` 배선 추가 (DataSource는 기존 `removeMember` 재사용)
- 마이페이지 신설 — 프로필·닉네임 변경·내 점포 목록(대기 인원 표시)·점포 추가·로그아웃
- `HomeTabBar`의 마이페이지 탭에 실제 라우팅 연결 (기존에는 로컬 state만 변경)
- Android core library desugaring, `POST_NOTIFICATIONS` 권한, 기본 알림 채널(`sc_default`) 설정 추가

<br>

## 📸 스크린샷
|    구현 내용    |   스크린샷   |
| :-------------: | :----------: |
| 백그라운드 알림 수신 | <img src = "" width ="250"> |
| 포그라운드 알림 수신 | <img src = "" width ="250"> |
| 알림 탭 → 승인 대기 모달 | <img src = "" width ="250"> |
| 마이페이지 | <img src = "" width ="250"> |
| 승인 대기 멤버 승인·거절 | <img src = "" width ="250"> |

<br>
EOF
)"
```

스크린샷은 Step 1~3에서 촬영한 이미지를 PR 편집 화면에서 업로드해 `src`에 채운다.

---

## 실행 순서 요약

| Task | 산출물 | 선행 |
|---|---|---|
| 0 | 사전 확인 (Blaze, APNs, 리전) | — |
| 1 | Functions 스캐폴딩 + 신규 신청자 추출 | 0 |
| 2 | 폐기 토큰 추출 | 1 |
| 3 | 관리자 추출 + 페이로드 생성 | 1 |
| 4 | 트리거 배선 및 배포 | 1, 2, 3 |
| 5 | Flutter 플랫폼 설정 + 상수 | 0 |
| 6 | PushMessage 엔티티/매퍼 | 5 |
| 7 | DataSource 확장 | 5, 6 |
| 8 | Repository / UseCase | 7 |
| 9 | Controller + 딥링크(홈 착지) | 8 |
| 10 | `removeMember` 도메인 배선 | — |
| 11 | 승인 대기 멤버 모달 | 10 |
| 12 | 마이페이지 라우트 + 탭바 배선 | — |
| 13 | 마이페이지 화면 | 11, 12 |
| 14 | 딥링크 → 승인 대기 모달 | 9, 11, 12 |
| 15 | 실기기 검증 + 마무리 | 4, 14 |

- Task 1~4(Cloud Functions)와 Task 5~9(Flutter 알림 수신)는 서로 독립적이므로 병렬 진행 가능하다.
- Task 10과 Task 12는 선행 의존이 없어 언제든 시작할 수 있다.
- Task 15는 양쪽 계통이 모두 끝나야 한다.
