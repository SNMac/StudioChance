import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';
import 'package:studio_chance/presentation/home/widgets/three_day_calendar/current_time_indicator.dart';
import 'package:studio_chance/presentation/home/widgets/three_day_calendar/reservation_cell.dart';
import 'package:studio_chance/presentation/providers/home_calendar_controller.dart';

// 겹치는 이벤트에서 상단(위) 셀의 시작 위치 (열 왼쪽 끝 기준, px)
// 뒤에 있는 셀의 이름 3자(≈30px)가 노출되도록 설정
// 계산: 뒤 셀 내용 시작(1+4+4+10+2.5=21.5) + 3자(≈30) ≈ 52
const double _overlapTopLeft = 52.0;

class _PositionedEvent {
  const _PositionedEvent({
    required this.event,
    required this.left,
    required this.right,
    required this.clipContent,
  });

  final ReservationDisplayData event;
  final double left;
  final double right; // 열 오른쪽 끝에서의 간격
  final bool clipContent;
}

/// 이벤트 목록을 받아 겹침을 계산하고 시각적 위치를 반환
/// 반환 순서 = z 순서 (낮은 z → 먼저 렌더링 → Stack에서 뒤에 위치)
///
/// z 순서 규칙:
///   - 시작이 빠를수록 낮은 z (뒤에 위치)
///   - 시작이 같으면 짧은 것이 낮은 z (긴 것이 위에 쌓임)
///
/// 열 배정:
///   - 열 0 → 전체 너비 (left=1, right=8), clipContent=false
///   - 열 1+ → 오른쪽 영역 (left=_overlapTopLeft, right=8), clipContent=true
///   - TODO: 3개 이상 겹침 레이아웃 미구현 (열 1과 동일 위치로 처리)
List<_PositionedEvent> _computePositions(List<ReservationDisplayData> events) {
  final timeEvents = events
      .where((e) => !e.isAllDay && e.startTime != null && e.endTime != null)
      .toList();

  // z 순서 정렬: 빠른 시작 → 낮은 z, 같은 시작이면 짧은 것 → 낮은 z
  timeEvents.sort((a, b) {
    final startCmp = a.startTime!.compareTo(b.startTime!);
    if (startCmp != 0) return startCmp;
    final aDur = a.endTime!.difference(a.startTime!);
    final bDur = b.endTime!.difference(b.startTime!);
    return aDur.compareTo(bDur);
  });

  // 열 배정: 각 열의 마지막 이벤트 종료 시간을 추적
  // 새 이벤트의 시작이 열의 종료 시간 이후면 해당 열 재사용 가능
  final columnEndTimes = <DateTime>[];
  final columnAssignments = <int>[];

  for (final event in timeEvents) {
    int assignedColumn = -1;
    for (int col = 0; col < columnEndTimes.length; col++) {
      if (!columnEndTimes[col].isAfter(event.startTime!)) {
        assignedColumn = col;
        columnEndTimes[col] = event.endTime!;
        break;
      }
    }
    if (assignedColumn == -1) {
      assignedColumn = columnEndTimes.length;
      columnEndTimes.add(event.endTime!);
    }
    columnAssignments.add(assignedColumn);
  }

  return [
    for (int i = 0; i < timeEvents.length; i++)
      _PositionedEvent(
        event: timeEvents[i],
        left: columnAssignments[i] == 0 ? 1.0 : _overlapTopLeft,
        right: 8,
        clipContent: columnAssignments[i] > 0,
      ),
  ];
}

/// 3일 캘린더 날짜별 이벤트 그리드
/// 수평 시간 구분선과 현재 시간선을 표시, 수직 스크롤 지원
/// 핀치 줌은 ThreeDayCalendar에서 처리
class TimeGrid extends ConsumerWidget {
  const TimeGrid({
    super.key,
    required this.scrollController,
    required this.isToday,
    required this.events,
  });

  final ScrollController scrollController;

  /// 해당 날짜가 오늘인지 여부 (현재 시간선 색상 결정)
  final bool isToday;

  final List<ReservationDisplayData> events;

  double _topOffset(DateTime start, double hourHeight) =>
      hourHeight * (start.hour + start.minute / 60) + 0.5;

  double _cellHeight(DateTime start, DateTime end, double hourHeight) =>
      (hourHeight * end.difference(start).inMinutes / 60 - 2.0)
          .clamp(1.0, double.infinity);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hourHeight = ref.watch(
      homeCalendarControllerProvider.select((s) => s.hourHeight),
    );
    final totalHeight = hourHeight * 24;
    final positioned = _computePositions(events);

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

            // 시간대 이벤트 셀 (z 순서대로 렌더링 — 먼저 = 뒤에, 나중 = 앞에)
            for (final p in positioned)
              Positioned(
                top: _topOffset(p.event.startTime!, hourHeight),
                left: p.left,
                right: p.right,
                height: _cellHeight(
                    p.event.startTime!, p.event.endTime!, hourHeight),
                child: ReservationCell(
                  data: p.event,
                  clipContent: p.clipContent,
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
