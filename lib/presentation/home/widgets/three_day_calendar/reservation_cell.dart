import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:studio_chance/domain/entities/reservation_summary.dart';
import 'package:studio_chance/common/enums/reservation_status.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';
import 'package:studio_chance/presentation/commons/extensions/phone_formatter.dart';
import 'package:studio_chance/presentation/commons/extensions/store_color_extensions.dart';

// ── 예약 셀 표시용 데이터 ─────────────────────────────────────────────────────

/// 예약 셀 렌더링에 필요한 최소 데이터.
/// [summary]는 도메인 ReservationSummary를 그대로 사용.
/// [isContinuation] / [continuesNextDay]는 셀 분할 로직에서만 추가됨.
class ReservationDisplayData {
  const ReservationDisplayData({
    required this.summary,
    this.isContinuation = false,
    this.continuesNextDay = false,
  });

  final ReservationSummary summary;

  /// true: 이전 날에서 이어지는 연속 셀 (텍스트·아이콘 미표시, 배경+스트립만)
  final bool isContinuation;

  /// true: 다음 날로 이어지는 셀 (하단 코너·여백 없음)
  final bool continuesNextDay;
}

// ── 예약 셀 위젯 ──────────────────────────────────────────────────────────────

class ReservationCell extends StatelessWidget {
  const ReservationCell({
    super.key,
    required this.data,
    this.clipContent = false,
    this.isHighlighted = false,
    this.contentRightInset = 0,
  });

  final ReservationDisplayData data;

  /// true: 스택 front/middle 셀 — 단일행, TextOverflow.clip
  /// false: 스택 back 셀 또는 단독 셀 — FittedBox scaleDown
  final bool clipContent;

  /// true: 배경 = foregroundColor, 스트립 = foregroundColor, 라벨 = white
  final bool isHighlighted;

  /// `clipContent=true`일 때 우측에 추가로 확보할 여백 (배지 등과 겹치지 않도록)
  final double contentRightInset;

  BorderRadius get _cellBorderRadius {
    const r = Radius.circular(4);
    return BorderRadius.only(
      topLeft: data.isContinuation ? Radius.zero : r,
      topRight: data.isContinuation ? Radius.zero : r,
      bottomLeft: data.continuesNextDay ? Radius.zero : r,
      bottomRight: data.continuesNextDay ? Radius.zero : r,
    );
  }

  @override
  Widget build(BuildContext context) {
    final storeColor = data.summary.storeSummary.color;
    final bgColor = isHighlighted
        ? Color(storeColor.foregroundColorValue)
        : Color(storeColor.backgroundColorValue);
    final fgColor = Color(storeColor.foregroundColorValue);
    final lblColor = isHighlighted ? Colors.white : Color(storeColor.labelColorValue);
    final borderRadius = _cellBorderRadius;

    return ClipRRect(
      borderRadius: borderRadius,
      child: Stack(
        children: [
          // 전체 배경
          Container(color: bgColor),

          // 좌측 4px 스트립
          // isHighlighted=true: fgColor == bgColor → 시각적으로 단일 색상
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: SizedBox(
              width: 4,
              child: ColoredBox(color: fgColor),
            ),
          ),

          // 외곽선 overlay
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: context.systemBackground,
                width: 0.5,
              ),
              borderRadius: borderRadius,
            ),
          ),

          // isContinuation=true: 배경+스트립만 (텍스트·아이콘 없음)
          if (!data.isContinuation)
            Positioned.fill(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(width: 8),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: 1.5,
                        right: clipContent ? contentRightInset : 4,
                      ),
                      child: clipContent
                          ? _buildClipContent(context, lblColor)
                          : FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.topLeft,
                              child: _buildContentRow(context, lblColor),
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

  Widget _buildClipContent(BuildContext context, Color lblColor) {
    final style = Theme.of(context).textTheme.labelSmall?.copyWith(color: lblColor);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 15.0,
          child: Center(
            child: _StatusIcon(status: data.summary.status, color: lblColor),
          ),
        ),
        const SizedBox(width: 2.5),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${data.summary.customerName} · ${data.summary.headCount}인',
                style: style,
                maxLines: 1,
                overflow: TextOverflow.clip,
              ),
              Text(
                data.summary.customerPhone.formattedPhone,
                style: style,
                maxLines: 1,
                overflow: TextOverflow.clip,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContentRow(BuildContext context, Color lblColor) {
    final style = Theme.of(context).textTheme.labelSmall?.copyWith(color: lblColor);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 15.0,
          child: Center(
            child: _StatusIcon(status: data.summary.status, color: lblColor),
          ),
        ),
        const SizedBox(width: 2.5),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${data.summary.customerName} · ${data.summary.headCount}인',
              style: style,
              maxLines: 1,
            ),
            Text(
              data.summary.customerPhone.formattedPhone,
              style: style,
              maxLines: 1,
            ),
          ],
        ),
      ],
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
        ReservationStatus.pending =>
          'assets/images/icons/circle_dashed.svg',
        ReservationStatus.canceled =>
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
