import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio_chance/presentation/home/widgets/three_day_calendar/all_day_row.dart';
import 'package:studio_chance/presentation/home/widgets/three_day_calendar/three_day_header.dart';
import 'package:studio_chance/presentation/home/widgets/three_day_calendar/time_grid.dart';
import 'package:studio_chance/presentation/providers/home_calendar_controller.dart';

/// 3일 캘린더 최상위 위젯
/// 헤더, 종일 행, 시간 그리드를 조합하며 수평 스와이프로 날짜 이동을 지원함
class ThreeDayCalendar extends ConsumerWidget {
  const ThreeDayCalendar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // 고정 헤더: 3일 날짜 표시
        const ThreeDayHeader(),
        // 고정 종일 이벤트 행
        const AllDayRow(),
        // 스크롤 가능한 시간 그리드 (수평 스와이프로 날짜 이동)
        Expanded(
          child: GestureDetector(
            onHorizontalDragEnd: (details) {
              final dx = details.velocity.pixelsPerSecond.dx;
              if (dx.abs() > 300) {
                // 왼쪽 스와이프 → 미래(+1일), 오른쪽 스와이프 → 과거(-1일)
                ref
                    .read(homeCalendarControllerProvider.notifier)
                    .navigateDays(dx < 0 ? 1 : -1);
              }
            },
            child: const TimeGrid(),
          ),
        ),
      ],
    );
  }
}
