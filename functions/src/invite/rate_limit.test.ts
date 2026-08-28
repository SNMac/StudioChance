import assert from 'node:assert/strict';
import { test } from 'node:test';

import {
  RATE_LIMIT_MAX_FAILURES,
  RATE_LIMIT_WINDOW_MIN,
  nextAttemptState,
} from './rate_limit.js';

const NOW = new Date('2026-08-29T12:00:00Z');

test('기록이 없으면 통과하고 카운트 1로 시작한다', () => {
  const result = nextAttemptState(null, NOW);
  assert.equal(result.blocked, false);
  assert.equal(result.next.count, 1);
  assert.deepEqual(result.next.windowStartAt, NOW);
});

test('창 안에서 한도 미만이면 통과하고 카운트가 증가한다', () => {
  const result = nextAttemptState({ count: 3, windowStartAt: NOW }, NOW);
  assert.equal(result.blocked, false);
  assert.equal(result.next.count, 4);
});

test('창 안에서 한도에 도달하면 차단한다', () => {
  const result = nextAttemptState(
    { count: RATE_LIMIT_MAX_FAILURES, windowStartAt: NOW },
    NOW,
  );
  assert.equal(result.blocked, true);
});

test('창이 지나면 카운트가 초기화된다', () => {
  const stale = new Date(NOW.getTime() - (RATE_LIMIT_WINDOW_MIN + 1) * 60000);
  const result = nextAttemptState(
    { count: RATE_LIMIT_MAX_FAILURES, windowStartAt: stale },
    NOW,
  );
  assert.equal(result.blocked, false);
  assert.equal(result.next.count, 1);
  assert.deepEqual(result.next.windowStartAt, NOW);
});
