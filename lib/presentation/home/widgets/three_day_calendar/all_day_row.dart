import 'package:flutter/material.dart';
import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';

/// 3일 캘린더 종일 이벤트 행 위젯
/// 스크롤과 무관하게 항상 상단에 고정되며, 추후 종일 이벤트를 표시할 영역을 제공함
class AllDayRow extends StatelessWidget {
  const AllDayRow({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: allDayRowHeight,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 좌측: "종일" 텍스트 레이블
                SizedBox(
                  width: timeColumnWidth,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      '종일',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: context.secondaryLabel,
                          ),
                    ),
                  ),
                ),
                // 시간 열↔날짜 열 구분선은 ThreeDayCalendar Stack 오버레이에서 처리
                const SizedBox(width: 1.5),
                // 우측: 3열 균등 빈 영역 (이벤트 추후 추가, 열 사이 구분선 포함)
                Expanded(
                  child: Row(
                    children: [
                      const Expanded(child: SizedBox()),
                      Container(width: 0.5, color: context.separator),
                      const Expanded(child: SizedBox()),
                      Container(width: 0.5, color: context.separator),
                      const Expanded(child: SizedBox()),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // 하단 구분선
          Divider(
            height: calendarDividerThickness,
            thickness: calendarDividerThickness,
            color: context.separator,
          ),
        ],
      ),
    );
  }
}
