import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/domain/entities/reservation.dart';
import 'package:studio_chance/domain/entities/store_summary.dart';
import 'package:studio_chance/domain/use_cases/reservation_use_case.dart';
import 'package:studio_chance/presentation/home/widgets/three_day_calendar/reservation_cell.dart';
import 'package:studio_chance/presentation/home/widgets/three_day_calendar/reservation_detail_modal.dart';
import 'package:studio_chance/presentation/providers/home_reservations_provider.dart';

/// 3일 캘린더 종일 이벤트 셀 (날짜 1열)
class AllDayCell extends ConsumerStatefulWidget {
  const AllDayCell({
    super.key,
    required this.events,
    required this.reservations,
    this.availableStores,
  });

  final List<ReservationDisplayData> events;

  /// 탭 시 상세 모달에 전달할 전체 Reservation 맵 (id → Reservation)
  final Map<String, Reservation> reservations;

  /// 예약 점포 선택 팝업에 표시할 점포 목록.
  final List<StoreSummary>? availableStores;

  @override
  ConsumerState<AllDayCell> createState() => _AllDayCellState();
}

class _AllDayCellState extends ConsumerState<AllDayCell> {
  final Logger _logger = Logger();
  String? _highlightedId;

  Future<void> _onCellTap(ReservationDisplayData event) async {
    final reservation = widget.reservations[event.summary.id];
    if (reservation == null) return;
    setState(() => _highlightedId = event.summary.id);
    if (!mounted) return;
    await showReservationDetailModal(
      context,
      reservation,
      availableStores: widget.availableStores,
      onSaved: (updated) {
        ref
            .read(reservationUseCaseProvider)
            .updateReservation(reservation: updated)
            .then((result) {
          result.fold(
            (e) => _logger.e('예약 수정 실패', error: e),
            (_) => ref.invalidate(homeReservationsProvider),
          );
        });
      },
    );
    if (!mounted) return;
    setState(() => _highlightedId = null);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
    );
  }
}
