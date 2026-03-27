import 'package:flutter/material.dart';
import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/presentation/home/widgets/three_day_calendar/reservation_cell.dart';

/// 3일 캘린더 종일 이벤트 셀 (날짜 1열)
class AllDayCell extends StatelessWidget {
  const AllDayCell({super.key, required this.events});

  final List<ReservationDisplayData> events;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: allDayRowHeight,
      child: Stack(
        // TODO: 다중 이벤트 겹침 처리 미구현 — 현재는 단순 Stack (겹쳐 보임)
        children: [
          for (final event in events)
            Positioned(
              left: 1,
              right: 8,
              top: 1,
              bottom: 4,
              child: ReservationCell(data: event),
            ),
        ],
      ),
    );
  }
}
