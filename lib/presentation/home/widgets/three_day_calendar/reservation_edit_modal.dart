import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:studio_chance/constants/data_constants.dart';
import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/domain/entities/reservation.dart';
import 'package:studio_chance/domain/entities/store_summary.dart';
import 'package:studio_chance/domain/enums/reservation_status.dart';
import 'package:studio_chance/presentation/colors.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';
import 'package:studio_chance/presentation/commons/widgets/app_bar/app_bar_action_button.dart';
import 'package:studio_chance/presentation/commons/widgets/app_bar/modal_app_bar.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/grouped_form_container.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/memo_text_field.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/title_date_time_button.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/title_navigation_button.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/title_popup_button.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/title_switch_button.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/title_text_field.dart';
import 'package:studio_chance/presentation/commons/widgets/modal_grabber.dart';
import 'package:studio_chance/presentation/commons/widgets/safe_area_with_padding.dart';

/// 예약 수정 모달.
///
/// [reservation]의 기존 값으로 폼을 pre-fill하고, 완료 탭 시 수정된 [Reservation]을
/// [onSaved] 콜백으로 전달한다.
///
/// 저장 책임은 호출자에게 위임 — 이 위젯은 UI/상태만 담당.
class ReservationEditModal extends ConsumerStatefulWidget {
  const ReservationEditModal({
    super.key,
    required this.reservation,
    required this.availableStores,
    required this.onSaved,
    this.scrollController,
  });

  final Reservation reservation;

  /// 예약 점포 선택 팝업에 표시할 점포 목록.
  /// TODO: 실제 데이터 연결 시 Home Provider에서 사용자 가입 점포 목록으로 교체.
  final List<StoreSummary> availableStores;

  /// 완료 탭 시 수정된 Reservation을 전달하는 콜백.
  final void Function(Reservation) onSaved;

  /// DraggableScrollableSheet에서 전달받는 ScrollController (Android 전용).
  final ScrollController? scrollController;

  @override
  ConsumerState<ReservationEditModal> createState() =>
      _ReservationEditModalState();
}

class _ReservationEditModalState extends ConsumerState<ReservationEditModal> {
  // ── 폼 상태 ──────────────────────────────────────────────────────────────
  late StoreSummary _storeSummary;
  late ReservationStatus _status;
  late bool _isAllDay;
  late DateTime _startTime;
  late DateTime _endTime;
  late String _platform;
  late String _paymentMethod;

  // ── 텍스트 컨트롤러 ──────────────────────────────────────────────────────
  late final TextEditingController _nameController;
  late final TextEditingController _headCountController;
  late final TextEditingController _phoneController;
  late final TextEditingController _memoController;
  late final TextEditingController _priceController;
  late final TextEditingController _adjustmentController;

  // ── 날짜 피커 열림 상태 ──────────────────────────────────────────────────
  bool _isStartPickerOpen = false;
  bool _isEndPickerOpen = false;

  // ── 유효성 ───────────────────────────────────────────────────────────────
  bool get _isValid {
    final headCount = int.tryParse(_headCountController.text) ?? 0;
    return _nameController.text.trim().isNotEmpty &&
        headCount > 0 &&
        (_isAllDay || _startTime.isBefore(_endTime));
  }

  @override
  void initState() {
    super.initState();
    final r = widget.reservation;
    _storeSummary = r.storeSummary;
    _status = r.status;
    _isAllDay = r.isAllDay;
    _startTime = r.startTime;
    _endTime = r.endTime;
    _platform = reservationPlatforms.contains(r.platform)
        ? r.platform
        : reservationPlatforms.first;
    _paymentMethod = paymentMethods.contains(r.paymentMethod)
        ? r.paymentMethod
        : paymentMethods.first;

    _nameController = TextEditingController(text: r.customerName);
    _headCountController = TextEditingController(
      text: r.headCount > 0 ? r.headCount.toString() : '',
    );
    _phoneController = TextEditingController(text: r.customerPhone);
    _memoController = TextEditingController(text: r.memo);
    _priceController = TextEditingController(
      text: r.calculatedPrice > 0 ? r.calculatedPrice.toString() : '',
    );
    _adjustmentController = TextEditingController(
      text: r.priceAdjustment != 0 ? r.priceAdjustment.toString() : '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _headCountController.dispose();
    _phoneController.dispose();
    _memoController.dispose();
    _priceController.dispose();
    _adjustmentController.dispose();
    super.dispose();
  }

  // ── 액션 ──────────────────────────────────────────────────────────────────

  void _onAllDayChanged(bool value) {
    setState(() {
      _isAllDay = value;
      if (value) {
        _startTime = DateTime(
          _startTime.year,
          _startTime.month,
          _startTime.day,
        );
        _endTime = DateTime(
          _endTime.year,
          _endTime.month,
          _endTime.day,
          23,
          59,
        );
      }
      _isStartPickerOpen = false;
      _isEndPickerOpen = false;
    });
  }

  void _onComplete() {
    final calculatedPrice = int.tryParse(_priceController.text) ?? 0;
    final priceAdjustment = int.tryParse(_adjustmentController.text) ?? 0;

    final updated = widget.reservation.copyWith(
      storeSummary: _storeSummary,
      status: _status,
      customerName: _nameController.text.trim(),
      headCount: int.tryParse(_headCountController.text) ?? 0,
      customerPhone: _phoneController.text.trim(),
      memo: _memoController.text,
      isAllDay: _isAllDay,
      startTime: _startTime,
      endTime: _endTime,
      platform: _platform,
      paymentMethod: _paymentMethod,
      calculatedPrice: calculatedPrice,
      priceAdjustment: priceAdjustment,
      totalPrice: calculatedPrice + priceAdjustment,
    );
    widget.onSaved(updated);
    Navigator.pop(context);
  }

  // ── 날짜/시간 포맷 헬퍼 ──────────────────────────────────────────────────

  String _formatDateTime(DateTime dt, {bool dateOnly = false}) {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final weekday = weekdays[dt.weekday - 1];
    final date =
        '${dt.year}. ${dt.month.toString().padLeft(2, '0')}. ${dt.day.toString().padLeft(2, '0')}. ($weekday)';
    if (dateOnly) return date;
    return '$date ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  // ── 빌드 ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: context.systemGroupedBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ModalGrabber(),
          ModalAppBar(
            title: '예약 수정',
            leading: AppBarActionButton(
              label: '취소',
              isRegularWeight: true,
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              AppBarActionButton(
                label: '완료',
                onPressed: _isValid ? _onComplete : null,
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: widget.scrollController,
              keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
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
                    _buildSection1(textTheme),
                    _buildSection2(),
                    _buildSection3(),
                    _buildSection4(textTheme),
                    _buildSection5(textTheme),
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

  Widget _buildSection1(TextTheme textTheme) {
    return GroupedFormContainer(
      children: [
        // 예약 점포
        Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: horizontalPadding,
          ),
          child: TitlePopupButton<StoreSummary>(
            title: '예약 점포',
            selectedValue: _storeSummary,
            items: widget.availableStores,
            itemLabelBuilder: (s) => s.name,
            itemLeadingBuilder: (s) => Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Color(s.color.foregroundColorValue),
                shape: BoxShape.circle,
              ),
            ),
            onSelected: (s) => setState(() => _storeSummary = s),
          ),
        ),
        // 예약 상태
        Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: horizontalPadding,
          ),
          child: TitlePopupButton<ReservationStatus>(
            title: '예약 상태',
            selectedValue: _status,
            items: ReservationStatus.values,
            itemLabelBuilder: (s) => s.displayName,
            onSelected: (s) => setState(() => _status = s),
          ),
        ),
      ],
    );
  }

  // ── 섹션 2: 예약자 정보 ──────────────────────────────────────────────────

  Widget _buildSection2() {
    return GroupedFormContainer(
      children: [
        TitleTextField(
          title: '예약자명',
          controller: _nameController,
          onChanged: (_) => setState(() {}),
          keyboardType: TextInputType.name,
          autocorrect: false,
        ),
        TitleTextField(
          title: '인원',
          controller: _headCountController,
          onChanged: (_) => setState(() {}),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        TitleTextField(
          title: '연락처',
          controller: _phoneController,
          keyboardType: TextInputType.phone,
        ),
        MemoTextField(
          placeholder: '메모',
          controller: _memoController,
          maxLength: maxMemoCharCount,
          inputFormatters: [
            LengthLimitingTextInputFormatter(maxMemoCharCount),
          ],
        ),
      ],
    );
  }

  // ── 섹션 3: 일시 정보 ────────────────────────────────────────────────────

  Widget _buildSection3() {
    return GroupedFormContainer(
      children: [
        TitleSwitchButton(
          title: '하루종일',
          value: _isAllDay,
          onChanged: _onAllDayChanged,
        ),
        TitleDateTimeButton(
          title: '입실 일시',
          content: _formatDateTime(_startTime, dateOnly: _isAllDay),
          isOpen: _isStartPickerOpen,
          onPressed: () => setState(() {
            _isStartPickerOpen = !_isStartPickerOpen;
            if (_isStartPickerOpen) _isEndPickerOpen = false;
          }),
          mode: _isAllDay
              ? CupertinoDatePickerMode.date
              : CupertinoDatePickerMode.dateAndTime,
          initialDateTime: _startTime,
          onDateTimeChanged: (dt) => setState(() => _startTime = dt),
        ),
        TitleDateTimeButton(
          title: '퇴실 일시',
          content: _formatDateTime(_endTime, dateOnly: _isAllDay),
          isOpen: _isEndPickerOpen,
          onPressed: () => setState(() {
            _isEndPickerOpen = !_isEndPickerOpen;
            if (_isEndPickerOpen) _isStartPickerOpen = false;
          }),
          mode: _isAllDay
              ? CupertinoDatePickerMode.date
              : CupertinoDatePickerMode.dateAndTime,
          initialDateTime: _endTime,
          onDateTimeChanged: (dt) => setState(() {
            _endTime = dt;
            // 유효성 재평가
          }),
        ),
      ],
    );
  }

  // ── 섹션 4: 결제 정보 ────────────────────────────────────────────────────

  Widget _buildSection4(TextTheme textTheme) {
    return GroupedFormContainer(
      footer: Padding(
        padding: const EdgeInsetsDirectional.only(
          start: horizontalPadding,
          top: 8,
        ),
        child: Text(
          '할인인 경우 -[값]을 입력해주세요',
          style: textTheme.labelMedium?.copyWith(
            color: context.secondaryLabel,
          ),
        ),
      ),
      children: [
        // 예약 플랫폼
        Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: horizontalPadding,
          ),
          child: TitlePopupButton<String>(
            title: '예약 플랫폼',
            selectedValue: _platform,
            items: reservationPlatforms,
            itemLabelBuilder: (s) => s,
            onSelected: (s) => setState(() => _platform = s),
          ),
        ),
        // 결제 방식
        Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: horizontalPadding,
          ),
          child: TitlePopupButton<String>(
            title: '결제 방식',
            selectedValue: _paymentMethod,
            items: paymentMethods,
            itemLabelBuilder: (s) => s,
            onSelected: (s) => setState(() => _paymentMethod = s),
          ),
        ),
        TitleTextField(
          title: '요금',
          controller: _priceController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        TitleTextField(
          title: '추가 요금/할인',
          controller: _adjustmentController,
          keyboardType: const TextInputType.numberWithOptions(signed: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^-?\d*')),
          ],
        ),
      ],
    );
  }

  // ── 섹션 5: 안내문 ────────────────────────────────────────────────────────

  Widget _buildSection5(TextTheme textTheme) {
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
          style: textTheme.bodyMedium?.copyWith(
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

// ── show 함수 ──────────────────────────────────────────────────────────────

/// 예약 수정 모달 표시 (플랫폼 적응형).
///
/// iOS: [showCupertinoSheet] — 네이티브 시트 물리 애니메이션.
/// Android: [showModalBottomSheet] + [DraggableScrollableSheet].
///
/// [onSaved]는 완료 탭 시 수정된 [Reservation]을 전달받는 콜백.
/// 실제 저장은 호출자에서 Use Case를 통해 처리.
Future<void> showReservationEditModal(
  BuildContext context, {
  required Reservation reservation,
  required List<StoreSummary> availableStores,
  required void Function(Reservation) onSaved,
}) {
  if (Platform.isIOS) {
    return showCupertinoSheet<void>(
      context: context,
      builder: (_) => ReservationEditModal(
        reservation: reservation,
        availableStores: availableStores,
        onSaved: onSaved,
      ),
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
      // TODO: 피그마 기준 특정 입력칸이 보이는 높이로 조정 (현재 0.6 임시)
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 1.0,
      expand: false,
      snap: true,
      snapSizes: const [0.6, 1.0],
      builder: (_, controller) => ReservationEditModal(
        reservation: reservation,
        availableStores: availableStores,
        onSaved: onSaved,
        scrollController: controller,
      ),
    ),
  );
}
