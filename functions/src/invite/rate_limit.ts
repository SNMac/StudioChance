export const RATE_LIMIT_WINDOW_MIN = 10;
export const RATE_LIMIT_MAX_FAILURES = 10;

export type AttemptRecord = {
  count: number;
  windowStartAt: Date;
};

/**
 * 고정 창(fixed window) 방식으로 다음 상태를 계산한다.
 *
 * ponytail: 트랜잭션 없이 read → write로 쓰이므로 동시 요청이 한도를 약간
 * 넘길 수 있다. 정확한 쿼터가 아니라 브루트포스 비용 승수가 목적이라 허용한다.
 * 정밀한 제한이 필요해지면 Firestore 트랜잭션 또는 전용 rate limiter로 교체.
 */
export function nextAttemptState(
  record: AttemptRecord | null,
  now: Date,
): { blocked: boolean; next: AttemptRecord } {
  const windowExpired =
    record === null ||
    now.getTime() - record.windowStartAt.getTime() >
      RATE_LIMIT_WINDOW_MIN * 60 * 1000;

  if (windowExpired) {
    return { blocked: false, next: { count: 1, windowStartAt: now } };
  }

  if (record.count >= RATE_LIMIT_MAX_FAILURES) {
    return { blocked: true, next: record };
  }

  return {
    blocked: false,
    next: { count: record.count + 1, windowStartAt: record.windowStartAt },
  };
}
