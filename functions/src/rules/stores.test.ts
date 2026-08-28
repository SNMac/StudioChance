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
  env = await createTestEnv();
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
