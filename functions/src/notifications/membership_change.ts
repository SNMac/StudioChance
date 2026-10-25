import type { TokenMessage } from 'firebase-admin/messaging';

import { adminUidsOf } from './join_request_payload.js';
import { ROLE_DISPLAY_NAMES, isAdmin, type MemberInfo, type Role } from './member_role.js';
import { buildTokenMessage } from './token_message.js';

/**
 * 멤버 구성 변화 알림의 `data.type` 값.
 * Flutter `notification_constants.dart`의 같은 이름 상수와 동일해야 한다
 * (계약 테스트 `contract/shared_constants.test.ts`가 검사한다).
 */
export const ADMIN_DELEGATED_TYPE = 'adminDelegated';
export const MEMBER_LEFT_TYPE = 'memberLeft';
export const MEMBER_REMOVED_TYPE = 'memberRemoved';
export const JOIN_APPROVED_TYPE = 'joinApproved';
export const JOIN_REJECTED_TYPE = 'joinRejected';
export const STORE_DELETED_TYPE = 'storeDeleted';

export type MembershipEventType =
  | typeof ADMIN_DELEGATED_TYPE
  | typeof MEMBER_LEFT_TYPE
  | typeof MEMBER_REMOVED_TYPE
  | typeof JOIN_APPROVED_TYPE
  | typeof JOIN_REJECTED_TYPE
  | typeof STORE_DELETED_TYPE;

/**
 * 알림 하나로 이어지는 멤버 구성 변화.
 * - `recipientUids`: 알림을 받을 사용자
 * - `subjectUid`: 문구에 이름이 들어가는 사용자 (위임한 이전 관리자, 나간 멤버)
 * - `role`: 승인된 역할 (가입 승인만)
 */
export type MembershipEvent = {
  type: MembershipEventType;
  recipientUids: string[];
  subjectUid?: string;
  role?: Role;
};

/** 트리거가 넘겨주는 점포 문서 중 분류에 필요한 필드 */
export type StoreSnapshot = {
  memberById?: Record<string, MemberInfo>;
  waitingMemberById?: Record<string, MemberInfo>;
  deletedAt?: unknown;
};

/**
 * 점포 문서 변경 전후와 쓴 사람(`authId`)으로 멤버 구성 변화를 분류한다.
 *
 * | 사건 | 판정 | 수신자 |
 * |---|---|---|
 * | 점포 삭제 | `deletedAt`이 새로 생김 | 쓴 사람을 뺀 멤버·승인 대기자 |
 * | 관리자 위임 | 기존 멤버의 역할이 ADMIN이 됨 | 새 관리자 |
 * | 점포 나가기 | `memberById` 키 삭제, 쓴 사람 = 그 키 | 관리자 |
 * | 추방 | `memberById` 키 삭제, 쓴 사람 ≠ 그 키 | 추방된 사람 |
 * | 가입 승인 | `waitingMemberById`에서 빠지고 `memberById`에 생김 | 신청자 |
 * | 가입 거절 | `waitingMemberById`에서 빠지고 `memberById`에 없음, 쓴 사람 ≠ 그 키 | 신청자 |
 * | 신청 취소 | 위와 같고 쓴 사람 = 그 키 | (발송 안 함) |
 *
 * 점포 삭제는 다른 판정보다 우선한다. 같은 쓰기에 멤버 변화가 섞여도 추방·거절로
 * 해석하지 않고 삭제 알림 하나만 보낸다.
 *
 * 나가기·신청 취소는 앱이 본인 계정으로 직접 쓴다는 전제에 기댄다. Admin SDK처럼
 * `authId`가 없는 쓰기는 모두 관리자 행위(추방·거절)로 분류된다.
 */
export function classifyMembershipChanges(
  before: StoreSnapshot,
  after: StoreSnapshot,
  authId: string | undefined,
): MembershipEvent[] {
  const beforeMembers = before.memberById ?? {};
  const afterMembers = after.memberById ?? {};
  const beforeWaiting = before.waitingMemberById ?? {};
  const afterWaiting = after.waitingMemberById ?? {};

  if (before.deletedAt == null && after.deletedAt != null) {
    // 같은 쓰기에서 멤버 목록이 비워져도 삭제 직전 멤버까지 받도록 전후를 합친다
    const recipientUids = [
      ...new Set(
        [beforeMembers, beforeWaiting, afterMembers, afterWaiting].flatMap(Object.keys),
      ),
    ].filter((uid) => uid !== authId);
    return recipientUids.length === 0
      ? []
      : [{ type: STORE_DELETED_TYPE, recipientUids }];
  }

  const events: MembershipEvent[] = [];

  const previousAdminUid = adminUidsOf(beforeMembers).find(
    (uid) => !isAdmin(afterMembers[uid]),
  );
  for (const [uid, info] of Object.entries(afterMembers)) {
    const wasMember = uid in beforeMembers;
    if (wasMember && isAdmin(info) && !isAdmin(beforeMembers[uid])) {
      events.push({
        type: ADMIN_DELEGATED_TYPE,
        recipientUids: [uid],
        subjectUid: previousAdminUid ?? authId,
      });
    }
  }

  for (const uid of Object.keys(beforeMembers)) {
    if (uid in afterMembers) continue;
    if (uid === authId) {
      events.push({
        type: MEMBER_LEFT_TYPE,
        recipientUids: adminUidsOf(afterMembers),
        subjectUid: uid,
      });
    } else {
      events.push({ type: MEMBER_REMOVED_TYPE, recipientUids: [uid] });
    }
  }

  for (const uid of Object.keys(beforeWaiting)) {
    if (uid in afterWaiting) continue;
    if (uid in afterMembers && !(uid in beforeMembers)) {
      events.push({
        type: JOIN_APPROVED_TYPE,
        recipientUids: [uid],
        role: afterMembers[uid]?.role,
      });
    } else if (uid !== authId) {
      events.push({ type: JOIN_REJECTED_TYPE, recipientUids: [uid] });
    }
  }

  return events.filter((event) => event.recipientUids.length > 0);
}

/** 알림 제목·본문을 만든다. [subjectName]은 `subjectUid`의 표시 이름이다. */
export function buildMembershipNotification(
  event: MembershipEvent,
  storeName: string,
  subjectName: string,
): { title: string; body: string } {
  switch (event.type) {
    case ADMIN_DELEGATED_TYPE:
      return {
        title: `'${storeName}' 관리자가 되었습니다`,
        body: `${subjectName}님이 관리자 역할을 위임했습니다.`,
      };
    case MEMBER_LEFT_TYPE:
      return {
        title: `'${storeName}'에서 멤버가 나갔습니다`,
        body: `${subjectName}님이 점포를 나갔습니다.`,
      };
    case MEMBER_REMOVED_TYPE:
      return {
        title: `'${storeName}' 멤버에서 제외되었습니다`,
        body: '더 이상 이 점포의 예약을 볼 수 없습니다.',
      };
    case JOIN_APPROVED_TYPE:
      return {
        title: `'${storeName}' 가입이 승인되었습니다`,
        body: `${event.role ? ROLE_DISPLAY_NAMES[event.role] : '멤버'}로 점포에 참여합니다.`,
      };
    case JOIN_REJECTED_TYPE:
      return {
        title: `'${storeName}' 가입 신청이 거절되었습니다`,
        body: '초대 코드를 다시 받아 신청할 수 있습니다.',
      };
    case STORE_DELETED_TYPE:
      return {
        title: `'${storeName}' 점포가 삭제되었습니다`,
        body: '관리자가 점포를 삭제했습니다.',
      };
  }
}

/** 수신자 기기 토큰마다 알림 메시지를 만든다. 탭하면 앱이 마이페이지로 이동한다. */
export function buildMembershipMessages(params: {
  tokens: string[];
  event: MembershipEvent;
  storeId: string;
  storeName: string;
  subjectName: string;
}): TokenMessage[] {
  const notification = buildMembershipNotification(
    params.event,
    params.storeName,
    params.subjectName,
  );

  return params.tokens.map((token) =>
    buildTokenMessage(token, notification, {
      type: params.event.type,
      storeId: params.storeId,
    }),
  );
}
