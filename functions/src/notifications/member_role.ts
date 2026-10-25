/**
 * 점포 멤버 역할. Dart `UserRole`의 `@JsonValue` 값과 같다
 * (계약 테스트 `contract/shared_constants.test.ts`가 검사한다).
 */
export type Role = 'ADMIN' | 'STAFF' | 'VIEWER';

/** 점포 문서 `memberById`·`waitingMemberById`의 값 */
export type MemberInfo = { role?: Role };

/**
 * Dart `UserRole.displayName`과 같은 표시 이름
 * (계약 테스트 `contract/shared_constants.test.ts`가 검사한다).
 */
export const ROLE_DISPLAY_NAMES: Record<Role, string> = {
  ADMIN: '관리자',
  STAFF: '스태프',
  VIEWER: '뷰어',
};

export function isAdmin(info: MemberInfo | undefined): boolean {
  return info?.role === 'ADMIN';
}
