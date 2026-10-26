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

/// 점포 soft delete 유지 기간(일 단위)
const int storeSoftDeleteDays = 7;

/// 공휴일 값 표시용
const int holidayValue = 8;

/// 비어있는 값 표시용
const int emptyValue = -1;

/// 하루의 분 수. 시간대는 그날 00:00부터의 분으로 다루므로 하루의 끝(24:00)이기도 하다
const int minutesPerDay = 24 * 60;
