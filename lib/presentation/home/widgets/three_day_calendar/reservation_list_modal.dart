import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/domain/entities/reservation_summary.dart';
import 'package:studio_chance/presentation/colors.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';
import 'package:studio_chance/presentation/commons/widgets/app_bar/modal_app_bar.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/grouped_form_container.dart';
import 'package:studio_chance/presentation/commons/widgets/modal_body_padding.dart';
import 'package:studio_chance/presentation/commons/widgets/modal_grabber.dart';
import 'package:studio_chance/presentation/home/widgets/three_day_calendar/reservation_cell.dart';

final _timeFormat = DateFormat('HH:mm');

/// N≥4 그룹 이벤트 목록 모달.
///
/// 선택된 [ReservationSummary]를 반환 (취소 시 null).
/// 배경/shape/barrierColor는 [showReservationListModal]의 showModalBottomSheet가 제공.
/// Grabber는 [ModalGrabber] 컴포넌트 사용.
class ReservationListModal extends StatelessWidget {
  const ReservationListModal({
    super.key,
    required this.events,
    this.scrollController,
  });

  final List<ReservationDisplayData> events;

  /// DraggableScrollableSheet에서 전달받는 ScrollController.
  /// SingleChildScrollView에 연결하여 드래그 확장/축소를 활성화.
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ModalGrabber(),
        const ModalAppBar(title: '예약 목록'),
        Expanded(
          child: SingleChildScrollView(
            controller: scrollController,
            child: ModalBodyPadding(
              child: GroupedFormContainer(
                  children: [
                    for (final event in events)
                      SizedBox(
                        height: inputFormComponentHeight,
                        child: CupertinoButton(
                          padding: const EdgeInsetsDirectional.symmetric(
                            horizontal: horizontalPadding,
                          ),
                          onPressed: () =>
                              Navigator.pop(context, event.summary),
                          child: Row(
                            children: [
                              // 색상 도트
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(
                                    event
                                        .summary
                                        .storeSummary
                                        .color
                                        .foregroundColorValue,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // 고객명 · 인원
                              Expanded(
                                child: Text(
                                  '${event.summary.customerName} · ${event.summary.headCount}인',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              // 시간 범위
                              Text(
                                '${_timeFormat.format(event.summary.startTime)}~'
                                '${_timeFormat.format(event.summary.endTime)}',
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.normal,
                                      color: context.secondaryLabel,
                                    ),
                              ),
                              const SizedBox(width: 12),
                              // chevron
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 10),
                                child: Icon(
                                  CupertinoIcons.chevron_forward,
                                  color: context.tertiaryLabel,
                                ),
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
      ],
    );
  }
}

/// 이벤트 목록 모달 표시.
///
/// iOS/Android 공통으로 [showModalBottomSheet] 사용.
/// - barrierColor: 20% 불투명 검정 (scrim)
/// - shape: 상단 코너 radius 10
/// - Grabber: [ReservationListModal] 위젯 내부 렌더링 (iOS 스타일 커스텀)
/// - snap: [0.5, 1.0] — 살짝 내리면 0.5로 스냅백, 세게 내리면 minChildSize(0.3) 도달 → dismiss
///
/// 선택된 [ReservationSummary]를 반환 (취소 시 null).
Future<ReservationSummary?> showReservationListModal(
  BuildContext context,
  List<ReservationDisplayData> events,
) {
  return showModalBottomSheet<ReservationSummary>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: context.systemGroupedBackground,
    barrierColor: modalBarrierColor,
    clipBehavior: Clip.antiAlias,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(modalTopCornerRadius),
      ),
    ),
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 1.0,
      expand: false,
      snap: true,
      snapSizes: const [0.5, 1.0],
      builder: (_, controller) =>
          ReservationListModal(events: events, scrollController: controller),
    ),
  );
}
