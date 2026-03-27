import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:studio_chance/presentation/colors.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';

// ── 예약 상태 ────────────────────────────────────────────────────────────────

enum ReservationStatus {
  confirmed,      // 예약 확정 (checkmark_circle_fill)
  pendingPayment, // 입금 대기 (circle_dashed)
  cancelled,      // 예약 취소 (circle_slash)
}

// ── 색상 테마 ────────────────────────────────────────────────────────────────

enum ReservationCellColorTheme {
  red,
  orange,
  yellow,
  green,
  blue,
  indigo,
  purple;

  Color get backgroundColor => switch (this) {
        ReservationCellColorTheme.red => redBackground,
        ReservationCellColorTheme.orange => orangeBackground,
        ReservationCellColorTheme.yellow => yellowBackground,
        ReservationCellColorTheme.green => greenBackground,
        ReservationCellColorTheme.blue => blueBackground,
        ReservationCellColorTheme.indigo => indigoBackground,
        ReservationCellColorTheme.purple => purpleBackground,
      };

  Color get foregroundColor => switch (this) {
        ReservationCellColorTheme.red => redForeground,
        ReservationCellColorTheme.orange => orangeForeground,
        ReservationCellColorTheme.yellow => yellowForeground,
        ReservationCellColorTheme.green => greenForeground,
        ReservationCellColorTheme.blue => blueForeground,
        ReservationCellColorTheme.indigo => indigoForeground,
        ReservationCellColorTheme.purple => purpleForeground,
      };

  Color get labelColor => switch (this) {
        ReservationCellColorTheme.red => redLabel,
        ReservationCellColorTheme.orange => orangeLabel,
        ReservationCellColorTheme.yellow => yellowLabel,
        ReservationCellColorTheme.green => greenLabel,
        ReservationCellColorTheme.blue => blueLabel,
        ReservationCellColorTheme.indigo => indigoLabel,
        ReservationCellColorTheme.purple => purpleLabel,
      };
}

// ── 예약 셀 표시용 데이터 ─────────────────────────────────────────────────────

/// 예약 셀 표시용 임시 뷰 모델.
/// TODO: 예약(Reservation) 도메인 엔티티 정의 후 교체 예정.
class ReservationDisplayData {
  const ReservationDisplayData({
    required this.reserverName,
    required this.headcount,
    required this.phoneNumber,
    required this.status,
    required this.colorTheme,
    required this.isAllDay,
    this.date,
    this.startTime,
    this.endTime,
  });

  final String reserverName;
  final int headcount;
  final String phoneNumber;
  final ReservationStatus status;
  final ReservationCellColorTheme colorTheme;
  final bool isAllDay;

  /// 종일 이벤트가 속한 날짜 (isAllDay = true 일 때 사용)
  final DateTime? date;

  /// 시간대 이벤트 시작 시간 (isAllDay = false 일 때 사용)
  final DateTime? startTime;

  /// 시간대 이벤트 종료 시간 (isAllDay = false 일 때 사용)
  final DateTime? endTime;
}

// ── 예약 셀 위젯 ──────────────────────────────────────────────────────────────

class ReservationCell extends StatelessWidget {
  const ReservationCell({super.key, required this.data});

  final ReservationDisplayData data;

  @override
  Widget build(BuildContext context) {
    final bgColor = data.colorTheme.backgroundColor;
    final fgColor = data.colorTheme.foregroundColor;
    final lblColor = data.colorTheme.labelColor;

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Stack(
        children: [
          // 전체 배경 (~Background: 연한 색)
          Container(color: bgColor),

          // 좌측 4px 진한 스트립 (~Foreground: 진한 색)
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: SizedBox(
              width: 4,
              child: ColoredBox(color: fgColor),
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

          // 콘텐츠 Row
          Positioned.fill(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 4px 스트립 너비 + 라벨 영역 왼쪽에서 4px 간격
                const SizedBox(width: 8),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4, right: 4),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.topLeft,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // labelSmall 라인 높이(15px) 기준으로 아이콘과 첫 번째 텍스트 중앙 정렬
                          SizedBox(
                            height: 15.0,
                            child: Center(
                              child: _StatusIcon(
                                status: data.status,
                                color: lblColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 2.5),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${data.reserverName} · ${data.headcount}인',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(color: lblColor),
                                maxLines: 1,
                              ),
                              Text(
                                data.phoneNumber,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(color: lblColor),
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── 상태 아이콘 ───────────────────────────────────────────────────────────────

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({required this.status, required this.color});

  final ReservationStatus status;
  final Color color;

  static String _svgPath(ReservationStatus status) => switch (status) {
        ReservationStatus.confirmed =>
          'assets/images/icons/checkmark_circle_fill.svg',
        ReservationStatus.pendingPayment =>
          'assets/images/icons/circle_dashed.svg',
        ReservationStatus.cancelled =>
          'assets/images/icons/circle_slash.svg',
      };

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      _svgPath(status),
      width: 10,
      height: 10,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
