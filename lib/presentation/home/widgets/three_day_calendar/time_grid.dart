import 'dart:math' show max;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/domain/entities/reservation.dart';
import 'package:studio_chance/domain/entities/store_summary.dart';
import 'package:studio_chance/domain/use_cases/reservation_use_case.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';
import 'package:studio_chance/presentation/home/widgets/three_day_calendar/current_time_indicator.dart';
import 'package:studio_chance/presentation/home/widgets/three_day_calendar/reservation_cell.dart';
import 'package:studio_chance/presentation/home/widgets/three_day_calendar/reservation_detail_modal.dart';
import 'package:studio_chance/presentation/home/widgets/three_day_calendar/reservation_list_modal.dart';
import 'package:studio_chance/presentation/providers/home_calendar_controller.dart';
import 'package:studio_chance/presentation/providers/home_reservations_provider.dart';

/// N=2 겹침에서 시작 시간이 다를 때 (delta > 0) 적용하는 고정 stagger (px).
/// back 셀의 foreground strip(4px) + gap(4px) = 8px.
const double _differentStartStagger = 8.0;

/// 자정 넘김 셀의 바운스 연장 길이 (px).
const double _bounceExtension = 1000.0;

// ── 위치 계산 결과 ─────────────────────────────────────────────────────────────

class _PositionedItem {
  _PositionedItem({
    required this.event,
    required this.left,
    required this.right,
    required this.clipContent,
    this.groupEvents,
  });

  final ReservationDisplayData event;
  final double left;
  final double right;
  final bool clipContent;

  /// N≥4 그룹: non-null이면 탭 시 이벤트 목록 모달 표시
  final List<ReservationDisplayData>? groupEvents;
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
///       - delta == 0 (동시 시작): cellWidth(= usableWidth/2) stagger
///       - delta > 0 (시작 시간 다름): [_differentStartStagger](8px 고정)
///   5b. 위치 계산: left = 1 + col × stagger, right = 8 고정
///       - N≥4 컴포넌트: groupEvents 채우기 (탭 시 목록 모달)
List<_PositionedItem> _computePositions(
    List<ReservationDisplayData> events, double columnWidth) {
  final usableWidth = columnWidth - 9.0; // 1(left) + 8(right)

  final timeEvents = events
      .where((e) => !e.summary.isAllDay)
      .toList();

  if (timeEvents.isEmpty) return [];

  // Step 1: z 순서 정렬
  timeEvents.sort((a, b) {
    final startCmp = a.summary.startTime.compareTo(b.summary.startTime);
    if (startCmp != 0) return startCmp;
    return a.summary.endTime
        .difference(a.summary.startTime)
        .compareTo(b.summary.endTime.difference(b.summary.startTime));
  });

  final n = timeEvents.length;

  // Step 2: 그리디 인터벌 컬러링 → 열 인덱스 배정
  final columnEndTimes = <DateTime>[];
  final colOf = <int>[];

  for (final event in timeEvents) {
    int col = -1;
    for (int c = 0; c < columnEndTimes.length; c++) {
      if (!columnEndTimes[c].isAfter(event.summary.startTime)) {
        col = c;
        columnEndTimes[c] = event.summary.endTime;
        break;
      }
    }
    if (col == -1) {
      col = columnEndTimes.length;
      columnEndTimes.add(event.summary.endTime);
    }
    colOf.add(col);
  }

  // Step 3: Union-Find — 겹치는 이벤트들을 같은 연결 컴포넌트로 묶음
  final parent = List<int>.generate(n, (i) => i);

  int findRoot(int x) {
    while (parent[x] != x) {
      parent[x] = parent[parent[x]];
      x = parent[x];
    }
    return x;
  }

  for (int i = 0; i < n; i++) {
    for (int j = i + 1; j < n; j++) {
      if (timeEvents[i].summary.startTime.isBefore(timeEvents[j].summary.endTime) &&
          timeEvents[j].summary.startTime.isBefore(timeEvents[i].summary.endTime)) {
        final pi = findRoot(i), pj = findRoot(j);
        if (pi != pj) parent[pi] = pj;
      }
    }
  }

  // Step 4: 컴포넌트별 최대 열 인덱스 → N
  final compMaxCol = <int, int>{};
  for (int i = 0; i < n; i++) {
    final root = findRoot(i);
    compMaxCol[root] = max(compMaxCol[root] ?? 0, colOf[i]);
  }

  // Step 5a: N=2 컴포넌트 전용 — 시작 시간 차이에 따른 stagger 결정
  final compStagger = <int, double>{};
  for (final root in compMaxCol.keys) {
    if (compMaxCol[root]! + 1 != 2) continue;

    final col0 = <int>[], col1 = <int>[];
    for (int k = 0; k < n; k++) {
      if (findRoot(k) != root) continue;
      (colOf[k] == 0 ? col0 : col1).add(k);
    }

    var minDeltaMin = double.infinity;
    for (final a in col0) {
      for (final b in col1) {
        if (timeEvents[a].summary.startTime.isBefore(timeEvents[b].summary.endTime) &&
            timeEvents[b].summary.startTime.isBefore(timeEvents[a].summary.endTime)) {
          final delta = timeEvents[b]
              .summary.startTime
              .difference(timeEvents[a].summary.startTime)
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
  final result = <_PositionedItem>[];

  for (int i = 0; i < n; i++) {
    final root = findRoot(i);
    final numCols = (compMaxCol[root] ?? 0) + 1;
    final cellWidth = usableWidth / numCols;
    final col = colOf[i];
    final stagger = numCols == 2 ? (compStagger[root] ?? cellWidth) : cellWidth;

    // N≥4: groupEvents 채우기 (탭 시 목록 모달 표시)
    List<ReservationDisplayData>? groupEvents;
    if (numCols >= 4) {
      groupEvents = <ReservationDisplayData>[];
      for (int k = 0; k < n; k++) {
        if (findRoot(k) == root) groupEvents.add(timeEvents[k]);
      }
    }

    result.add(_PositionedItem(
      event: timeEvents[i],
      left: 1.0 + col * stagger,
      right: 8.0,
      clipContent: col > 0,
      groupEvents: groupEvents,
    ));
  }

  return result;
}

// ── TimeGrid 위젯 ──────────────────────────────────────────────────────────────

/// 3일 캘린더 날짜별 이벤트 그리드
class TimeGrid extends ConsumerStatefulWidget {
  const TimeGrid({
    super.key,
    required this.scrollController,
    required this.isToday,
    required this.events,
    required this.reservations,
    this.availableStores,
  });

  final ScrollController scrollController;

  /// 해당 날짜가 오늘인지 여부
  final bool isToday;

  final List<ReservationDisplayData> events;

  /// 탭 시 상세 모달에 전달할 전체 Reservation 맵 (id → Reservation)
  final Map<String, Reservation> reservations;

  /// 예약 점포 선택 팝업에 표시할 점포 목록.
  final List<StoreSummary>? availableStores;

  @override
  ConsumerState<TimeGrid> createState() => _TimeGridState();
}

class _TimeGridState extends ConsumerState<TimeGrid> {
  final Logger _logger = Logger();

  /// z-순서 최상단으로 올릴 셀 id
  String? _selectedId;

  /// 하이라이트 중인 셀 id (로컬)
  String? _highlightedId;

  void _onReservationSaved(Reservation updated) {
    ref
        .read(reservationUseCaseProvider)
        .updateReservation(reservation: updated)
        .then((result) {
      result.fold(
        (e) => _logger.e('예약 수정 실패', error: e),
        (_) => ref.invalidate(homeReservationsProvider),
      );
    });
  }

  ({double top, double height}) _placementFor(
      ReservationDisplayData event, double hourHeight) {
    final topGap = event.isContinuation ? 0.0 : 0.5;
    final bottomGap = event.continuesNextDay ? 0.0 : 1.5;
    final start = event.summary.startTime;
    final end = event.summary.endTime;
    var top = hourHeight * (start.hour + start.minute / 60) + topGap;
    var height =
        (hourHeight * end.difference(start).inMinutes / 60 - topGap - bottomGap)
            .clamp(1.0, double.infinity);

    if (event.isContinuation) {
      top -= _bounceExtension;
      height += _bounceExtension;
    }
    if (event.continuesNextDay) {
      height += _bounceExtension;
    }

    return (top: top, height: height);
  }

  Future<void> _onCellTap(_PositionedItem item) async {
    if (item.groupEvents != null) {
      // ② N≥4 그룹 셀 탭 — 목록 모달 → 선택 → 상세 모달
      final selected =
          await showReservationListModal(context, item.groupEvents!);
      if (selected == null || !mounted) return;
      setState(() {
        _highlightedId = selected.id;
        _selectedId = selected.id;
      });
      final reservation = widget.reservations[selected.id];
      if (reservation == null) {
        setState(() {
          _highlightedId = null;
          _selectedId = null;
        });
        return;
      }
      if (!mounted) return;
      await showReservationDetailModal(
        context,
        reservation,
        availableStores: widget.availableStores,
        onSaved: _onReservationSaved,
      );
      if (!mounted) return;
      setState(() {
        _highlightedId = null;
        _selectedId = null;
      });
    } else if (item.event.isContinuation) {
      // ③ isContinuation 셀 탭 — 원본 날짜로 이동 + cross-widget 하이라이트 + 상세 모달
      final reservation = widget.reservations[item.event.summary.id];
      if (reservation == null) return;
      final originalStartTime = reservation.startTime;
      final originalDate = DateTime(
        originalStartTime.year,
        originalStartTime.month,
        originalStartTime.day,
      );
      // notifier를 await 이전에 캡처 → unmount 후에도 안전하게 clear() 호출 가능
      final highlightNotifier = ref.read(pendingHighlightIdProvider.notifier);
      highlightNotifier.set(item.event.summary.id);
      ref
          .read(homeCalendarControllerProvider.notifier)
          .selectDateFromContinuation(originalDate);
      ref.read(scrollToTimeTriggerProvider.notifier).trigger(originalStartTime);
      await showReservationDetailModal(
        context,
        reservation,
        availableStores: widget.availableStores,
        onSaved: _onReservationSaved,
      );
      // Provider 조작은 mounted와 무관하게 안전 (notifier는 위젯 생명주기 독립적)
      highlightNotifier.clear();
    } else {
      // ① 일반 셀 탭
      setState(() {
        _highlightedId = item.event.summary.id;
        _selectedId = item.event.summary.id;
      });
      final reservation = widget.reservations[item.event.summary.id];
      if (reservation == null) {
        setState(() {
          _highlightedId = null;
          _selectedId = null;
        });
        return;
      }
      if (!mounted) return;
      await showReservationDetailModal(
        context,
        reservation,
        availableStores: widget.availableStores,
        onSaved: _onReservationSaved,
      );
      if (!mounted) return;
      setState(() {
        _highlightedId = null;
        _selectedId = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hourHeight = ref.watch(
      homeCalendarControllerProvider.select((s) => s.hourHeight),
    );
    final externalHighlight = ref.watch(pendingHighlightIdProvider);
    final effectiveHighlightId = _highlightedId ?? externalHighlight;
    final totalHeight = hourHeight * 24;

    return SingleChildScrollView(
      controller: widget.scrollController,
      physics: const BouncingScrollPhysics(),
      child: SizedBox(
        height: totalHeight,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final positioned =
                _computePositions(widget.events, constraints.maxWidth);

            // z-순서: _selectedId 셀을 목록 맨 마지막(=맨 앞 z-순서)으로
            final orderedPositioned = _selectedId == null
                ? positioned
                : () {
                    final idx = positioned.indexWhere(
                        (p) => p.event.summary.id == _selectedId);
                    if (idx < 0) return positioned;
                    final result = List<_PositionedItem>.from(positioned);
                    result.add(result.removeAt(idx));
                    return result;
                  }();

            return Stack(
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

                // 이벤트 셀 (z 순서 — 먼저 = 뒤에, 나중 = 앞에)
                for (final item in orderedPositioned)
                  Builder(builder: (context) {
                    final p = _placementFor(item.event, hourHeight);
                    return Positioned(
                      top: p.top,
                      left: item.left,
                      right: item.right,
                      height: p.height,
                      child: GestureDetector(
                        onTap: () => _onCellTap(item),
                        child: ReservationCell(
                          data: item.event,
                          clipContent: item.clipContent,
                          isHighlighted:
                              effectiveHighlightId == item.event.summary.id,
                        ),
                      ),
                    );
                  }),

                // 현재 시간선
                CurrentTimeLine(hourHeight: hourHeight, isToday: widget.isToday),
              ],
            );
          },
        ),
      ),
    );
  }
}
