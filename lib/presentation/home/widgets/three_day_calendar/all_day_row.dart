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
  });

  final List<ReservationDisplayData> events;

  /// 탭 시 상세 모달에 전달할 전체 Reservation 맵 (id → Reservation)
  final Map<String, Reservation> reservations;

  /// 예약 셀 탭 시 상세 모달을 여는 콜백 (공간 옵션 선 조회 + 모달 표시 포함).
  final Future<void> Function(Reservation) onOpenDetailModal;

  /// true이면 셀 터치를 완전히 차단한다 (로딩 중 중복 탭 방지).
  final bool isInteractionBlocked;

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

    return AbsorbPointer(
      absorbing: widget.isInteractionBlocked,
      child: SizedBox(
        height: allDayRowHeight,
        child: sortedEvents.isEmpty
            ? const SizedBox.shrink()
            : Stack(
                children: [
                  Positioned(
                    left: 1,
                    right: 8,
                    top: 1,
                    bottom: 4,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => hasOverflow
                          ? _onGroupTap(sortedEvents)
                          : _onCellTap(sortedEvents.first),
                      child: Stack(
                        children: [
                          ReservationCell(
                            data: sortedEvents.first,
                            clipContent: hasOverflow,
                            isHighlighted: _highlightedId ==
                                sortedEvents.first.summary.id,
                          ),
                          if (hasOverflow)
                            Positioned(
                              top: 2,
                              right: 4,
                              child: _OverflowBadge(
                                count: sortedEvents.length - 1,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
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
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: context.secondaryLabel,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
