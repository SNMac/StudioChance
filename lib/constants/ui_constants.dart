const double inputFormComponentHeight = 48.0;

/// 메모 필드 최소 높이 (MemoTextField minLines=3 + 패딩 기준)
const double memoMinHeight = 96.0;
const double verticalPadding = 32.0;
const double horizontalPadding = 16.0;
const double formBorderRadius = 12.0;

// 모달
const double modalTopCornerRadius = 10.0;

// 홈 화면 - 네비게이션 바
const double homeNavBarHeight = 44.0;

// 홈 화면 - 캘린더
const double timeColumnWidth = 44.0;
const double allDayRowHeight = 40.0;

/// 종일 행 접기/펼치기 토글 아이콘 크기.
const double allDayToggleIconSize = 14.0;

/// 종일 행 접기/펼치기 토글의 터치 영역 높이 (행 높이에서 상단 여백 제외).
const double allDayToggleHitHeight = allDayRowHeight - 2;

/// 종일 행 접기/펼치기 전환 시간.
const Duration allDayExpandDuration = Duration(milliseconds: 200);

/// 종일 행을 펼쳤을 때 세로로 쌓을 수 있는 최대 칸 수.
/// 초과분은 마지막 칸의 "+N건 더보기" 행으로 접힌다.
const int allDayMaxStackCount = 3;
const double allDayOverflowBadgeHeight = 14.0;

/// 종일 셀 초과 배지가 차지하는 가로 공간 — ReservationCell 콘텐츠가 배지와
/// 겹치지 않도록 이 만큼 우측 여백을 추가로 확보한다.
const double allDayOverflowBadgeReservedWidth = 24.0;
const double defaultHourHeight = 40.0;
const double minHourHeight = 36.0;
const double maxHourHeight = 72.0;
const double calendarDividerThickness = 0.5;
const double currentTimeLineThickness = 1.0;
const double currentTimeCapsuleWidth = 32.0;
const double currentTimeCapsuleHeight = 13.0;
// 캡슐 우측 여백: 시간 열 오른쪽 끝에서 캡슐까지의 간격
// CurrentTimeLine.left도 동일 값(음수)으로 맞춰 캡슐 오른쪽 끝에서 선이 시작되도록 함
const double currentTimeCapsuleRightInset = 0.25;

// 홈 화면 - 월간 캘린더
const double monthlyCalendarDayRowHeight = 40.0; // 날짜 셀 행 높이
const double monthlyCalendarWeekdayRowHeight = 20.0; // 요일 헤더 행 높이
const double monthlyCalendarHeight =
    260.0; // 5행 기준 높이 (16=패딩 + 20=요일헤더 + 5×44.8=셀)

/// 월간 캘린더 총 높이 (항상 6행 고정)
/// 셀 높이 = (5행 기준 260 - 패딩16 - 요일헤더20) / 5 = 44.8
/// 6행 총 높이 = 16 + 20 + 6 × 44.8 ≈ 304.8
double monthlyCalendarHeightForMonth(DateTime month) {
  const cellHeight =
      (monthlyCalendarHeight - 16.0 - monthlyCalendarWeekdayRowHeight) / 5.0;
  return 16.0 + monthlyCalendarWeekdayRowHeight + 6 * cellHeight;
}

// 홈 화면 - 3일 캘린더 헤더
const double threeDayHeaderHeight = 28.0;

/// 3일 캘린더에서 화면에 동시에 보이는 날짜 열 수.
const int threeDayVisibleColumnCount = 3;

// 홈 화면 - 탭바
const double tabBarHeight = 49.0;
