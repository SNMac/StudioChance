import type { BatchResponse } from 'firebase-admin/messaging';

/**
 * 다시 사용할 수 없는 토큰을 나타내는 에러 코드.
 * 네트워크 오류·서버 일시 장애는 재시도 가능하므로 포함하지 않는다.
 */
const UNUSABLE_TOKEN_CODES = new Set([
  'messaging/registration-token-not-registered',
  'messaging/invalid-registration-token',
  'messaging/invalid-argument',
]);

/**
 * 전송 결과에서 `users/{uid}.fcmTokens`에서 제거해야 할 토큰만 골라낸다.
 *
 * `response.responses`의 순서는 입력 `tokens`의 순서와 1:1 대응한다.
 */
export function invalidTokensFrom(
  response: BatchResponse,
  tokens: string[],
): string[] {
  const invalid: string[] = [];
  response.responses.forEach((result, index) => {
    if (result.success) return;
    if (UNUSABLE_TOKEN_CODES.has(result.error?.code ?? '')) {
      invalid.push(tokens[index]);
    }
  });
  return invalid;
}
