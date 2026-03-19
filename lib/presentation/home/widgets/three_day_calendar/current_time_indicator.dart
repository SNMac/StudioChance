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
  /// 상위 위젯(TimeGrid)에서 Positioned 배치 시 사용
  static double topPosition(double hourHeight) {
    final now = DateTime.now();
    return hourHeight * (now.hour + now.minute / 60);
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
    // 1분마다 현재 시간 갱신
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      setState(() {
        _now = DateTime.now();
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
        // 좌측 캡슐: 현재 시간 표시
        Container(
          width: currentTimeCapsuleWidth,
          height: currentTimeCapsuleHeight,
          decoration: BoxDecoration(
            color: context.systemRed,
            borderRadius: BorderRadius.circular(currentTimeCapsuleHeight / 2),
          ),
          alignment: Alignment.center,
          child: Text(
            _timeText,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 10,
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
