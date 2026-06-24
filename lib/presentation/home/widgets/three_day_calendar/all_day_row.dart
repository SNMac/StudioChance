import 'package:flutter/material.dart';
import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/domain/entities/reservation.dart';
import 'package:studio_chance/presentation/home/widgets/three_day_calendar/reservation_cell.dart';

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

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: widget.isInteractionBlocked,
      child: SizedBox(
      height: allDayRowHeight,
      child: Stack(
        // TODO: 다중 이벤트 겹침 처리 미구현 — 현재는 단순 Stack (겹쳐 보임)
        children: [
          for (final event in widget.events)
            Positioned(
              left: 1,
              right: 8,
              top: 1,
              bottom: 4,
              child: GestureDetector(
                onTap: () => _onCellTap(event),
                child: ReservationCell(
                  data: event,
                  isHighlighted: _highlightedId == event.summary.id,
                ),
              ),
            ),
        ],
      ),
    ),
    );
  }
}
