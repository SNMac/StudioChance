import 'package:flutter/material.dart';
import 'package:studio_chance/constants/ui_constants.dart';

/// 3일 캘린더 종일 이벤트 셀 (날짜 1열)
/// 추후 종일 이벤트를 표시할 영역. 현재는 빈 상태.
class AllDayCell extends StatelessWidget {
  const AllDayCell({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: allDayRowHeight,
    );
  }
}
