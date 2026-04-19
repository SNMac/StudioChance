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
import 'package:studio_chance/presentation/commons/widgets/input_form/title_text_label.dart';
import 'package:studio_chance/presentation/commons/widgets/modal_grabber.dart';
import 'package:studio_chance/presentation/commons/widgets/safe_area_with_padding.dart';

/// 예약 확인 모달 (읽기 전용 ↔ 편집 모드 인라인 전환).
///
/// - 읽기 전용: 모든 필드 표시 전용, AppBar에 '편집' 버튼
/// - 편집 모드: 필드 편집 가능, '완료' 탭 시 [onSaved] 콜백 후 읽기 전용 복귀
class ReservationDetailModal extends ConsumerStatefulWidget {
  const ReservationDetailModal({
    super.key,
    required this.reservation,
    required this.onSaved,
    this.availableStores,
    this.scrollController,
  });

  final Reservation reservation;

  /// 완료 탭 시 수정된 Reservation을 전달하는 콜백.
  final void Function(Reservation) onSaved;

  /// 예약 점포 선택 팝업에 표시할 점포 목록.
  /// null이면 [reservation.storeSummary] 단일 항목으로 fallback.
  /// TODO: 실제 데이터 연결 시 Home Provider에서 전달.
  final List<StoreSummary>? availableStores;

  /// DraggableScrollableSheet에서 전달받는 ScrollController (Android 전용).
  final ScrollController? scrollController;

  @override
  ConsumerState<ReservationDetailModal> createState() =>
      _ReservationDetailModalState();
}

class _ReservationDetailModalState
    extends ConsumerState<ReservationDetailModal> {
  // ── 모드 상태 ─────────────────────────────────────────────────────────────
  bool _isEditing = false;

  // ── 편집 상태 ─────────────────────────────────────────────────────────────
  late StoreSummary _storeSummary;
  late ReservationStatus _status;
  late bool _isAllDay;
  late DateTime _startTime;
  late DateTime _endTime;
  late String _platform;
  late String _paymentMethod;

  bool _isStartPickerOpen = false;
  bool _isEndPickerOpen = false;

  // ── 텍스트 컨트롤러 ──────────────────────────────────────────────────────
  late final TextEditingController _nameController;
  late final TextEditingController _headCountController;
  late final TextEditingController _phoneController;
  late final TextEditingController _memoController;
  late final TextEditingController _priceController;
  late final TextEditingController _adjustmentController;

  // ── 유효성 ───────────────────────────────────────────────────────────────
  bool get _isValid {
    final headCount = int.tryParse(_headCountController.text) ?? 0;
    return _nameController.text.trim().isNotEmpty &&
        headCount > 0 &&
        (_isAllDay || _startTime.isBefore(_endTime));
  }

  List<StoreSummary> get _availableStores =>
      widget.availableStores ?? [widget.reservation.storeSummary];

  @override
  void initState() {
    super.initState();
    _initFields(widget.reservation);
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

  // ── 초기화/리셋 ──────────────────────────────────────────────────────────

  void _initFields(Reservation r) {
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

  void _resetFields() {
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

    _nameController.text = r.customerName;
    _headCountController.text = r.headCount > 0 ? r.headCount.toString() : '';
    _phoneController.text = r.customerPhone;
    _memoController.text = r.memo;
    _priceController.text =
        r.calculatedPrice > 0 ? r.calculatedPrice.toString() : '';
    _adjustmentController.text =
        r.priceAdjustment != 0 ? r.priceAdjustment.toString() : '';
  }

  // ── 액션 ─────────────────────────────────────────────────────────────────

  void _onCancelPressed() {
    if (_isEditing) {
      // 편집 중 취소 → 변경 내용 폐기 + 읽기 전용 복귀
      _resetFields();
      setState(() {
        _isEditing = false;
        _isStartPickerOpen = false;
        _isEndPickerOpen = false;
      });
    } else {
      // 읽기 전용 중 취소 → 모달 닫기
      Navigator.pop(context);
    }
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
    setState(() {
      _isEditing = false;
      _isStartPickerOpen = false;
      _isEndPickerOpen = false;
    });
  }

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

  // ── 날짜/시간 포맷 헬퍼 ──────────────────────────────────────────────────

  String _formatDateTime(DateTime dt, {bool dateOnly = false}) {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final weekday = weekdays[dt.weekday - 1];
    final date =
        '${dt.year}. ${dt.month.toString().padLeft(2, '0')}. ${dt.day.toString().padLeft(2, '0')}. ($weekday)';
    if (dateOnly) return date;
    return '$date ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  // ── 빌드 ─────────────────────────────────────────────────────────────────

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
            title: _isEditing ? '예약 수정' : '예약 정보',
            leading: AppBarActionButton(
              label: _isEditing ? '취소' : '닫기',
              isRegularWeight: true,
              onPressed: _onCancelPressed,
            ),
            actions: [
              if (_isEditing)
                AppBarActionButton(
                  label: '완료',
                  onPressed: _isValid ? _onComplete : null,
                )
              else
                AppBarActionButton(
                  label: '편집',
                  onPressed: () => setState(() => _isEditing = true),
                ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: widget.scrollController,
              keyboardDismissBehavior: _isEditing
                  ? ScrollViewKeyboardDismissBehavior.onDrag
                  : ScrollViewKeyboardDismissBehavior.manual,
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
    if (_isEditing) {
      return GroupedFormContainer(
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: horizontalPadding,
            ),
            child: TitlePopupButton<StoreSummary>(
              title: '예약 점포',
              selectedValue: _storeSummary,
              items: _availableStores,
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

    return GroupedFormContainer(
      children: [
        TitleTextLabel(
          title: '예약 점포',
          content: widget.reservation.storeSummary.name,
        ),
        TitleTextLabel(
          title: '예약 상태',
          content: widget.reservation.status.displayName,
        ),
      ],
    );
  }

  // ── 섹션 2: 예약자 정보 ──────────────────────────────────────────────────

  Widget _buildSection2() {
    if (_isEditing) {
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

    return GroupedFormContainer(
      children: [
        TitleTextLabel(
          title: '예약자명',
          content: widget.reservation.customerName,
        ),
        TitleTextLabel(
          title: '인원',
          content: widget.reservation.headCount.toString(),
        ),
        TitleTextLabel(
          title: '연락처',
          content: widget.reservation.customerPhone,
        ),
        _ReadOnlyMemo(text: widget.reservation.memo),
      ],
    );
  }

  // ── 섹션 3: 일시 정보 ────────────────────────────────────────────────────

  Widget _buildSection3() {
    if (_isEditing) {
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
            onDateTimeChanged: (dt) => setState(() => _endTime = dt),
          ),
        ],
      );
    }

    return GroupedFormContainer(
      children: [
        TitleSwitchButton(
          title: '하루종일',
          value: widget.reservation.isAllDay,
          onChanged: null,
        ),
        TitleTextLabel(
          title: '입실 일시',
          content: _formatDateTime(
            widget.reservation.startTime,
            dateOnly: widget.reservation.isAllDay,
          ),
        ),
        TitleTextLabel(
          title: '퇴실 일시',
          content: _formatDateTime(
            widget.reservation.endTime,
            dateOnly: widget.reservation.isAllDay,
          ),
        ),
      ],
    );
  }

  // ── 섹션 4: 결제 정보 ────────────────────────────────────────────────────

  Widget _buildSection4(TextTheme textTheme) {
    if (_isEditing) {
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

    return GroupedFormContainer(
      children: [
        TitleTextLabel(
          title: '예약 플랫폼',
          content: widget.reservation.platform,
        ),
        TitleTextLabel(
          title: '결제 방식',
          content: widget.reservation.paymentMethod,
        ),
        TitleTextLabel(
          title: '요금',
          content: widget.reservation.calculatedPrice.toString(),
        ),
        TitleTextLabel(
          title: '추가 요금/할인',
          content: widget.reservation.priceAdjustment.toString(),
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
      constraints: const BoxConstraints(minHeight: memoMinHeight),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(
          horizontalPadding,
          12,
          horizontalPadding,
          32,
        ),
        child: Align(
          alignment: AlignmentDirectional.topStart,
          child: Text(
            isEmpty ? '메모' : text,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.normal,
              color: isEmpty ? context.tertiaryLabel : context.label,
            ),
          ),
        ),
      ),
    );
  }
}

// ── show 함수 ──────────────────────────────────────────────────────────────

/// 예약 확인 모달 표시 (플랫폼 적응형).
///
/// 읽기 전용으로 시작하며, 편집 버튼으로 인라인 편집 모드 전환 가능.
/// [onSaved]는 편집 완료 탭 시 수정된 [Reservation]을 전달받는 콜백.
Future<void> showReservationDetailModal(
  BuildContext context,
  Reservation reservation, {
  List<StoreSummary>? availableStores,
  required void Function(Reservation) onSaved,
}) {
  if (Platform.isIOS) {
    return showCupertinoSheet<void>(
      context: context,
      builder: (_) => ReservationDetailModal(
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
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 1.0,
      expand: false,
      snap: true,
      snapSizes: const [0.6, 1.0],
      builder: (_, controller) => ReservationDetailModal(
        reservation: reservation,
        availableStores: availableStores,
        onSaved: onSaved,
        scrollController: controller,
      ),
    ),
  );
}
