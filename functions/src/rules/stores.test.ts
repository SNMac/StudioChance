import { after, before, beforeEach, test } from 'node:test';

import {
  assertFails,
  assertSucceeds,
  type RulesTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  collection,
  deleteDoc,
  doc,
  getDoc,
  getDocs,
  query,
  setDoc,
  updateDoc,
  where,
} from 'firebase/firestore';

import { createTestEnv } from './helpers.js';

let env: RulesTestEnvironment;

before(async () => {
  env = await createTestEnv('stores');
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

test('비멤버는 점포 문서를 읽지 못한다', async () => {
  const db = env.authenticatedContext('outsider').firestore();
  await assertFails(getDoc(doc(db, 'stores/s1')));
});

test('비멤버는 초대 코드로 stores를 쿼리하지 못한다 (#13 회귀 가드)', async () => {
  const db = env.authenticatedContext('outsider').firestore();
  await assertFails(
    getDocs(
      query(collection(db, 'stores'), where('inviteInfo.inviteCode', '==', 'AB3D9F')),
    ),
  );
});

test('대기 멤버(승인 전)는 점포 문서를 읽지 못한다', async () => {
  await env.withSecurityRulesDisabled(async (ctx) => {
    await setDoc(
      doc(ctx.firestore(), 'stores/s1'),
      { waitingMemberById: { pending1: { role: 'STAFF' } } },
      { merge: true },
    );
  });

  const db = env.authenticatedContext('pending1').firestore();
  await assertFails(getDoc(doc(db, 'stores/s1')));
});

test('ADMIN은 점포를 수정할 수 있다', async () => {
  const db = env.authenticatedContext('admin1').firestore();
  await assertSucceeds(updateDoc(doc(db, 'stores/s1'), { name: '새 이름' }));
});

test('STAFF는 점포를 수정하지 못한다', async () => {
  const db = env.authenticatedContext('staff1').firestore();
  await assertFails(updateDoc(doc(db, 'stores/s1'), { name: '새 이름' }));
});

test('ADMIN이 아니면 점포를 삭제하지 못한다', async () => {
  const db = env.authenticatedContext('staff1').firestore();
  await assertFails(deleteDoc(doc(db, 'stores/s1')));
});

test('비멤버는 waitingMemberById에 자기 항목을 추가할 수 있다 (가입 신청)', async () => {
  const db = env.authenticatedContext('applicant1').firestore();
  await assertSucceeds(
    updateDoc(doc(db, 'stores/s1'), {
      'waitingMemberById.applicant1': { role: 'STAFF' },
      updatedAt: new Date(),
    }),
  );
});

test('가입 신청자가 남의 항목을 추가하면 거부된다', async () => {
  const db = env.authenticatedContext('applicant1').firestore();
  await assertFails(
    updateDoc(doc(db, 'stores/s1'), {
      'waitingMemberById.someoneElse': { role: 'ADMIN' },
      updatedAt: new Date(),
    }),
  );
});

test('가입 신청과 함께 다른 필드를 바꾸면 거부된다', async () => {
  const db = env.authenticatedContext('applicant1').firestore();
  await assertFails(
    updateDoc(doc(db, 'stores/s1'), {
      'waitingMemberById.applicant1': { role: 'STAFF' },
      bankAccountNumber: '탈취',
      updatedAt: new Date(),
    }),
  );
});

test('생성자를 ADMIN으로 포함한 문서 생성은 성공한다', async () => {
  const db = env.authenticatedContext('creator1').firestore();
  await assertSucceeds(
    setDoc(doc(collection(db, 'stores')), {
      name: '새 점포',
      memberById: { creator1: { role: 'ADMIN' } },
    }),
  );
});

test('memberById에 자신이 없으면 점포 생성이 거부된다', async () => {
  const db = env.authenticatedContext('creator1').firestore();
  await assertFails(
    setDoc(doc(collection(db, 'stores')), {
      name: '새 점포',
      memberById: { someoneElse: { role: 'ADMIN' } },
    }),
  );
});

test('자신이 있지만 role이 ADMIN이 아니면 점포 생성이 거부된다', async () => {
  const db = env.authenticatedContext('creator1').firestore();
  await assertFails(
    setDoc(doc(collection(db, 'stores')), {
      name: '새 점포',
      memberById: { creator1: { role: 'STAFF' } },
    }),
  );
});

test('memberById 필드가 없으면 점포 생성이 거부된다', async () => {
  const db = env.authenticatedContext('creator1').firestore();
  await assertFails(
    setDoc(doc(collection(db, 'stores')), { name: '새 점포' }),
  );
});
