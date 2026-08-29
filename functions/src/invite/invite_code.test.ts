import assert from 'node:assert/strict';
import { test } from 'node:test';

import {
  adminUidOf,
  displayNameOf,
  evaluateInviteStore,
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
