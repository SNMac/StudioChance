import { after, before, beforeEach, test } from 'node:test';

import {
  assertFails,
  assertSucceeds,
  type RulesTestEnvironment,
} from '@firebase/rules-unit-testing';
import { doc, getDoc, setDoc, updateDoc } from 'firebase/firestore';

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

test('비로그인 사용자는 사용자 문서를 읽지 못한다', async () => {
  const db = env.unauthenticatedContext().firestore();
  await assertFails(getDoc(doc(db, 'users/u1')));
});

test('본인은 자신의 문서 본문을 쓸 수 있다', async () => {
  const db = env.authenticatedContext('u1').firestore();
  await assertSucceeds(
    updateDoc(doc(db, 'users/u1'), { name: '새 이름' }),
  );
});

test('타인의 문서 본문은 쓰지 못한다', async () => {
  // storeById/updatedAt만 바꾸는 완화 규칙에 걸리지 않도록 name을 바꾼다 —
  // storeById만 바꾸면 그 예외 규칙 때문에 통과해 버려 이 테스트의 의도(본문 차단
  // 검증)를 검증하지 못한다.
  const db = env.authenticatedContext('u2').firestore();
  await assertFails(
    updateDoc(doc(db, 'users/u1'), { name: '탈취' }),
  );
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
