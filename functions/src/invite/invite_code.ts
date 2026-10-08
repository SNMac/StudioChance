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

/**
 * 점포 문서를 조회 결과로 판정한다. Firestore 타입(Timestamp)에 의존하지
 * 않아야 순수 함수로 테스트할 수 있으므로 Date와 원시 타입만 받는다.
 */
export function evaluateInviteStore(input: {
  deletedAt: unknown;
  inviteCreatedAt: Date | null;
  now: Date;
}): { ok: true } | { ok: false; reason: 'notFound' | 'expired' } {
  // deletedAt은 softDeleteStore에서만 기록되며, 그 경로는 inviteInfo도 함께
  // null로 만든다. 그래도 방어적으로 확인한다.
  if (input.deletedAt) return { ok: false, reason: 'notFound' };

  // 코드가 있는데 발급 시각이 없는 문서 — 만료 판정이 불가능하므로 없는 것으로 본다
  if (!input.inviteCreatedAt) return { ok: false, reason: 'notFound' };

  if (isInviteExpired(input.inviteCreatedAt, input.now)) {
    return { ok: false, reason: 'expired' };
  }

  return { ok: true };
}

/** memberById에서 ADMIN 한 명의 uid를 고른다. 없으면 null */
export function adminUidOf(memberById: unknown): string | null {
  if (typeof memberById !== 'object' || memberById === null) return null;

  const entry = Object.entries(
    memberById as Record<string, { role?: string }>,
  ).find(([, member]) => member?.role === 'ADMIN');
  return entry?.[0] ?? null;
}

/**
 * 표시 이름. nickname을 우선하되 빈 문자열은 없는 것으로 본다.
 * nickname을 우선하는 것은 앱의 다른 멤버 표시 경로와 같은 규칙이다
 * (pending_member_modal, 가입 신청 푸시 알림).
 */
export function displayNameOf(nickname: unknown, name: unknown): string {
  const nick = typeof nickname === 'string' ? nickname : '';
  const nm = typeof name === 'string' ? name : '';
  return nick || nm;
}
