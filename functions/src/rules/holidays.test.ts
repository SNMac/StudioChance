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
  env = await createTestEnv('holidays');
});

after(async () => {
  await env.cleanup();
});

beforeEach(async () => {
  await env.clearFirestore();
  await env.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), 'holidays/2026'), {
      days: { '2026-05-01': ['노동절'] },
      source: 'official',
    });
  });
});

test('인증 사용자는 공휴일 달력을 읽을 수 있다', async () => {
  const db = env.authenticatedContext('u1').firestore();
  await assertSucceeds(getDoc(doc(db, 'holidays/2026')));
});

test('비인증 사용자는 공휴일 달력을 읽지 못한다', async () => {
  const db = env.unauthenticatedContext().firestore();
  await assertFails(getDoc(doc(db, 'holidays/2026')));
});

// 공휴일 달력은 Cloud Functions(Admin SDK)만 쓴다 (ADR-0001)
test('클라이언트는 공휴일 달력을 쓰지 못한다', async () => {
  const db = env.authenticatedContext('u1').firestore();
  await assertFails(
    setDoc(doc(db, 'holidays/2026'), { days: {}, source: 'official' }),
  );
});
