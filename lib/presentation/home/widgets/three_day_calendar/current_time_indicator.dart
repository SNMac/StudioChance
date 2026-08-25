import 'dart:async';

import 'package:flutter/material.dart';
import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';

/// 현재 시간의 캡슐 top 위치 계산
/// 캡슐 중앙 = hourHeight * (hour + minute/60) = 정확한 현재 시간 위치
/// 시간 레이블도 동일 기준으로 중앙 정렬되므로 y축 일치
double currentTimeTopPosition(double hourHeight) {
  final now = DateTime.now();
  return hourHeight * (now.hour + now.minute / 60) -
      currentTimeCapsuleHeight / 2;
}

/// 현재 시간 캡슐 위젯 (고정 시간 열 Stack의 직접 자식으로 배치)
/// Positioned를 직접 반환하므로 타이머 rebuild 시 top 위치가 자동 갱신됨
class CurrentTimeCapsule extends StatefulWidget {
  const CurrentTimeCapsule({super.key, required this.hourHeight});

  final double hourHeight;

  @override
  State<CurrentTimeCapsule> createState() => _CurrentTimeCapsuleState();
}

class _CurrentTimeCapsuleState extends State<CurrentTimeCapsule> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _scheduleNextUpdate();
  }

  void _scheduleNextUpdate() {
    final now = DateTime.now();
    final nextMinute = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute,
    ).add(const Duration(minutes: 1));
    _timer = Timer(nextMinute.difference(now), () {
      if (!mounted) return;
      setState(() {});
      _timer = Timer.periodic(const Duration(minutes: 1), (_) {
        if (!mounted) return;
        setState(() {});
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final timeText =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    return Positioned(
      top: currentTimeTopPosition(widget.hourHeight),
      right: currentTimeCapsuleRightInset, // 시간 열 오른쪽 끝에서 캡슐까지 여백
      child: Container(
        width: currentTimeCapsuleWidth,
        height: currentTimeCapsuleHeight,
        decoration: BoxDecoration(
          color: context.systemRed,
          borderRadius: BorderRadius.circular(100),
        ),
        alignment: Alignment.center,
        child: Text(
          timeText,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: 10,
            height: 1.0,
            color: context.white,
          ),
        ),
      ),
    );
  }
}

/// 현재 시간 수평선 위젯 (날짜 열 event grid Stack의 직접 자식으로 배치)
/// Positioned를 직접 반환하므로 타이머 rebuild 시 top 위치가 자동 갱신됨
/// isToday: true → systemRed, false → systemRed 30% opacity
class CurrentTimeLine extends StatefulWidget {
  const CurrentTimeLine({
    super.key,
    required this.hourHeight,
    required this.isToday,
  });

  final double hourHeight;
  final bool isToday;

  @override
  State<CurrentTimeLine> createState() => _CurrentTimeLineState();
}

class _CurrentTimeLineState extends State<CurrentTimeLine> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _scheduleNextUpdate();
  }

  void _scheduleNextUpdate() {
    final now = DateTime.now();
    final nextMinute = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute,
    ).add(const Duration(minutes: 1));
    _timer = Timer(nextMinute.difference(now), () {
      if (!mounted) return;
      setState(() {});
      _timer = Timer.periodic(const Duration(minutes: 1), (_) {
        if (!mounted) return;
        setState(() {});
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 선의 top = 캡슐 top + capsuleHeight/2 (캡슐 중앙 = 선 y좌표)
    final top =
        currentTimeTopPosition(widget.hourHeight) +
        currentTimeCapsuleHeight / 2;
    final color = widget.isToday
        ? context.systemRed
        : context.systemRed.withValues(alpha: 0.3);
    // left: -currentTimeCapsuleRightInset → 캡슐 오른쪽 끝과 선의 시작점을 맞춤
    // TimeGrid Stack은 clipBehavior: Clip.none 설정 필요
    // (수직 구분선 overlay가 위에 렌더링되어 시각적으로는 날짜 열 시작부터 보임)
    return Positioned(
      top: top,
      left: -currentTimeCapsuleRightInset,
      right: 0,
      child: Container(height: currentTimeLineThickness, color: color),
    );
  }
}
