/// 메모 최대 글자 수
const int maxMemoCharCount = 200;

/// 점포 초대 코드 유효 시간(분 단위)
const int storeInviteCodeAvailableMin = 15;

/// 사용자 soft delete 유지 기간(일 단위)
const int userSoftDeleteDays = 7;

/// 점포 soft delete 유지 기간(일 단위)
const int storeSoftDeleteDays = 7;

/// 공휴일 값 표시용
const int holidayValue = 8;

/// 비어있는 값 표시용
const int emptyValue = -1;

/// 예약 플랫폼 목록
const List<String> reservationPlatforms = [
  '네이버 예약',
  '카카오 예약',
  '전화',
  '직접 방문',
  '기타',
];

/// 결제 방식 목록
const List<String> paymentMethods = [
  '현금',
  '계좌이체',
  '카드',
  '기타',
];