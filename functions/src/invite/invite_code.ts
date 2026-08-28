/** 클라이언트의 lib/constants/data_constants.dart storeInviteCodeAvailableMin과 일치해야 한다 */
export const INVITE_CODE_AVAILABLE_MIN = 15;

/**
 * 발급 시 사용하는 문자 집합은 혼동하기 쉬운 I/O/0/1을 뺀 32자다
 * (StoreFirestoreDataSource._generateRandomCode). 검증은 그보다 느슨하게
 * 대문자·숫자 6자만 확인한다 — 집합을 좁히면 발급 규칙이 바뀔 때 함께 깨진다.
 */
const CODE_PATTERN = /^[A-Z0-9]{6}$/;

export function isValidInviteCode(code: unknown): code is string {
  return typeof code === 'string' && CODE_PATTERN.test(code);
}

export function isInviteExpired(createdAt: Date, now: Date): boolean {
  const expiresAt = createdAt.getTime() + INVITE_CODE_AVAILABLE_MIN * 60 * 1000;
  return now.getTime() > expiresAt;
}
