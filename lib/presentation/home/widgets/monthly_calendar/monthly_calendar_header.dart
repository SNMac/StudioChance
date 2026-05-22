import 'package:flutter/material.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';

/// 월간 캘린더 요일 헤더 (일~토 7열)
class MonthlyCalendarHeader extends StatelessWidget {
  const MonthlyCalendarHeader({super.key});

  static const _weekdays = ['일', '월', '화', '수', '목', '금', '토'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(_weekdays.length, (index) {
        // 일요일(0): 빨강, 토요일(6): 파랑, 나머지: secondaryLabel
        final Color color;
        if (index == 0) {
          color = context.systemRed;
        } else if (index == 6) {
          color = context.systemBlue;
        } else {
          color = context.secondaryLabel;
        }

        return Expanded(
          child: Center(
            child: Text(
              _weekdays[index],
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: color,
              ),
            ),
          ),
        );
      }),
    );
  }
}
