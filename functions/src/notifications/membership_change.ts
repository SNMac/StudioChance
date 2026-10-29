import type { TokenMessage } from 'firebase-admin/messaging';

import { STORE_SOFT_DELETE_DAYS } from '../stores/store_deletion.js';
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
export const STORE_RESTORED_TYPE = 'storeRestored';

export type MembershipEventType =
  | typeof ADMIN_DELEGATED_TYPE
  | typeof MEMBER_LEFT_TYPE
  | typeof MEMBER_REMOVED_TYPE
  | typeof JOIN_APPROVED_TYPE
  | typeof JOIN_REJECTED_TYPE
  | typeof STORE_DELETED_TYPE
  | typeof STORE_RESTORED_TYPE;

/**
 * 점포 삭제 알림의 갈래. `data.type`은 모두 `storeDeleted`이고 문구만 다르다 (ADR-0007)
 * - `scheduled`: 점포 삭제로 삭제 예정 점포가 됨 (멤버)
 * - `applicationCanceled`: 점포가 삭제되어 가입 신청이 정리됨 (승인 대기자)
 * - `permanent`: 기한 전에 영구 삭제됨 (멤버)
 */
export type StoreDeletionKind = 'scheduled' | 'applicationCanceled' | 'permanent';

/**
 * 알림 하나로 이어지는 멤버 구성 변화.
 * - `recipientUids`: 알림을 받을 사용자
 * - `subjectUid`: 문구에 이름이 들어가는 사용자 (위임한 이전 관리자, 나간 멤버)
 * - `role`: 승인된 역할 (가입 승인만)
 * - `deletion`: 점포 삭제 알림의 갈래 (점포 삭제만)
 */
export type MembershipEvent = {
  type: MembershipEventType;
  recipientUids: string[];
  subjectUid?: string;
  role?: Role;
  deletion?: StoreDeletionKind;
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
 * | 점포 삭제 | `deletedAt`이 새로 생김 | 쓴 사람을 뺀 멤버 (`scheduled`), 승인 대기자 (`applicationCanceled`) |
 * | 점포 복구 | `deletedAt`이 사라짐 | 쓴 사람을 뺀 멤버 |
 * | 관리자 위임 | 기존 멤버의 역할이 ADMIN이 됨 | 새 관리자 |
 * | 점포 나가기 | `memberById` 키 삭제, 쓴 사람 = 그 키 | 관리자 |
 * | 추방 | `memberById` 키 삭제, 쓴 사람 ≠ 그 키 | 추방된 사람 |
 * | 가입 승인 | `waitingMemberById`에서 빠지고 `memberById`에 생김 | 신청자 |
 * | 가입 거절 | `waitingMemberById`에서 빠지고 `memberById`에 없음, 쓴 사람 ≠ 그 키 | 신청자 |
 * | 신청 취소 | 위와 같고 쓴 사람 = 그 키 | (발송 안 함) |
 *
 * 점포 삭제·복구는 다른 판정보다 우선한다. 점포 삭제는 승인 대기 신청을 같은 쓰기에서
 * 정리하지만 거절로 해석하지 않고 삭제 알림만 보낸다. 점포 문서가 지워질 때의 알림은
 * [classifyStoreRemoval]이 정한다.
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
    // 같은 쓰기에서 승인 대기 명단이 비워지므로 전후를 합친다
    const memberUids = uniqueUids(beforeMembers, afterMembers).filter((uid) => uid !== authId);
    const applicantUids = uniqueUids(beforeWaiting, afterWaiting).filter(
      (uid) => uid !== authId && !memberUids.includes(uid),
    );
    return nonEmpty([
      { type: STORE_DELETED_TYPE, recipientUids: memberUids, deletion: 'scheduled' },
      { type: STORE_DELETED_TYPE, recipientUids: applicantUids, deletion: 'applicationCanceled' },
    ]);
  }

  if (before.deletedAt != null && after.deletedAt == null) {
    return nonEmpty([
      {
        type: STORE_RESTORED_TYPE,
        recipientUids: Object.keys(afterMembers).filter((uid) => uid !== authId),
      },
    ]);
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

  return nonEmpty(events);
}

/**
 * 점포 문서가 지워질 때 보낼 알림을 정한다 (`cascadeStoreDelete`).
 *
 * | 지운 경로 | 판정 | 수신자 |
 * |---|---|---|
 * | 기한이 지나 TTL이 지움 | `deletedAt + 7일`이 지남 | (발송 안 함 — 점포 삭제 때 이미 알렸다) |
 * | 영구 삭제 | `deletedAt + 7일` 전 | 관리자를 뺀 멤버 |
 * | 계정 삭제가 혼자 쓰던 점포를 지움 | `deletedAt` 없음 | 관리자를 뺀 멤버, 승인 대기자 |
 *
 * 문서 삭제 트리거에는 쓴 사람이 없으므로 지운 사람인 관리자를 역할로 뺀다.
 */
export function classifyStoreRemoval(removed: StoreSnapshot, now: Date): MembershipEvent[] {
  const deletedAt = toDate(removed.deletedAt);
  if (deletedAt && now.getTime() >= deletedAt.getTime() + STORE_SOFT_DELETE_DAYS * DAY_MS) {
    return [];
  }

  const members = removed.memberById ?? {};
  const memberUids = Object.keys(members).filter((uid) => !isAdmin(members[uid]));
  const applicantUids = Object.keys(removed.waitingMemberById ?? {}).filter(
    (uid) => !(uid in members),
  );
  return nonEmpty([
    { type: STORE_DELETED_TYPE, recipientUids: memberUids, deletion: 'permanent' },
    { type: STORE_DELETED_TYPE, recipientUids: applicantUids, deletion: 'applicationCanceled' },
  ]);
}

const DAY_MS = 24 * 60 * 60 * 1000;

function uniqueUids(...maps: Record<string, MemberInfo>[]): string[] {
  return [...new Set(maps.flatMap(Object.keys))];
}

function nonEmpty(events: MembershipEvent[]): MembershipEvent[] {
  return events.filter((event) => event.recipientUids.length > 0);
}

/** Firestore `Timestamp`(트리거 데이터)와 `Date`(테스트)를 모두 받는다 */
function toDate(value: unknown): Date | undefined {
  if (value instanceof Date) return value;
  if (value && typeof (value as { toDate?: unknown }).toDate === 'function') {
    return (value as { toDate: () => Date }).toDate();
  }
  return undefined;
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
        title: `${storeName} 관리자가 되었습니다`,
        body: `${subjectName} 님이 관리자 역할을 위임했습니다.`,
      };
    case MEMBER_LEFT_TYPE:
      return {
        title: `${storeName}에서 멤버가 나갔습니다`,
        body: `${subjectName} 님이 점포를 나갔습니다.`,
      };
    case MEMBER_REMOVED_TYPE:
      return {
        title: `${storeName} 멤버에서 제외되었습니다`,
        body: '더 이상 이 점포의 예약을 볼 수 없습니다.',
      };
    case JOIN_APPROVED_TYPE:
      return {
        title: `${storeName} 가입이 승인되었습니다`,
        body: `${event.role ? ROLE_DISPLAY_NAMES[event.role] : '멤버'}로 점포에 참여합니다.`,
      };
    case JOIN_REJECTED_TYPE:
      return {
        title: `${storeName} 가입 신청이 거절되었습니다`,
        body: '초대 코드를 다시 받아 신청할 수 있습니다.',
      };
    case STORE_DELETED_TYPE:
      return storeDeletionNotification(event.deletion, storeName);
    case STORE_RESTORED_TYPE:
      return {
        title: `${storeName} 점포가 복구되었습니다`,
        body: '다시 예약을 추가하고 고칠 수 있습니다.',
      };
  }
}

function storeDeletionNotification(
  deletion: StoreDeletionKind | undefined,
  storeName: string,
): { title: string; body: string } {
  switch (deletion) {
    case 'scheduled':
      return {
        title: `${storeName} 점포가 ${STORE_SOFT_DELETE_DAYS}일 후 삭제됩니다`,
        body: '그 전에 관리자가 복구할 수 있습니다. 그때까지 예약을 추가하거나 고칠 수 없습니다.',
      };
    case 'applicationCanceled':
      return {
        title: `${storeName} 점포가 삭제되었습니다`,
        body: '가입 신청이 취소되었습니다.',
      };
    case 'permanent':
    case undefined:
      return {
        title: `${storeName} 점포가 삭제되었습니다`,
        body: '관리자가 점포를 영구 삭제했습니다.',
      };
  }
}

/** 수신자 기기 토큰마다 알림 메시지를 만든다. 탭하면 앱이 사건에 맞는 화면으로 이동한다. */
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
