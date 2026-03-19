import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';

/// 현재 시간 인디케이터 위젯
/// 1분마다 자동으로 갱신되며, 좌측 캡슐(시간 표시)과 우측 수평선으로 구성됨
class CurrentTimeIndicator extends ConsumerStatefulWidget {
  const CurrentTimeIndicator({super.key, required this.hourHeight});

  final double hourHeight;

  /// 현재 시간 기준 top 위치를 계산하여 반환
  /// 캡슐이 시간 레이블과 수직으로 정렬되도록 캡슐 높이의 절반만큼 위로 이동
  /// 상위 위젯(TimeGrid)에서 Positioned 배치 시 사용
  static double topPosition(double hourHeight) {
    final now = DateTime.now();
    return hourHeight * (now.hour + now.minute / 60) -
        currentTimeCapsuleHeight / 2;
  }

  @override
  ConsumerState<CurrentTimeIndicator> createState() =>
      _CurrentTimeIndicatorState();
}

class _CurrentTimeIndicatorState extends ConsumerState<CurrentTimeIndicator> {
  late Timer _timer;
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _scheduleNextUpdate();
  }

  /// 다음 분 정각에 맞춰 타이머 설정 후 1분 간격으로 반복
  void _scheduleNextUpdate() {
    final now = DateTime.now();
    // 다음 분 정각까지 남은 시간 계산
    final nextMinute = DateTime(now.year, now.month, now.day, now.hour, now.minute)
        .add(const Duration(minutes: 1));
    final delay = nextMinute.difference(now);

    _timer = Timer(delay, () {
      if (!mounted) return;
      setState(() => _now = DateTime.now());
      // 이후 1분 간격으로 반복
      _timer = Timer.periodic(const Duration(minutes: 1), (_) {
        if (!mounted) return;
        setState(() => _now = DateTime.now());
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  /// 현재 시간을 "HH:MM" 형식으로 반환
  String get _timeText {
    final hour = _now.hour.toString().padLeft(2, '0');
    final minute = _now.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 캡슐 좌측 여백: 시간 레이블 위에 오도록 위치 조정
        // 캡슐 우측이 timeColumnWidth + 0.5(구분선)에 맞닿도록
        SizedBox(width: timeColumnWidth + 0.5 - currentTimeCapsuleWidth),
        // 캡슐: 현재 시간 표시
        Container(
          width: currentTimeCapsuleWidth,
          height: currentTimeCapsuleHeight,
          decoration: BoxDecoration(
            color: context.systemRed,
            borderRadius: BorderRadius.circular(100),
          ),
          alignment: Alignment.center,
          child: Text(
            _timeText,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  height: 1.0,
                  color: context.white,
                ),
          ),
        ),
        // 우측 수평선
        Expanded(
          child: Container(
            height: currentTimeLineThickness,
            color: context.systemRed,
          ),
        ),
      ],
    );
  }
}
