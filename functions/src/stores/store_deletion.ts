/**
 * 삭제 예정 점포로 남는 기간(일). 지나면 점포 복구를 할 수 없다 (ADR-0007).
 * 앱 `storeSoftDeleteDays`, firestore.rules의 복구 기한과 같아야 한다
 * (계약 테스트 `contract/shared_constants.test.ts`가 검사한다).
 */
export const STORE_SOFT_DELETE_DAYS = 7;

const DAY_MS = 24 * 60 * 60 * 1000;

/** [deletedAt]에 삭제 예정이 된 점포가 완전히 지워지는(복구할 수 없게 되는) 시각 */
export function deletionDeadlineOf(deletedAt: Date): Date {
  return new Date(deletedAt.getTime() + STORE_SOFT_DELETE_DAYS * DAY_MS);
}
