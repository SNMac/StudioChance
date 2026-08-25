import 'package:flutter/material.dart';
import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/domain/entities/reservation.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';
import 'package:studio_chance/presentation/home/utils/calendar_events_utils.dart';
import 'package:studio_chance/presentation/home/widgets/three_day_calendar/reservation_cell.dart';
import 'package:studio_chance/presentation/home/widgets/three_day_calendar/reservation_list_modal.dart';

/// 3일 캘린더 종일 이벤트 셀 (날짜 1열)
class AllDayCell extends StatefulWidget {
  const AllDayCell({
    super.key,
    required this.events,
    required this.reservations,
    required this.onOpenDetailModal,
    required this.isInteractionBlocked,
    required this.isExpanded,
  });

  final List<ReservationDisplayData> events;

  /// 탭 시 상세 모달에 전달할 전체 Reservation 맵 (id → Reservation)
  final Map<String, Reservation> reservations;

  /// 예약 셀 탭 시 상세 모달을 여는 콜백 (공간 옵션 선 조회 + 모달 표시 포함).
  final Future<void> Function(Reservation) onOpenDetailModal;

  /// true이면 셀 터치를 완전히 차단한다 (로딩 중 중복 탭 방지).
  final bool isInteractionBlocked;

  /// true이면 겹친 종일 예약을 세로로 쌓아 표시한다.
  /// false이면 대표 1건 + "+N" 배지로 접는다.
  /// 행 높이는 3일 열이 공유하므로 부모(ThreeDayCalendar)가 결정한다.
  final bool isExpanded;

  @override
  State<AllDayCell> createState() => _AllDayCellState();
}

class _AllDayCellState extends State<AllDayCell> {
  String? _highlightedId;

  Future<void> _onCellTap(ReservationDisplayData event) async {
    final reservation = widget.reservations[event.summary.id];
    if (reservation == null) return;
    setState(() => _highlightedId = event.summary.id);
    if (!mounted) return;
    await widget.onOpenDetailModal(reservation);
    if (!mounted) return;
    setState(() => _highlightedId = null);
  }

  /// N≥2 겹침 셀 탭 — 목록 모달 → 선택 → 상세 모달.
  /// TimeGrid._onCellTap의 groupEvents 분기(N≥4 그룹 처리)와 동일한 흐름.
  Future<void> _onGroupTap(List<ReservationDisplayData> events) async {
    final selected = await showReservationListModal(context, events);
    if (selected == null || !mounted) return;
    setState(() => _highlightedId = selected.id);
    final reservation = widget.reservations[selected.id];
    if (reservation == null) {
      setState(() => _highlightedId = null);
      return;
    }
    if (!mounted) return;
    await widget.onOpenDetailModal(reservation);
    if (!mounted) return;
    setState(() => _highlightedId = null);
  }

  @override
  Widget build(BuildContext context) {
    final sortedEvents = sortAllDayEventsForDisplay(widget.events);
    final hasOverflow = sortedEvents.length >= 2;

    if (sortedEvents.isEmpty) {
      return const SizedBox(height: allDayRowHeight);
    }

    return AbsorbPointer(
      absorbing: widget.isInteractionBlocked,
      child: widget.isExpanded && hasOverflow
          ? _buildExpanded(sortedEvents)
          : _buildCollapsed(sortedEvents, hasOverflow: hasOverflow),
    );
  }

  /// 대표 1건 + "+N" 배지 (1건이거나 접힘 상태).
  Widget _buildCollapsed(
    List<ReservationDisplayData> sortedEvents, {
    required bool hasOverflow,
  }) {
    return _Slot(
      onTap: () => hasOverflow
          ? _onGroupTap(sortedEvents)
          : _onCellTap(sortedEvents.first),
      child: Stack(
        children: [
          ReservationCell(
            data: sortedEvents.first,
            clipContent: hasOverflow,
            isHighlighted: _highlightedId == sortedEvents.first.summary.id,
            contentRightInset: hasOverflow
                ? allDayOverflowBadgeReservedWidth
                : 0,
          ),
          if (hasOverflow)
            Positioned(
              top: 2,
              right: 4,
              child: _OverflowBadge(count: sortedEvents.length - 1),
            ),
        ],
      ),
    );
  }

  /// 세로로 쌓기. [allDayMaxStackCount]칸을 넘으면 마지막 칸이 "+N건 더보기"가 된다.
  Widget _buildExpanded(List<ReservationDisplayData> sortedEvents) {
    final showsMoreRow = sortedEvents.length > allDayMaxStackCount;
    final cellCount = showsMoreRow
        ? allDayMaxStackCount - 1
        : sortedEvents.length;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final event in sortedEvents.take(cellCount))
          _Slot(
            onTap: () => _onCellTap(event),
            child: ReservationCell(
              data: event,
              isHighlighted: _highlightedId == event.summary.id,
            ),
          ),
        if (showsMoreRow)
          _Slot(
            onTap: () => _onGroupTap(sortedEvents),
            child: _MoreRow(count: sortedEvents.length - cellCount),
          ),
      ],
    );
  }
}

/// 종일 행의 한 칸 (높이 [allDayRowHeight], 셀 여백 포함).
class _Slot extends StatelessWidget {
  const _Slot({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: allDayRowHeight,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(1, 1, 8, 4),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: child,
        ),
      ),
    );
  }
}

/// 펼침 상태에서 최대 칸 수를 넘은 나머지를 안내하는 행. 탭하면 목록 모달.
class _MoreRow extends StatelessWidget {
  const _MoreRow({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(start: 4),
        child: Text(
          '+$count건 더보기',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: context.secondaryLabel,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// 종일 셀 겹침 초과 배지 ("+N"). N = 화면에 표시되지 않은 나머지 이벤트 수.
class _OverflowBadge extends StatelessWidget {
  const _OverflowBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: allDayOverflowBadgeHeight,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: context.tertiarySystemFill,
        borderRadius: BorderRadius.circular(allDayOverflowBadgeHeight / 2),
      ),
      alignment: Alignment.center,
      child: Text(
        '+$count',
        // labelSmall의 height:1.5(줄높이 15px)가 배지 높이(14px)보다 커서
        // Align이 라인박스 전체를 기준으로 중앙 정렬하면 살짝 치우쳐 보인다.
        // height:1.0으로 줄박스를 글자 크기에 맞게 좁혀 정확히 중앙에 오도록 한다.
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: context.secondaryLabel,
          fontWeight: FontWeight.w600,
          height: 1.0,
        ),
      ),
    );
  }
}
