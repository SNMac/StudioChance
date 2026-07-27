import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/domain/entities/reservation_summary.dart';
import 'package:studio_chance/presentation/colors.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';
import 'package:studio_chance/presentation/commons/extensions/store_color_extensions.dart';
import 'package:studio_chance/presentation/commons/widgets/app_bar/modal_app_bar.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/grouped_form_container.dart';
import 'package:studio_chance/presentation/commons/widgets/safe_area_with_padding.dart';
import 'package:studio_chance/presentation/commons/widgets/modal_grabber.dart';
import 'package:studio_chance/presentation/home/widgets/three_day_calendar/reservation_cell.dart';

final _timeFormat = DateFormat('HH:mm');

const double _kModalInitialSize = 0.5;
const double _kModalMaxSize = 1.0;

/// N≥4 그룹 이벤트 목록 모달.
///
/// 선택된 [ReservationSummary]를 반환 (취소 시 null).
/// 배경/shape/barrierColor는 [showReservationListModal]의 showModalBottomSheet가 제공.
/// Grabber는 [ModalGrabber] 컴포넌트 사용.
///
/// 두 detent 시트: [showReservationListModal]이 `maxAvailableHeight`를 전달하고,
/// 이 위젯이 [AnimationController]로 높이를 직접 제어한다 (CLAUDE.md "모달 시트 패턴").
class ReservationListModal extends StatefulWidget {
  const ReservationListModal({
    super.key,
    required this.events,
    required this.maxAvailableHeight,
  });

  final List<ReservationDisplayData> events;
  final double maxAvailableHeight;

  @override
  State<ReservationListModal> createState() => _ReservationListModalState();
}

class _ReservationListModalState extends State<ReservationListModal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _sheetController;
  double _grabberDragStartSize = _kModalInitialSize;
  double _grabberDragStartY = 0;

  @override
  void initState() {
    super.initState();
    _sheetController = AnimationController(
      vsync: this,
      value: _kModalInitialSize,
      lowerBound: _kModalInitialSize,
      upperBound: _kModalMaxSize,
    );
  }

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  void _dismissModal() {
    Navigator.pop(context);
  }

  void _animateTo(double target) {
    _sheetController.animateTo(
      target,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _snapToNearest() {
    const mid = (_kModalInitialSize + _kModalMaxSize) / 2;
    _animateTo(_sheetController.value >= mid ? _kModalMaxSize : _kModalInitialSize);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _sheetController,
      builder: (ctx, child) => SizedBox(
        height: widget.maxAvailableHeight * _sheetController.value,
        child: child,
      ),
      child: Material(
        color: context.systemGroupedBackground,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(modalTopCornerRadius),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 그라버·앱바 영역 드래그 → 시트 높이 직접 제어.
            // Listener(raw pointer)로 제스처 아레나 완전 우회.
            Listener(
              behavior: HitTestBehavior.translucent,
              onPointerDown: (event) {
                _grabberDragStartSize = _sheetController.value;
                _grabberDragStartY = event.position.dy;
              },
              onPointerMove: (event) {
                final delta = -event.delta.dy / widget.maxAvailableHeight;
                _sheetController.value = (_sheetController.value + delta)
                    .clamp(_kModalInitialSize, _kModalMaxSize);
              },
              onPointerUp: (event) {
                final totalDy = event.position.dy - _grabberDragStartY;
                if (totalDy.abs() < 10) return;
                if (totalDy > 30) {
                  if (_grabberDragStartSize <= _kModalInitialSize + 0.05) {
                    _dismissModal();
                  } else {
                    _animateTo(_kModalInitialSize);
                  }
                } else if (totalDy < -30) {
                  _animateTo(_kModalMaxSize);
                } else {
                  _snapToNearest();
                }
              },
              onPointerCancel: (_) => _snapToNearest(),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ModalGrabber(),
                  ModalAppBar(title: '예약 목록'),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: SafeAreaWithPadding(
                  top: false,
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    horizontalPadding,
                    16,
                    horizontalPadding,
                    8,
                  ),
                  child: GroupedFormContainer(
                    children: [
                      for (final event in widget.events)
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
        ),
      ),
    );
  }
}

/// 이벤트 목록 모달 표시.
///
/// iOS/Android 공통으로 [showModalBottomSheet] 사용.
/// - barrierColor: 20% 불투명 검정 (scrim)
/// - shape: 상단 코너 radius 10 ([ReservationListModal] 내부 Material에서 적용)
/// - Grabber: [ReservationListModal] 위젯 내부 렌더링 (iOS 스타일 커스텀)
/// - 두 detent(0.5 / 1.0): 그라버·앱바 영역 드래그로 전환, 초기 크기 아래로
///   더 당기면 dismiss
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
    enableDrag: false,
    backgroundColor: Colors.transparent,
    barrierColor: modalBarrierColor,
    builder: (ctx) => LayoutBuilder(
      builder: (_, constraints) => ReservationListModal(
        events: events,
        maxAvailableHeight: constraints.maxHeight,
      ),
    ),
  );
}
