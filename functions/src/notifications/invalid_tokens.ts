import type { BatchResponse } from 'firebase-admin/messaging';

/**
 * 다시 사용할 수 없는 토큰을 나타내는 에러 코드.
 * 네트워크 오류·서버 일시 장애는 재시도 가능하므로 포함하지 않는다.
 *
 * `messaging/invalid-argument`는 토큰 자체가 아니라 메시지 전체에 대한
 * 범용 "잘못된 인자" 코드다. `android.notification.channelId` 같은 공유
 * 필드가 잘못되면 배치의 모든 메시지가 이 코드로 실패할 수 있어, 포함할 경우
 * 관리자 전원의 정상 토큰이 한 번에 삭제될 위험이 있다. 죽은 토큰을 남겨두는
 * 비용(발송 1회 낭비)이 산 토큰을 지우는 비용(재로그인 전까지 알림 두절)보다
 * 훨씬 작으므로 제외한다.
 */
const UNUSABLE_TOKEN_CODES = new Set([
  'messaging/registration-token-not-registered',
  'messaging/invalid-registration-token',
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
