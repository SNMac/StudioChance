import { randomInt } from 'node:crypto';

/**
 * 클라이언트의 lib/constants/data_constants.dart storeInviteCodeAvailableMin과 일치해야 한다
 * (계약 테스트 contract/shared_constants.test.ts가 검사한다)
 */
export const INVITE_CODE_AVAILABLE_MIN = 15;

/** 발급 문자 집합. 받아 적다 헷갈리기 쉬운 I/O/0/1을 뺀 32자다 */
const INVITE_CODE_CHARS = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
const INVITE_CODE_LENGTH = 6;

/**
 * 검증은 발급 문자 집합보다 느슨하게 대문자·숫자 6자만 확인한다
 * — 집합을 좁히면 발급 규칙이 바뀔 때 함께 깨진다.
 */
const CODE_PATTERN = /^[A-Z0-9]{6}$/;

/**
 * 새 초대 코드. [randomIndex]는 테스트에서 결과를 고정하기 위한 주입점이다.
 * 코드는 추측당하면 안 되므로 기본값은 암호학적 난수(`crypto.randomInt`)다.
 */
export function generateInviteCode(
  randomIndex: (max: number) => number = randomInt,
): string {
  let code = '';
  for (let i = 0; i < INVITE_CODE_LENGTH; i++) {
    code += INVITE_CODE_CHARS[randomIndex(INVITE_CODE_CHARS.length)];
  }
  return code;
}

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

/**
 * 발급 요청을 점포 문서로 판정한다. [evaluateInviteStore]처럼 Date와 원시 타입만 받는다.
 *
 * - 점포가 없으면 notFound, 호출자가 관리자가 아니면 permissionDenied.
 *   삭제한 점포는 관리자에게만 notFound를 준다 — 멤버가 아닌 사람에게 삭제 여부를 알리지 않는다
 * - 재발급이 아니고 유효한 코드가 남아 있으면 그 코드를 그대로 돌려준다(reuse).
 *   화면이 로컬 시계로 만료라고 본 코드라도 서버 기준으로 살아 있으면, 새로 만들어
 *   이미 공유한 코드를 관리자도 모르게 무효로 만드는 것보다 낫다
 */
export function decideInviteIssue(input: {
  uid: string;
  exists: boolean;
  deletedAt: unknown;
  memberById: unknown;
  inviteCode: unknown;
  inviteCreatedAt: Date | null;
  forceRegenerate: boolean;
  now: Date;
}):
  | { kind: 'reuse'; inviteCode: string; createdAt: Date }
  | { kind: 'issue' }
  | { kind: 'denied'; reason: 'notFound' | 'permissionDenied' } {
  if (!input.exists) return { kind: 'denied', reason: 'notFound' };
  if (!isAdminOf(input.memberById, input.uid)) {
    return { kind: 'denied', reason: 'permissionDenied' };
  }
  if (input.deletedAt) return { kind: 'denied', reason: 'notFound' };

  if (
    !input.forceRegenerate &&
    typeof input.inviteCode === 'string' &&
    input.inviteCreatedAt &&
    !isInviteExpired(input.inviteCreatedAt, input.now)
  ) {
    return { kind: 'reuse', inviteCode: input.inviteCode, createdAt: input.inviteCreatedAt };
  }

  return { kind: 'issue' };
}

function isAdminOf(memberById: unknown, uid: string): boolean {
  if (typeof memberById !== 'object' || memberById === null) return false;
  return (memberById as Record<string, { role?: string }>)[uid]?.role === 'ADMIN';
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
