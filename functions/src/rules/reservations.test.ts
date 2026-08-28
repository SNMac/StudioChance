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

test('현행: STAFF는 예약을 쓰지 못한다 (memberRole() 평가 오류)', async () => {
  const db = env.authenticatedContext('staff1').firestore();
  await assertFails(
    setDoc(doc(db, 'stores/s1/reservations/r2'), { name: '김철수' }),
  );
});

test('VIEWER는 예약을 쓰지 못한다', async () => {
  const db = env.authenticatedContext('viewer1').firestore();
  await assertFails(
    setDoc(doc(db, 'stores/s1/reservations/r3'), { name: '김철수' }),
  );
});
