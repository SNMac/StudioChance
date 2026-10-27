import { after, before, beforeEach, test } from 'node:test';

import {
  assertFails,
  assertSucceeds,
  type RulesTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  collection,
  deleteDoc,
  deleteField,
  doc,
  getDoc,
  getDocs,
  query,
  serverTimestamp,
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

test('승인 대기자는 점포 문서를 읽지 못한다', async () => {
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

// ─── 초대 코드(inviteInfo): 발급은 issueInviteCode(Admin SDK)만 한다 (ADR-0006) ───

async function seedInviteInfo() {
  await env.withSecurityRulesDisabled(async (ctx) => {
    await updateDoc(doc(ctx.firestore(), 'stores/s1'), {
      inviteInfo: { inviteCode: 'AB3D9F', createdAt: new Date() },
    });
  });
}

test('ADMIN도 inviteInfo에 미래 발급 시각을 쓰지 못한다 (#49)', async () => {
  const db = env.authenticatedContext('admin1').firestore();
  await assertFails(
    updateDoc(doc(db, 'stores/s1'), {
      inviteInfo: { inviteCode: 'AB3D9F', createdAt: new Date(2099, 0, 1) },
    }),
  );
});

test('ADMIN도 inviteInfo를 직접 발급하지 못한다', async () => {
  const db = env.authenticatedContext('admin1').firestore();
  await assertFails(
    updateDoc(doc(db, 'stores/s1'), {
      inviteInfo: { inviteCode: 'AB3D9F', createdAt: serverTimestamp() },
    }),
  );
});

test('ADMIN은 inviteInfo가 있는 점포의 다른 필드를 수정할 수 있다', async () => {
  await seedInviteInfo();
  const db = env.authenticatedContext('admin1').firestore();
  await assertSucceeds(updateDoc(doc(db, 'stores/s1'), { name: '새 이름' }));
});

// store_data_source.dart의 softDeleteStore와 같은 쓰기 모양
test('softDeleteStore 쓰기 모양으로 ADMIN이 점포를 삭제할 수 있다', async () => {
  await seedInviteInfo();
  const db = env.authenticatedContext('admin1').firestore();
  await assertSucceeds(
    updateDoc(doc(db, 'stores/s1'), {
      deletedAt: serverTimestamp(),
      expiresAt: serverTimestamp(),
      updatedAt: serverTimestamp(),
      inviteInfo: null,
    }),
  );
});

test('inviteInfo를 넣어 점포를 만들면 거부된다', async () => {
  const db = env.authenticatedContext('creator1').firestore();
  await assertFails(
    setDoc(doc(collection(db, 'stores')), {
      name: '새 점포',
      memberById: { creator1: { role: 'ADMIN' } },
      inviteInfo: { inviteCode: 'AB3D9F', createdAt: new Date(2099, 0, 1) },
    }),
  );
});

// createStore는 inviteInfo를 null로 저장한다
test('inviteInfo가 null이면 점포를 만들 수 있다', async () => {
  const db = env.authenticatedContext('creator1').firestore();
  await assertSucceeds(
    setDoc(doc(collection(db, 'stores')), {
      name: '새 점포',
      memberById: { creator1: { role: 'ADMIN' } },
      inviteInfo: null,
    }),
  );
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

test('타인을 함께 멤버로 넣으면 역할과 무관하게 거부된다', async () => {
  const db = env.authenticatedContext('creator1').firestore();
  await assertFails(
    setDoc(doc(collection(db, 'stores')), {
      name: '새 점포',
      memberById: {
        creator1: { role: 'ADMIN' },
        other: { role: 'STAFF' },
      },
    }),
  );
  await assertFails(
    setDoc(doc(collection(db, 'stores')), {
      name: '새 점포',
      memberById: {
        creator1: { role: 'ADMIN' },
        other: { role: 'ADMIN' },
      },
    }),
  );
});

test('비로그인 사용자는 점포를 만들지 못한다', async () => {
  const db = env.unauthenticatedContext().firestore();
  await assertFails(
    setDoc(doc(collection(db, 'stores')), {
      name: '새 점포',
      memberById: { creator1: { role: 'ADMIN' } },
    }),
  );
});

// ─── 관리자 1명 불변식 (ADR-0004) ─────────────────────────────────────

async function seedWaiting(uid: string, role: string): Promise<void> {
  await env.withSecurityRulesDisabled(async (ctx) => {
    await updateDoc(doc(ctx.firestore(), 'stores/s1'), {
      [`waitingMemberById.${uid}`]: { role },
    });
  });
}

test('ADMIN은 승인 대기자를 STAFF로 승인할 수 있다', async () => {
  await seedWaiting('pending1', 'STAFF');
  const db = env.authenticatedContext('admin1').firestore();
  await assertSucceeds(
    updateDoc(doc(db, 'stores/s1'), {
      'waitingMemberById.pending1': deleteField(),
      'memberById.pending1': { role: 'STAFF' },
      updatedAt: new Date(),
    }),
  );
});

test('ADMIN으로 승인하면 관리자가 2명이 되어 거부된다', async () => {
  await seedWaiting('pending1', 'STAFF');
  const db = env.authenticatedContext('admin1').firestore();
  await assertFails(
    updateDoc(doc(db, 'stores/s1'), {
      'waitingMemberById.pending1': deleteField(),
      'memberById.pending1': { role: 'ADMIN' },
      updatedAt: new Date(),
    }),
  );
});

test('다른 멤버를 ADMIN으로 올리면 거부된다', async () => {
  const db = env.authenticatedContext('admin1').firestore();
  await assertFails(
    updateDoc(doc(db, 'stores/s1'), { 'memberById.staff1.role': 'ADMIN' }),
  );
});

test('관리자가 자신을 강등하면 관리자가 없어져 거부된다', async () => {
  const db = env.authenticatedContext('admin1').firestore();
  await assertFails(
    updateDoc(doc(db, 'stores/s1'), { 'memberById.admin1.role': 'STAFF' }),
  );
});

test('관리자가 자신을 추방하면 거부된다', async () => {
  const db = env.authenticatedContext('admin1').firestore();
  await assertFails(
    updateDoc(doc(db, 'stores/s1'), { 'memberById.admin1': deleteField() }),
  );
});

test('관리자는 다른 멤버를 추방할 수 있다', async () => {
  const db = env.authenticatedContext('admin1').firestore();
  await assertSucceeds(
    updateDoc(doc(db, 'stores/s1'), { 'memberById.staff1': deleteField() }),
  );
});

test('관리자는 스태프 역할을 뷰어로 바꿀 수 있다', async () => {
  const db = env.authenticatedContext('admin1').firestore();
  await assertSucceeds(
    updateDoc(doc(db, 'stores/s1'), { 'memberById.staff1.role': 'VIEWER' }),
  );
});

test('관리자 위임: 자신을 STAFF로, 대상을 ADMIN으로 한 번에 바꾸면 성공한다', async () => {
  const db = env.authenticatedContext('admin1').firestore();
  await assertSucceeds(
    updateDoc(doc(db, 'stores/s1'), {
      'memberById.admin1.role': 'STAFF',
      'memberById.staff1.role': 'ADMIN',
      updatedAt: new Date(),
    }),
  );
});

test('위임 후 이전 관리자는 더 이상 점포를 수정하지 못한다', async () => {
  const adminDb = env.authenticatedContext('admin1').firestore();
  await assertSucceeds(
    updateDoc(doc(adminDb, 'stores/s1'), {
      'memberById.admin1.role': 'VIEWER',
      'memberById.staff1.role': 'ADMIN',
    }),
  );
  await assertFails(updateDoc(doc(adminDb, 'stores/s1'), { name: '새 이름' }));

  const newAdminDb = env.authenticatedContext('staff1').firestore();
  await assertSucceeds(updateDoc(doc(newAdminDb, 'stores/s1'), { name: '새 이름' }));
});

test('관리자 수 판정은 멤버 값이 {role} 하나라는 전제에 기댄다 (ADR-0004 전제 고정)', async () => {
  // 값에 필드가 늘면 {'role': 'ADMIN'}과 일치하지 않아 관리자 0명으로 세진다.
  // 이 테스트가 깨지면 Rules의 관리자 수 식을 함께 고쳐야 한다
  await env.withSecurityRulesDisabled(async (ctx) => {
    await updateDoc(doc(ctx.firestore(), 'stores/s1'), {
      'memberById.admin1': { role: 'ADMIN', joinedAt: new Date() },
    });
  });
  const db = env.authenticatedContext('admin1').firestore();
  await assertFails(updateDoc(doc(db, 'stores/s1'), { name: '새 이름' }));
});

// ─── 가입 신청·신청 취소 ──────────────────────────────────────────────

test('ADMIN 역할로 가입 신청하면 거부된다', async () => {
  const db = env.authenticatedContext('applicant1').firestore();
  await assertFails(
    updateDoc(doc(db, 'stores/s1'), {
      'waitingMemberById.applicant1': { role: 'ADMIN' },
      updatedAt: new Date(),
    }),
  );
});

test('이미 멤버인 사람은 가입 신청을 추가하지 못한다', async () => {
  const db = env.authenticatedContext('staff1').firestore();
  await assertFails(
    updateDoc(doc(db, 'stores/s1'), {
      'waitingMemberById.staff1': { role: 'VIEWER' },
      updatedAt: new Date(),
    }),
  );
});

test('승인 대기자는 자기 가입 신청을 취소할 수 있다', async () => {
  await seedWaiting('pending1', 'STAFF');
  const db = env.authenticatedContext('pending1').firestore();
  await assertSucceeds(
    updateDoc(doc(db, 'stores/s1'), {
      'waitingMemberById.pending1': deleteField(),
      updatedAt: new Date(),
    }),
  );
});

test('남의 가입 신청은 취소하지 못한다', async () => {
  await seedWaiting('pending1', 'STAFF');
  const db = env.authenticatedContext('pending2').firestore();
  await assertFails(
    updateDoc(doc(db, 'stores/s1'), {
      'waitingMemberById.pending1': deleteField(),
      updatedAt: new Date(),
    }),
  );
});

// ─── 점포 나가기 ──────────────────────────────────────────────────────

test('스태프는 점포를 나갈 수 있다', async () => {
  const db = env.authenticatedContext('staff1').firestore();
  await assertSucceeds(
    updateDoc(doc(db, 'stores/s1'), {
      'memberById.staff1': deleteField(),
      updatedAt: new Date(),
    }),
  );
});

test('뷰어는 점포를 나갈 수 있다', async () => {
  const db = env.authenticatedContext('viewer1').firestore();
  await assertSucceeds(
    updateDoc(doc(db, 'stores/s1'), { 'memberById.viewer1': deleteField() }),
  );
});

test('멤버는 다른 멤버를 내보내지 못한다', async () => {
  const db = env.authenticatedContext('staff1').firestore();
  await assertFails(
    updateDoc(doc(db, 'stores/s1'), { 'memberById.viewer1': deleteField() }),
  );
});

test('나가면서 다른 필드를 바꾸면 거부된다', async () => {
  const db = env.authenticatedContext('staff1').firestore();
  await assertFails(
    updateDoc(doc(db, 'stores/s1'), {
      'memberById.staff1': deleteField(),
      name: '탈취',
    }),
  );
});

test('멤버는 나가기 규칙으로 자기 역할을 바꾸지 못한다', async () => {
  const db = env.authenticatedContext('staff1').firestore();
  await assertFails(
    updateDoc(doc(db, 'stores/s1'), { 'memberById.staff1.role': 'ADMIN' }),
  );
});

// 앱의 나가기·신청 취소는 removeMember의 쓰기 모양을 그대로 쓴다
// (memberById·waitingMemberById의 본인 키를 함께 삭제). 없는 키 삭제는 맵을 바꾸지
// 않으므로 각 본인 규칙을 통과해야 한다 — store_data_source.dart의 removeMember 참고
test('removeMember 쓰기 모양으로 스태프가 나갈 수 있다', async () => {
  const db = env.authenticatedContext('staff1').firestore();
  await assertSucceeds(
    updateDoc(doc(db, 'stores/s1'), {
      'memberById.staff1': deleteField(),
      'waitingMemberById.staff1': deleteField(),
      updatedAt: new Date(),
    }),
  );
});

test('removeMember 쓰기 모양으로 승인 대기자가 신청을 취소할 수 있다', async () => {
  await seedWaiting('pending1', 'STAFF');
  const db = env.authenticatedContext('pending1').firestore();
  await assertSucceeds(
    updateDoc(doc(db, 'stores/s1'), {
      'memberById.pending1': deleteField(),
      'waitingMemberById.pending1': deleteField(),
      updatedAt: new Date(),
    }),
  );
});
