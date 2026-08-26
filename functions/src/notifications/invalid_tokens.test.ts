import { test } from 'node:test';
import assert from 'node:assert/strict';
import type { BatchResponse } from 'firebase-admin/messaging';

import { invalidTokensFrom } from './invalid_tokens.js';

/** 테스트용 BatchResponse 조립 헬퍼 */
function batchResponse(codes: (string | null)[]): BatchResponse {
  return {
    successCount: codes.filter((c) => c === null).length,
    failureCount: codes.filter((c) => c !== null).length,
    responses: codes.map((code) =>
      code === null
        ? { success: true, messageId: 'ok' }
        : { success: false, error: { code, message: code } },
    ),
  } as unknown as BatchResponse;
}

test('폐기된 토큰만 반환한다', () => {
  const response = batchResponse([
    null,
    'messaging/registration-token-not-registered',
    null,
  ]);

  assert.deepEqual(invalidTokensFrom(response, ['t1', 't2', 't3']), ['t2']);
});

test('일시적 오류는 제거 대상이 아니다', () => {
  const response = batchResponse(['messaging/server-unavailable']);

  assert.deepEqual(invalidTokensFrom(response, ['t1']), []);
});

test('형식이 잘못된 토큰도 제거 대상이다', () => {
  const response = batchResponse([
    'messaging/invalid-registration-token',
    'messaging/invalid-argument',
  ]);

  assert.deepEqual(invalidTokensFrom(response, ['t1', 't2']), ['t1', 't2']);
});

test('모두 성공하면 빈 배열을 반환한다', () => {
  assert.deepEqual(invalidTokensFrom(batchResponse([null, null]), ['t1', 't2']), []);
});
