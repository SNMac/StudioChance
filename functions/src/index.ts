import { initializeApp } from 'firebase-admin/app';
import { FieldValue, getFirestore } from 'firebase-admin/firestore';
import { getMessaging } from 'firebase-admin/messaging';
import { logger } from 'firebase-functions/v2';
import { onDocumentUpdated } from 'firebase-functions/v2/firestore';

import { adminUidsOf, buildJoinRequestMessages } from './notifications/join_request_payload.js';
import { invalidTokensFrom } from './notifications/invalid_tokens.js';
import { collectNewWaitingUids } from './notifications/waiting_member_diff.js';

initializeApp();

export { lookupInviteCode } from './invite/lookup_invite_code.js';

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

    const db = getFirestore();

    // 토큰 → 소유 관리자 uid. 폐기 토큰 정리 시 어느 문서를 갱신할지 알기 위해 필요하다.
    const ownerUidByToken = new Map<string, string>();
    // 토큰은 users/{uid}/private/fcm에 있다 (firestore.rules 참고).
    // 서브문서의 id는 모두 'fcm'이라 doc.id로 소유자를 되찾을 수 없으므로
    // getAll에 넘긴 순서와 같은 인덱스로 adminUids와 짝짓는다.
    const fcmDocs = await db.getAll(
      ...adminUids.map((uid) => db.doc(`users/${uid}/private/fcm`)),
    );
    fcmDocs.forEach((doc, index) => {
      const tokens = (doc.get('tokens') as string[] | undefined) ?? [];
      for (const token of tokens) {
        ownerUidByToken.set(token, adminUids[index]);
      }
    });

    if (ownerUidByToken.size === 0) {
      logger.warn('관리자 FCM 토큰이 없어 알림을 건너뜁니다', { storeId, adminUids });
      return;
    }

    for (const applicantUid of newApplicantUids) {
      const applicantDoc = await db.doc(`users/${applicantUid}`).get();
      const applicantName =
        (applicantDoc.get('nickname') as string | undefined) ??
        (applicantDoc.get('name') as string | undefined) ??
        '알 수 없는 사용자';

      // 신청자 본인에게는 보내지 않는다 (정상 흐름에서는 발생하지 않지만 방어적으로 처리)
      const targetTokens = [...ownerUidByToken.entries()]
        .filter(([, ownerUid]) => ownerUid !== applicantUid)
        .map(([token]) => token);
      if (targetTokens.length === 0) continue;

      const response = await getMessaging().sendEach(
        buildJoinRequestMessages({
          tokens: targetTokens,
          applicantName,
          applicantUid,
          storeId,
          storeName,
        }),
      );

      logger.info('가입 신청 알림 발송 완료', {
        storeId,
        applicantUid,
        successCount: response.successCount,
        failureCount: response.failureCount,
        // 실패 코드를 남겨야 정리 대상이 아닌 영구 실패 토큰을 사후에 식별할 수 있다
        ...(response.failureCount > 0 && {
          failureCodes: response.responses
            .filter((result) => !result.success)
            .map((result) => result.error?.code ?? 'unknown'),
        }),
      });

      const expiredTokens = invalidTokensFrom(response, targetTokens);
      if (expiredTokens.length === 0) continue;

      await Promise.all(
        expiredTokens.map((token) =>
          db.doc(`users/${ownerUidByToken.get(token)}/private/fcm`).update({
            tokens: FieldValue.arrayRemove(token),
          }),
        ),
      );
      for (const token of expiredTokens) {
        ownerUidByToken.delete(token);
      }
      logger.info('폐기된 FCM 토큰 정리', { storeId, count: expiredTokens.length });
    }
  },
);
