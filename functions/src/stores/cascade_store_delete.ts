import { type DocumentReference, type Firestore, getFirestore } from 'firebase-admin/firestore';
import { logger } from 'firebase-functions/v2';
import { onDocumentDeleted } from 'firebase-functions/v2/firestore';

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
 * 점포 문서가 지워지면(`expiresAt` TTL·콘솔 삭제 모두) 서브컬렉션을 지운다.
 *
 * 여러 번 실행해도 결과가 같으므로 재시도를 켠다. 끄면 일시적인 오류 한 번으로
 * 예약이 영구히 고아가 된다.
 */
export const cascadeStoreDelete = onDocumentDeleted(
  {
    document: 'stores/{storeId}',
    region: 'asia-northeast3',
    retry: true,
  },
  async (event) => {
    const storeId = event.params.storeId;
    const db = getFirestore();
    await deleteStoreSubcollections(db, db.doc(`stores/${storeId}`));
    logger.info('삭제된 점포의 서브컬렉션 정리 완료', { storeId });
  },
);
