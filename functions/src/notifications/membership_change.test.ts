import { test } from 'node:test';
import assert from 'node:assert/strict';

import { ANDROID_CHANNEL_ID } from './token_message.js';
import {
  ADMIN_DELEGATED_TYPE,
  JOIN_APPROVED_TYPE,
  JOIN_REJECTED_TYPE,
  MEMBER_LEFT_TYPE,
  MEMBER_REMOVED_TYPE,
  STORE_DELETED_TYPE,
  STORE_RESTORED_TYPE,
  buildMembershipMessages,
  buildMembershipNotification,
  classifyMembershipChanges,
  classifyStoreRemoval,
  type StoreSnapshot,
} from './membership_change.js';

const base: StoreSnapshot = {
  memberById: {
    admin1: { role: 'ADMIN' },
    staff1: { role: 'STAFF' },
    viewer1: { role: 'VIEWER' },
  },
  waitingMemberById: {
    pending1: { role: 'STAFF' },
  },
};

function withMembers(
  memberById: StoreSnapshot['memberById'],
  waitingMemberById: StoreSnapshot['waitingMemberById'] = base.waitingMemberById,
): StoreSnapshot {
  return { memberById, waitingMemberById };
}

test('멤버 구성이 그대로면 아무 사건도 없다', () => {
  assert.deepEqual(classifyMembershipChanges(base, { ...base }, 'admin1'), []);
});

test('관리자 위임은 새 관리자에게 이전 관리자 이름으로 알린다', () => {
  const after = withMembers({
    admin1: { role: 'STAFF' },
    staff1: { role: 'ADMIN' },
    viewer1: { role: 'VIEWER' },
  });

  assert.deepEqual(classifyMembershipChanges(base, after, 'admin1'), [
    { type: ADMIN_DELEGATED_TYPE, recipientUids: ['staff1'], subjectUid: 'admin1' },
  ]);
});

test('멤버가 스스로 키를 지우면 나가기로 관리자에게 알린다', () => {
  const after = withMembers({
    admin1: { role: 'ADMIN' },
    viewer1: { role: 'VIEWER' },
  });

  assert.deepEqual(classifyMembershipChanges(base, after, 'staff1'), [
    { type: MEMBER_LEFT_TYPE, recipientUids: ['admin1'], subjectUid: 'staff1' },
  ]);
});

test('다른 사람이 멤버 키를 지우면 추방으로 추방된 사람에게 알린다', () => {
  const after = withMembers({
    admin1: { role: 'ADMIN' },
    viewer1: { role: 'VIEWER' },
  });

  assert.deepEqual(classifyMembershipChanges(base, after, 'admin1'), [
    { type: MEMBER_REMOVED_TYPE, recipientUids: ['staff1'] },
  ]);
});

test('쓴 사람을 알 수 없으면(Admin SDK) 멤버 키 삭제를 추방으로 본다', () => {
  const after = withMembers({
    admin1: { role: 'ADMIN' },
    viewer1: { role: 'VIEWER' },
  });

  assert.deepEqual(classifyMembershipChanges(base, after, undefined), [
    { type: MEMBER_REMOVED_TYPE, recipientUids: ['staff1'] },
  ]);
});

test('대기 명단에서 멤버로 옮겨지면 승인으로 역할과 함께 신청자에게 알린다', () => {
  const after = withMembers(
    { ...base.memberById, pending1: { role: 'VIEWER' } },
    {},
  );

  assert.deepEqual(classifyMembershipChanges(base, after, 'admin1'), [
    { type: JOIN_APPROVED_TYPE, recipientUids: ['pending1'], role: 'VIEWER' },
  ]);
});

test('관리자가 대기 명단에서 지우면 거절로 신청자에게 알린다', () => {
  const after = withMembers(base.memberById, {});

  assert.deepEqual(classifyMembershipChanges(base, after, 'admin1'), [
    { type: JOIN_REJECTED_TYPE, recipientUids: ['pending1'] },
  ]);
});

test('신청자가 스스로 대기 명단에서 지우면(신청 취소) 알리지 않는다', () => {
  const after = withMembers(base.memberById, {});

  assert.deepEqual(classifyMembershipChanges(base, after, 'pending1'), []);
});

test('새 가입 신청은 이 함수의 사건이 아니다 (가입 신청 알림이 담당)', () => {
  const after = withMembers(base.memberById, {
    ...base.waitingMemberById,
    pending2: { role: 'STAFF' },
  });

  assert.deepEqual(classifyMembershipChanges(base, after, 'pending2'), []);
});

test('관리자가 없는 점포에서 멤버가 나가면 받을 사람이 없어 사건을 버린다', () => {
  const before = withMembers({ staff1: { role: 'STAFF' } }, {});
  const after = withMembers({}, {});

  assert.deepEqual(classifyMembershipChanges(before, after, 'staff1'), []);
});

test('점포 삭제는 삭제한 사람을 뺀 멤버에게 삭제 예정을, 승인 대기자에게 신청 취소를 알린다', () => {
  // 점포 삭제는 같은 쓰기에서 승인 대기 명단을 비운다 (ADR-0007)
  const after: StoreSnapshot = { ...base, waitingMemberById: {}, deletedAt: new Date() };

  assert.deepEqual(classifyMembershipChanges(base, after, 'admin1'), [
    { type: STORE_DELETED_TYPE, recipientUids: ['staff1', 'viewer1'], deletion: 'scheduled' },
    { type: STORE_DELETED_TYPE, recipientUids: ['pending1'], deletion: 'applicationCanceled' },
  ]);
});

test('점포 삭제와 멤버 변화가 한 쓰기에 섞이면 삭제 알림만 보낸다', () => {
  // 삭제 경로가 멤버 목록까지 비우게 바뀌어도 추방·거절 알림이 섞여 나가지 않아야 한다
  const after: StoreSnapshot = {
    memberById: { admin1: { role: 'ADMIN' } },
    waitingMemberById: {},
    deletedAt: new Date(),
  };

  assert.deepEqual(classifyMembershipChanges(base, after, 'admin1'), [
    { type: STORE_DELETED_TYPE, recipientUids: ['staff1', 'viewer1'], deletion: 'scheduled' },
    { type: STORE_DELETED_TYPE, recipientUids: ['pending1'], deletion: 'applicationCanceled' },
  ]);
});

test('혼자 쓰는 점포를 삭제하면 승인 대기자에게만 알린다', () => {
  const before = withMembers({ admin1: { role: 'ADMIN' } });
  const after: StoreSnapshot = { ...before, waitingMemberById: {}, deletedAt: new Date() };

  assert.deepEqual(classifyMembershipChanges(before, after, 'admin1'), [
    { type: STORE_DELETED_TYPE, recipientUids: ['pending1'], deletion: 'applicationCanceled' },
  ]);
});

test('점포 복구는 복구한 사람을 뺀 멤버에게 알린다', () => {
  const before: StoreSnapshot = { ...base, waitingMemberById: {}, deletedAt: new Date() };
  const after: StoreSnapshot = { ...base, waitingMemberById: {} };

  assert.deepEqual(classifyMembershipChanges(before, after, 'admin1'), [
    { type: STORE_RESTORED_TYPE, recipientUids: ['staff1', 'viewer1'] },
  ]);
});

test('삭제 예정 점포에서 멤버가 나가면 관리자에게 알린다', () => {
  const before: StoreSnapshot = { ...base, deletedAt: new Date() };
  const after: StoreSnapshot = {
    ...before,
    memberById: { admin1: { role: 'ADMIN' }, viewer1: { role: 'VIEWER' } },
  };

  assert.deepEqual(classifyMembershipChanges(before, after, 'staff1'), [
    { type: MEMBER_LEFT_TYPE, recipientUids: ['admin1'], subjectUid: 'staff1' },
  ]);
});

const DAY_MS = 24 * 60 * 60 * 1000;

test('기한 전에 영구 삭제되면 관리자를 뺀 멤버에게 알린다', () => {
  const now = new Date();
  const removed: StoreSnapshot = {
    ...base,
    waitingMemberById: {},
    deletedAt: new Date(now.getTime() - 2 * DAY_MS),
  };

  assert.deepEqual(classifyStoreRemoval(removed, now), [
    { type: STORE_DELETED_TYPE, recipientUids: ['staff1', 'viewer1'], deletion: 'permanent' },
  ]);
});

test('기한이 지나 지워지면 다시 알리지 않는다', () => {
  const now = new Date();
  const removed: StoreSnapshot = { ...base, deletedAt: new Date(now.getTime() - 8 * DAY_MS) };

  assert.deepEqual(classifyStoreRemoval(removed, now), []);
});

test('삭제 예정을 거치지 않고 지워진 점포는 멤버와 승인 대기자에게 알린다', () => {
  // 계정 삭제가 혼자 쓰던 점포를 바로 지우는 경로. 이때 승인 대기 명단은 남아 있다
  const removed = withMembers({ admin1: { role: 'ADMIN' } });

  assert.deepEqual(classifyStoreRemoval(removed, new Date()), [
    { type: STORE_DELETED_TYPE, recipientUids: ['pending1'], deletion: 'applicationCanceled' },
  ]);
});

test('트리거가 넘겨주는 Timestamp 형태의 deletedAt도 읽는다', () => {
  const now = new Date();
  const deletedAt = new Date(now.getTime() - 8 * DAY_MS);
  const removed: StoreSnapshot = { ...base, deletedAt: { toDate: () => deletedAt } };

  assert.deepEqual(classifyStoreRemoval(removed, now), []);
});

test('이미 삭제된 점포의 이후 수정은 삭제로 다시 알리지 않는다', () => {
  const before: StoreSnapshot = { ...base, deletedAt: new Date() };
  const after: StoreSnapshot = { ...before };

  assert.deepEqual(classifyMembershipChanges(before, after, 'admin1'), []);
});

test('점포 삭제 문구는 갈래마다 다르다', () => {
  const titleOf = (deletion: 'scheduled' | 'applicationCanceled' | 'permanent') =>
    buildMembershipNotification(
      { type: STORE_DELETED_TYPE, recipientUids: ['staff1'], deletion },
      '스튜디오A',
      '',
    ).title;

  assert.equal(titleOf('scheduled'), '스튜디오A 점포가 7일 후 삭제됩니다');
  assert.equal(titleOf('applicationCanceled'), '스튜디오A 점포가 삭제되었습니다');
  assert.equal(titleOf('permanent'), '스튜디오A 점포가 삭제되었습니다');
});

test('사건별 문구에 점포명과 이름·역할이 들어간다', () => {
  assert.deepEqual(
    buildMembershipNotification(
      { type: ADMIN_DELEGATED_TYPE, recipientUids: ['staff1'], subjectUid: 'admin1' },
      '스튜디오A',
      '갑',
    ),
    {
      title: '스튜디오A 관리자가 되었습니다',
      body: '갑 님이 관리자 역할을 위임했습니다.',
    },
  );
  assert.deepEqual(
    buildMembershipNotification(
      { type: MEMBER_LEFT_TYPE, recipientUids: ['admin1'], subjectUid: 'staff1' },
      '스튜디오A',
      '을',
    ),
    {
      title: '스튜디오A에서 멤버가 나갔습니다',
      body: '을 님이 점포를 나갔습니다.',
    },
  );
  assert.equal(
    buildMembershipNotification(
      { type: JOIN_APPROVED_TYPE, recipientUids: ['pending1'], role: 'VIEWER' },
      '스튜디오A',
      '',
    ).body,
    '뷰어로 점포에 참여합니다.',
  );
});

test('메시지에 사건 type·storeId와 Android 채널이 담긴다', () => {
  const [message] = buildMembershipMessages({
    tokens: ['t1'],
    event: { type: MEMBER_REMOVED_TYPE, recipientUids: ['staff1'] },
    storeId: 'store1',
    storeName: '스튜디오A',
    subjectName: '',
  });

  assert.equal(message.token, 't1');
  assert.deepEqual(message.data, { type: MEMBER_REMOVED_TYPE, storeId: 'store1' });
  assert.equal(message.android?.notification?.channelId, ANDROID_CHANNEL_ID);
  assert.equal(message.notification?.title, '스튜디오A 멤버에서 제외되었습니다');
});
