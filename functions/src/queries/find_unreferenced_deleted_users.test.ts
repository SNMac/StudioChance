import assert from 'node:assert/strict';
import { after, before, beforeEach, test } from 'node:test';

import { type App, deleteApp, initializeApp } from 'firebase-admin/app';
import { type Firestore, getFirestore, Timestamp } from 'firebase-admin/firestore';

import { projectIdFor } from '../rules/helpers.js';
import { findUnreferencedDeletedUsers } from '../users/find_unreferenced_deleted_users.js';

// `deletedAt != null`은 필드가 없는 정상 사용자를 빼고, 컬렉션 그룹 조회는 모든 점포의
// 예약을 본다는 전제를 실제 Firestore 동작으로 확인한다.

let app: App;
let db: Firestore;

before(() => {
  app = initializeApp({ projectId: projectIdFor('deleted-users') }, 'deleted-users');
  db = getFirestore(app);
});

after(async () => {
  await deleteApp(app);
});

beforeEach(async () => {
  await db.recursiveDelete(db.collection('users'));
  await db.recursiveDelete(db.collection('stores'));
});

// markAccountDeleted(user_data_source.dart)와 같은 모양
const deletedUser = (nickname: string) => ({ nickname, deletedAt: Timestamp.now() });

const idsOf = async () => (await findUnreferencedDeletedUsers(db)).map((ref) => ref.id);

test('작성한 예약이 없는 삭제된 계정을 고른다', async () => {
  await db.doc('users/u1').set(deletedUser('삭제됨'));

  assert.deepEqual(await idsOf(), ['u1']);
});

test('다른 점포에라도 작성한 예약이 남아 있으면 고르지 않는다', async () => {
  await db.doc('users/u1').set(deletedUser('삭제됨'));
  await db.doc('stores/s2/reservations/r1').set({ writerId: 'u1' });

  assert.deepEqual(await idsOf(), []);
});

test('삭제되지 않은 사용자는 예약이 없어도 고르지 않는다', async () => {
  await db.doc('users/u1').set({ nickname: '정상', name: '이름' });

  assert.deepEqual(await idsOf(), []);
});
