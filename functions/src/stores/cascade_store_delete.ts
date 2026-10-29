import {
  type DocumentReference,
  FieldPath,
  FieldValue,
  type Firestore,
  getFirestore,
} from 'firebase-admin/firestore';
import { logger } from 'firebase-functions/v2';
import { onDocumentDeleted } from 'firebase-functions/v2/firestore';

import {
  buildMembershipMessages,
  classifyStoreRemoval,
  type StoreSnapshot,
  uniqueUids,
} from '../notifications/membership_change.js';
import { sendToUsers } from '../notifications/send_to_users.js';

/** Firestore `NOT_FOUND` gRPC 코드 */
const NOT_FOUND = 5;

/**
 * 지워진 점포 문서 아래의 서브컬렉션(예약 등)을 모두 지운다.
 *
 * Firestore는 문서를 지워도 서브컬렉션을 남긴다. 이 정리가 없으면 TTL이 점포를 지운 뒤
 * 예약이 접근 경로 없이 영구히 저장·과금된다. 서브컬렉션을 이름으로 고르지 않으므로
 * 점포에 서브컬렉션이 늘어도 따로 손댈 곳이 없다.
 */
export async function deleteStoreSubcollections(
  db: Firestore,
  storeRef: DocumentReference,
): Promise<void> {
  await db.recursiveDelete(storeRef);
}

/**
 * 지워진 점포를 가리키는 사용자 문서의 `storeById.{storeId}` 항목을 지운다.
 *
 * 점포 삭제는 멤버의 항목을 남겨 두고 삭제 예정으로만 표시한다 (ADR-0007). 점포 문서가
 * 실제로 지워지면 여기서 정리하지 않는 한 멤버 앱에 사라진 점포가 남는다.
 * 사용자 문서가 없으면(삭제된 계정이 정리된 경우) 건너뛴다.
 */
export async function clearStoreEntries(
  db: Firestore,
  storeId: string,
  uids: string[],
): Promise<void> {
  await Promise.all(
    uids.map(async (uid) => {
      try {
        await db
          .doc(`users/${uid}`)
          .update(
            new FieldPath('storeById', storeId),
            FieldValue.delete(),
            'updatedAt',
            FieldValue.serverTimestamp(),
          );
      } catch (error) {
        if ((error as { code?: unknown }).code === NOT_FOUND) return;
        throw error;
      }
    }),
  );
}

/**
 * 점포 문서가 지워지면(`expiresAt` TTL·영구 삭제·계정 삭제·콘솔 삭제 모두) 서브컬렉션과
 * 멤버의 점포 항목을 지우고, 기한 전에 지워졌으면 남은 멤버에게 알린다.
 *
 * 정리는 여러 번 실행해도 결과가 같으므로 재시도를 켠다. 끄면 일시적인 오류 한 번으로
 * 예약이 영구히 고아가 된다. 알림은 재시도로 두 번 나가지 않도록 맨 마지막에 보내고,
 * 실패해도 함수를 실패시키지 않는다.
 */
export const cascadeStoreDelete = onDocumentDeleted(
  {
    document: 'stores/{storeId}',
    region: 'asia-northeast3',
    retry: true,
  },
  async (event) => {
    const storeId = event.params.storeId;
    const removed = (event.data?.data() ?? {}) as StoreSnapshot & { name?: string };
    const db = getFirestore();

    await deleteStoreSubcollections(db, db.doc(`stores/${storeId}`));
    await clearStoreEntries(
      db,
      storeId,
      uniqueUids(removed.memberById ?? {}, removed.waitingMemberById ?? {}),
    );
    logger.info('삭제된 점포의 서브컬렉션·멤버 항목 정리 완료', { storeId });

    const storeName = removed.name ?? '점포';
    for (const change of classifyStoreRemoval(removed, new Date())) {
      try {
        await sendToUsers({
          uids: change.recipientUids,
          buildMessages: (tokens) =>
            buildMembershipMessages({ tokens, event: change, storeId, storeName, subjectName: '' }),
          label: '점포 삭제 알림',
          logContext: { storeId, type: change.type, deletion: change.deletion },
        });
      } catch (error) {
        logger.error('점포 삭제 알림 발송 실패', { storeId, error: String(error) });
      }
    }
  },
);
