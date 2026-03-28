import 'dart:math' show max;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';
import 'package:studio_chance/presentation/home/widgets/three_day_calendar/current_time_indicator.dart';
import 'package:studio_chance/presentation/home/widgets/three_day_calendar/overflow_cell.dart';
import 'package:studio_chance/presentation/home/widgets/three_day_calendar/reservation_cell.dart';
import 'package:studio_chance/presentation/providers/home_calendar_controller.dart';

/// 이벤트 1글자를 표시하기 위한 셀 최소 너비 (px)
/// 계산: SizedBox(8) + 아이콘(10) + 간격(2.5) + 한글 1자(≈10) ≈ 31
const double _minCellWidthFor1Char = 31.0;

/// N=2 겹침에서 시작 시간이 다를 때 (delta > 0) 적용하는 고정 stagger (px).
/// back 셀의 foreground strip(4px) + gap(4px) = 8px.
/// 비겹침 구간에서 이름이 충분히 노출되므로, 겹침 구간엔 strip만 노출해도 충분.
const double _differentStartStagger = 8.0;

// ── 위치 계산 결과 ─────────────────────────────────────────────────────────────

class _PositionedItem {
  _PositionedItem.normal({
    required this.event,
    required this.left,
    required this.right,
    required this.clipContent,
  })  : overflowEvents = null,
        overflowStart = null,
        overflowEnd = null;

  _PositionedItem.overflow({
    required List<ReservationDisplayData> events,
    required this.left,
    required this.right,
    required DateTime start,
    required DateTime end,
  })  : event = null,
        clipContent = false,
        overflowEvents = events,
        overflowStart = start,
        overflowEnd = end;

  /// null이면 오버플로우 셀
  final ReservationDisplayData? event;
  final double left;
  final double right;
  final bool clipContent;

  /// 오버플로우 셀 전용
  final List<ReservationDisplayData>? overflowEvents;
  final DateTime? overflowStart;
  final DateTime? overflowEnd;

  bool get isOverflow => event == null;
}

// ── 위치 계산 알고리즘 ─────────────────────────────────────────────────────────

/// 시간대 이벤트의 스택 위치를 계산.
///
/// [columnWidth]: 열 너비 (LayoutBuilder.constraints.maxWidth)
///
/// 알고리즘:
///   1. z 순서 정렬: 시작 빠른것 → 낮은 z (뒤), 같은 시작이면 짧은것 → 낮은 z (뒤)
///   2. 그리디 인터벌 컬러링 → 열 인덱스(col) 배정
///   3. Union-Find: 겹치는 이벤트들을 연결 컴포넌트로 묶음
///   4. 컴포넌트별 N = max(col) + 1
///   5a. N=2 전용 — 시작 시간 차이(delta)에 따른 stagger 결정:
///       - delta == 0 (동시 시작): cellWidth(= usableWidth/2) stagger → 이름 ~3자 표시
///       - delta > 0 (시작 시간 다름): [_differentStartStagger](8px 고정) → strip+gap만 노출
///   5b. 위치 계산: left = 1 + col × stagger, right = 8 고정
///       - cellWidth(= usableWidth/N) ≥ 31px → 스택 배치
///       - cellWidth < 31px → 오버플로우 셀 (N개 이벤트를 1개로 대체)
List<_PositionedItem> _computePositions(
    List<ReservationDisplayData> events, double columnWidth) {
  final usableWidth = columnWidth - 9.0; // 1(left) + 8(right)

  final timeEvents = events
      .where((e) => !e.isAllDay && e.startTime != null && e.endTime != null)
      .toList();

  if (timeEvents.isEmpty) return [];

  // Step 1: z 순서 정렬
  timeEvents.sort((a, b) {
    final startCmp = a.startTime!.compareTo(b.startTime!);
    if (startCmp != 0) return startCmp;
    return a.endTime!.difference(a.startTime!).compareTo(
        b.endTime!.difference(b.startTime!));
  });

  final n = timeEvents.length;

  // Step 2: 그리디 인터벌 컬러링 → 열 인덱스 배정
  // 각 열의 마지막 이벤트 종료 시간을 추적
  // 새 이벤트 시작 ≥ 열 종료 시간 → 해당 열 재사용 가능 (겹치지 않음)
  final columnEndTimes = <DateTime>[];
  final colOf = <int>[];

  for (final event in timeEvents) {
    int col = -1;
    for (int c = 0; c < columnEndTimes.length; c++) {
      if (!columnEndTimes[c].isAfter(event.startTime!)) {
        col = c;
        columnEndTimes[c] = event.endTime!;
        break;
      }
    }
    if (col == -1) {
      col = columnEndTimes.length;
      columnEndTimes.add(event.endTime!);
    }
    colOf.add(col);
  }

  // Step 3: Union-Find — 겹치는 이벤트들을 같은 연결 컴포넌트로 묶음
  final parent = List<int>.generate(n, (i) => i);

  int findRoot(int x) {
    while (parent[x] != x) {
      parent[x] = parent[parent[x]]; // 경로 반분
      x = parent[x];
    }
    return x;
  }

  for (int i = 0; i < n; i++) {
    for (int j = i + 1; j < n; j++) {
      if (timeEvents[i].startTime!.isBefore(timeEvents[j].endTime!) &&
          timeEvents[j].startTime!.isBefore(timeEvents[i].endTime!)) {
        final pi = findRoot(i), pj = findRoot(j);
        if (pi != pj) parent[pi] = pj;
      }
    }
  }

  // Step 4: 컴포넌트별 최대 열 인덱스 → N (동시 최대 겹침 수)
  final compMaxCol = <int, int>{};
  for (int i = 0; i < n; i++) {
    final root = findRoot(i);
    compMaxCol[root] = max(compMaxCol[root] ?? 0, colOf[i]);
  }

  // Step 5a: N=2 컴포넌트 전용 — 시작 시간 차이에 따른 stagger 결정
  // delta == 0 (동시 시작): 겹침 구간에서 이름이 가려지므로
  //                         → cellWidth stagger (이름 ~3자 표시, 반절 방식)
  // delta > 0 (시작 시간 다름): 비겹침 구간에서 이름이 충분히 노출됨
  //                             → 8px 고정 stagger (foreground strip 4px + gap 4px만 노출)
  final compStagger = <int, double>{};
  for (final root in compMaxCol.keys) {
    if (compMaxCol[root]! + 1 != 2) continue;

    final col0 = <int>[], col1 = <int>[];
    for (int k = 0; k < n; k++) {
      if (findRoot(k) != root) continue;
      (colOf[k] == 0 ? col0 : col1).add(k);
    }

    // 직접 겹치는 (col0, col1) 쌍의 최소 시작 시간 차이(분)
    var minDeltaMin = double.infinity;
    for (final a in col0) {
      for (final b in col1) {
        if (timeEvents[a].startTime!.isBefore(timeEvents[b].endTime!) &&
            timeEvents[b].startTime!.isBefore(timeEvents[a].endTime!)) {
          final delta = timeEvents[b]
              .startTime!
              .difference(timeEvents[a].startTime!)
              .inMinutes
              .abs()
              .toDouble();
          if (delta < minDeltaMin) minDeltaMin = delta;
        }
      }
    }

    compStagger[root] =
        minDeltaMin == 0 ? usableWidth / 2 : _differentStartStagger;
  }

  // Step 5b: 위치 계산
  // left = 1 + col × stagger, right = 8 고정 → 뒤 셀을 덮는 스택 구조
  // col > 0 (front/middle) → clipContent=true (단일행 clip)
  // col == 0 (back) → clipContent=false (FittedBox 정상 레이아웃)
  final result = <_PositionedItem>[];
  final overflowHandled = <int>{};

  for (int i = 0; i < n; i++) {
    final root = findRoot(i);
    final numCols = (compMaxCol[root] ?? 0) + 1;
    // cellWidth: 오버플로우 임계값 계산 및 N≥3 stagger에 사용
    final cellWidth = usableWidth / numCols;

    if (cellWidth < _minCellWidthFor1Char) {
      // 오버플로우: 컴포넌트 전체를 1개 OverflowCell로 대체
      if (!overflowHandled.contains(root)) {
        overflowHandled.add(root);
        final compEvents = <ReservationDisplayData>[];
        for (int k = 0; k < n; k++) {
          if (findRoot(k) == root) compEvents.add(timeEvents[k]);
        }
        final groupStart = compEvents
            .map((e) => e.startTime!)
            .reduce((a, b) => a.isBefore(b) ? a : b);
        final groupEnd = compEvents
            .map((e) => e.endTime!)
            .reduce((a, b) => a.isAfter(b) ? a : b);
        result.add(_PositionedItem.overflow(
          events: compEvents,
          left: 1.0,
          right: 8.0,
          start: groupStart,
          end: groupEnd,
        ));
      }
    } else {
      final col = colOf[i];
      // N=2: compStagger 사용 (delta 기준 분기)
      // N≥3: cellWidth stagger (기존 규칙)
      final stagger =
          numCols == 2 ? (compStagger[root] ?? cellWidth) : cellWidth;
      result.add(_PositionedItem.normal(
        event: timeEvents[i],
        left: 1.0 + col * stagger,
        right: 8.0,
        clipContent: col > 0,
      ));
    }
  }

  return result;
}

// ── TimeGrid 위젯 ──────────────────────────────────────────────────────────────

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

    return SingleChildScrollView(
      controller: scrollController,
      physics: const BouncingScrollPhysics(),
      child: SizedBox(
        height: totalHeight,
        // LayoutBuilder로 열 너비를 획득해 오버플로우 임계값 계산에 사용
        child: LayoutBuilder(
          builder: (context, constraints) {
            final positioned =
                _computePositions(events, constraints.maxWidth);

            return Stack(
              // Clip.none: CurrentTimeLine이 left: -currentTimeCapsuleRightInset으로
              // 시간 열 방향으로 0.25px 넘어가는 것을 허용
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
                for (final item in positioned)
                  if (item.isOverflow)
                    Positioned(
                      top: _topOffset(item.overflowStart!, hourHeight),
                      left: item.left,
                      right: item.right,
                      height: _cellHeight(
                          item.overflowStart!, item.overflowEnd!, hourHeight),
                      child: OverflowCell(events: item.overflowEvents!),
                    )
                  else
                    Positioned(
                      top: _topOffset(item.event!.startTime!, hourHeight),
                      left: item.left,
                      right: item.right,
                      height: _cellHeight(
                          item.event!.startTime!, item.event!.endTime!,
                          hourHeight),
                      child: ReservationCell(
                        data: item.event!,
                        clipContent: item.clipContent,
                      ),
                    ),

                // 현재 시간선
                CurrentTimeLine(hourHeight: hourHeight, isToday: isToday),
              ],
            );
          },
        ),
      ),
    );
  }
}
