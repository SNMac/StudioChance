import type { Firestore, QueryDocumentSnapshot } from 'firebase-admin/firestore';

/**
 * 초대 코드가 일치하는 점포 문서. 없으면 null.
 *
 * 삭제 여부·만료는 여기서 거르지 않고 evaluateInviteStore가 판정한다.
 * 특히 `deletedAt`을 쿼리 조건으로 걸면 안 된다 — 정상 점포에는 그 필드가
 * 아예 없고, Firestore는 필터 대상 필드가 없는 문서를 결과에서 빼므로
 * 어떤 점포도 조회되지 않는다 (#43, 에뮬레이터 테스트가 이를 지킨다).
 */
export async function findStoreByInviteCode(
  db: Firestore,
  code: string,
): Promise<QueryDocumentSnapshot | null> {
  const snapshot = await db
    .collection('stores')
    .where('inviteInfo.inviteCode', '==', code)
    .limit(1)
    .get();
  return snapshot.empty ? null : snapshot.docs[0];
}
