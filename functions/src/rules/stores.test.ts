import { after, before, beforeEach, test } from 'node:test';

import {
  assertFails,
  assertSucceeds,
  type RulesTestEnvironment,
} from '@firebase/rules-unit-testing';
import { deleteDoc, doc, getDoc, setDoc, updateDoc } from 'firebase/firestore';

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

// TODO(#13): Task 9에서 assertFails로 뒤집는다. 지금은 취약한 현 상태를 고정한다.
test('현행: 비멤버도 점포 문서를 읽을 수 있다 (이슈 #13의 취약점)', async () => {
  const db = env.authenticatedContext('outsider').firestore();
  await assertSucceeds(getDoc(doc(db, 'stores/s1')));
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
