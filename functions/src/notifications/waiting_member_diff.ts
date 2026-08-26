/**
 * 점포 문서의 `waitingMemberById` 변경분에서 "새로 추가된" 신청자 uid만 추출한다.
 *
 * 기존 키의 값만 바뀐 경우(역할 변경 등)나 키가 삭제된 경우(승인·거절)는
 * 신규 가입 신청이 아니므로 제외한다.
 */
export function collectNewWaitingUids(
  before: Record<string, unknown> | undefined,
  after: Record<string, unknown> | undefined,
): string[] {
  const beforeUids = new Set(Object.keys(before ?? {}));
  return Object.keys(after ?? {}).filter((uid) => !beforeUids.has(uid));
}
