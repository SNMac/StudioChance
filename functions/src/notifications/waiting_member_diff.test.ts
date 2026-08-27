import { test } from 'node:test';
import assert from 'node:assert/strict';

import { collectNewWaitingUids } from './waiting_member_diff.js';

test('새로 추가된 uid만 반환한다', () => {
  const before = { userA: { role: 'STAFF' } };
  const after = { userA: { role: 'STAFF' }, userB: { role: 'VIEWER' } };

  assert.deepEqual(collectNewWaitingUids(before, after), ['userB']);
});

test('기존 uid의 값만 바뀌면 신규로 보지 않는다', () => {
  const before = { userA: { role: 'STAFF' } };
  const after = { userA: { role: 'VIEWER' } };

  assert.deepEqual(collectNewWaitingUids(before, after), []);
});

test('대기 멤버가 제거되기만 하면 빈 배열을 반환한다', () => {
  assert.deepEqual(collectNewWaitingUids({ userA: {} }, {}), []);
});

test('before가 없으면 after의 모든 uid가 신규다', () => {
  assert.deepEqual(collectNewWaitingUids(undefined, { userA: {} }), ['userA']);
});

test('before/after가 모두 없으면 빈 배열을 반환한다', () => {
  assert.deepEqual(collectNewWaitingUids(undefined, undefined), []);
});

test('여러 명이 동시에 추가되면 모두 반환한다', () => {
  const after = { userA: {}, userB: {}, userC: {} };

  assert.deepEqual(collectNewWaitingUids({ userA: {} }, after), ['userB', 'userC']);
});
