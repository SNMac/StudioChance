import assert from 'node:assert/strict';
import { after, before, beforeEach, test } from 'node:test';

import { type App, deleteApp, initializeApp } from 'firebase-admin/app';
import { type Firestore, getFirestore, Timestamp } from 'firebase-admin/firestore';

import { INVITE_CODE_AVAILABLE_MIN } from '../invite/invite_code.js';
import { issueInviteCodeFor } from '../invite/issue_invite_code.js';
import { projectIdFor } from '../rules/helpers.js';

// 트랜잭션 안의 코드 중복 쿼리와 inviteInfo 쓰기를 실제 Firestore 동작으로 확인한다.

let app: App;
let db: Firestore;

before(() => {
  app = initializeApp({ projectId: projectIdFor('issue-invite') }, 'issue-invite');
  db = getFirestore(app);
});

after(async () => {
  await deleteApp(app);
});

beforeEach(async () => {
  await db.recursiveDelete(db.collection('stores'));
});

const NOW = new Date('2026-08-29T00:10:00Z');
const admin = { memberById: { 'admin-1': { role: 'ADMIN' } } };

/** 주어진 코드를 차례로 내놓는다 */
function codes(...values: string[]): () => string {
  let i = 0;
  return () => values[i++];
}

function issue(storeId: string, generateCode: () => string, forceRegenerate = false) {
  return issueInviteCodeFor(db, {
    uid: 'admin-1',
    storeId,
    forceRegenerate,
    clock: () => NOW,
    generateCode,
  });
}

test('새 코드와 서버가 정한 발급 시각을 저장한다', async () => {
  await db.doc('stores/s1').set({ name: '점포', inviteInfo: null, ...admin });

  const outcome = await issue('s1', codes('AAAAAA'));

  assert.deepEqual(outcome, { ok: true, inviteCode: 'AAAAAA', createdAt: NOW });
  const saved = (await db.doc('stores/s1').get()).get('inviteInfo');
  assert.equal(saved.inviteCode, 'AAAAAA');
  assert.equal((saved.createdAt as Timestamp).toMillis(), NOW.getTime());
});

test('다른 점포가 쓰는 코드는 피해서 다시 뽑는다 (만료된 코드 포함)', async () => {
  const expiredAt = Timestamp.fromMillis(
    NOW.getTime() - (INVITE_CODE_AVAILABLE_MIN + 1) * 60 * 1000,
  );
  await db.doc('stores/other').set({
    name: '다른 점포',
    inviteInfo: { inviteCode: 'TAKEN2', createdAt: expiredAt },
  });
  await db.doc('stores/s1').set({ name: '점포', inviteInfo: null, ...admin });

  const outcome = await issue('s1', codes('TAKEN2', 'FRESH3'));

  assert.equal(outcome.ok && outcome.inviteCode, 'FRESH3');
});

test('재발급은 이 점포의 현재 코드와 같은 값을 쓰지 않는다', async () => {
  await db.doc('stores/s1').set({
    name: '점포',
    inviteInfo: { inviteCode: 'SAME44', createdAt: Timestamp.fromDate(NOW) },
    ...admin,
  });

  const outcome = await issue('s1', codes('SAME44', 'NEW555'), true);

  assert.equal(outcome.ok && outcome.inviteCode, 'NEW555');
});

test('유효한 코드가 남아 있으면 쓰지 않고 그 코드를 돌려준다', async () => {
  const createdAt = new Date(NOW.getTime() - 60 * 1000);
  await db.doc('stores/s1').set({
    name: '점포',
    inviteInfo: { inviteCode: 'KEEP66', createdAt: Timestamp.fromDate(createdAt) },
    ...admin,
  });

  const outcome = await issue('s1', codes('NEVER7'));

  assert.deepEqual(outcome, { ok: true, inviteCode: 'KEEP66', createdAt });
});

test('관리자가 아니면 쓰지 않는다', async () => {
  await db.doc('stores/s1').set({
    name: '점포',
    inviteInfo: null,
    memberById: { 'admin-1': { role: 'STAFF' } },
  });

  const outcome = await issue('s1', codes('AAAAAA'));

  assert.deepEqual(outcome, { ok: false, reason: 'permissionDenied' });
  assert.equal((await db.doc('stores/s1').get()).get('inviteInfo'), null);
});
