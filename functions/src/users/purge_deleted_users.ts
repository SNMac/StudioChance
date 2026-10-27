import { getFirestore } from 'firebase-admin/firestore';
import { logger } from 'firebase-functions/v2';
import { onSchedule } from 'firebase-functions/v2/scheduler';

import { findUnreferencedDeletedUsers } from './find_unreferenced_deleted_users.js';

/**
 * 매주 월요일 04:30 KST에 어디에도 연결되지 않은 삭제된 계정의 문서를 지운다 (ADR-0005).
 *
 * 삭제된 계정의 문서는 남은 예약에 작성자 닉네임을 보여 주려고 남긴 것이라, 작성한 예약이
 * 모두 사라지면 남길 이유가 없다. 계정 삭제 직후가 아니라 주 단위로 지우므로 계정 삭제가
 * 일으킨 점포 나가기 알림(notifyOnMembershipChange)은 닉네임을 읽을 수 있다.
 */
export const purgeDeletedUsers = onSchedule(
  {
    schedule: '30 4 * * 1',
    timeZone: 'Asia/Seoul',
    region: 'asia-northeast3',
    timeoutSeconds: 540,
  },
  async () => {
    const db = getFirestore();
    const targets = await findUnreferencedDeletedUsers(db);

    for (const ref of targets) {
      // 하위 문서(private/fcm 등)가 남아 있어도 함께 지운다
      await db.recursiveDelete(ref);
    }
    logger.info('삭제된 계정 문서 정리 완료', { count: targets.length });
  },
);
