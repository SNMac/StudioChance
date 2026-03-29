import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/domain/entities/reservation_summary.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/grouped_form_container.dart';
import 'package:studio_chance/presentation/home/widgets/three_day_calendar/reservation_cell.dart';

final _timeFormat = DateFormat('HH:mm');

/// N≥4 그룹 이벤트 목록 모달.
///
/// 선택된 [ReservationSummary]를 반환 (취소 시 null).
/// 배경/shape/DragHandle은 show 함수의 showModalBottomSheet/showCupertinoSheet가 제공.
class ReservationListModal extends StatelessWidget {
  const ReservationListModal({
    super.key,
    required this.events,
    this.scrollController,
  });

  final List<ReservationDisplayData> events;

  /// DraggableScrollableSheet에서 전달받는 ScrollController (Android 전용).
  /// SingleChildScrollView에 연결하여 드래그 확장/축소를 활성화.
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
        controller: scrollController,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: GroupedFormContainer(
              children: [
                for (final event in events)
                  SizedBox(
                    height: inputFormComponentHeight,
                    child: CupertinoButton(
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      onPressed: () => Navigator.pop(context, event.summary),
                      child: Row(
                        children: [
                          // 색상 도트
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(event.summary.storeSummary.color
                                  .foregroundColorValue),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // 고객명
                          Expanded(
                            child: Text(
                              event.summary.customerName,
                              style: Theme.of(context).textTheme.bodyLarge,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // 시간 범위
                          Text(
                            '${_timeFormat.format(event.summary.startTime)}~'
                            '${_timeFormat.format(event.summary.endTime)}',
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.normal,
                                      color: context.secondaryLabel,
                                    ),
                          ),
                          const SizedBox(width: 12),
                          // chevron
                          Icon(
                            CupertinoIcons.chevron_forward,
                            size: 10,
                            color: context.tertiaryLabel,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  }
}

/// 이벤트 목록 모달 표시 (플랫폼 적응형).
///
/// iOS: [showCupertinoSheet] + showDragHandle + topGap 절반 높이
/// Android: [showModalBottomSheet] + [DraggableScrollableSheet]
///   - snap: [0.5, 1.0] — 살짝 내리면 0.5로 스냅백, 세게 내리면 minChildSize(0.3) 도달 → dismiss
///
/// 선택된 [ReservationSummary]를 반환 (취소 시 null).
Future<ReservationSummary?> showReservationListModal(
    BuildContext context, List<ReservationDisplayData> events) {
  if (Platform.isIOS) {
    return showCupertinoSheet<ReservationSummary>(
      context: context,
      showDragHandle: true,
      topGap: 0.5,
      builder: (_) => ReservationListModal(events: events),
    );
  }
  return showModalBottomSheet<ReservationSummary>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 1.0,
      expand: false,
      snap: true,
      snapSizes: const [0.5, 1.0],
      builder: (_, controller) => ReservationListModal(
        events: events,
        scrollController: controller,
      ),
    ),
  );
}
