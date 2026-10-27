import { initializeApp } from 'firebase-admin/app';
import { logger } from 'firebase-functions/v2';
import {
  onDocumentUpdated,
  onDocumentUpdatedWithAuthContext,
} from 'firebase-functions/v2/firestore';

import { adminUidsOf, buildJoinRequestMessages } from './notifications/join_request_payload.js';
import {
  buildMembershipMessages,
  classifyMembershipChanges,
  type StoreSnapshot,
} from './notifications/membership_change.js';
import { displayNameOf, sendToUsers } from './notifications/send_to_users.js';
import { collectNewWaitingUids } from './notifications/waiting_member_diff.js';

initializeApp();

export { lookupInviteCode } from './invite/lookup_invite_code.js';
export { syncHolidays } from './holidays/sync_holidays.js';
export { cascadeStoreDelete } from './stores/cascade_store_delete.js';
export { purgeDeletedUsers } from './users/purge_deleted_users.js';

/**
 * 점포 대기 명단(`waitingMemberById`)에 새 신청자가 추가되면
 * 해당 점포 관리자(ADMIN)의 모든 기기에 푸시 알림을 보낸다.
 *
 * Firestore 리전(asia-northeast3)과 함수 리전을 반드시 일치시킨다.
 */
export const notifyAdminsOnJoinRequest = onDocumentUpdated(
  {
    document: 'stores/{storeId}',
    region: 'asia-northeast3',
  },
  async (event) => {
    const after = event.data?.after.data();
    if (!after) return;

    const newApplicantUids = collectNewWaitingUids(
      event.data?.before.data()?.waitingMemberById,
      after.waitingMemberById,
    );
    if (newApplicantUids.length === 0) return;

    const storeId = event.params.storeId;
    const storeName = (after.name as string | undefined) ?? '점포';

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
  },
);

/**
 * 점포 멤버 구성이 바뀌면(관리자 위임·점포 나가기·추방·가입 승인·거절·점포 삭제)
 * 당사자에게 푸시 알림을 보낸다. 분류 규칙은 `classifyMembershipChanges` 참고.
 *
 * 쓴 사람(`authId`)으로 나가기와 추방, 신청 취소와 거절을 구분하므로 auth context
 * 트리거를 쓴다. 새 가입 신청은 `notifyAdminsOnJoinRequest`가 담당한다.
 */
export const notifyOnMembershipChange = onDocumentUpdatedWithAuthContext(
  {
    document: 'stores/{storeId}',
    region: 'asia-northeast3',
  },
  async (event) => {
    const before = event.data?.before.data() as StoreSnapshot | undefined;
    const after = event.data?.after.data() as StoreSnapshot | undefined;
    if (!before || !after) return;

    const changes = classifyMembershipChanges(before, after, event.authId);
    if (changes.length === 0) return;

    const storeId = event.params.storeId;
    const storeName = (event.data?.after.get('name') as string | undefined) ?? '점포';

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
  },
);
