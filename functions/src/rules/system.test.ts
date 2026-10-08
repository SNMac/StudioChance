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
