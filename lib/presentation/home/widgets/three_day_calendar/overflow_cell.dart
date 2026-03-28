import 'package:flutter/material.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';
import 'package:studio_chance/presentation/home/widgets/three_day_calendar/reservation_cell.dart';

/// 동일 시간대에 이벤트가 너무 많아 균등 분할 시 1글자도 표시할 수 없을 때
/// 개별 셀 대신 표시되는 오버플로우 표시 셀.
///
/// TODO: 셀 색상 미확정 (사용자 결정 대기).
///       현재: tertiarySystemFill 배경 + 멀티컬러 스트립 (추천안 임시 적용).
/// TODO: 탭 시 겹쳐진 이벤트 목록 모달 표시 (미구현).
class OverflowCell extends StatelessWidget {
  const OverflowCell({super.key, required this.events});

  /// 이 셀로 대체된 겹침 이벤트 목록 (z 순서 — 낮은 z 먼저)
  final List<ReservationDisplayData> events;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Stack(
        children: [
          // 배경 (임시: tertiarySystemFill — 사용자 결정 후 교체)
          Container(color: context.tertiarySystemFill),

          // 좌측 4px 멀티컬러 스트립 (각 이벤트의 foreground 색상 균등 분할)
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: SizedBox(
              width: 4,
              child: Column(
                children: [
                  for (final event in events)
                    Expanded(
                      child: ColoredBox(
                        color: event.colorTheme.foregroundColor,
                      ),
                    ),
                ],
              ),
            ),
          ),

          // 외곽선 overlay (systemBackground, 0.5px, radius 4)
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: context.systemBackground,
                width: 0.5,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
          ),

          // 이벤트 수 표시
          Center(
            child: Text(
              '${events.length}개',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: context.secondaryLabel,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
