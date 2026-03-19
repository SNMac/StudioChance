import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';
import 'package:studio_chance/presentation/providers/home_calendar_controller.dart';

/// 홈 화면 네비게이션 바
class HomeNavBar extends ConsumerWidget {
  const HomeNavBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeCalendarControllerProvider);
    final notifier = ref.read(homeCalendarControllerProvider.notifier);

    // 네비게이션 바에 표시할 연월 텍스트
    final month = state.displayedMonth;
    final monthText = '${month.year}년 ${month.month}월';
    final today = DateTime.now().day;

    return Container(
      height: homeNavBarHeight,
      color: context.systemBackground,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          // 좌측: 연월 + chevron 버튼
          GestureDetector(
            onTap: notifier.toggleMonthlyCalendar,
            child: SizedBox(
              height: homeNavBarHeight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    monthText,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: context.label,
                    ),
                  ),
                  const SizedBox(width: 4.0),
                  Icon(
                    // 월간 캘린더 표시 여부에 따라 chevron 방향 전환
                    state.isMonthlyCalendarVisible
                        ? CupertinoIcons.chevron_up
                        : CupertinoIcons.chevron_down,
                    size: 16.0,
                    color: context.label,
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          // 우측: 버튼 2개
          Row(
            children: [
              // calendar_circle 버튼 (날짜 picker 표시)
              GestureDetector(
                onTap: () => _showDatePicker(context, ref, state),
                child: SizedBox(
                  width: 44.0,
                  height: 44.0,
                  child: Center(
                    child: Icon(
                      CupertinoIcons.calendar_circle,
                      size: 20.0,
                      color: context.label,
                    ),
                  ),
                ),
              ),
              // 오늘 날짜 원형 버튼
              GestureDetector(
                onTap: notifier.goToToday,
                child: SizedBox(
                  width: 44.0,
                  height: 44.0,
                  child: Center(
                    child: Container(
                      width: 20.0,
                      height: 20.0,
                      decoration: BoxDecoration(
                        color: context.label,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$today',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: context.systemBackground,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// CupertinoDatePicker를 모달로 표시
  void _showDatePicker(
    BuildContext context,
    WidgetRef ref,
    HomeCalendarState state,
  ) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => SizedBox(
        height: 300,
        child: CupertinoDatePicker(
          mode: CupertinoDatePickerMode.date,
          initialDateTime: state.selectedStartDate,
          onDateTimeChanged: (date) =>
              ref.read(homeCalendarControllerProvider.notifier).selectDate(date),
        ),
      ),
    );
  }
}
