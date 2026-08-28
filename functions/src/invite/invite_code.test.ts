import assert from 'node:assert/strict';
import { test } from 'node:test';

import {
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
