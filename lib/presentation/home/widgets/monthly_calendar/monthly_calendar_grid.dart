import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';
import 'package:studio_chance/presentation/providers/home_calendar_controller.dart';

/// 월간 캘린더 날짜 그리드 (5행 × 7열 고정)
class MonthlyCalendarGrid extends ConsumerWidget {
  /// 표시할 연월 (day=1 고정)
  final DateTime displayedMonth;

  /// 3일 캘린더의 첫 번째 날짜
  final DateTime selectedStartDate;

  const MonthlyCalendarGrid({
    super.key,
    required this.displayedMonth,
    required this.selectedStartDate,
  });

  /// 해당 월의 날짜 수 계산
  int _daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final year = displayedMonth.year;
    final month = displayedMonth.month;

    // 해당 월 1일의 요일 (일=0, 월=1, ..., 토=6)
    // Flutter DateTime.weekday: 월=1, ..., 일=7 → % 7 → 일=0
    final firstDayOfMonth = DateTime(year, month, 1);
    final startWeekday = firstDayOfMonth.weekday % 7;

    final totalDays = _daysInMonth(year, month);

    // 이전 달 정보
    final prevMonth = month == 1 ? 12 : month - 1;
    final prevYear = month == 1 ? year - 1 : year;
    final prevMonthDays = _daysInMonth(prevYear, prevMonth);

    // 선택된 3일 범위
    final selectedDay1 = DateTime(
      selectedStartDate.year,
      selectedStartDate.month,
      selectedStartDate.day,
    );
    final selectedDay2 = selectedDay1.add(const Duration(days: 1));
    final selectedDay3 = selectedDay1.add(const Duration(days: 2));

    return Column( // 5행 × 7열 = 35 셀
      children: List.generate(5, (row) {
        return Row(
          children: List.generate(7, (col) {
            final cellIndex = row * 7 + col;

            // 날짜 및 현재 달 여부 결정
            final bool isCurrentMonth;
            final int day;
            final int cellYear;
            final int cellMonth;

            if (cellIndex < startWeekday) {
              // 이전 달 날짜
              isCurrentMonth = false;
              day = prevMonthDays - startWeekday + cellIndex + 1;
              cellYear = prevYear;
              cellMonth = prevMonth;
            } else if (cellIndex < startWeekday + totalDays) {
              // 현재 달 날짜
              isCurrentMonth = true;
              day = cellIndex - startWeekday + 1;
              cellYear = year;
              cellMonth = month;
            } else {
              // 다음 달 날짜
              isCurrentMonth = false;
              day = cellIndex - startWeekday - totalDays + 1;
              final nextMonth = month == 12 ? 1 : month + 1;
              final nextYear = month == 12 ? year + 1 : year;
              cellYear = nextYear;
              cellMonth = nextMonth;
            }

            final cellDate = DateTime(cellYear, cellMonth, day);

            // 기본 텍스트 색상 (요일 기준)
            final Color baseColor;
            if (col == 0) {
              baseColor = context.systemRed;
            } else if (col == 6) {
              baseColor = context.systemBlue;
            } else {
              baseColor = context.label;
            }

            // 이전/다음 달 날짜는 opacity 0.3 적용
            final Color textColor =
                isCurrentMonth
                    ? baseColor
                    : baseColor.withValues(alpha: 0.3);

            // 선택 상태 결정
            final bool isSelected1 = cellDate == selectedDay1;
            final bool isSelected2 = cellDate == selectedDay2;
            final bool isSelected3 = cellDate == selectedDay3;

            BoxDecoration? decoration;
            Color finalTextColor = textColor;

            if (isSelected1) {
              // 첫째 날: 배경 label 색, 텍스트 systemBackground
              decoration = BoxDecoration(
                color: context.label,
                borderRadius: BorderRadius.circular(8),
              );
              finalTextColor = context.systemBackground;
            } else if (isSelected2 || isSelected3) {
              // 둘째, 셋째 날: 배경 secondarySystemFill, 텍스트 원래 색상
              decoration = BoxDecoration(
                color: context.secondarySystemFill,
                borderRadius: BorderRadius.circular(8),
              );
            }

            return Expanded(
              child: GestureDetector(
                onTap: () {
                  ref
                      .read(homeCalendarControllerProvider.notifier)
                      .selectDate(cellDate);
                },
                child: Center(
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: decoration ?? const BoxDecoration(),
                    alignment: Alignment.center,
                    child: Text(
                      '$day',
                      style: Theme.of(
                        context,
                      ).textTheme.labelLarge?.copyWith(
                        fontSize: 16,
                        color: finalTextColor,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      }),
    );
  }
}
