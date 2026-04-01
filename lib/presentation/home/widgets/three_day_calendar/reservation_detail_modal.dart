import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/domain/entities/reservation.dart';
import 'package:studio_chance/presentation/colors.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';
import 'package:studio_chance/presentation/commons/widgets/app_bar/app_bar_action_button.dart';
import 'package:studio_chance/presentation/commons/widgets/app_bar/modal_app_bar.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/grouped_form_container.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/title_navigation_button.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/title_switch_button.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/title_text_label.dart';
import 'package:studio_chance/presentation/commons/widgets/modal_grabber.dart';
import 'package:studio_chance/presentation/commons/widgets/safe_area_with_padding.dart';
import 'package:studio_chance/presentation/home/widgets/three_day_calendar/reservation_edit_modal.dart';

/// 예약 확인 모달 (읽기 전용).
///
/// 편집 모달([ReservationEditModal])과 동일한 5개 섹션 레이아웃을 사용하되,
/// 모든 필드는 읽기 전용으로 표시된다.
class ReservationDetailModal extends StatelessWidget {
  const ReservationDetailModal({
    super.key,
    required this.reservation,
    this.scrollController,
  });

  final Reservation reservation;

  /// DraggableScrollableSheet에서 전달받는 ScrollController (Android 전용).
  final ScrollController? scrollController;

  void _onEdit(BuildContext context) {
    Navigator.pop(context);
    // TODO: availableStores 실제 데이터 연결 시 교체 필요
    showReservationEditModal(
      context,
      reservation: reservation,
      availableStores: [reservation.storeSummary],
      onSaved: (_) {
        // TODO: 저장 Use Case 연결
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.systemGroupedBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ModalGrabber(),
          ModalAppBar(
            title: '예약 정보',
            leading: AppBarActionButton(
              label: '취소',
              isRegularWeight: true,
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              AppBarActionButton(
                label: '편집',
                onPressed: () => _onEdit(context),
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              child: SafeAreaWithPadding(
                top: false,
                padding: const EdgeInsetsDirectional.fromSTEB(
                  horizontalPadding,
                  16,
                  horizontalPadding,
                  32,
                ),
                child: Column(
                  spacing: 20,
                  children: [
                    _buildSection1(),
                    _buildSection2(context),
                    _buildSection3(),
                    _buildSection4(),
                    _buildSection5(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 섹션 1: 기본 정보 ────────────────────────────────────────────────────

  Widget _buildSection1() {
    return GroupedFormContainer(
      children: [
        TitleTextLabel(
          title: '예약 점포',
          content: reservation.storeSummary.name,
        ),
        TitleTextLabel(
          title: '예약 상태',
          content: reservation.status.displayName,
        ),
      ],
    );
  }

  // ── 섹션 2: 예약자 정보 ──────────────────────────────────────────────────

  Widget _buildSection2(BuildContext context) {
    return GroupedFormContainer(
      children: [
        TitleTextLabel(
          title: '예약자명',
          content: reservation.customerName,
        ),
        TitleTextLabel(
          title: '인원',
          content: reservation.headCount.toString(),
        ),
        TitleTextLabel(
          title: '연락처',
          content: reservation.customerPhone,
        ),
        _ReadOnlyMemo(text: reservation.memo),
      ],
    );
  }

  // ── 섹션 3: 일시 정보 ────────────────────────────────────────────────────

  Widget _buildSection3() {
    return GroupedFormContainer(
      children: [
        TitleSwitchButton(
          title: '하루종일',
          value: reservation.isAllDay,
          onChanged: null,
        ),
        TitleTextLabel(
          title: '입실 일시',
          content: _formatDateTime(
            reservation.startTime,
            dateOnly: reservation.isAllDay,
          ),
        ),
        TitleTextLabel(
          title: '퇴실 일시',
          content: _formatDateTime(
            reservation.endTime,
            dateOnly: reservation.isAllDay,
          ),
        ),
      ],
    );
  }

  // ── 섹션 4: 결제 정보 ────────────────────────────────────────────────────

  Widget _buildSection4() {
    return GroupedFormContainer(
      children: [
        TitleTextLabel(
          title: '예약 플랫폼',
          content: reservation.platform,
        ),
        TitleTextLabel(
          title: '결제 방식',
          content: reservation.paymentMethod,
        ),
        TitleTextLabel(
          title: '요금',
          content: reservation.calculatedPrice.toString(),
        ),
        TitleTextLabel(
          title: '추가 요금/할인',
          content: reservation.priceAdjustment.toString(),
        ),
      ],
    );
  }

  // ── 섹션 5: 안내문 ────────────────────────────────────────────────────────

  Widget _buildSection5(BuildContext context) {
    // TODO: 실제 n번째 계산 로직 연결 (현재 1 하드코딩)
    const int reservationCount = 1;

    return GroupedFormContainer(
      header: Padding(
        padding: const EdgeInsetsDirectional.only(
          start: horizontalPadding,
          bottom: 8,
        ),
        child: Text(
          '$reservationCount번째 예약입니다.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: context.secondaryLabel,
          ),
        ),
      ),
      children: [
        TitleNavigationButton(
          title: '입금 안내문',
          onPressed: () {
            // TODO: 입금 안내문 화면 연결
          },
        ),
        TitleNavigationButton(
          title: '확정 안내문',
          onPressed: () {
            // TODO: 확정 안내문 화면 연결
          },
        ),
      ],
    );
  }
}

// ── Private 위젯 ───────────────────────────────────────────────────────────

/// 메모 읽기 전용 표시 위젯.
///
/// 메모 내용을 멀티라인으로 표시. 비어있으면 placeholder 스타일.
class _ReadOnlyMemo extends StatelessWidget {
  const _ReadOnlyMemo({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final isEmpty = text.isEmpty;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: inputFormComponentHeight),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(
          horizontalPadding,
          12,
          horizontalPadding,
          12,
        ),
        child: Align(
          alignment: AlignmentDirectional.topStart,
          child: Text(
            isEmpty ? '메모' : text,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.normal,
              color: isEmpty
                  ? context.tertiaryLabel
                  : context.label,
            ),
          ),
        ),
      ),
    );
  }
}

// ── 날짜/시간 포맷 헬퍼 ───────────────────────────────────────────────────

String _formatDateTime(DateTime dt, {bool dateOnly = false}) {
  const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
  final weekday = weekdays[dt.weekday - 1];
  final date =
      '${dt.year}. ${dt.month.toString().padLeft(2, '0')}. ${dt.day.toString().padLeft(2, '0')}. ($weekday)';
  if (dateOnly) return date;
  return '$date ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

// ── show 함수 ──────────────────────────────────────────────────────────────

/// 예약 확인 모달 표시 (플랫폼 적응형).
Future<void> showReservationDetailModal(
  BuildContext context,
  Reservation reservation,
) {
  if (Platform.isIOS) {
    return showCupertinoSheet<void>(
      context: context,
      builder: (_) => ReservationDetailModal(reservation: reservation),
    );
  }
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    barrierColor: modalBarrierColor,
    clipBehavior: Clip.antiAlias,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(modalTopCornerRadius),
      ),
    ),
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 1.0,
      expand: false,
      snap: true,
      snapSizes: const [0.6, 1.0],
      builder: (_, controller) => ReservationDetailModal(
        reservation: reservation,
        scrollController: controller,
      ),
    ),
  );
}
