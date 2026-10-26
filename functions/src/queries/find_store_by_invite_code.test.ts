import assert from 'node:assert/strict';
import { after, before, beforeEach, test } from 'node:test';

import { type App, deleteApp, initializeApp } from 'firebase-admin/app';
import { type Firestore, getFirestore, Timestamp } from 'firebase-admin/firestore';

import { findStoreByInviteCode } from '../invite/find_store_by_invite_code.js';
import { projectIdFor } from '../rules/helpers.js';

// fake_cloud_firestore와 달리 실제 Firestore는 필터 대상 필드가 없는 문서를 결과에서 뺀다.
// 이 차이로 초대 코드 조회가 실사용에서 전부 실패한 적이 있어(#43) 에뮬레이터에서 검증한다.
// Admin SDK는 emulators:exec가 넣어 주는 FIRESTORE_EMULATOR_HOST로 에뮬레이터에 붙는다.

let app: App;
let db: Firestore;

before(() => {
  app = initializeApp({ projectId: projectIdFor('invite-query') }, 'invite-query');
  db = getFirestore(app);
});

after(async () => {
  await deleteApp(app);
});

beforeEach(async () => {
  await db.recursiveDelete(db.collection('stores'));
});

const inviteInfo = (inviteCode: string) => ({
  inviteCode,
  createdAt: Timestamp.now(),
});

test('deletedAt 필드가 없는 정상 점포가 조회된다', async () => {
  await db.doc('stores/s1').set({ name: '점포', inviteInfo: inviteInfo('ABC123') });

  const doc = await findStoreByInviteCode(db, 'ABC123');

  assert.equal(doc?.id, 's1');
});

test('삭제한 점포는 쓰던 초대 코드로 조회되지 않는다', async () => {
  await db.doc('stores/s1').set({ name: '점포', inviteInfo: inviteInfo('ABC123') });
  // softDeleteStore(store_data_source.dart)와 같은 모양으로 삭제한다
  await db.doc('stores/s1').update({
    deletedAt: Timestamp.now(),
    expiresAt: Timestamp.now(),
    inviteInfo: null,
  });

  assert.equal(await findStoreByInviteCode(db, 'ABC123'), null);
});

test('초대 코드를 만든 적 없는 점포는 조회되지 않는다', async () => {
  // createStore는 inviteInfo를 null로 저장한다
  await db.doc('stores/s1').set({ name: '점포', inviteInfo: null });

  assert.equal(await findStoreByInviteCode(db, 'ABC123'), null);
});

test('일치하는 코드가 없으면 null이다', async () => {
  await db.doc('stores/s1').set({ name: '점포', inviteInfo: inviteInfo('ABC123') });

  assert.equal(await findStoreByInviteCode(db, 'XYZ789'), null);
});
