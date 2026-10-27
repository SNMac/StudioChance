import assert from 'node:assert/strict';
import { test } from 'node:test';

import {
  adminUidOf,
  decideInviteIssue,
  displayNameOf,
  evaluateInviteStore,
  generateInviteCode,
  INVITE_CODE_AVAILABLE_MIN,
  isInviteExpired,
  isValidInviteCode,
} from './invite_code.js';

test('6자 대문자·숫자 코드는 유효하다', () => {
  assert.equal(isValidInviteCode('AB3D9F'), true);
});

test('길이가 다르면 무효하다', () => {
  assert.equal(isValidInviteCode('AB3D9'), false);
  assert.equal(isValidInviteCode('AB3D9FG'), false);
});

test('소문자와 특수문자는 무효하다', () => {
  assert.equal(isValidInviteCode('ab3d9f'), false);
  assert.equal(isValidInviteCode('AB3D-F'), false);
});

test('문자열이 아니면 무효하다', () => {
  assert.equal(isValidInviteCode(undefined), false);
  assert.equal(isValidInviteCode(123456), false);
});

test('유효 시간 직전은 만료가 아니다', () => {
  const createdAt = new Date('2026-08-29T00:00:00Z');
  const now = new Date(
    createdAt.getTime() + (INVITE_CODE_AVAILABLE_MIN * 60 - 1) * 1000,
  );
  assert.equal(isInviteExpired(createdAt, now), false);
});

test('정확히 유효 시간만큼 지난 시점은 만료가 아니다 (경계값)', () => {
  const createdAt = new Date('2026-08-29T00:00:00Z');
  const now = new Date(
    createdAt.getTime() + INVITE_CODE_AVAILABLE_MIN * 60 * 1000,
  );
  assert.equal(isInviteExpired(createdAt, now), false);
});

test('유효 시간이 지나면 만료다', () => {
  const createdAt = new Date('2026-08-29T00:00:00Z');
  const now = new Date(
    createdAt.getTime() + (INVITE_CODE_AVAILABLE_MIN * 60 + 1) * 1000,
  );
  assert.equal(isInviteExpired(createdAt, now), true);
});

test('evaluateInviteStore: 정상 케이스는 ok', () => {
  const now = new Date('2026-08-29T00:10:00Z');
  const result = evaluateInviteStore({
    deletedAt: undefined,
    inviteCreatedAt: new Date('2026-08-29T00:00:00Z'),
    now,
  });
  assert.deepEqual(result, { ok: true });
});

test('evaluateInviteStore: deletedAt이 있으면 notFound', () => {
  const now = new Date('2026-08-29T00:10:00Z');
  const result = evaluateInviteStore({
    deletedAt: new Date('2026-08-01T00:00:00Z'),
    inviteCreatedAt: new Date('2026-08-29T00:00:00Z'),
    now,
  });
  assert.deepEqual(result, { ok: false, reason: 'notFound' });
});

test('evaluateInviteStore: inviteCreatedAt이 null이면 notFound', () => {
  const now = new Date('2026-08-29T00:10:00Z');
  const result = evaluateInviteStore({
    deletedAt: undefined,
    inviteCreatedAt: null,
    now,
  });
  assert.deepEqual(result, { ok: false, reason: 'notFound' });
});

test('evaluateInviteStore: 만료됐으면 expired', () => {
  const createdAt = new Date('2026-08-29T00:00:00Z');
  const now = new Date(
    createdAt.getTime() + (INVITE_CODE_AVAILABLE_MIN * 60 + 1) * 1000,
  );
  const result = evaluateInviteStore({
    deletedAt: undefined,
    inviteCreatedAt: createdAt,
    now,
  });
  assert.deepEqual(result, { ok: false, reason: 'expired' });
});

test('adminUidOf: ADMIN이 있으면 그 uid를 반환한다', () => {
  const memberById = {
    'staff-1': { role: 'STAFF' },
    'admin-1': { role: 'ADMIN' },
  };
  assert.equal(adminUidOf(memberById), 'admin-1');
});

test('adminUidOf: ADMIN이 없으면 null', () => {
  const memberById = { 'staff-1': { role: 'STAFF' } };
  assert.equal(adminUidOf(memberById), null);
});

test('adminUidOf: memberById가 null이면 null', () => {
  assert.equal(adminUidOf(null), null);
});

test('adminUidOf: memberById가 객체가 아니면 null', () => {
  assert.equal(adminUidOf('not-an-object'), null);
  assert.equal(adminUidOf(undefined), null);
});

test('displayNameOf: nickname이 있으면 nickname을 반환한다', () => {
  assert.equal(displayNameOf('닉네임', '이름'), '닉네임');
});

test('displayNameOf: nickname이 빈 문자열이면 name으로 폴백한다', () => {
  assert.equal(displayNameOf('', '이름'), '이름');
});

test('displayNameOf: 둘 다 없으면 빈 문자열', () => {
  assert.equal(displayNameOf(undefined, undefined), '');
  assert.equal(displayNameOf('', ''), '');
});

test('generateInviteCode: 만든 코드는 조회 검증을 통과한다', () => {
  for (let i = 0; i < 100; i++) {
    assert.equal(isValidInviteCode(generateInviteCode()), true);
  }
});

test('generateInviteCode: 헷갈리기 쉬운 I·O·0·1을 쓰지 않는다', () => {
  // 문자 집합 전체를 한 번씩 뽑아 본다
  const all = Array.from({ length: 32 }, (_, i) => generateInviteCode(() => i)[0]).join('');
  assert.doesNotMatch(all, /[IO01]/);
  assert.equal(new Set(all).size, 32);
});

const issueBase = {
  uid: 'admin-1',
  exists: true,
  deletedAt: undefined,
  memberById: { 'admin-1': { role: 'ADMIN' }, 'staff-1': { role: 'STAFF' } },
  inviteCode: 'AB3D9F',
  inviteCreatedAt: new Date('2026-08-29T00:00:00Z'),
  forceRegenerate: false,
  now: new Date('2026-08-29T00:10:00Z'),
};

test('decideInviteIssue: 유효한 코드가 남아 있으면 그 코드를 돌려준다', () => {
  assert.deepEqual(decideInviteIssue(issueBase), {
    kind: 'reuse',
    inviteCode: 'AB3D9F',
    createdAt: issueBase.inviteCreatedAt,
  });
});

test('decideInviteIssue: 재발급이면 유효한 코드가 있어도 새로 만든다', () => {
  assert.deepEqual(decideInviteIssue({ ...issueBase, forceRegenerate: true }), {
    kind: 'issue',
  });
});

test('decideInviteIssue: 만료된 코드는 재사용하지 않는다', () => {
  const now = new Date(
    issueBase.inviteCreatedAt.getTime() + (INVITE_CODE_AVAILABLE_MIN * 60 + 1) * 1000,
  );
  assert.deepEqual(decideInviteIssue({ ...issueBase, now }), { kind: 'issue' });
});

test('decideInviteIssue: 코드가 없거나 발급 시각을 모르면 새로 만든다', () => {
  assert.deepEqual(decideInviteIssue({ ...issueBase, inviteCode: undefined }), {
    kind: 'issue',
  });
  assert.deepEqual(decideInviteIssue({ ...issueBase, inviteCreatedAt: null }), {
    kind: 'issue',
  });
});

test('decideInviteIssue: 관리자가 아니면 permissionDenied', () => {
  assert.deepEqual(decideInviteIssue({ ...issueBase, uid: 'staff-1' }), {
    kind: 'denied',
    reason: 'permissionDenied',
  });
  assert.deepEqual(decideInviteIssue({ ...issueBase, uid: 'stranger' }), {
    kind: 'denied',
    reason: 'permissionDenied',
  });
});

test('decideInviteIssue: 점포가 없으면 notFound', () => {
  assert.deepEqual(decideInviteIssue({ ...issueBase, exists: false, memberById: undefined }), {
    kind: 'denied',
    reason: 'notFound',
  });
});

test('decideInviteIssue: 삭제한 점포는 관리자에게 notFound, 그 밖의 사람에게는 permissionDenied', () => {
  const deleted = { ...issueBase, deletedAt: new Date('2026-08-28T00:00:00Z') };
  assert.deepEqual(decideInviteIssue(deleted), { kind: 'denied', reason: 'notFound' });
  assert.deepEqual(decideInviteIssue({ ...deleted, uid: 'stranger' }), {
    kind: 'denied',
    reason: 'permissionDenied',
  });
});
