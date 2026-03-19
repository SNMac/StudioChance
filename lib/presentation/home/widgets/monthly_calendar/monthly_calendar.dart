import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';
import 'package:studio_chance/presentation/home/widgets/monthly_calendar/monthly_calendar_grid.dart';
import 'package:studio_chance/presentation/home/widgets/monthly_calendar/monthly_calendar_header.dart';
import 'package:studio_chance/presentation/providers/home_calendar_controller.dart';

/// 월간 캘린더 (요일 헤더 + 날짜 그리드 조합)
class MonthlyCalendar extends ConsumerWidget {
  const MonthlyCalendar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeCalendarControllerProvider);
    return ColoredBox(
      color: context.systemBackground,
      child: Column(
        children: [
          const MonthlyCalendarHeader(),
          MonthlyCalendarGrid(
            displayedMonth: state.displayedMonth,
            selectedStartDate: state.selectedStartDate,
          ),
        ],
      ),
    );
  }
}
