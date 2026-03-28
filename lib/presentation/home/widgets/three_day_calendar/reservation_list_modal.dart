import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/domain/entities/reservation_summary.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/grouped_form_container.dart';
import 'package:studio_chance/presentation/home/widgets/three_day_calendar/reservation_cell.dart';

/// N≥4 그룹 이벤트 목록 모달.
///
/// 선택된 [ReservationSummary]를 반환 (취소 시 null).
class ReservationListModal extends StatelessWidget {
  const ReservationListModal({super.key, required this.events});

  final List<ReservationDisplayData> events;

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
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
                          '${timeFormat.format(event.summary.startTime)}~'
                          '${timeFormat.format(event.summary.endTime)}',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
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
    );
  }
}

/// 이벤트 목록 모달 표시 (플랫폼 적응형).
///
/// 선택된 [ReservationSummary]를 반환 (취소 시 null).
Future<ReservationSummary?> showReservationListModal(
    BuildContext context, List<ReservationDisplayData> events) {
  if (Platform.isIOS) {
    return showCupertinoSheet<ReservationSummary>(
      context: context,
      builder: (_) => ReservationListModal(events: events),
    );
  }
  return showModalBottomSheet<ReservationSummary>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => ReservationListModal(events: events),
  );
}
