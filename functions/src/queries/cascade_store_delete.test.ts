import assert from 'node:assert/strict';
import { after, before, beforeEach, test } from 'node:test';

import { type App, deleteApp, initializeApp } from 'firebase-admin/app';
import { type Firestore, getFirestore } from 'firebase-admin/firestore';

import { projectIdFor } from '../rules/helpers.js';
import { clearStoreEntries, deleteStoreSubcollections } from '../stores/cascade_store_delete.js';

// 이미 지워진 점포 문서에 recursiveDelete를 해도 서브컬렉션이 지워지는지 실제 Firestore 동작으로 확인한다.
// TTL은 에뮬레이터가 지원하지 않으므로 TTL 삭제가 트리거를 일으키는지는 dev에서 확인한다
// (docs/operations.md).

let app: App;
let db: Firestore;

before(() => {
  app = initializeApp({ projectId: projectIdFor('cascade-store') }, 'cascade-store');
  db = getFirestore(app);
});

after(async () => {
  await deleteApp(app);
});

beforeEach(async () => {
  await db.recursiveDelete(db.collection('stores'));
  await db.recursiveDelete(db.collection('users'));
});

test('지워진 점포의 예약이 모두 지워진다', async () => {
  await db.doc('stores/s1').set({ name: '점포' });
  await db.doc('stores/s1/reservations/r1').set({ writerId: 'u1' });
  await db.doc('stores/s1/reservations/r2').set({ writerId: 'u1' });
  // TTL이 점포 문서를 지운 뒤 트리거가 실행되는 순서를 재현한다
  await db.doc('stores/s1').delete();

  await deleteStoreSubcollections(db, db.doc('stores/s1'));

  const remaining = await db.collection('stores/s1/reservations').get();
  assert.equal(remaining.size, 0);
});

test('예약이 아닌 서브컬렉션도 지워진다', async () => {
  // 서브컬렉션을 이름으로 고르지 않는다는 전제. 예약만 지우도록 바뀌면 여기서 걸린다
  await db.doc('stores/s1/someFutureCollection/d1').set({ value: 1 });
  await db.doc('stores/s1').delete();

  await deleteStoreSubcollections(db, db.doc('stores/s1'));

  assert.deepEqual(await db.doc('stores/s1').listCollections(), []);
});

test('다른 점포의 예약은 남는다', async () => {
  await db.doc('stores/s1/reservations/r1').set({ writerId: 'u1' });
  await db.doc('stores/s2').set({ name: '다른 점포' });
  await db.doc('stores/s2/reservations/r2').set({ writerId: 'u1' });

  await deleteStoreSubcollections(db, db.doc('stores/s1'));

  const other = await db.collection('stores/s2/reservations').get();
  assert.deepEqual(
    other.docs.map((doc) => doc.id),
    ['r2'],
  );
  assert.equal((await db.doc('stores/s2').get()).exists, true);
});

test('멤버의 지워진 점포 항목만 지우고 다른 점포 항목은 남긴다', async () => {
  await db.doc('users/u1').set({
    storeById: { s1: { name: '점포', role: 'STAFF' }, s2: { name: '다른 점포', role: 'ADMIN' } },
  });

  await clearStoreEntries(db, 's1', ['u1']);

  assert.deepEqual(Object.keys((await db.doc('users/u1').get()).get('storeById')), ['s2']);
});

test('사용자 문서가 없거나 항목이 없어도 실패하지 않는다', async () => {
  // 정리된 삭제 계정과 이미 나간 멤버
  await db.doc('users/u2').set({ storeById: {} });

  await clearStoreEntries(db, 's1', ['missing', 'u2']);

  assert.equal((await db.doc('users/missing').get()).exists, false);
  assert.deepEqual((await db.doc('users/u2').get()).get('storeById'), {});
});
