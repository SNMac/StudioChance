# stores read 권한 강화 및 Rules 테스트 하네스 구현 플랜

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 로그인한 아무 사용자나 모든 점포 문서(계좌 정보 포함)를 읽을 수 있는 `stores` read 규칙을 멤버 전용으로 조이고, 그 전제가 되는 초대 코드 조회를 Callable Cloud Function으로 옮긴다. 함께 `fcmTokens`를 본인 전용 서브컬렉션으로 격리하고 Rules 자동 테스트를 도입한다.

**Architecture:** 비멤버가 넘어야 하는 유일한 경계인 "초대 코드로 점포 1건 조회"만 Callable Function으로 이전한다. 함수는 계좌·멤버·초대 코드를 제외한 표시용 최소 정보만 반환하고, 만료 판정과 브루트포스 제한을 서버에서 수행한다. 그 뒤 Rules에서 `stores read`를 `isMember()`로 조인다.

**Tech Stack:** Firestore Security Rules, Cloud Functions v2 (TypeScript, Node 22, `asia-northeast3`), `@firebase/rules-unit-testing` 5.x + `node:test`, Flutter (freezed, Riverpod, fpdart), `cloud_functions` 패키지

**Spec:** `docs/superpowers/specs/2026-08-29-stores-read-hardening-design.md`

## Global Constraints

- 이슈 번호: `#13`(stores read), `#39`(Rules 테스트 + fcmTokens). 커밋 메시지는 `<type>: #<번호> - <한국어 설명>` 형식
- 브랜치: `feat/#13-stores-read-rules` (이미 생성됨, 기준 브랜치 `develop`)
- Cloud Functions 리전은 반드시 `asia-northeast3` (Firestore 리전과 일치)
- 코드 생성이 필요한 변경 뒤에는 `dart run build_runner build --delete-conflicting-outputs`
- `dart format`은 **수정한 파일만** 지정해 실행 (디렉터리 전체 금지)
- 콘솔 출력은 `logger` 라이브러리 사용, 주석·커밋 메시지는 한국어
- Either 패턴은 `result.fold(...)` 함수형만 사용 (`isLeft()`/`getLeft()` 금지)
- 정식 출시 전이므로 기존 Firestore 데이터 마이그레이션은 고려하지 않는다
- 에뮬레이터 테스트 프로젝트 ID는 `demo-studio-chance` (demo- 프리픽스라 자격증명 불필요)
- 검증된 라이브러리 버전: `@firebase/rules-unit-testing@^5.0.2`, `firebase@^12.18.0` (CommonJS 로드 확인 완료)

---

## File Structure

**신규 생성**

| 경로 | 책임 |
|---|---|
| `firebase.emulator.json` | 테스트 전용 최소 에뮬레이터 설정 (추적됨. 배포용 `firebase.json`은 계속 gitignore) |
| `functions/src/rules/helpers.ts` | Rules 테스트 공통 환경 생성 |
| `functions/src/rules/stores.test.ts` | `stores` 문서 규칙 검증 |
| `functions/src/rules/reservations.test.ts` | `reservations` 서브컬렉션 규칙 검증 |
| `functions/src/rules/users.test.ts` | `users` 및 `users/{uid}/private` 규칙 검증 |
| `functions/src/rules/system.test.ts` | `system/serverTime`, `inviteLookupAttempts` 규칙 검증 |
| `functions/src/invite/invite_code.ts` | 코드 형식 검증·만료 판정 순수 함수 |
| `functions/src/invite/invite_code.test.ts` | 위 순수 함수 테스트 |
| `functions/src/invite/rate_limit.ts` | 시도 한도 창 계산 순수 함수 |
| `functions/src/invite/rate_limit.test.ts` | 위 순수 함수 테스트 |
| `functions/src/invite/lookup_invite_code.ts` | Callable 함수 본체 (Firestore I/O) |
| `lib/domain/entities/invite_store_preview.dart` | 가입 전 점포 표시 정보 엔티티 |
| `lib/data/models/invite_store_preview_model.dart` | 위 엔티티의 Data 모델 |
| `test/data/models/invite_store_preview_model_test.dart` | 모델 파싱 테스트 |

**수정**

| 경로 | 변경 요지 |
|---|---|
| `firestore.rules` | `users/{uid}/private/*` 추가, `stores read`를 `isMember()`로 |
| `functions/package.json` | devDeps 추가, `test:unit`/`test:rules` 스크립트 분리 |
| `functions/.gitignore` | `firestore-debug.log` |
| `functions/src/index.ts` | FCM 토큰 조회·정리 경로를 서브문서로, Callable export 추가 |
| `lib/data/models/user_model.dart` | `fcmTokens` 필드 삭제 |
| `lib/data/data_sources/user_data_source.dart` | 토큰 6개 메서드를 서브문서 대상으로 |
| `lib/data/repositories/user_repository_impl.dart` | `createUser(model, fcmToken:)` |
| `lib/data/data_sources/store_data_source.dart` | `getStoreByInviteCode` → `lookupInviteCode` |
| `lib/data/repositories/store_repository_impl.dart` | 반환 타입 교체, 만료 검증 삭제 |
| `lib/domain/repository_interfaces/store_repository.dart` | 시그니처 |
| `lib/domain/use_cases/store_use_case.dart` | 시그니처 |
| `lib/presentation/commons/invite_code/controllers/states/invite_code_verification_state.dart` | 상태 타입 |
| `lib/presentation/commons/invite_code/controllers/invite_code_verification_controller.dart` | 필드명 |
| `lib/presentation/commons/invite_code/screens/invite_code_verified_screen.dart` | `adminName` 직접 사용 |
| `lib/presentation/commons/extensions/address_formatter.dart` | extension 추가 |
| `pubspec.yaml` | `cloud_functions` |
| `.github/workflows/ci.yml` | functions 테스트 job |

---

### Task 1: Rules 테스트 하네스 구축

에뮬레이터 기반 Rules 테스트를 돌릴 수 있게 만들고, **지금의 취약한 동작을 테스트로 고정**한다. Task 9에서 이 테스트를 뒤집는 것이 이번 작업의 최종 증거가 된다.

**Files:**
- Create: `firebase.emulator.json`
- Create: `functions/src/rules/helpers.ts`
- Create: `functions/src/rules/stores.test.ts`
- Modify: `functions/package.json`
- Modify: `functions/.gitignore`

**Interfaces:**
- Consumes: 없음 (첫 작업)
- Produces: `createTestEnv(suffix: string): Promise<RulesTestEnvironment>`, `projectIdFor(suffix): string` — 이후 모든 Rules 테스트 파일이 `./helpers.js`에서 import한다

- [x] **Step 1: 에뮬레이터 설정 파일 생성**

배포용 `firebase.json`은 gitignore 상태를 유지하고, 테스트에 필요한 최소 설정만 새 파일로 추적한다.

`firebase.emulator.json` (저장소 루트):

```json
{
  "firestore": { "rules": "firestore.rules" },
  "emulators": {
    "firestore": { "port": 8080 },
    "ui": { "enabled": false }
  }
}
```

- [x] **Step 2: devDependency 설치**

```bash
cd functions && npm i -D @firebase/rules-unit-testing@^5.0.2 firebase@^12.18.0 firebase-tools@^15.19.1
```

`firebase-tools`를 devDependency로 두는 이유는 CI에서 `npm ci` 한 번으로 CLI까지 확보하기 위해서다. npm 스크립트는 `node_modules/.bin`을 PATH에 올리므로 스크립트 안에서 `firebase`를 그대로 쓸 수 있다.

- [x] **Step 3: 테스트 스크립트 분리**

`functions/package.json`의 `scripts`를 아래로 교체한다. 에뮬레이터가 필요한 테스트와 필요 없는 순수 단위 테스트를 반드시 나눠야 CI가 깨지지 않는다.

```json
  "scripts": {
    "build": "rm -rf lib && tsc",
    "test:unit": "npm run build && node --test \"lib/notifications/**/*.test.js\" \"lib/invite/**/*.test.js\"",
    "test:rules": "npm run build && firebase emulators:exec --config ../firebase.emulator.json --only firestore --project demo-studio-chance \"node --test lib/rules/**/*.test.js\"",
    "test": "npm run test:unit && npm run test:rules",
    "serve": "npm run build && firebase emulators:start --only functions",
    "logs": "firebase functions:log"
  },
```

`lib/invite/**/*.test.js`는 Task 5에서 생기며, 매칭되는 파일이 없어도 `node --test`는 실패하지 않는다.

- [x] **Step 4: 에뮬레이터 로그 gitignore**

`functions/.gitignore`에 한 줄 추가한다. 에뮬레이터가 cwd에 로그를 남긴다.

```
node_modules/
lib/
*.local
firestore-debug.log
```

- [x] **Step 5: 테스트 공통 헬퍼 작성**

`functions/src/rules/helpers.ts`:

```ts
import { readFileSync } from 'node:fs';
import { join } from 'node:path';

import {
  initializeTestEnvironment,
  type RulesTestEnvironment,
} from '@firebase/rules-unit-testing';

/**
 * 테스트 파일마다 고유한 프로젝트 ID를 쓴다.
 *
 * node --test는 파일을 별도 프로세스에서 병렬 실행하는데, 같은 프로젝트를 공유하면
 * 한 파일의 clearFirestore()가 다른 파일의 시드를 지워 결과가 매번 달라진다.
 * demo- 프리픽스는 유지되므로 자격증명은 여전히 필요 없다.
 */
export function projectIdFor(suffix: string): string {
  return `demo-studio-chance-${suffix}`;
}

/**
 * 컴파일 결과는 `functions/lib/rules/helpers.js`에 놓이므로
 * 저장소 루트의 firestore.rules까지 세 단계 올라간다.
 */
const RULES_PATH = join(__dirname, '../../../firestore.rules');

export async function createTestEnv(suffix: string): Promise<RulesTestEnvironment> {
  return initializeTestEnvironment({
    projectId: projectIdFor(suffix),
    firestore: { rules: readFileSync(RULES_PATH, 'utf8') },
  });
}
```

- [x] **Step 6: 현행 stores read 동작을 고정하는 테스트 작성**

`functions/src/rules/stores.test.ts`:

```ts
import { after, before, beforeEach, test } from 'node:test';

import {
  assertFails,
  assertSucceeds,
  type RulesTestEnvironment,
} from '@firebase/rules-unit-testing';
import { doc, getDoc, setDoc } from 'firebase/firestore';

import { createTestEnv } from './helpers.js';

let env: RulesTestEnvironment;

before(async () => {
  env = await createTestEnv('stores');
});

after(async () => {
  await env.cleanup();
});

beforeEach(async () => {
  await env.clearFirestore();
  await env.withSecurityRulesDisabled(async (ctx) => {
    await setDoc(doc(ctx.firestore(), 'stores/s1'), {
      name: '테스트 점포',
      bankAccountNumber: '110-123-456789',
      memberById: {
        admin1: { role: 'ADMIN' },
        staff1: { role: 'STAFF' },
        viewer1: { role: 'VIEWER' },
      },
      waitingMemberById: {},
    });
  });
});

test('멤버는 점포 문서를 읽을 수 있다', async () => {
  const db = env.authenticatedContext('staff1').firestore();
  await assertSucceeds(getDoc(doc(db, 'stores/s1')));
});

test('비로그인은 점포 문서를 읽지 못한다', async () => {
  const db = env.unauthenticatedContext().firestore();
  await assertFails(getDoc(doc(db, 'stores/s1')));
});

// TODO(#13): Task 9에서 assertFails로 뒤집는다. 지금은 취약한 현 상태를 고정한다.
test('현행: 비멤버도 점포 문서를 읽을 수 있다 (이슈 #13의 취약점)', async () => {
  const db = env.authenticatedContext('outsider').firestore();
  await assertSucceeds(getDoc(doc(db, 'stores/s1')));
});
```

- [x] **Step 7: 테스트 실행하여 3건 통과 확인**

```bash
cd functions && npm run test:rules
```

기대: `pass 3 / fail 0`. 실패한다면 Java 설치 여부(`java -version`)와 8080 포트 점유를 확인한다.

- [x] **Step 8: 커밋**

```bash
git add firebase.emulator.json functions/package.json functions/package-lock.json functions/.gitignore functions/src/rules/
git commit -m "test: #39 - Firestore Rules 테스트 하네스 도입 및 현행 stores read 동작 고정"
```

---

### Task 2: 기존 Rules 회귀 커버리지

Task 9에서 `stores` 블록을 건드릴 때 다른 규칙을 망가뜨리지 않았음을 보장할 안전망을 먼저 깐다.

**Files:**
- Create: `functions/src/rules/reservations.test.ts`
- Create: `functions/src/rules/system.test.ts`
- Modify: `functions/src/rules/stores.test.ts`

**Interfaces:**
- Consumes: `createTestEnv(suffix)` from `./helpers.js` (Task 1)
- Produces: 없음 (테스트 전용)

- [x] **Step 1: stores 쓰기 규칙 테스트 추가**

`functions/src/rules/stores.test.ts` 끝에 아래를 덧붙인다. `updateDoc`, `deleteDoc`를 import에 추가해야 한다.

```ts
test('ADMIN은 점포를 수정할 수 있다', async () => {
  const db = env.authenticatedContext('admin1').firestore();
  await assertSucceeds(updateDoc(doc(db, 'stores/s1'), { name: '새 이름' }));
});

test('STAFF는 점포를 수정하지 못한다', async () => {
  const db = env.authenticatedContext('staff1').firestore();
  await assertFails(updateDoc(doc(db, 'stores/s1'), { name: '새 이름' }));
});

test('ADMIN이 아니면 점포를 삭제하지 못한다', async () => {
  const db = env.authenticatedContext('staff1').firestore();
  await assertFails(deleteDoc(doc(db, 'stores/s1')));
});

test('비멤버는 waitingMemberById에 자기 항목을 추가할 수 있다 (가입 신청)', async () => {
  const db = env.authenticatedContext('applicant1').firestore();
  await assertSucceeds(
    updateDoc(doc(db, 'stores/s1'), {
      'waitingMemberById.applicant1': { role: 'STAFF' },
      updatedAt: new Date(),
    }),
  );
});

test('가입 신청자가 남의 항목을 추가하면 거부된다', async () => {
  const db = env.authenticatedContext('applicant1').firestore();
  await assertFails(
    updateDoc(doc(db, 'stores/s1'), {
      'waitingMemberById.someoneElse': { role: 'ADMIN' },
      updatedAt: new Date(),
    }),
  );
});

test('가입 신청과 함께 다른 필드를 바꾸면 거부된다', async () => {
  const db = env.authenticatedContext('applicant1').firestore();
  await assertFails(
    updateDoc(doc(db, 'stores/s1'), {
      'waitingMemberById.applicant1': { role: 'STAFF' },
      bankAccountNumber: '탈취',
      updatedAt: new Date(),
    }),
  );
});
```

- [x] **Step 2: reservations 규칙 테스트 작성**

`functions/src/rules/reservations.test.ts`:

```ts
import { after, before, beforeEach, test } from 'node:test';

import {
  assertFails,
  assertSucceeds,
  type RulesTestEnvironment,
} from '@firebase/rules-unit-testing';
import { doc, getDoc, setDoc } from 'firebase/firestore';

import { createTestEnv } from './helpers.js';

let env: RulesTestEnvironment;

before(async () => {
  env = await createTestEnv('reservations');
});

after(async () => {
  await env.cleanup();
});

beforeEach(async () => {
  await env.clearFirestore();
  await env.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();
    await setDoc(doc(db, 'stores/s1'), {
      name: '테스트 점포',
      memberById: {
        admin1: { role: 'ADMIN' },
        staff1: { role: 'STAFF' },
        viewer1: { role: 'VIEWER' },
      },
    });
    await setDoc(doc(db, 'stores/s1/reservations/r1'), { name: '홍길동' });
  });
});

test('VIEWER는 예약을 읽을 수 있다', async () => {
  const db = env.authenticatedContext('viewer1').firestore();
  await assertSucceeds(getDoc(doc(db, 'stores/s1/reservations/r1')));
});

test('비멤버는 예약을 읽지 못한다', async () => {
  const db = env.authenticatedContext('outsider').firestore();
  await assertFails(getDoc(doc(db, 'stores/s1/reservations/r1')));
});

test('STAFF는 예약을 쓸 수 있다', async () => {
  const db = env.authenticatedContext('staff1').firestore();
  await assertSucceeds(
    setDoc(doc(db, 'stores/s1/reservations/r2'), { name: '김철수' }),
  );
});

test('VIEWER는 예약을 쓰지 못한다', async () => {
  const db = env.authenticatedContext('viewer1').firestore();
  await assertFails(
    setDoc(doc(db, 'stores/s1/reservations/r3'), { name: '김철수' }),
  );
});
```

- [x] **Step 3: system/serverTime 및 미정의 컬렉션 테스트 작성**

`functions/src/rules/system.test.ts`:

```ts
import { after, before, beforeEach, test } from 'node:test';

import {
  assertFails,
  assertSucceeds,
  type RulesTestEnvironment,
} from '@firebase/rules-unit-testing';
import { doc, getDoc, serverTimestamp, setDoc } from 'firebase/firestore';

import { createTestEnv } from './helpers.js';

let env: RulesTestEnvironment;

before(async () => {
  env = await createTestEnv('system');
});

after(async () => {
  await env.cleanup();
});

beforeEach(async () => {
  await env.clearFirestore();
});

test('인증 사용자는 serverTimestamp로 probe를 쓸 수 있다', async () => {
  const db = env.authenticatedContext('u1').firestore();
  await assertSucceeds(
    setDoc(doc(db, 'system/serverTime'), { probe: serverTimestamp() }),
  );
});

test('임의의 시각을 probe에 주입하면 거부된다', async () => {
  const db = env.authenticatedContext('u1').firestore();
  await assertFails(
    setDoc(doc(db, 'system/serverTime'), { probe: new Date(2000, 0, 1) }),
  );
});

// 브루트포스 카운터는 Admin SDK 전용이며 Rules를 정의하지 않는다.
// 최상단 default-deny가 클라이언트를 막는지 확인한다.
test('클라이언트는 inviteLookupAttempts를 읽지 못한다', async () => {
  const db = env.authenticatedContext('u1').firestore();
  await assertFails(getDoc(doc(db, 'inviteLookupAttempts/u1')));
});

test('클라이언트는 inviteLookupAttempts를 쓰지 못한다', async () => {
  const db = env.authenticatedContext('u1').firestore();
  await assertFails(setDoc(doc(db, 'inviteLookupAttempts/u1'), { count: 0 }));
});
```

- [x] **Step 4: 전체 Rules 테스트 실행**

```bash
cd functions && npm run test:rules
```

기대: 전부 통과. 하나라도 실패하면 현행 `firestore.rules`와 테스트 기대가 어긋난 것이므로, **Rules가 아니라 테스트를 현행에 맞춘다.** 이 단계의 목적은 현 상태를 기록하는 것이다.

- [x] **Step 5: 커밋**

```bash
git add functions/src/rules/
git commit -m "test: #39 - stores 쓰기·reservations·system 규칙 회귀 테스트 추가"
```

---

### Task 3: fcmTokens 서브컬렉션 격리 (Rules + Flutter)

`users/{uid}` read는 인증 사용자 전체에 열려 있어 다른 사용자의 FCM 토큰이 노출된다. 토큰만 본인 전용 서브문서로 옮긴다.

**Files:**
- Modify: `firestore.rules`
- Create(테스트): `functions/src/rules/users.test.ts`
- Modify: `lib/data/models/user_model.dart`
- Modify: `lib/data/data_sources/user_data_source.dart`
- Modify: `lib/data/repositories/user_repository_impl.dart`
- Modify: `test/data/data_sources/user_data_source_test.dart`

**Interfaces:**
- Consumes: `createTestEnv(suffix)` (Task 1)
- Produces: 저장 위치 `users/{uid}/private/fcm` 문서의 `tokens: string[]` 필드 — Task 4의 Cloud Functions가 같은 경로를 읽는다. `UserDataSource.createUser(UserModel userModel, {String? fcmToken})`

- [x] **Step 1: 실패하는 Rules 테스트 작성**

`functions/src/rules/users.test.ts`:

```ts
import { after, before, beforeEach, test } from 'node:test';

import {
  assertFails,
  assertSucceeds,
  type RulesTestEnvironment,
} from '@firebase/rules-unit-testing';
import { doc, getDoc, setDoc } from 'firebase/firestore';

import { createTestEnv } from './helpers.js';

let env: RulesTestEnvironment;

before(async () => {
  env = await createTestEnv('users');
});

after(async () => {
  await env.cleanup();
});

beforeEach(async () => {
  await env.clearFirestore();
  await env.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();
    await setDoc(doc(db, 'users/u1'), { name: '홍길동', storeById: {} });
    await setDoc(doc(db, 'users/u1/private/fcm'), { tokens: ['token-a'] });
  });
});

test('다른 사용자의 문서는 읽을 수 있다 (멤버 이름 표시용)', async () => {
  const db = env.authenticatedContext('u2').firestore();
  await assertSucceeds(getDoc(doc(db, 'users/u1')));
});

test('본인은 자신의 FCM 토큰 문서를 읽을 수 있다', async () => {
  const db = env.authenticatedContext('u1').firestore();
  await assertSucceeds(getDoc(doc(db, 'users/u1/private/fcm')));
});

test('다른 사용자의 FCM 토큰 문서는 읽지 못한다', async () => {
  const db = env.authenticatedContext('u2').firestore();
  await assertFails(getDoc(doc(db, 'users/u1/private/fcm')));
});

test('다른 사용자의 FCM 토큰 문서는 쓰지 못한다', async () => {
  const db = env.authenticatedContext('u2').firestore();
  await assertFails(
    setDoc(doc(db, 'users/u1/private/fcm'), { tokens: ['탈취'] }),
  );
});

test('본인은 자신의 FCM 토큰 문서를 쓸 수 있다', async () => {
  const db = env.authenticatedContext('u1').firestore();
  await assertSucceeds(
    setDoc(doc(db, 'users/u1/private/fcm'), { tokens: ['token-b'] }),
  );
});
```

- [x] **Step 2: 테스트 실패 확인**

```bash
cd functions && npm run test:rules
```

기대: `private/fcm` 관련 4건이 FAIL. 현재 Rules에는 `users/{uid}` 하위 서브컬렉션 규칙이 없어 최상단 default-deny에 걸리므로 **본인 접근 2건도 함께 실패**한다.

- [x] **Step 3: Rules에 서브컬렉션 규칙 추가**

`firestore.rules`의 `match /users/{uid} { ... }` 블록이 **닫힌 직후**에 아래를 넣는다.

```javascript
    // ─── users 하위 private 서브컬렉션 ─────────────────────────────────────
    // 경로: users/{uid}/private/{docId}
    //
    // users/{uid} 본문은 멤버 이름 표시를 위해 인증 사용자 전체에 열려 있어,
    // FCM 토큰처럼 본인만 알아야 하는 값을 둘 수 없다. 기기 상관·핑거프린팅을
    // 막기 위해 토큰은 이 서브컬렉션으로 옮기고 본인만 접근하도록 한다.
    // Cloud Functions는 Admin SDK라 이 규칙을 우회한다.
    match /users/{uid}/private/{docId} {
      allow read, write: if request.auth != null && request.auth.uid == uid;
    }
```

- [x] **Step 4: 테스트 통과 확인**

```bash
cd functions && npm run test:rules
```

기대: 전부 PASS.

- [x] **Step 5: UserModel에서 fcmTokens 필드 삭제**

`fcmTokens`는 앱 로직 어디에서도 읽지 않는 순수 저장용 필드이고 `User` 엔티티에도 없다. 필드 자체를 제거한다.

`lib/data/models/user_model.dart`에서 아래 줄을 삭제한다.

```dart
    @JsonKey(includeToJson: false) @Default([]) List<String> fcmTokens,
```

- [x] **Step 6: DataSource 인터페이스와 구현을 서브문서 대상으로 변경**

`lib/data/data_sources/user_data_source.dart`. 인터페이스 20행:

```dart
  Future<void> createUser(UserModel userModel, {String? fcmToken});
```

구현부에 헬퍼를 추가한다 (`_userDocRef` 정의 근처).

```dart
  /// FCM 토큰 전용 문서. users/{uid} 본문은 다른 사용자도 읽을 수 있으므로
  /// 토큰은 본인만 접근 가능한 이 경로에 둔다 (firestore.rules 참고).
  DocumentReference<Map<String, dynamic>> _fcmDocRef(String uid) {
    return _userDocRef(uid).collection('private').doc('fcm');
  }
```

`createUser`를 아래로 교체한다.

```dart
  @override
  Future<void> createUser(UserModel userModel, {String? fcmToken}) async {
    try {
      final json = userModel.toJson();
      json['createdAt'] = FieldValue.serverTimestamp();
      json['updatedAt'] = FieldValue.serverTimestamp();
      json['lastLoginAt'] = FieldValue.serverTimestamp();

      final batch = _firestore.batch();
      batch.set(_userDocRef(userModel.id), json);
      if (fcmToken != null) {
        batch.set(_fcmDocRef(userModel.id), {
          'tokens': [fcmToken],
        });
      }
      await batch.commit();
    } catch (e) {
      throw handleFirestoreError(e);
    }
  }
```

`recordLogin`을 아래로 교체한다.

```dart
  @override
  Future<void> recordLogin(
    String uid, {
    required List<String> authProviders,
    String? fcmToken,
  }) async {
    try {
      final batch = _firestore.batch();
      batch.update(_userDocRef(uid), {
        'authProviders': authProviders,
        'lastLoginAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (fcmToken != null) {
        // update는 문서가 없으면 실패한다. 첫 로그인 기기에서도 동작해야 하므로
        // 반드시 merge set을 쓴다.
        batch.set(_fcmDocRef(uid), {
          'tokens': FieldValue.arrayUnion([fcmToken]),
        }, SetOptions(merge: true));
      }
      await batch.commit();
    } catch (e) {
      throw handleFirestoreError(e);
    }
  }
```

`addFcmToken` / `removeFcmToken` / `replaceFcmToken`을 아래로 교체한다.

```dart
  @override
  Future<void> addFcmToken(String uid, String token) async {
    try {
      await _fcmDocRef(uid).set({
        'tokens': FieldValue.arrayUnion([token]),
      }, SetOptions(merge: true));
    } catch (e) {
      throw handleFirestoreError(e);
    }
  }

  @override
  Future<void> replaceFcmToken(
    String uid,
    String oldToken,
    String newToken,
  ) async {
    try {
      final docRef = _fcmDocRef(uid);

      // arrayRemove + arrayUnion을 동일 필드에 적용하므로 Transaction으로 원자성 보장
      await _firestore.runTransaction((tx) async {
        final doc = await tx.get(docRef);
        final tokens = List<String>.from(doc.data()?['tokens'] ?? []);
        tokens.remove(oldToken);
        if (!tokens.contains(newToken)) tokens.add(newToken);

        tx.set(docRef, {'tokens': tokens}, SetOptions(merge: true));
      });
    } catch (e) {
      throw handleFirestoreError(e);
    }
  }

  @override
  Future<void> removeFcmToken(String uid, String token) async {
    try {
      await _fcmDocRef(uid).set({
        'tokens': FieldValue.arrayRemove([token]),
      }, SetOptions(merge: true));
    } catch (e) {
      throw handleFirestoreError(e);
    }
  }
```

`softDeleteUser`에서 `'fcmTokens': []` 줄을 지우고 batch로 바꾼다.

```dart
  @override
  Future<void> softDeleteUser(String uid) async {
    try {
      // expiresAt은 클라이언트 시각 기준으로 계산됩니다.
      // deletedAt(서버 타임스탬프)과 미세한 차이가 있을 수 있으나,
      // 7일 만료 기준에서 실질적인 문제가 없으므로 허용합니다.
      final hardDeleteDate = DateTime.now().add(
        const Duration(days: userSoftDeleteDays),
      );
      final batch = _firestore.batch();
      batch.update(_userDocRef(uid), {
        'deletedAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(hardDeleteDate),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      batch.set(_fcmDocRef(uid), {'tokens': <String>[]});
      await batch.commit();
    } catch (e) {
      throw handleFirestoreError(e);
    }
  }
```

- [x] **Step 7: 호출부 수정**

`lib/data/repositories/user_repository_impl.dart`에서 `UserModel` 생성의 `fcmTokens:` 줄을 지우고, `createUser` 호출에 토큰을 넘긴다.

```dart
        final newUserModel = UserModel(
          id: authInfo.uid,
          name: authInfo.displayName ?? '이름 없음',
          email: authInfo.email ?? '',
          nickname: null,
          authProviders: authInfo.authProviders,
          storeById: {},
        );

        await _userDataSource.createUser(newUserModel, fcmToken: fcmToken);
```

- [x] **Step 8: 코드 생성 및 정적 분석**

```bash
dart run build_runner build --delete-conflicting-outputs
dart analyze
```

기대: 에러 0건. `fcmTokens`를 참조하던 곳이 남아 있으면 여기서 드러난다.

- [x] **Step 9: 기존 Dart 테스트 갱신 및 실행**

`test/data/data_sources/user_data_source_test.dart`에서 `fcmTokens` 필드를 직접 읽던 단언을 서브문서 경로로 바꾼다. `fake_cloud_firestore`에서는 아래처럼 읽는다.

```dart
    final fcmDoc = await firestore
        .collection('users')
        .doc(uid)
        .collection('private')
        .doc('fcm')
        .get();
    expect(fcmDoc.data()?['tokens'], contains(token));
```

```bash
flutter test
```

기대: 전부 통과.

- [x] **Step 10: 포맷 및 커밋**

```bash
dart format lib/data/models/user_model.dart lib/data/data_sources/user_data_source.dart lib/data/repositories/user_repository_impl.dart test/data/data_sources/user_data_source_test.dart
git add firestore.rules functions/src/rules/users.test.ts lib/data test/data
git commit -m "refactor: #39 - FCM 토큰을 users/{uid}/private/fcm 서브문서로 격리"
```

---

### Task 4: Cloud Functions의 FCM 토큰 경로 이전

Task 3에서 저장 위치를 옮겼으므로 발송 함수도 같은 경로를 봐야 한다. 이 작업 전까지 dev 환경 알림이 나가지 않는다.

**Files:**
- Modify: `functions/src/index.ts`

**Interfaces:**
- Consumes: `users/{uid}/private/fcm` 문서의 `tokens: string[]` (Task 3)
- Produces: 없음

- [x] **Step 1: 토큰 조회 경로 변경**

`functions/src/index.ts`에서 관리자 토큰을 모으는 블록을 아래로 교체한다. 서브문서의 `doc.id`는 전부 `'fcm'`이라 소유자를 되찾을 수 없으므로, **요청 순서와 같은 인덱스로 `adminUids`와 짝짓는다.**

```ts
    // 토큰 → 소유 관리자 uid. 폐기 토큰 정리 시 어느 문서를 갱신할지 알기 위해 필요하다.
    const ownerUidByToken = new Map<string, string>();
    // 토큰은 users/{uid}/private/fcm에 있다 (firestore.rules 참고).
    // 서브문서의 id는 모두 'fcm'이라 doc.id로 소유자를 되찾을 수 없으므로
    // getAll에 넘긴 순서와 같은 인덱스로 adminUids와 짝짓는다.
    const fcmDocs = await db.getAll(
      ...adminUids.map((uid) => db.doc(`users/${uid}/private/fcm`)),
    );
    fcmDocs.forEach((doc, index) => {
      const tokens = (doc.get('tokens') as string[] | undefined) ?? [];
      for (const token of tokens) {
        ownerUidByToken.set(token, adminUids[index]);
      }
    });
```

- [x] **Step 2: 폐기 토큰 정리 경로 변경**

같은 파일 하단의 정리 블록을 아래로 교체한다. `users/{uid}.updatedAt`은 더 이상 건드리지 않는다.

```ts
      await Promise.all(
        expiredTokens.map((token) =>
          db.doc(`users/${ownerUidByToken.get(token)}/private/fcm`).update({
            tokens: FieldValue.arrayRemove(token),
          }),
        ),
      );
```

- [x] **Step 3: 빌드 및 단위 테스트**

```bash
cd functions && npm run test:unit
```

기대: 기존 순수 함수 테스트 전부 통과, TypeScript 컴파일 에러 없음. `FieldValue` import가 그대로 쓰이는지 확인한다(`noUnusedLocals`가 켜져 있어 미사용 import는 빌드를 깨뜨린다).

- [x] **Step 4: 커밋**

```bash
git add functions/src/index.ts
git commit -m "refactor: #39 - 알림 발송의 FCM 토큰 조회·정리 경로를 서브문서로 이전"
```

---

### Task 5: 초대 코드 순수 로직

Callable 본체에서 Firestore I/O와 분리 가능한 판단 로직을 먼저 만든다. 기존 `functions/src/notifications/`와 같은 방침이다.

**Files:**
- Create: `functions/src/invite/invite_code.ts`
- Create: `functions/src/invite/invite_code.test.ts`
- Create: `functions/src/invite/rate_limit.ts`
- Create: `functions/src/invite/rate_limit.test.ts`

**Interfaces:**
- Consumes: 없음
- Produces: Task 6이 사용한다
  - `INVITE_CODE_AVAILABLE_MIN = 15`
  - `isValidInviteCode(code: unknown): code is string`
  - `isInviteExpired(createdAt: Date, now: Date): boolean`
  - `RATE_LIMIT_WINDOW_MIN = 10`, `RATE_LIMIT_MAX_FAILURES = 10`
  - `type AttemptRecord = { count: number; windowStartAt: Date }`
  - `nextAttemptState(record: AttemptRecord | null, now: Date): { blocked: boolean; next: AttemptRecord }`

- [x] **Step 1: 실패하는 초대 코드 테스트 작성**

`functions/src/invite/invite_code.test.ts`:

```ts
import assert from 'node:assert/strict';
import { test } from 'node:test';

import {
  INVITE_CODE_AVAILABLE_MIN,
  isInviteExpired,
  isValidInviteCode,
} from './invite_code.js';

test('6자 대문자·숫자 코드는 유효하다', () => {
  assert.equal(isValidInviteCode('AB3D9F'), true);
});

test('길이가 다르면 무효하다', () => {
  assert.equal(isValidInviteCode('AB3D9'), false);
  assert.equal(isValidInviteCode('AB3D9FG'), false);
});

test('소문자와 특수문자는 무효하다', () => {
  assert.equal(isValidInviteCode('ab3d9f'), false);
  assert.equal(isValidInviteCode('AB3D-F'), false);
});

test('문자열이 아니면 무효하다', () => {
  assert.equal(isValidInviteCode(undefined), false);
  assert.equal(isValidInviteCode(123456), false);
});

test('유효 시간 직전은 만료가 아니다', () => {
  const createdAt = new Date('2026-08-29T00:00:00Z');
  const now = new Date(
    createdAt.getTime() + (INVITE_CODE_AVAILABLE_MIN * 60 - 1) * 1000,
  );
  assert.equal(isInviteExpired(createdAt, now), false);
});

test('유효 시간이 지나면 만료다', () => {
  const createdAt = new Date('2026-08-29T00:00:00Z');
  const now = new Date(
    createdAt.getTime() + (INVITE_CODE_AVAILABLE_MIN * 60 + 1) * 1000,
  );
  assert.equal(isInviteExpired(createdAt, now), true);
});
```

- [x] **Step 2: 테스트 실패 확인**

```bash
cd functions && npm run test:unit
```

기대: 컴파일 실패 — `Cannot find module './invite_code.js'`.

- [x] **Step 3: 초대 코드 순수 로직 구현**

`functions/src/invite/invite_code.ts`:

```ts
/** 클라이언트의 lib/constants/data_constants.dart storeInviteCodeAvailableMin과 일치해야 한다 */
export const INVITE_CODE_AVAILABLE_MIN = 15;

/**
 * 발급 시 사용하는 문자 집합은 혼동하기 쉬운 I/O/0/1을 뺀 32자다
 * (StoreFirestoreDataSource._generateRandomCode). 검증은 그보다 느슨하게
 * 대문자·숫자 6자만 확인한다 — 집합을 좁히면 발급 규칙이 바뀔 때 함께 깨진다.
 */
const CODE_PATTERN = /^[A-Z0-9]{6}$/;

export function isValidInviteCode(code: unknown): code is string {
  return typeof code === 'string' && CODE_PATTERN.test(code);
}

export function isInviteExpired(createdAt: Date, now: Date): boolean {
  const expiresAt = createdAt.getTime() + INVITE_CODE_AVAILABLE_MIN * 60 * 1000;
  return now.getTime() > expiresAt;
}
```

- [x] **Step 4: 테스트 통과 확인**

```bash
cd functions && npm run test:unit
```

기대: 초대 코드 테스트 6건 PASS.

- [x] **Step 5: 실패하는 rate limit 테스트 작성**

`functions/src/invite/rate_limit.test.ts`:

```ts
import assert from 'node:assert/strict';
import { test } from 'node:test';

import {
  RATE_LIMIT_MAX_FAILURES,
  RATE_LIMIT_WINDOW_MIN,
  nextAttemptState,
} from './rate_limit.js';

const NOW = new Date('2026-08-29T12:00:00Z');

test('기록이 없으면 통과하고 카운트 1로 시작한다', () => {
  const result = nextAttemptState(null, NOW);
  assert.equal(result.blocked, false);
  assert.equal(result.next.count, 1);
  assert.deepEqual(result.next.windowStartAt, NOW);
});

test('창 안에서 한도 미만이면 통과하고 카운트가 증가한다', () => {
  const result = nextAttemptState({ count: 3, windowStartAt: NOW }, NOW);
  assert.equal(result.blocked, false);
  assert.equal(result.next.count, 4);
});

test('창 안에서 한도에 도달하면 차단한다', () => {
  const result = nextAttemptState(
    { count: RATE_LIMIT_MAX_FAILURES, windowStartAt: NOW },
    NOW,
  );
  assert.equal(result.blocked, true);
});

test('창이 지나면 카운트가 초기화된다', () => {
  const stale = new Date(NOW.getTime() - (RATE_LIMIT_WINDOW_MIN + 1) * 60000);
  const result = nextAttemptState(
    { count: RATE_LIMIT_MAX_FAILURES, windowStartAt: stale },
    NOW,
  );
  assert.equal(result.blocked, false);
  assert.equal(result.next.count, 1);
  assert.deepEqual(result.next.windowStartAt, NOW);
});
```

- [x] **Step 6: 테스트 실패 확인**

```bash
cd functions && npm run test:unit
```

기대: `Cannot find module './rate_limit.js'`.

- [x] **Step 7: rate limit 순수 로직 구현**

`functions/src/invite/rate_limit.ts`:

```ts
export const RATE_LIMIT_WINDOW_MIN = 10;
export const RATE_LIMIT_MAX_FAILURES = 10;

export type AttemptRecord = {
  count: number;
  windowStartAt: Date;
};

/**
 * 고정 창(fixed window) 방식으로 다음 상태를 계산한다.
 *
 * ponytail: 트랜잭션 없이 read → write로 쓰이므로 동시 요청이 한도를 약간
 * 넘길 수 있다. 정확한 쿼터가 아니라 브루트포스 비용 승수가 목적이라 허용한다.
 * 정밀한 제한이 필요해지면 Firestore 트랜잭션 또는 전용 rate limiter로 교체.
 */
export function nextAttemptState(
  record: AttemptRecord | null,
  now: Date,
): { blocked: boolean; next: AttemptRecord } {
  const windowExpired =
    record === null ||
    now.getTime() - record.windowStartAt.getTime() >
      RATE_LIMIT_WINDOW_MIN * 60 * 1000;

  if (windowExpired) {
    return { blocked: false, next: { count: 1, windowStartAt: now } };
  }

  if (record.count >= RATE_LIMIT_MAX_FAILURES) {
    return { blocked: true, next: record };
  }

  return {
    blocked: false,
    next: { count: record.count + 1, windowStartAt: record.windowStartAt },
  };
}
```

- [x] **Step 8: 테스트 통과 확인**

```bash
cd functions && npm run test:unit
```

기대: 초대 코드 6건 + rate limit 4건 전부 PASS.

- [x] **Step 9: 커밋**

```bash
git add functions/src/invite/
git commit -m "feat: #13 - 초대 코드 형식·만료·시도 한도 판정 순수 로직 추가"
```

---

### Task 6: Callable Function `lookupInviteCode`

비멤버가 넘어야 할 유일한 경계를 서버로 옮긴다. 계좌·멤버·초대 코드는 응답에 포함하지 않는다.

**Files:**
- Create: `functions/src/invite/lookup_invite_code.ts`
- Modify: `functions/src/index.ts`

**Interfaces:**
- Consumes: `isValidInviteCode`, `isInviteExpired`, `nextAttemptState`, `AttemptRecord` (Task 5)
- Produces: Callable `lookupInviteCode`. 요청 `{ code: string }`, 응답
  - 성공: `{ ok: true, store: { storeId, storeName, address, addressDetail, adminName } }`
  - 실패: `{ ok: false, reason: 'invalidCode' | 'notFound' | 'expired' | 'rateLimited' }`

  Task 7의 Flutter DataSource가 이 계약을 그대로 파싱한다.

- [x] **Step 1: Callable 구현**

도메인 실패를 `HttpsError`로 던지지 않는 이유는 스펙 §2에 있다 — 클라이언트의 `mapFirebaseCode`가 모든 Firestore 호출과 공유되는 매핑이라 `not-found`/`deadline-exceeded`에 초대 코드 전용 의미를 얹을 수 없다.

`functions/src/invite/lookup_invite_code.ts`:

```ts
import { getFirestore, Timestamp } from 'firebase-admin/firestore';
import { logger } from 'firebase-functions/v2';
import { HttpsError, onCall } from 'firebase-functions/v2/https';

import { isInviteExpired, isValidInviteCode } from './invite_code.js';
import { type AttemptRecord, nextAttemptState } from './rate_limit.js';

type FailureReason = 'invalidCode' | 'notFound' | 'expired' | 'rateLimited';

type LookupResult =
  | {
      ok: true;
      store: {
        storeId: string;
        storeName: string;
        address: string;
        addressDetail: string;
        adminName: string;
      };
    }
  | { ok: false; reason: FailureReason };

/**
 * 초대 코드로 가입 전 화면이 표시할 최소 정보만 조회한다.
 *
 * stores read를 멤버 전용으로 조인 뒤(firestore.rules), 아직 멤버가 아닌
 * 사용자가 넘어야 하는 유일한 경계가 이 함수다. 계좌 정보·memberById·
 * waitingMemberById·inviteInfo는 절대 응답에 넣지 않는다.
 */
export const lookupInviteCode = onCall<{ code?: unknown }, Promise<LookupResult>>(
  {
    region: 'asia-northeast3',
    enforceAppCheck: true,
  },
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new HttpsError('unauthenticated', '로그인이 필요합니다.');
    }

    const db = getFirestore();
    const now = new Date();

    // 브루트포스 제한: 실패한 시도만 센다. 정상 사용자는 오타 몇 번이면 끝나므로
    // 한도에 닿지 않는다. 카운터는 Rules를 정의하지 않아 클라이언트가 볼 수 없다.
    const attemptRef = db.doc(`inviteLookupAttempts/${uid}`);
    const attemptSnap = await attemptRef.get();
    const stored = attemptSnap.data();
    const record: AttemptRecord | null = stored
      ? {
          count: stored.count as number,
          windowStartAt: (stored.windowStartAt as Timestamp).toDate(),
        }
      : null;
    const { blocked, next } = nextAttemptState(record, now);
    if (blocked) {
      logger.warn('초대 코드 조회 시도 한도 초과', { uid });
      return { ok: false, reason: 'rateLimited' };
    }

    const recordFailure = async (reason: FailureReason): Promise<LookupResult> => {
      await attemptRef.set({
        count: next.count,
        windowStartAt: Timestamp.fromDate(next.windowStartAt),
      });
      return { ok: false, reason };
    };

    const code = request.data?.code;
    if (!isValidInviteCode(code)) {
      return recordFailure('invalidCode');
    }

    const snapshot = await db
      .collection('stores')
      .where('inviteInfo.inviteCode', '==', code)
      .limit(1)
      .get();
    if (snapshot.empty) {
      return recordFailure('notFound');
    }

    const storeDoc = snapshot.docs[0];
    const store = storeDoc.data();

    // deletedAt은 softDeleteStore에서만 기록되며, 그 경로는 inviteInfo도 함께
    // null로 만든다. 그래도 방어적으로 확인한다.
    if (store.deletedAt) {
      return recordFailure('notFound');
    }

    const createdAt = store.inviteInfo?.createdAt as Timestamp | undefined;
    if (!createdAt) {
      // 코드가 있는데 발급 시각이 없는 문서 — 만료 판정이 불가능하므로 없는 것으로 본다
      logger.warn('inviteInfo.createdAt이 없는 점포', { storeId: storeDoc.id });
      return recordFailure('notFound');
    }
    if (isInviteExpired(createdAt.toDate(), now)) {
      return recordFailure('expired');
    }

    // 성공하면 시도 기록을 지운다
    await attemptRef.delete();

    return {
      ok: true,
      store: {
        storeId: storeDoc.id,
        storeName: (store.name as string | undefined) ?? '',
        address: (store.address as string | undefined) ?? '',
        addressDetail: (store.addressDetail as string | undefined) ?? '',
        adminName: await resolveAdminName(store.memberById),
      },
    };
  },
);

/** 대표 관리자 이름. 찾지 못하면 빈 문자열 (현행 클라이언트 동작과 동일) */
async function resolveAdminName(memberById: unknown): Promise<string> {
  if (typeof memberById !== 'object' || memberById === null) return '';

  const adminUid = Object.entries(
    memberById as Record<string, { role?: string }>,
  ).find(([, member]) => member?.role === 'ADMIN')?.[0];
  if (!adminUid) return '';

  const adminDoc = await getFirestore().doc(`users/${adminUid}`).get();
  return (
    (adminDoc.get('nickname') as string | undefined) ??
    (adminDoc.get('name') as string | undefined) ??
    ''
  );
}
```

- [x] **Step 2: index.ts에서 export**

`functions/src/index.ts` 하단(또는 import 블록 아래)에 재export를 추가한다.

```ts
export { lookupInviteCode } from './invite/lookup_invite_code.js';
```

- [x] **Step 3: 빌드 확인**

```bash
cd functions && npm run build
```

기대: 컴파일 에러 0건.

- [x] **Step 4: 전체 테스트 실행**

```bash
cd functions && npm test
```

기대: 단위 테스트와 Rules 테스트 전부 통과. `inviteLookupAttempts` 차단 테스트(Task 2)가 여전히 통과하는지 확인한다.

- [x] **Step 5: dev 환경 배포**

```bash
firebase deploy --only functions -P dev
```

기대: `lookupInviteCode(asia-northeast3)` 생성 성공. 실패 시 Blaze 요금제와 `.firebaserc` 별칭을 확인한다.

- [x] **Step 6: 커밋**

```bash
git add functions/src/invite/lookup_invite_code.ts functions/src/index.ts
git commit -m "feat: #13 - 초대 코드 조회 Callable 함수 추가"
```

---

### Task 7: Flutter 엔티티·모델·DataSource

Callable 응답을 받을 타입을 만들고 DataSource의 조회 경로를 교체한다.

**Files:**
- Modify: `pubspec.yaml`
- Create: `lib/domain/entities/invite_store_preview.dart`
- Create: `lib/data/models/invite_store_preview_model.dart`
- Create: `test/data/models/invite_store_preview_model_test.dart`
- Modify: `lib/data/data_sources/store_data_source.dart`

**Interfaces:**
- Consumes: Callable 응답 계약 (Task 6)
- Produces:
  - `InviteStorePreview({storeId, storeName, address, addressDetail, adminName})` (전부 `String`)
  - `InviteStorePreviewModel.fromJson`, `.toEntity()`
  - `StoreDataSource.lookupInviteCode(String code) → Future<InviteStorePreviewModel?>` (없으면 `null`, 그 외 실패는 예외)

  Task 8의 Repository가 이것을 사용한다.

- [x] **Step 1: cloud_functions 의존성 추가**

```bash
flutter pub add cloud_functions
```

설치 후 `pubspec.yaml`에 들어간 버전이 기존 `firebase_core: ^4.6.0`과 충돌하지 않는지 `flutter pub get` 출력으로 확인한다.

- [x] **Step 2: 실패하는 모델 테스트 작성**

`test/data/models/invite_store_preview_model_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:studio_chance/data/models/invite_store_preview_model.dart';

void main() {
  group('InviteStorePreviewModel', () {
    test('Callable 응답 JSON을 파싱한다', () {
      final model = InviteStorePreviewModel.fromJson({
        'storeId': 'store-1',
        'storeName': '테스트 점포',
        'address': '경기 오산시 경기대로285번길 26',
        'addressDetail': '3층',
        'adminName': '홍길동',
      });

      expect(model.storeId, 'store-1');
      expect(model.storeName, '테스트 점포');
      expect(model.adminName, '홍길동');
    });

    test('toEntity가 모든 필드를 그대로 옮긴다', () {
      const model = InviteStorePreviewModel(
        storeId: 'store-1',
        storeName: '테스트 점포',
        address: '주소',
        addressDetail: '상세',
        adminName: '홍길동',
      );

      final entity = model.toEntity();

      expect(entity.storeId, 'store-1');
      expect(entity.storeName, '테스트 점포');
      expect(entity.address, '주소');
      expect(entity.addressDetail, '상세');
      expect(entity.adminName, '홍길동');
    });
  });
}
```

- [x] **Step 3: 테스트 실패 확인**

```bash
flutter test test/data/models/invite_store_preview_model_test.dart
```

기대: `Target of URI doesn't exist` 컴파일 에러.

- [x] **Step 4: 엔티티 작성**

`lib/domain/entities/invite_store_preview.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'invite_store_preview.freezed.dart';

/// 초대 코드로 조회한 "가입 전 점포 표시 정보"
///
/// 아직 멤버가 아닌 사용자에게 보여줄 최소 정보만 담는다. 계좌 정보·멤버 목록·
/// 초대 코드는 Callable 함수(`lookupInviteCode`)가 애초에 내려주지 않는다.
@freezed
abstract class InviteStorePreview with _$InviteStorePreview {
  const factory InviteStorePreview({
    required String storeId,
    required String storeName,
    required String address,
    required String addressDetail,
    required String adminName,
  }) = _InviteStorePreview;
}
```

- [x] **Step 5: 모델 작성**

`lib/data/models/invite_store_preview_model.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:studio_chance/domain/entities/invite_store_preview.dart';

part 'invite_store_preview_model.freezed.dart';
part 'invite_store_preview_model.g.dart';

@freezed
abstract class InviteStorePreviewModel with _$InviteStorePreviewModel {
  const InviteStorePreviewModel._();

  const factory InviteStorePreviewModel({
    required String storeId,
    required String storeName,
    required String address,
    required String addressDetail,
    required String adminName,
  }) = _InviteStorePreviewModel;

  factory InviteStorePreviewModel.fromJson(Map<String, dynamic> json) =>
      _$InviteStorePreviewModelFromJson(json);

  InviteStorePreview toEntity() {
    return InviteStorePreview(
      storeId: storeId,
      storeName: storeName,
      address: address,
      addressDetail: addressDetail,
      adminName: adminName,
    );
  }
}
```

- [x] **Step 6: 코드 생성 후 테스트 통과 확인**

```bash
dart run build_runner build --delete-conflicting-outputs
flutter test test/data/models/invite_store_preview_model_test.dart
```

기대: 2건 PASS.

- [x] **Step 7: DataSource 인터페이스와 구현 교체**

`lib/data/data_sources/store_data_source.dart`.

인터페이스 70행의 선언을 교체한다.

```dart
  /// 초대 코드로 가입 전 표시 정보를 조회한다.
  ///
  /// 코드가 없거나 삭제된 점포면 `null`을 반환한다. 만료·형식 불량·시도 한도
  /// 초과는 예외로 던진다.
  Future<InviteStorePreviewModel?> lookupInviteCode(String inviteCode);
```

구현 클래스의 생성자에 `FirebaseFunctions`를 주입한다.

```dart
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;
  final _rnd = Random();

  StoreFirestoreDataSource(this._firestore, this._functions);
```

`getStoreByInviteCode` 구현 전체를 아래로 교체한다.

```dart
  @override
  Future<InviteStorePreviewModel?> lookupInviteCode(String inviteCode) async {
    try {
      // stores read가 멤버 전용이라 클라이언트 쿼리로는 조회할 수 없다.
      // 서버가 만료 판정과 시도 한도까지 처리한다 (functions/src/invite/).
      final callable = _functions.httpsCallable('lookupInviteCode');
      final response = await callable.call<Map<String, dynamic>>({
        'code': inviteCode,
      });
      final data = Map<String, dynamic>.from(response.data);

      if (data['ok'] != true) {
        // 도메인 실패는 HttpsError가 아니라 판별 값으로 온다. mapFirebaseCode는
        // 이 DataSource의 모든 Firestore 호출과 공유되므로 not-found·
        // deadline-exceeded에 초대 코드 전용 의미를 얹을 수 없기 때문이다.
        final failure = inviteLookupFailureOf(data['reason'] as String?);
        if (failure == null) return null;
        throw failure;
      }

      return InviteStorePreviewModel.fromJson(
        Map<String, dynamic>.from(data['store'] as Map),
      );
    } catch (e) {
      throw handleFirestoreError(e);
    }
  }
```

같은 파일 하단(또는 `_generateRandomCode` 근처)에 매핑 함수를 추가한다. 테스트를 위해 최상위 함수로 둔다.

```dart
/// Callable이 돌려준 실패 사유를 예외로 옮긴다.
///
/// `notFound`와 알 수 없는 사유는 `null`을 반환하며, 호출부는 이를 "코드 없음"으로
/// 처리한다 (현행 `getStoreByInviteCode`의 null 계약을 유지).
Exception? inviteLookupFailureOf(String? reason) => switch (reason) {
  'expired' => StoreInviteCodeExpiredException(message: '만료된 초대 코드입니다.'),
  'invalidCode' => StoreValidationException(message: '유효하지 않은 초대 코드입니다.'),
  'rateLimited' => StoreResourceExhaustedException(
    message: '초대 코드 확인을 너무 많이 시도했습니다.\n잠시 후 다시 시도해 주세요.',
  ),
  _ => null,
};
```

DI 팩토리(446행)를 교체한다.

```dart
  return StoreFirestoreDataSource(
    FirebaseFirestore.instance,
    // Firestore·Functions 리전을 반드시 일치시킨다 (functions/src/invite/)
    FirebaseFunctions.instanceFor(region: 'asia-northeast3'),
  );
```

파일 상단에 import를 추가한다.

```dart
import 'package:cloud_functions/cloud_functions.dart';

import 'package:studio_chance/data/models/invite_store_preview_model.dart';
```

- [x] **Step 8: 매핑 함수 테스트 추가**

`test/data/models/invite_store_preview_model_test.dart` 하단에 group을 추가한다. import에 `package:studio_chance/common/exceptions/store_exceptions.dart`와 `package:studio_chance/data/data_sources/store_data_source.dart`를 넣는다.

```dart
  group('inviteLookupFailureOf', () {
    test('expired는 만료 예외로 매핑된다', () {
      expect(
        inviteLookupFailureOf('expired'),
        isA<StoreInviteCodeExpiredException>(),
      );
    });

    test('rateLimited는 요청 한도 예외로 매핑된다', () {
      expect(
        inviteLookupFailureOf('rateLimited'),
        isA<StoreResourceExhaustedException>(),
      );
    });

    test('invalidCode는 검증 예외로 매핑된다', () {
      expect(
        inviteLookupFailureOf('invalidCode'),
        isA<StoreValidationException>(),
      );
    });

    test('notFound와 알 수 없는 사유는 null이다 (코드 없음으로 처리)', () {
      expect(inviteLookupFailureOf('notFound'), isNull);
      expect(inviteLookupFailureOf('그런거없음'), isNull);
      expect(inviteLookupFailureOf(null), isNull);
    });
  });
```

- [x] **Step 9: 테스트 실행**

```bash
flutter test test/data/models/invite_store_preview_model_test.dart
```

기대: 6건 PASS. 이 시점에 `dart analyze`는 `getStoreByInviteCode`를 참조하는 Repository 때문에 에러를 낸다 — Task 8에서 해소된다.

- [x] **Step 10: 커밋**

```bash
dart format lib/domain/entities/invite_store_preview.dart lib/data/models/invite_store_preview_model.dart lib/data/data_sources/store_data_source.dart test/data/models/invite_store_preview_model_test.dart
git add pubspec.yaml pubspec.lock lib/domain/entities/invite_store_preview.dart lib/data/models/invite_store_preview_model.dart lib/data/data_sources/store_data_source.dart test/data/models/invite_store_preview_model_test.dart
git commit -m "feat: #13 - 초대 코드 조회를 Callable 호출로 교체 (DataSource)"
```

---

### Task 8: Flutter Repository·UseCase·화면 연결

DataSource 시그니처 변경을 상위 계층까지 전파하고, 서버로 옮긴 검증 로직을 클라이언트에서 지운다.

**Files:**
- Modify: `lib/data/repositories/store_repository_impl.dart`
- Modify: `lib/domain/repository_interfaces/store_repository.dart`
- Modify: `lib/domain/use_cases/store_use_case.dart`
- Modify: `lib/presentation/commons/extensions/address_formatter.dart`
- Modify: `lib/presentation/commons/invite_code/controllers/states/invite_code_verification_state.dart`
- Modify: `lib/presentation/commons/invite_code/controllers/invite_code_verification_controller.dart`
- Modify: `lib/presentation/commons/invite_code/screens/invite_code_verified_screen.dart`
- Modify: `test/data/repositories/store_repository_invite_test.dart`, `test/domain/use_cases/store_use_case_test.dart`, `test/presentation/commons/invite_code/controllers/invite_code_verification_controller_test.dart`, `test/data/data_sources/store_data_source_test.dart`

**Interfaces:**
- Consumes: `StoreDataSource.lookupInviteCode`, `InviteStorePreview` (Task 7)
- Produces: `StoreUseCase.getStoreByInviteCode(String) → Future<Either<Exception, InviteStorePreview?>>`

- [x] **Step 1: Repository 인터페이스 변경**

`lib/domain/repository_interfaces/store_repository.dart` 39행:

```dart
  /// 초대 코드로 가입 전 표시 정보를 조회한다. 코드가 없으면 `right(null)`.
  Future<Either<Exception, InviteStorePreview?>> getStoreByInviteCode(
    String inviteCode,
  );
```

`import 'package:studio_chance/domain/entities/invite_store_preview.dart';`를 추가한다.

- [x] **Step 2: Repository 구현 교체**

`lib/data/repositories/store_repository_impl.dart`의 `getStoreByInviteCode` 전체를 교체한다. 만료 검증·`getServerTime` 호출·`_fetchMembersWithRoles` 2회가 모두 사라진다 — 서버가 대신한다.

```dart
  @override
  Future<Either<Exception, InviteStorePreview?>> getStoreByInviteCode(
    String inviteCode,
  ) async {
    try {
      // 만료 판정과 대표 관리자 조합은 Callable이 수행한다
      // (functions/src/invite/lookup_invite_code.ts).
      final model = await _storeDataSource.lookupInviteCode(inviteCode);
      if (model == null) return right(null);

      return right(model.toEntity());
    } catch (e) {
      _logger.e('초대 코드로 점포 조회 실패');
      return left(toException(e));
    }
  }
```

- [x] **Step 3: UseCase 시그니처 변경**

`lib/domain/use_cases/store_use_case.dart`의 26행과 152행:

```dart
  Future<Either<Exception, InviteStorePreview?>> getStoreByInviteCode(
    String inviteCode,
  );
```

```dart
  @override
  Future<Either<Exception, InviteStorePreview?>> getStoreByInviteCode(
    String inviteCode,
  ) {
    return _storeRepository.getStoreByInviteCode(inviteCode);
  }
```

`import 'package:studio_chance/domain/entities/invite_store_preview.dart';`를 추가한다.

- [x] **Step 4: 주소 포맷 extension 추가**

`lib/presentation/commons/extensions/address_formatter.dart` 하단에 기존 두 extension과 같은 패턴으로 추가한다.

```dart
extension InviteStorePreviewAddressFormatter on InviteStorePreview {
  /// 점포 폼과 같은 규칙으로 줄여 표시한다.
  String get formattedAddress => formatShortAddress(address, addressDetail);
}
```

`import 'package:studio_chance/domain/entities/invite_store_preview.dart';`를 추가한다.

- [x] **Step 5: 상태 타입 변경**

`lib/presentation/commons/invite_code/controllers/states/invite_code_verification_state.dart`에서 `Store` import를 `InviteStorePreview`로 바꾸고 필드 타입을 교체한다.

```dart
    @Default(AsyncData(null)) AsyncValue<InviteStorePreview?> status,
```

- [x] **Step 6: 컨트롤러 필드명 변경**

`lib/presentation/commons/invite_code/controllers/invite_code_verification_controller.dart`의 `verifyInviteCode` 결과 처리와 `submitJoinRequest`를 교체한다.

```dart
    result.fold(
      (exception) => state = state.copyWith(
        status: AsyncError(exception, StackTrace.current),
      ),
      // 점포 별명 기본값은 점포명
      (preview) => state = state.copyWith(
        status: AsyncData(preview),
        storeAlias: preview?.storeName ?? '',
      ),
    );
```

```dart
    final preview = state.status.value!;
    // 역할은 초대 코드 단계 진입 전 역할 선택 화면에서 고른 값을 그대로 사용한다.
    final role = ref.read(roleSelectionControllerProvider);

    state = state.copyWith(submitStatus: const AsyncLoading());

    final storeUseCase = ref.read(storeUseCaseProvider);
    final result = await storeUseCase.joinStore(
      storeId: preview.storeId,
      storeAlias: state.storeAlias.trim(),
      role: role,
      color: state.color,
      memo: state.memo,
    );
```

- [x] **Step 7: 점포 확인 화면 변경**

`lib/presentation/commons/invite_code/screens/invite_code_verified_screen.dart`에서 `memberInfos`를 훑어 ADMIN을 찾던 블록을 삭제하고 서버가 준 값을 그대로 쓴다. 128~137행을 아래로 교체한다.

```dart
    // 대표 관리자 이름은 Callable이 조합해 내려준다 — 비멤버는 memberById를
    // 읽을 수 없으므로 클라이언트에서 다시 찾을 수 없다.
    final adminName = store?.adminName ?? '';

    // 점포 생성 화면과 같은 규칙으로 줄여 표시한다
    final address = store?.formattedAddress ?? '';
```

`store?.name ?? ''`을 `store?.storeName ?? ''`로 바꾼다. 더 이상 쓰이지 않는 `UserRole` import를 제거한다(`noUnusedLocals`는 없지만 `dart analyze`가 미사용 import를 경고한다).

- [x] **Step 8: 정적 분석**

```bash
dart analyze
```

기대: 에러 0건. 남은 참조가 있으면 여기서 전부 드러난다.

- [x] **Step 9: 기존 테스트 갱신**

`test/data/data_sources/store_data_source_test.dart`: `getStoreByInviteCode` 관련 group 전체를 삭제한다. Callable은 `fake_cloud_firestore`로 검증할 수 없고, 파싱과 사유 매핑은 Task 7에서 따로 덮었다.

`test/data/repositories/store_repository_invite_test.dart`: 만료 판정과 `getServerTime` 케이스는 서버 책임으로 옮겨갔으므로 삭제하고, 초대 코드 조회 group을 아래로 교체한다.

```dart
  group('getStoreByInviteCode', () {
    const preview = InviteStorePreviewModel(
      storeId: 'store-1',
      storeName: '테스트 점포',
      address: '경기 오산시 경기대로285번길 26',
      addressDetail: '3층',
      adminName: '홍길동',
    );

    test('조회 결과를 엔티티로 감싸 반환한다', () async {
      when(
        () => mockStoreDataSource.lookupInviteCode('AB3D9F'),
      ).thenAnswer((_) async => preview);

      final result = await repository.getStoreByInviteCode('AB3D9F');

      result.fold(
        (error) => fail('성공을 기대했으나 실패: $error'),
        (value) => expect(value?.storeId, 'store-1'),
      );
    });

    test('코드가 없으면 right(null)을 반환한다', () async {
      when(
        () => mockStoreDataSource.lookupInviteCode('NOTFND'),
      ).thenAnswer((_) async => null);

      final result = await repository.getStoreByInviteCode('NOTFND');

      result.fold(
        (error) => fail('성공을 기대했으나 실패: $error'),
        (value) => expect(value, isNull),
      );
    });

    test('DataSource가 던진 예외는 left로 감싼다', () async {
      when(
        () => mockStoreDataSource.lookupInviteCode('EXPIRD'),
      ).thenThrow(StoreInviteCodeExpiredException(message: '만료된 초대 코드입니다.'));

      final result = await repository.getStoreByInviteCode('EXPIRD');

      result.fold(
        (error) => expect(error, isA<StoreInviteCodeExpiredException>()),
        (_) => fail('실패를 기대했으나 성공'),
      );
    });
  });
```

`test/domain/use_cases/store_use_case_test.dart`와 `test/presentation/commons/invite_code/controllers/invite_code_verification_controller_test.dart`: `Store` 픽스처를 아래 상수로 교체하고, 목의 반환 타입을 `Either<Exception, InviteStorePreview?>`로 맞춘다.

```dart
const testPreview = InviteStorePreview(
  storeId: 'store-1',
  storeName: '테스트 점포',
  address: '경기 오산시 경기대로285번길 26',
  addressDetail: '3층',
  adminName: '홍길동',
);
```

컨트롤러 테스트에서는 조회 성공 후 상태가 아래를 만족하는지 확인한다.

```dart
      expect(container.read(provider).status.value?.storeId, 'store-1');
      // 점포 별명 기본값은 점포명
      expect(container.read(provider).storeAlias, '테스트 점포');
```

- [x] **Step 10: 전체 테스트 실행**

```bash
flutter test
```

기대: 전부 통과.

- [x] **Step 11: 포맷 및 커밋**

수정한 파일만 지정해 포맷한다.

```bash
dart format lib/data/repositories/store_repository_impl.dart lib/domain/repository_interfaces/store_repository.dart lib/domain/use_cases/store_use_case.dart lib/presentation/commons/extensions/address_formatter.dart lib/presentation/commons/invite_code/controllers/states/invite_code_verification_state.dart lib/presentation/commons/invite_code/controllers/invite_code_verification_controller.dart lib/presentation/commons/invite_code/screens/invite_code_verified_screen.dart
git add lib test
git commit -m "feat: #13 - 초대 코드 조회 결과를 InviteStorePreview로 교체"
```

---

### Task 9: stores read 권한 조이기

이번 작업의 목적지다. Task 1에서 고정한 취약점 테스트를 뒤집는다.

**Files:**
- Modify: `firestore.rules`
- Modify: `functions/src/rules/stores.test.ts`

**Interfaces:**
- Consumes: Task 8까지의 모든 변경 (앱이 더 이상 비멤버로서 `stores`를 읽지 않는다)
- Produces: 없음

- [x] **Step 1: 취약점 테스트를 기대하는 동작으로 뒤집기**

`functions/src/rules/stores.test.ts`의 해당 테스트를 교체한다.

```ts
test('비멤버는 점포 문서를 읽지 못한다', async () => {
  const db = env.authenticatedContext('outsider').firestore();
  await assertFails(getDoc(doc(db, 'stores/s1')));
});

test('대기 멤버(승인 전)는 점포 문서를 읽지 못한다', async () => {
  await env.withSecurityRulesDisabled(async (ctx) => {
    await setDoc(
      doc(ctx.firestore(), 'stores/s1'),
      { waitingMemberById: { pending1: { role: 'STAFF' } } },
      { merge: true },
    );
  });

  const db = env.authenticatedContext('pending1').firestore();
  await assertFails(getDoc(doc(db, 'stores/s1')));
});
```

`setDoc` import에 `{ merge: true }`용 옵션 인자를 쓰므로 추가 import는 필요 없다.

- [x] **Step 2: 테스트 실패 확인**

```bash
cd functions && npm run test:rules
```

기대: 방금 뒤집은 2건이 FAIL (현재 Rules가 아직 비멤버 읽기를 허용한다).

- [x] **Step 3: Rules 수정**

`firestore.rules`의 `stores` 블록에 `isMember()`를 추가하고 `read`를 교체한다. 주석의 완화 사유도 함께 갱신한다.

```javascript
    // ─── stores 컬렉션 ───────────────────────────────────────────────────
    // 경로: stores/{storeId}
    //
    // 읽기: 해당 점포의 멤버만 허용
    //   → 계좌 정보·멤버 목록·초대 코드가 담긴 문서이므로 최소 권한을 적용한다
    //   → 아직 멤버가 아닌 사용자의 초대 코드 조회는 Callable 함수
    //      lookupInviteCode가 대신한다 (functions/src/invite/). 표시에 필요한
    //      최소 정보만 반환하므로 문서를 통째로 열 필요가 없다
    // 생성: 인증된 모든 사용자 허용
    //   → 첫 점포 등록 시 본인이 memberById[uid] = ADMIN으로 포함되어야 함
    //      (UseCase 레벨에서 강제, Rules에서는 현재 미검증)
    // 수정/삭제: ADMIN 역할 보유자만 허용
    //
    // TODO: 생성 시 request.resource.data.memberById[request.auth.uid].role == 'ADMIN' 검증 추가
    match /stores/{storeId} {
      function isAdmin() {
        return request.auth != null
            && request.auth.uid in resource.data.memberById
            && resource.data.memberById[request.auth.uid].role == 'ADMIN';
      }

      function isMember() {
        return request.auth != null
            && request.auth.uid in resource.data.memberById;
      }

      allow read:   if isMember();
      allow create: if request.auth != null;
      allow update, delete: if isAdmin();
```

- [x] **Step 4: 전체 Rules 테스트 통과 확인**

```bash
cd functions && npm test
```

기대: 전부 PASS. 특히 Task 2의 가입 신청 update 테스트가 계속 통과해야 한다 — `update`는 `read`와 독립적으로 평가되므로 read를 조여도 신청 쓰기는 동작한다.

- [ ] **Step 5: dev 환경 배포 및 수동 확인**

**배포 순서를 지킨다.** Functions가 먼저다(Task 6에서 이미 배포됨).

```bash
firebase deploy --only firestore:rules -P dev
flutter run --flavor dev --target lib/main_dev.dart
```

수동 확인 항목:
1. 관리자 계정에서 초대 코드 발급 → 코드가 표시된다
2. 다른 계정에서 초대 코드 입력 → 점포 확인 화면에 점포명·대표 관리자·주소가 뜬다
3. 가입 신청 제출 → 성공하고 관리자에게 푸시 알림이 온다
4. 틀린 코드 입력 → "유효하지 않은 초대 코드" 안내
5. 승인 후 홈 화면에서 예약 목록이 정상 조회된다

- [x] **Step 6: 커밋**

```bash
git add firestore.rules functions/src/rules/stores.test.ts
git commit -m "feat: #13 - stores read 권한을 점포 멤버 전용으로 제한"
```

---

### Task 10: CI에 Functions 테스트 추가

지금 CI는 Flutter만 돌린다. Rules 테스트가 CI에서 돌지 않으면 규칙이 조용히 다시 느슨해질 수 있다.

**Files:**
- Modify: `.github/workflows/ci.yml`

**Interfaces:**
- Consumes: `npm test` (Task 1의 스크립트)
- Produces: 없음

- [x] **Step 1: functions job 추가**

`.github/workflows/ci.yml`의 기존 `test` job 아래에 job을 추가한다. Firestore 에뮬레이터는 Java를 요구하므로 명시적으로 설치한다.

```yaml
  functions:
    name: Functions & Rules
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Node
        uses: actions/setup-node@v4
        with:
          node-version: "22"
          cache: npm
          cache-dependency-path: functions/package-lock.json

      - name: Setup Java
        uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: "21"

      - name: Install dependencies
        run: npm ci
        working-directory: functions

      - name: Unit tests
        run: npm run test:unit
        working-directory: functions

      - name: Rules tests
        run: npm run test:rules
        working-directory: functions
```

`test:rules`는 `--config ../firebase.emulator.json`을 쓰므로 gitignore된 `firebase.json` 없이 동작한다. 프로젝트 ID가 `demo-` 프리픽스라 자격증명도 필요 없다.

- [x] **Step 2: 워크플로 문법 확인**

```bash
cd functions && npm ci && npm test
```

CI가 실행할 것과 같은 명령을 로컬에서 그대로 돌려 통과를 확인한다.

- [ ] **Step 3: 커밋 및 푸시**

```bash
git add .github/workflows/ci.yml
git commit -m "ci: #39 - Functions 단위 테스트와 Firestore Rules 테스트 추가"
git push -u origin "feat/#13-stores-read-rules"
```

- [ ] **Step 4: PR 생성**

`.github/PULL_REQUEST_TEMPLATE.md` 형식을 따른다. 제목은 커밋 형식과 다르다.

```
제목: Feature/#13 stores read 권한 강화 및 Rules 테스트 하네스

연관된 이슈: #13, #39
```

작업 내용에는 최소한 아래를 담는다 — 초대 코드 조회의 Callable 이전, `stores read`의 멤버 제한, `fcmTokens` 서브컬렉션 격리, Rules 테스트 하네스와 CI 연결, 브루트포스 시도 한도.

- [ ] **Step 5: prod 배포 (머지 후)**

```bash
firebase deploy --only functions -P prod
firebase deploy --only firestore:rules -P prod
```

순서를 반드시 지킨다. Rules를 먼저 배포하면 Callable이 없는 구간에서 초대 코드 조회가 실패한다.

---

## 남은 항목 (이번 범위 밖)

플랜 실행 후 이슈에 남길 후속 작업이다.

- 사용자 하드 삭제 시 `users/{uid}/private` 서브컬렉션 정리 — 하드 삭제 자체가 미구현이며, 서브컬렉션은 부모 문서 삭제로 함께 지워지지 않는다
- `createInviteCode`의 "유효 코드 재사용" 판정을 서버로 이전 — 그래서 `system/serverTime` 왕복 조회가 남아 있다
- FCM registration token → FID 마이그레이션
- `inviteLookupAttempts` 문서 정리를 위한 Firestore TTL 정책
