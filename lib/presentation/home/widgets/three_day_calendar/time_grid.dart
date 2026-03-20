import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';
import 'package:studio_chance/presentation/home/widgets/three_day_calendar/current_time_indicator.dart';
import 'package:studio_chance/presentation/providers/home_calendar_controller.dart';

/// 3일 캘린더 날짜별 이벤트 그리드
/// 수평 시간 구분선과 현재 시간선을 표시, 수직 스크롤 지원
/// 핀치 줌은 ThreeDayCalendar에서 처리
class TimeGrid extends ConsumerWidget {
  const TimeGrid({
    super.key,
    required this.scrollController,
    required this.isToday,
  });

  final ScrollController scrollController;

  /// 해당 날짜가 오늘인지 여부 (현재 시간선 색상 결정)
  final bool isToday;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hourHeight = ref.watch(
      homeCalendarControllerProvider.select((s) => s.hourHeight),
    );
    final totalHeight = hourHeight * 24;

    return SingleChildScrollView(
      controller: scrollController,
      physics: const BouncingScrollPhysics(),
      child: SizedBox(
        height: totalHeight,
        child: Stack(
          // Clip.none: CurrentTimeLine이 left: -currentTimeCapsuleRightInset으로
          // 시간 열 방향으로 0.25px 넘어가는 것을 허용 (수직 구분선 overlay가 위에 렌더링됨)
          clipBehavior: Clip.none,
          children: [
            const SizedBox.expand(),

            // 수평 시간 구분선 (1~23시)
            for (int hour = 1; hour < 24; hour++)
              Positioned(
                top: hourHeight * hour,
                left: 0,
                right: 0,
                child: Divider(
                  height: 0,
                  thickness: calendarDividerThickness,
                  color: context.separator,
                ),
              ),

            // 현재 시간선: CurrentTimeLine이 Positioned를 직접 반환
            CurrentTimeLine(hourHeight: hourHeight, isToday: isToday),
          ],
        ),
      ),
    );
  }
}
