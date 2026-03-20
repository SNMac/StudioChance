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
              // 점포 필터 버튼 (애플 캘린더의 "캘린더 선택"과 유사)
              // 시각적 크기: 24×24 (오늘 날짜 버튼과 동일)
              GestureDetector(
                onTap: () => _showStoreFilter(context),
                child: SizedBox(
                  width: 44.0,
                  height: navBarHeight,
                  child: Center(
                    child: Icon(
                      CupertinoIcons.calendar_circle,
                      size: 24.0,
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
                      width: 24.0,
                      height: 24.0,
                      decoration: BoxDecoration(
                        color: context.label,
                        borderRadius: BorderRadius.circular(12.0),
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

  /// 점포 필터 모달 표시
  /// TODO: 실제 점포 목록 데이터 연동 필요 (점포/멤버 도메인)
  void _showStoreFilter(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      enableDrag: true,
      backgroundColor: CupertinoColors.systemBackground.resolveFrom(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (ctx) => SafeArea(
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
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('점포 필터 (구현 예정)'),
            ),
          ],
        ),
      ),
    );
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
