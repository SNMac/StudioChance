import { getFirestore } from 'firebase-admin/firestore';
import { logger } from 'firebase-functions/v2';
import { onSchedule } from 'firebase-functions/v2/scheduler';

import { findUnreferencedDeletedUsers } from './find_unreferenced_deleted_users.js';

/**
 * 매주 월요일 04:30 KST에 어디에도 연결되지 않은 삭제된 계정의 문서를 지운다 (ADR-0005).
 *
 * 삭제된 계정의 문서는 남은 예약에 작성자 닉네임을 보여 주려고 남긴 것이라, 작성한 예약이
 * 모두 사라지면 남길 이유가 없다. 삭제한 지 얼마 안 된 계정은 건너뛴다(PURGE_GRACE_DAYS).
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
    const targets = await findUnreferencedDeletedUsers(db, new Date());

    for (const ref of targets) {
      // 하위 문서(private/fcm 등)가 남아 있어도 함께 지운다
      await db.recursiveDelete(ref);
    }
    logger.info('삭제된 계정 문서 정리 완료', { count: targets.length });
  },
);
