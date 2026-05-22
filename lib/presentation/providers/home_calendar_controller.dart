import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/presentation/providers/hour_height_preference_provider.dart';

part 'home_calendar_controller.freezed.dart';
part 'home_calendar_controller.g.dart';

/// 캘린더 페이지 전환 종류
enum CalendarTransitionKind { jump, animate }

/// 오늘 버튼 클릭 시 3일 캘린더 스크롤 트리거 (값이 바뀔 때마다 스크롤 실행)
@riverpod
class ScrollToCurrentTimeTrigger extends _$ScrollToCurrentTimeTrigger {
  @override
  int build() => 0;

  void trigger() => state = state + 1;
}

/// isContinuation 셀 탭 시 지정 시간으로 수직 스크롤하는 트리거
@riverpod
class ScrollToTimeTrigger extends _$ScrollToTimeTrigger {
  @override
  DateTime? build() => null;

  void trigger(DateTime time) => state = time;
  void clear() => state = null;
}

/// isContinuation 탭 시 원본 날짜 TimeGrid에 하이라이트를 전달하기 위한 Provider
@riverpod
class PendingHighlightId extends _$PendingHighlightId {
  @override
  String? build() => null;

  void set(String id) => state = id;
  void clear() => state = null;
}

/// 홈 캘린더 화면의 UI 상태
@freezed
abstract class HomeCalendarState with _$HomeCalendarState {
  const factory HomeCalendarState({
    /// 3일 캘린더의 첫 번째 날짜
    required DateTime selectedStartDate,

    /// 월간 캘린더 표시 여부
    required bool isMonthlyCalendarVisible,

    /// 시간 행 높이 (확대/축소 기준값)
    required double hourHeight,

    /// 네비게이션 바에 표시되는 연월 (day=1 고정)
    required DateTime displayedMonth,
  }) = _HomeCalendarState;
}

/// 홈 캘린더 상태 관리 컨트롤러
@riverpod
class HomeCalendarController extends _$HomeCalendarController {
  // 애니메이션 플래그 (상태 아님, 코드 생성 불필요)
  CalendarTransitionKind _threeDayTransition = CalendarTransitionKind.jump;
  CalendarTransitionKind _monthlyTransition = CalendarTransitionKind.jump;

  /// 3일 캘린더 페이지 전환 종류를 소비하고 기본값(jump)으로 리셋
  CalendarTransitionKind consumeThreeDayTransition() {
    final k = _threeDayTransition;
    _threeDayTransition = CalendarTransitionKind.jump;
    return k;
  }

  /// 월간 캘린더 페이지 전환 종류를 소비하고 기본값(jump)으로 리셋
  CalendarTransitionKind consumeMonthlyTransition() {
    final k = _monthlyTransition;
    _monthlyTransition = CalendarTransitionKind.jump;
    return k;
  }

  @override
  HomeCalendarState build() {
    final now = DateTime.now();

    // SharedPreferences에서 hourHeight 불러오기 (아직 로드 안 됐을 경우 기본값 사용)
    final prefs = ref.watch(sharedPreferencesProvider).asData?.value;
    final hourHeight = prefs != null ? loadHourHeight(prefs) : defaultHourHeight;

    return HomeCalendarState(
      selectedStartDate: DateTime(now.year, now.month, now.day),
      isMonthlyCalendarVisible: false,
      hourHeight: hourHeight,
      displayedMonth: DateTime(now.year, now.month, 1),
    );
  }

  /// 날짜 선택: selectedStartDate 및 displayedMonth 업데이트 (월간 캘린더 상태 유지)
  void selectDate(DateTime date) {
    state = state.copyWith(
      selectedStartDate: DateTime(date.year, date.month, date.day),
      displayedMonth: DateTime(date.year, date.month, 1),
    );
  }

  /// 월간 캘린더 표시 토글
  void toggleMonthlyCalendar() {
    state = state.copyWith(
      isMonthlyCalendarVisible: !state.isMonthlyCalendarVisible,
    );
  }

  /// 시간 행 높이 업데이트 및 SharedPreferences에 저장
  Future<void> updateHourHeight(double height) async {
    final clamped = height.clamp(minHourHeight, maxHourHeight);
    state = state.copyWith(hourHeight: clamped);

    final prefs = ref.read(sharedPreferencesProvider).asData?.value;
    if (prefs != null) await saveHourHeight(prefs, clamped);
  }

  /// 오늘 날짜로 이동 (슬라이드 애니메이션) + 3일 캘린더 현재 시간으로 스크롤
  void goToToday() {
    _threeDayTransition = CalendarTransitionKind.animate;
    _monthlyTransition = CalendarTransitionKind.animate;
    final now = DateTime.now();
    state = state.copyWith(
      selectedStartDate: DateTime(now.year, now.month, now.day),
      displayedMonth: DateTime(now.year, now.month, 1),
    );
    ref.read(scrollToCurrentTimeTriggerProvider.notifier).trigger();
  }

  /// 월간 캘린더 PageView에서 월 이동 시 displayedMonth 업데이트
  void setDisplayedMonth(DateTime month) {
    state = state.copyWith(displayedMonth: DateTime(month.year, month.month, 1));
  }

  /// 날짜를 days만큼 이동, displayedMonth는 이동 후 날짜 기준으로 업데이트
  void navigateDays(int days) {
    final newStart = state.selectedStartDate.add(Duration(days: days));
    state = state.copyWith(
      selectedStartDate: newStart,
      displayedMonth: DateTime(newStart.year, newStart.month, 1),
    );
  }

  /// 3일 캘린더 스와이프 시 날짜 이동 (ThreeDayCalendar.onPageChanged에서 호출)
  /// 월 경계 통과 시 월간 캘린더 animateToPage
  void selectDateFromSwipe(DateTime date) {
    final newStart = DateTime(date.year, date.month, date.day);
    final newMonth = DateTime(date.year, date.month, 1);
    if (newMonth != state.displayedMonth) {
      _monthlyTransition = CalendarTransitionKind.animate;
    }
    state = state.copyWith(
      selectedStartDate: newStart,
      displayedMonth: newMonth,
    );
  }

  /// 월간 캘린더 날짜 탭 시 이동 (monthly_calendar_grid.dart에서 호출)
  /// 3일 캘린더 animateToPage, 월간 캘린더는 이미 해당 페이지이므로 jump 유지
  void selectDateFromMonthly(DateTime date) {
    _threeDayTransition = CalendarTransitionKind.animate;
    selectDate(date);
  }

  /// 피커에서 날짜 확정 시 이동 (home_nav_bar.dart에서 호출)
  /// 3일 캘린더 + 월간 캘린더 모두 animateToPage
  void selectDateFromPicker(DateTime date) {
    _threeDayTransition = CalendarTransitionKind.animate;
    _monthlyTransition = CalendarTransitionKind.animate;
    selectDate(date);
  }

  /// isContinuation 셀 탭 시 원본 날짜로 이동 (3일 캘린더 + 월간 캘린더 모두 animate)
  void selectDateFromContinuation(DateTime date) {
    _threeDayTransition = CalendarTransitionKind.animate;
    _monthlyTransition = CalendarTransitionKind.animate;
    selectDate(date);
  }
}
