import type { DocumentReference, Firestore } from 'firebase-admin/firestore';

/**
 * 계정을 삭제했고(`deletedAt` 있음) 작성한 예약이 하나도 남지 않은 사용자 문서 (ADR-0005).
 *
 * 삭제된 계정의 문서를 참조하는 것은 예약의 `writerId`뿐이다. 삭제된 계정은 예약을
 * 새로 쓸 수 없어 참조는 줄어들기만 하므로, 여기서 고른 문서는 지워도 다시 필요해지지 않는다.
 *
 * `reservations.writerId` 컬렉션 그룹 인덱스가 필요하다 (firestore.indexes.json).
 *
 * ponytail: 삭제된 계정마다 조회를 차례로 한다. 수천 명까지는 함수 제한 시간 안에
 * 끝나지만, 그보다 쌓이면 묶음 병렬 조회나 확인 시각 기록으로 바꾼다.
 */
export async function findUnreferencedDeletedUsers(
  db: Firestore,
): Promise<DocumentReference[]> {
  // 정상 사용자에게는 deletedAt 필드가 없어 이 조건에 걸리지 않는다
  const deletedUsers = await db.collection('users').where('deletedAt', '!=', null).select().get();

  const unreferenced: DocumentReference[] = [];
  for (const user of deletedUsers.docs) {
    const written = await db
      .collectionGroup('reservations')
      .where('writerId', '==', user.id)
      .limit(1)
      .select()
      .get();
    if (written.empty) unreferenced.push(user.ref);
  }
  return unreferenced;
}
