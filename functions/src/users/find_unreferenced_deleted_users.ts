import { type DocumentReference, type Firestore, Timestamp } from 'firebase-admin/firestore';

/**
 * 계정을 삭제한 뒤 이 기간이 지나야 정리 대상이 된다.
 *
 * 계정 삭제가 일으킨 점포 나가기 알림(notifyOnStoreUpdate)이 이 문서에서 닉네임을
 * 읽는다. 작성한 예약이 없으면 문서는 삭제 직후부터 연결이 끊긴 상태라, 정리 함수가 마침
 * 그 몇 초 안에 실행되면 알림이 이름을 읽지 못한다. 알림에는 몇 초면 충분하지만 여유를 둔다.
 */
export const PURGE_GRACE_DAYS = 7;

/**
 * 계정을 삭제한 지 [PURGE_GRACE_DAYS]일이 지났고, 작성한 예약이 하나도 남지 않은
 * 사용자 문서 (ADR-0005).
 *
 * 삭제된 계정의 문서를 계속 참조하는 것은 예약의 `writerId`뿐이다. 삭제된 계정은 예약을
 * 새로 쓸 수 없어 참조는 줄어들기만 하므로, 여기서 고른 문서는 지워도 다시 필요해지지 않는다.
 *
 * `reservations.writerId` 컬렉션 그룹 인덱스가 필요하다 (firestore.indexes.json).
 *
 * ponytail: 삭제된 계정마다 조회를 차례로 한다. 수천 명까지는 함수 제한 시간 안에
 * 끝나지만, 그보다 쌓이면 묶음 병렬 조회나 확인 시각 기록으로 바꾼다.
 */
export async function findUnreferencedDeletedUsers(
  db: Firestore,
  now: Date,
): Promise<DocumentReference[]> {
  const cutoff = new Date(now.getTime() - PURGE_GRACE_DAYS * 24 * 60 * 60 * 1000);
  // 정상 사용자에게는 deletedAt 필드가 없어 이 조건에 걸리지 않는다
  const deletedUsers = await db
    .collection('users')
    .where('deletedAt', '<', Timestamp.fromDate(cutoff))
    .select()
    .get();

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
