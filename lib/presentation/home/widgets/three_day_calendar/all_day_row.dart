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
                // 우측: 3열 균등 빈 영역 (이벤트 추후 추가)
                const Expanded(
                  child: Row(
                    children: [
                      Expanded(child: SizedBox()),
                      Expanded(child: SizedBox()),
                      Expanded(child: SizedBox()),
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
