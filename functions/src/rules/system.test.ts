import { after, before, beforeEach, test } from 'node:test';

import {
  assertFails,
  type RulesTestEnvironment,
} from '@firebase/rules-unit-testing';
import { doc, getDoc, setDoc } from 'firebase/firestore';

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
