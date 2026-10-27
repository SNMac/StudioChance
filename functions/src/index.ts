import { initializeApp } from 'firebase-admin/app';
import { logger } from 'firebase-functions/v2';
import { onDocumentUpdatedWithAuthContext } from 'firebase-functions/v2/firestore';

import { adminUidsOf, buildJoinRequestMessages } from './notifications/join_request_payload.js';
import {
  buildMembershipMessages,
  classifyMembershipChanges,
  type StoreSnapshot,
} from './notifications/membership_change.js';
import { displayNameOf, sendToUsers } from './notifications/send_to_users.js';
import { collectNewWaitingUids } from './notifications/waiting_member_diff.js';

initializeApp();

export { issueInviteCode } from './invite/issue_invite_code.js';
export { lookupInviteCode } from './invite/lookup_invite_code.js';
export { getServerTime } from './time/get_server_time.js';
export { syncHolidays } from './holidays/sync_holidays.js';
export { cascadeStoreDelete } from './stores/cascade_store_delete.js';
export { purgeDeletedUsers } from './users/purge_deleted_users.js';

/** 점포 문서 수정 하나에서 두 알림이 공통으로 쓰는 값 */
type StoreUpdate = {
  storeId: string;
  storeName: string;
  before: StoreSnapshot;
  after: StoreSnapshot;
  authId: string | undefined;
};

/**
 * 점포 문서가 수정되면 가입 신청 알림과 멤버 구성 변화 알림을 보낸다.
 *
 * Firestore 트리거는 바뀐 필드로 거를 수 없어 점포 정보·요금표 수정에도 실행된다.
 * 두 알림을 함수 하나에 모아 수정 1회당 실행을 1회로 줄인다.
 * 두 알림은 서로 독립적이므로 한쪽이 실패해도 다른 쪽은 끝까지 보낸다.
 *
 * 쓴 사람(`authId`)으로 나가기와 추방, 신청 취소와 거절을 구분하므로 auth context
 * 트리거를 쓴다. Firestore 리전(asia-northeast3)과 함수 리전을 반드시 일치시킨다.
 */
export const notifyOnStoreUpdate = onDocumentUpdatedWithAuthContext(
  {
    document: 'stores/{storeId}',
    region: 'asia-northeast3',
  },
  async (event) => {
    const before = event.data?.before.data() as StoreSnapshot | undefined;
    const after = event.data?.after.data() as StoreSnapshot | undefined;
    if (!before || !after) return;

    const update: StoreUpdate = {
      storeId: event.params.storeId,
      storeName: (event.data?.after.get('name') as string | undefined) ?? '점포',
      before,
      after,
      authId: event.authId,
    };

    const results = await Promise.allSettled([
      notifyNewJoinRequests(update),
      notifyMembershipChanges(update),
    ]);
    const failures = results.filter(
      (result): result is PromiseRejectedResult => result.status === 'rejected',
    );
    if (failures.length > 0) {
      throw new AggregateError(
        failures.map((failure) => failure.reason),
        '점포 수정 알림 일부 발송 실패',
      );
    }
  },
);

/**
 * 점포 대기 명단(`waitingMemberById`)에 새 신청자가 추가되면
 * 해당 점포 관리자(ADMIN)의 모든 기기에 푸시 알림을 보낸다.
 */
async function notifyNewJoinRequests({
  storeId,
  storeName,
  before,
  after,
}: StoreUpdate): Promise<void> {
  const newApplicantUids = collectNewWaitingUids(
    before.waitingMemberById,
    after.waitingMemberById,
  );
  if (newApplicantUids.length === 0) return;

  const adminUids = adminUidsOf(after.memberById);
  if (adminUids.length === 0) {
    logger.warn('관리자가 없어 가입 신청 알림을 건너뜁니다', { storeId });
    return;
  }

  for (const applicantUid of newApplicantUids) {
    const applicantName = await displayNameOf(applicantUid);
    await sendToUsers({
      // 신청자 본인에게는 보내지 않는다 (정상 흐름에서는 발생하지 않지만 방어적으로 처리)
      uids: adminUids.filter((uid) => uid !== applicantUid),
      buildMessages: (tokens) =>
        buildJoinRequestMessages({
          tokens,
          applicantName,
          applicantUid,
          storeId,
          storeName,
        }),
      label: '가입 신청 알림',
      logContext: { storeId, applicantUid },
    });
  }
}

/**
 * 점포 멤버 구성이 바뀌면(관리자 위임·점포 나가기·추방·가입 승인·거절·점포 삭제)
 * 당사자에게 푸시 알림을 보낸다. 분류 규칙은 `classifyMembershipChanges` 참고.
 * 새 가입 신청은 `notifyNewJoinRequests`가 담당한다.
 */
async function notifyMembershipChanges({
  storeId,
  storeName,
  before,
  after,
  authId,
}: StoreUpdate): Promise<void> {
  const changes = classifyMembershipChanges(before, after, authId);
  if (changes.length === 0) return;

  for (const change of changes) {
    const subjectName = change.subjectUid ? await displayNameOf(change.subjectUid) : '';
    await sendToUsers({
      uids: change.recipientUids,
      buildMessages: (tokens) =>
        buildMembershipMessages({ tokens, event: change, storeId, storeName, subjectName }),
      label: '멤버 구성 변화 알림',
      logContext: { storeId, type: change.type },
    });
  }
}
