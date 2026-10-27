import { HttpsError, onCall } from 'firebase-functions/v2/https';

/**
 * 서버의 현재 시각. 앱이 초대 코드의 남은 유효 시간을 서버 시각 기준으로 보여 주려고
 * 기기 시계와의 차이를 구할 때 쓴다 (ADR-0006).
 *
 * 만료 판정은 issueInviteCode·lookupInviteCode가 서버에서 하므로 이 값은 표시용이다.
 * 실패해도 앱은 기기 시계로 표시한다.
 */
export const getServerTime = onCall<void, { nowMillis: number }>(
  {
    region: 'asia-northeast3',
    enforceAppCheck: true,
  },
  (request) => {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', '로그인이 필요합니다.');
    }
    return { nowMillis: Date.now() };
  },
);
