/**
 * 삭제 예정 점포로 남는 기간(일). 지나면 점포 복구를 할 수 없다 (ADR-0007).
 * 앱 `storeSoftDeleteDays`, firestore.rules의 복구 기한과 같아야 한다
 * (계약 테스트 `contract/shared_constants.test.ts`가 검사한다).
 */
export const STORE_SOFT_DELETE_DAYS = 7;
