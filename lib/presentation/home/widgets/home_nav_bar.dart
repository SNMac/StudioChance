import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';
import 'package:studio_chance/presentation/providers/home_calendar_controller.dart';

/// 홈 화면 네비게이션 바
class HomeNavBar extends ConsumerWidget {
  const HomeNavBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeCalendarControllerProvider);
    final notifier = ref.read(homeCalendarControllerProvider.notifier);

    // 네비게이션 바에 표시할 연월 텍스트
    final month = state.displayedMonth;
    final monthText = '${month.year}년 ${month.month}월';
    final today = DateTime.now().day;
    final navBarHeight = Platform.isIOS ? homeNavBarHeight : kToolbarHeight;

    return Container(
      height: navBarHeight,
      color: context.systemBackground,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          // 좌측: 연월 + chevron 버튼
          GestureDetector(
            onTap: notifier.toggleMonthlyCalendar,
            child: SizedBox(
              height: navBarHeight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    monthText,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: context.label,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  _ChevronIcon(
                    isUp: state.isMonthlyCalendarVisible,
                    color: context.label,
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          // 우측: 버튼 2개
          Row(
            children: [
              // calendar_circle 버튼 (날짜 picker 표시)
              GestureDetector(
                onTap: () => _showDatePicker(context, ref, state),
                child: SizedBox(
                  width: 44.0,
                  height: navBarHeight,
                  child: Center(
                    child: Icon(
                      CupertinoIcons.calendar_circle,
                      size: 20.0,
                      color: context.label,
                    ),
                  ),
                ),
              ),
              // 오늘 날짜 원형 버튼
              GestureDetector(
                onTap: notifier.goToToday,
                child: SizedBox(
                  width: 44.0,
                  height: navBarHeight,
                  child: Center(
                    child: Container(
                      width: 20.0,
                      height: 20.0,
                      decoration: BoxDecoration(
                        color: context.label,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$today',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: context.systemBackground,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 플랫폼별 날짜 picker 모달 표시
  void _showDatePicker(
    BuildContext context,
    WidgetRef ref,
    HomeCalendarState state,
  ) {
    if (Platform.isIOS) {
      // grabber + 끌어내려서 dismiss 지원 (showModalBottomSheet + enableDrag)
      // 완료 버튼에서만 날짜 적용 (StatefulBuilder로 임시 날짜 관리)
      DateTime tempDate = state.selectedStartDate;
      showModalBottomSheet<void>(
        context: context,
        enableDrag: true,
        backgroundColor: CupertinoColors.systemBackground.resolveFrom(context),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        ),
        builder: (ctx) => StatefulBuilder(
          builder: (ctx, setModalState) => SizedBox(
            height: 360,
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Grabber
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 8, bottom: 4),
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey3.resolveFrom(ctx),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // 완료 버튼
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CupertinoButton(
                        child: const Text('완료'),
                        onPressed: () {
                          Navigator.pop(ctx);
                          ref
                              .read(homeCalendarControllerProvider.notifier)
                              .selectDate(tempDate);
                        },
                      ),
                    ],
                  ),
                  // 날짜 picker
                  Expanded(
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.date,
                      initialDateTime: state.selectedStartDate,
                      onDateTimeChanged: (date) =>
                          setModalState(() => tempDate = date),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      showDatePicker(
        context: context,
        initialDate: state.selectedStartDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      ).then((date) {
        if (date != null) {
          ref.read(homeCalendarControllerProvider.notifier).selectDate(date);
        }
      });
    }
  }
}

/// 네비바 chevron 아이콘 (너비 12, 높이 7)
class _ChevronIcon extends StatelessWidget {
  const _ChevronIcon({required this.isUp, required this.color});

  final bool isUp;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(12, 7),
      painter: _ChevronPainter(color: color, isUp: isUp),
    );
  }
}

class _ChevronPainter extends CustomPainter {
  _ChevronPainter({required this.color, required this.isUp});

  final Color color;
  final bool isUp;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    if (isUp) {
      path.moveTo(0, size.height);
      path.lineTo(size.width / 2, 0);
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(0, 0);
      path.lineTo(size.width / 2, size.height);
      path.lineTo(size.width, 0);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ChevronPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.isUp != isUp;
}
