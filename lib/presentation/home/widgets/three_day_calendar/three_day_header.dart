import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';
import 'package:studio_chance/presentation/providers/home_calendar_controller.dart';

/// 3일 캘린더 헤더 위젯
/// selectedStartDate 기준 3일의 요일/일자를 표시하며 하단 구분선을 포함함
class ThreeDayHeader extends ConsumerWidget {
  const ThreeDayHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeCalendarControllerProvider);
    final start = state.selectedStartDate;

    // selectedStartDate 기준 3일 목록 생성
    final days = List.generate(3, (i) => start.add(Duration(days: i)));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            // 좌측 시간 컬럼 너비 확보
            SizedBox(width: timeColumnWidth),
            // 3열 날짜 헤더
            Expanded(
              child: Row(
                children: days
                    .map((day) => Expanded(child: _DayHeaderCell(date: day)))
                    .toList(),
              ),
            ),
          ],
        ),
        // 하단 구분선
        Divider(
          height: 0.5,
          thickness: 0.5,
          color: context.separator,
        ),
      ],
    );
  }
}

/// 하루 날짜 헤더 셀: 요일 텍스트 + 일자 표시
class _DayHeaderCell extends StatelessWidget {
  const _DayHeaderCell({required this.date});

  final DateTime date;

  static const _weekdayLabels = ['월', '화', '수', '목', '금', '토', '일'];

  String get _weekdayLabel => _weekdayLabels[date.weekday - 1];

  bool get _isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool get _isSaturday => date.weekday == DateTime.saturday;
  bool get _isSunday => date.weekday == DateTime.sunday;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 6),
        // 요일 텍스트
        Text(
          _weekdayLabel,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: _weekdayTextColor(context),
              ),
        ),
        const SizedBox(height: 2),
        // 일자 표시
        _buildDayNumber(context),
        const SizedBox(height: 6),
      ],
    );
  }

  /// 요일 텍스트 색상 결정
  Color _weekdayTextColor(BuildContext context) {
    if (_isToday) return context.label;
    if (_isSaturday) return context.systemBlue;
    if (_isSunday) return context.systemRed;
    return context.secondaryLabel;
  }

  /// 일자 숫자 색상 결정 (비오늘 기준)
  Color _dayNumberColor(BuildContext context) {
    if (_isSaturday) return context.systemBlue;
    if (_isSunday) return context.systemRed;
    return context.secondaryLabel;
  }

  /// 일자 표시 위젯 빌드
  Widget _buildDayNumber(BuildContext context) {
    final dayText = date.day.toString();

    if (_isToday) {
      // 오늘: 원형 배경 컨테이너
      return Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: context.label,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          dayText,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: context.systemBackground,
              ),
        ),
      );
    }

    // 비오늘: 일반 텍스트
    return Text(
      dayText,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: _dayNumberColor(context),
          ),
    );
  }
}
