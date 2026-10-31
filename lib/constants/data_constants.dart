/// 메모 최대 글자 수
const int maxMemoCharCount = 500;

/// 닉네임 최대 글자 수
/// - 계정 삭제 때 닉네임 대신 남기는 소셜 계정 이름도 이 길이로 자른다
const int maxNicknameCharCount = 10;

/// 확정 안내문 안내/주의사항 최대 글자 수
const int maxConfirmationNotesCharCount = 3000;

/// 점포 초대 코드 유효 시간(분 단위)
/// - Cloud Functions의 `INVITE_CODE_AVAILABLE_MIN`과 동일해야 한다 (계약 테스트
///   `functions/src/contract/shared_constants.test.ts`가 검사한다)
const int storeInviteCodeAvailableMin = 15;

/// 삭제 예정 점포로 남는 기간(일 단위). 이 안에 관리자가 점포 복구를 할 수 있다 (ADR-0007)
/// - 기한은 서버 시각인 `deletedAt`에 이 기간을 더한 시각이다
/// - Cloud Functions의 `STORE_SOFT_DELETE_DAYS`, firestore.rules의 복구 기한과 같아야 한다
///   (계약 테스트 `functions/src/contract/shared_constants.test.ts`가 검사한다)
const int storeSoftDeleteDays = 7;

/// 점포 삭제의 TTL 만료 시각(`expiresAt`) 여유(일 단위)
/// - `expiresAt`은 기기 시각 + ([storeSoftDeleteDays] + 이 값)일로 쓴다. 기기 시계가 조금
///   틀려도 TTL이 화면의 기한보다 먼저 지우지 않게 하려는 것이다
/// - Rules는 서버 시각 + [storeSoftDeleteDays]일부터 + ([storeSoftDeleteDays] + 이 값 × 2)일
///   사이만 받는다. 기기 시계가 이 값보다 틀리면 점포 삭제가 거부되므로 UseCase가 먼저
///   확인한다 (계약 테스트 `functions/src/contract/shared_constants.test.ts`가 검사한다)
const int storeDeletionExpiryBufferDays = 1;

/// 공휴일 값 표시용
const int holidayValue = 8;

/// 비어있는 값 표시용
const int emptyValue = -1;

/// 하루의 분 수. 시간대는 그날 00:00부터의 분으로 다루므로 하루의 끝(24:00)이기도 하다
const int minutesPerDay = 24 * 60;
