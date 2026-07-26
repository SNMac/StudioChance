import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio_chance/constants/data_constants.dart';
import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/domain/entities/reservation.dart';
import 'package:studio_chance/domain/entities/space_option.dart';
import 'package:studio_chance/domain/entities/store_summary.dart';
import 'package:studio_chance/domain/enums/payment_method.dart';
import 'package:studio_chance/domain/enums/reservation_platform.dart';
import 'package:studio_chance/domain/enums/reservation_status.dart';
import 'package:studio_chance/presentation/colors.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';
import 'package:studio_chance/presentation/commons/extensions/phone_formatter.dart';
import 'package:studio_chance/presentation/commons/extensions/price_formatter.dart';
import 'package:studio_chance/presentation/commons/widgets/app_bar/app_bar_action_button.dart';
import 'package:studio_chance/presentation/commons/widgets/app_bar/modal_app_bar.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/grouped_form_container.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/memo_text_field.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/title_date_time_button.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/title_popup_button.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/title_switch_button.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/title_text_field.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/title_text_label.dart';
import 'package:studio_chance/presentation/commons/widgets/modal_grabber.dart';
import 'package:studio_chance/presentation/commons/widgets/safe_area_with_padding.dart';
import 'package:studio_chance/presentation/providers/home_reservation_actions_controller.dart';
import 'package:studio_chance/common/exceptions/app_exception.dart';
import 'package:studio_chance/domain/entities/reservation_ocr_result.dart';
import 'package:studio_chance/presentation/commons/widgets/custom_alert_dialog.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/text_action_button.dart';
import 'package:studio_chance/presentation/commons/widgets/image_preview_page.dart';
import 'package:studio_chance/presentation/providers/reservation_ocr_controller.dart';

/// 예약 생성 모달 (편집 모드 전용, 완료 시 [onSaved] 콜백 후 닫힘).
class ReservationCreateModal extends ConsumerStatefulWidget {
  const ReservationCreateModal({
    super.key,
    required this.initialReservation,
    required this.onSaved,
    required this.maxAvailableHeight,
    this.availableStores,
    this.initialSpaceOptions,
  });

  final Reservation initialReservation;

  /// 저장 탭 시 생성할 Reservation을 전달하는 콜백.
  final void Function(Reservation) onSaved;

  final double maxAvailableHeight;

  /// 예약 점포 선택 팝업에 표시할 점포 목록.
  /// null이면 [initialReservation.storeSummary] 단일 항목으로 fallback.
  final List<StoreSummary>? availableStores;

  /// 모달 오픈 전 선 조회된 공간 옵션. 제공되면 내부 async 로드를 스킵한다.
  final List<SpaceOption>? initialSpaceOptions;

  @override
  ConsumerState<ReservationCreateModal> createState() =>
      _ReservationCreateModalState();
}

class _ReservationCreateModalState extends ConsumerState<ReservationCreateModal> {
  // ── 편집 상태 ─────────────────────────────────────────────────────────────
  late StoreSummary _storeSummary;
  late ReservationStatus _status;
  late bool _isAllDay;
  late DateTime _startTime;
  late DateTime _endTime;
  late ReservationPlatform _platform;
  late PaymentMethod _paymentMethod;

  bool _isStartPickerOpen = false;
  bool _isEndPickerOpen = false;

  // ── 텍스트 컨트롤러 ──────────────────────────────────────────────────────
  late final TextEditingController _nameController;
  late final TextEditingController _headCountController;
  late final TextEditingController _phoneController;
  late final TextEditingController _memoController;
  late final TextEditingController _adjustmentController;

  // ── 스크롤 컨트롤러 ──────────────────────────────────────────────────────
  late final ScrollController _scrollController;

  // ── 공간 옵션 / 가격 설정 ──────────────────────────────────────────────────
  List<SpaceOption> _spaceOptions = const [];
  bool _isLoadingSpaceOptions = true;
  String? _spaceOptionId;
  int _calculatedPrice = 0;
  String? _pendingSpaceNameFromOcr;

  // ── 유효성 ───────────────────────────────────────────────────────────────
  bool get _isValid {
    final headCount = int.tryParse(_headCountController.text) ?? 0;
    return _nameController.text.trim().isNotEmpty &&
        headCount > 0 &&
        _phoneController.text.trim().isNotEmpty &&
        (_isAllDay || _startTime.isBefore(_endTime));
  }

  List<StoreSummary> get _availableStores =>
      widget.availableStores ?? [widget.initialReservation.storeSummary];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _initFields(widget.initialReservation);
    _spaceOptionId = widget.initialReservation.spaceOptionId;

    final initial = widget.initialSpaceOptions;
    if (initial != null) {
      _isLoadingSpaceOptions = false;
      _spaceOptions = initial;
      _spaceOptionId ??= initial.isNotEmpty ? initial.first.id : null;
    } else {
      _loadSpaceOptions(widget.initialReservation.storeSummary.id);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _nameController.dispose();
    _headCountController.dispose();
    _phoneController.dispose();
    _memoController.dispose();
    _adjustmentController.dispose();
    super.dispose();
  }

  void _initFields(Reservation r) {
    _storeSummary = r.storeSummary;
    _status = r.status;
    _isAllDay = r.isAllDay;
    _startTime = r.startTime;
    _endTime = r.endTime;
    _platform = r.platform;
    _paymentMethod = r.paymentMethod;

    _nameController = TextEditingController(text: r.customerName);
    _headCountController = TextEditingController(
      text: r.headCount > 0 ? r.headCount.toString() : '',
    );
    _phoneController = TextEditingController(text: r.customerPhone.formattedPhone);
    _memoController = TextEditingController(text: r.memo);
    _adjustmentController = TextEditingController(
      text: r.priceAdjustment != 0 ? r.priceAdjustment.formattedAmount : '',
    );
  }

  // ── 가격 계산 ─────────────────────────────────────────────────────────────

  void _loadSpaceOptions(String storeId, {List<String> ocrUnmatched = const []}) {
    ref
        .read(homeReservationActionsControllerProvider.notifier)
        .getStoreSpaceOptions(storeId)
        .then((spaces) {
          if (!mounted) return;
          final animation = ModalRoute.of(context)?.animation;
          // 모달 오픈 애니메이션이 진행 중이면 완료 후 setState 실행
          if (animation != null && animation.status != AnimationStatus.completed) {
            late final void Function(AnimationStatus) listener;
            listener = (status) {
              if (status == AnimationStatus.completed) {
                animation.removeStatusListener(listener);
                if (!mounted) return;
                _applySpaceOptions(spaces, ocrUnmatched: ocrUnmatched);
              }
            };
            animation.addStatusListener(listener);
          } else {
            _applySpaceOptions(spaces, ocrUnmatched: ocrUnmatched);
          }
        });
  }

  void _applySpaceOptions(List<SpaceOption>? spaces, {List<String> ocrUnmatched = const []}) {
    final loaded = spaces ?? const [];
    if (loaded.isEmpty) {
      setState(() {
        _isLoadingSpaceOptions = false;
        _pendingSpaceNameFromOcr = null;
      });
      showCustomAlertDialog(
        context: context,
        title: '공간 정보 오류',
        content: '예약 공간 정보를 불러오지 못했습니다.\n잠시 후 다시 시도해 주세요.',
        showCancel: false,
      );
      return;
    }
    final pending = _pendingSpaceNameFromOcr;
    final unmatched = List<String>.from(ocrUnmatched);
    setState(() {
      _isLoadingSpaceOptions = false;
      _spaceOptions = loaded;
      if (pending != null) {
        final matched = loaded.where((s) => s.name == pending).firstOrNull;
        if (matched != null) {
          _spaceOptionId = matched.id;
        } else {
          _spaceOptionId ??= loaded.first.id;
          unmatched.add('공간');
        }
      } else {
        _spaceOptionId ??= loaded.first.id;
      }
      _pendingSpaceNameFromOcr = null;
    });
    _recalculatePrice();
    _showOcrUnmatchedAlert(unmatched);
  }

  void _recalculatePrice() {
    final spaces = _spaceOptions;
    if (spaces.isEmpty) return;
    final priceSetting = _spaceOptionId != null
        ? (spaces.where((s) => s.id == _spaceOptionId).firstOrNull?.priceSetting ?? spaces.first.priceSetting)
        : spaces.first.priceSetting;
    final headCount = int.tryParse(_headCountController.text) ?? 0;
    final price = priceSetting.calculatePrice(
      start: _startTime,
      end: _endTime,
      headCount: headCount,
      isAllDay: _isAllDay,
      isHoliday: false, // TODO: 공휴일 API 연동 후 실제 값 전달
    );
    setState(() => _calculatedPrice = price);
  }

  void _showOcrUnmatchedAlert(List<String> unmatched) {
    if (unmatched.isEmpty || !mounted) return;
    showCustomAlertDialog(
      context: context,
      title: '자동 입력 확인 필요',
      content: '다음 항목을 직접 확인해 주세요:\n${unmatched.join(', ')}',
      showCancel: false,
    );
  }

  void _applyOcrResult(ReservationOcrResult result) {
    final unmatched = <String>[];

    setState(() {
      if (result.customerName != null) {
        _nameController.text = result.customerName!;
      } else {
        _nameController.text = '';
        unmatched.add('예약자명');
      }
      if (result.customerPhone != null) {
        _phoneController.text = result.customerPhone!.formattedPhone;
      } else {
        _phoneController.text = '';
        unmatched.add('연락처');
      }
      _headCountController.text = result.headCount?.toString() ?? '';
      if (result.startTime != null) {
        _startTime = result.startTime!;
      } else {
        unmatched.add('시작 시간');
      }
      if (result.endTime != null) _endTime = result.endTime!;
      _isAllDay = result.isAllDay ?? false;
      _platform = result.platform ?? ReservationPlatform.other;
      _memoController.text = result.memo ?? '';
    });

    final ocrStoreName = result.storeName;
    StoreSummary? matchedStore;
    if (ocrStoreName != null && _availableStores.length > 1) {
      // 동일 이름 점포가 2개 이상이면 어느 쪽인지 특정할 수 없으므로 모호한 매칭으로 처리
      final candidates =
          _availableStores.where((s) => s.name == ocrStoreName).toList();
      matchedStore = candidates.length == 1 ? candidates.first : null;
      if (matchedStore != null) {
        setState(() {
          _storeSummary = matchedStore!;
          _spaceOptions = const [];
          _isLoadingSpaceOptions = true;
          _spaceOptionId = null;
        });
      } else {
        unmatched.add('점포');
      }
    }

    if (matchedStore != null) {
      _pendingSpaceNameFromOcr = result.spaceName;
      _loadSpaceOptions(matchedStore.id, ocrUnmatched: unmatched);
    } else {
      final ocrSpaceName = result.spaceName;
      if (ocrSpaceName != null && _isLoadingSpaceOptions) {
        // 초기 공간 옵션 로딩이 아직 끝나지 않음 — 로딩 완료 시점에 매칭되도록 위임
        _pendingSpaceNameFromOcr = ocrSpaceName;
        _loadSpaceOptions(_storeSummary.id, ocrUnmatched: unmatched);
      } else {
        if (ocrSpaceName != null && _spaceOptions.isNotEmpty) {
          final matched = _spaceOptions
              .where((s) => s.name == ocrSpaceName)
              .firstOrNull;
          if (matched != null) {
            setState(() => _spaceOptionId = matched.id);
          } else {
            unmatched.add('공간');
          }
        }
        _recalculatePrice();
        _showOcrUnmatchedAlert(unmatched);
      }
    }
  }

  // ── 액션 ─────────────────────────────────────────────────────────────────

  void _onCancelPressed() => Navigator.pop(context);

  void _onSavePressed() {
    final calculatedPrice = _calculatedPrice;
    final priceAdjustment =
        int.tryParse(_adjustmentController.text.replaceAll(',', '')) ?? 0;

    final newReservation = widget.initialReservation.copyWith(
      storeSummary: _storeSummary,
      status: _status,
      customerName: _nameController.text.trim(),
      headCount: int.tryParse(_headCountController.text) ?? 0,
      customerPhone: _phoneController.text.replaceAll('-', '').trim(),
      memo: _memoController.text,
      isAllDay: _isAllDay,
      startTime: _startTime,
      endTime: _endTime,
      platform: _platform,
      paymentMethod: _paymentMethod,
      calculatedPrice: calculatedPrice,
      priceAdjustment: priceAdjustment,
      totalPrice: calculatedPrice + priceAdjustment,
      spaceOptionId: _spaceOptionId,
    );
    widget.onSaved(newReservation);
    Navigator.pop(context);
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
        // iCal 관례: 종일 이벤트 endTime = 다음날 자정(exclusive).
        _endTime = DateTime(_startTime.year, _startTime.month, _startTime.day)
            .add(const Duration(days: 1));
      }
      _isStartPickerOpen = false;
      _isEndPickerOpen = false;
    });
    _recalculatePrice();
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
    ref.listen(reservationOcrControllerProvider, (_, next) {
      next.whenOrNull(
        data: (result) {
          if (result != null && mounted) _applyOcrResult(result);
        },
        error: (e, _) {
          if (!mounted) return;
          if (e is AppException && !e.isSilentable) {
            showCustomAlertDialog(
              context: context,
              title: e.title,
              content: e.content,
              showCancel: false,
            );
          } else {
            showCustomAlertDialog(
              context: context,
              title: 'OCR 오류',
              content: '스크린샷 분석에 실패했습니다.\n잠시 후 다시 시도해 주세요.',
              showCancel: false,
            );
          }
        },
      );
    });
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      height: widget.maxAvailableHeight,
      child: Material(
        color: context.systemGroupedBackground,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(modalTopCornerRadius),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Opacity(opacity: 0.0, child: ModalGrabber()),
            ModalAppBar(
              title: '예약 등록',
              leading: AppBarActionButton(
                label: '취소',
                isRegularWeight: true,
                onPressed: _onCancelPressed,
              ),
              actions: [
                AppBarActionButton(
                  label: '저장',
                  onPressed: _isValid ? _onSavePressed : null,
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: _buildBody(textTheme),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(TextTheme textTheme) {
    return SafeAreaWithPadding(
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
          _buildOcrButton(),
          _buildSection1(),
          _buildSection2(),
          _buildSection3(),
          _buildSection4(textTheme),
        ],
      ),
    );
  }

  Future<void> _handleOcrButtonTap() async {
    final bytes = await ref
        .read(reservationOcrControllerProvider.notifier)
        .pickForPreview();
    if (bytes == null || !mounted) return;
    final confirmed = await showImagePreviewPage(context, bytes);
    if (!confirmed || !mounted) return;

    // 이미지 확정 후 모든 점포의 공간 옵션 병렬 조회
    final notifier = ref.read(homeReservationActionsControllerProvider.notifier);
    final allSpaceOptions = await Future.wait(
      _availableStores.map((s) => notifier.getStoreSpaceOptions(s.id)),
    );
    if (!mounted) return;

    // 점포명이 프롬프트의 매칭 키이므로, 이름이 중복되면 목록 전달 자체를 생략
    final storeNames = _availableStores.map((s) => s.name).toList();
    final hasDuplicateStoreNames = storeNames.toSet().length != storeNames.length;

    final storeSpaceMap = <String, List<String>>{};
    if (!hasDuplicateStoreNames) {
      for (var i = 0; i < _availableStores.length; i++) {
        final spaces = allSpaceOptions[i];
        if (spaces != null && spaces.isNotEmpty) {
          storeSpaceMap[_availableStores[i].name] = spaces.map((s) => s.name).toList();
        }
      }
    }

    ref.read(reservationOcrControllerProvider.notifier).analyzeImage(
      bytes,
      storeSpaceMap: storeSpaceMap.isNotEmpty ? storeSpaceMap : null,
    );
  }

  Widget _buildOcrButton() {
    final isLoading = ref.watch(
      reservationOcrControllerProvider.select((s) => s.isLoading),
    );
    return TextActionButton(
      title: isLoading ? '분석 중...' : '스크린샷으로 자동 입력',
      fontWeight: FontWeight.normal,
      onPressed: isLoading
          ? () => showCustomAlertDialog(
                context: context,
                title: '자동 입력 취소',
                content: '스크린샷 분석을 중단할까요?',
                confirmText: '중단',
                cancelText: '계속',
                onConfirmAfterPop: () =>
                    ref.read(reservationOcrControllerProvider.notifier).cancel(),
              )
          : _handleOcrButtonTap,
    );
  }

  // ── 섹션 1: 기본 정보 ────────────────────────────────────────────────────

  Widget _buildSection1() {
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
            onSelected: (s) {
              setState(() {
                _storeSummary = s;
                _spaceOptions = const [];
                _isLoadingSpaceOptions = true;
                _spaceOptionId = null;
              });
              _loadSpaceOptions(s.id);
            },
          ),
        ),
        // 로딩 중에도 행을 항상 렌더링해 레이아웃을 안정적으로 유지.
        // 애니메이션 완료 후 setState가 실행되므로 애니메이션 끊김 없음.
        // 에러로 빈 배열이 되면 행을 숨김 (크래시 방지).
        if (_isLoadingSpaceOptions || _spaceOptions.isNotEmpty)
          Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: horizontalPadding,
            ),
            child: _isLoadingSpaceOptions
                ? const TitleTextLabel(title: '예약 공간', content: '—')
                : TitlePopupButton<SpaceOption>(
                    title: '예약 공간',
                    selectedValue: _spaceOptions.where((s) => s.id == _spaceOptionId).firstOrNull ?? _spaceOptions.first,
                    items: _spaceOptions,
                    itemLabelBuilder: (s) => s.name,
                    onSelected: (s) {
                      setState(() => _spaceOptionId = s.id);
                      _recalculatePrice();
                    },
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
          onChanged: (_) {
            setState(() {});
            _recalculatePrice();
          },
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        TitleTextField(
          title: '연락처',
          controller: _phoneController,
          onChanged: (_) => setState(() {}),
          keyboardType: TextInputType.phone,
          inputFormatters: [PhoneNumberInputFormatter()],
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
    final displayEndTime =
        _isAllDay ? _endTime.subtract(const Duration(days: 1)) : _endTime;

    return GroupedFormContainer(
      children: [
        TitleSwitchButton(
          title: '하루종일',
          value: _isAllDay,
          onChanged: _onAllDayChanged,
        ),
        TitleDateTimeButton(
          title: _isAllDay ? '입실 일' : '입실 일시',
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
          onDateTimeChanged: (dt) {
            setState(() {
              _startTime = dt;
              final minEnd = _isAllDay
                  ? dt.add(const Duration(days: 1))
                  : dt.add(const Duration(hours: 1));
              if (!_endTime.isAfter(dt)) _endTime = minEnd;
            });
            _recalculatePrice();
          },
        ),
        TitleDateTimeButton(
          title: _isAllDay ? '퇴실 일' : '퇴실 일시',
          content: _formatDateTime(displayEndTime, dateOnly: _isAllDay),
          isOpen: _isEndPickerOpen,
          onPressed: () => setState(() {
            _isEndPickerOpen = !_isEndPickerOpen;
            if (_isEndPickerOpen) _isStartPickerOpen = false;
          }),
          mode: _isAllDay
              ? CupertinoDatePickerMode.date
              : CupertinoDatePickerMode.dateAndTime,
          initialDateTime: displayEndTime,
          onDateTimeChanged: (dt) {
            final newEnd = _isAllDay ? dt.add(const Duration(days: 1)) : dt;
            setState(() {
              _endTime = newEnd;
              // 퇴실이 입실과 같거나 이전이면 입실을 퇴실 1시간/1일 앞으로 밀어냄
              if (!newEnd.isAfter(_startTime)) {
                _startTime = _isAllDay
                    ? newEnd.subtract(const Duration(days: 1))
                    : newEnd.subtract(const Duration(hours: 1));
              }
            });
            _recalculatePrice();
          },
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
          '할인인 경우 -[값]을 입력해주세요 (예: -2,000)',
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
          child: TitlePopupButton<ReservationPlatform>(
            title: '예약 플랫폼',
            selectedValue: _platform,
            items: ReservationPlatform.values,
            itemLabelBuilder: (p) => p.displayName,
            onSelected: (p) => setState(() => _platform = p),
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: horizontalPadding,
          ),
          child: TitlePopupButton<PaymentMethod>(
            title: '결제 방식',
            selectedValue: _paymentMethod,
            items: PaymentMethod.values,
            itemLabelBuilder: (m) => m.displayName,
            onSelected: (m) => setState(() => _paymentMethod = m),
          ),
        ),
        TitleTextLabel(
          title: '요금',
          content: _calculatedPrice.formattedPrice,
        ),
        TitleTextField(
          title: '추가 요금/할인',
          controller: _adjustmentController,
          keyboardType: const TextInputType.numberWithOptions(signed: true),
          inputFormatters: [const PriceInputFormatter(allowNegative: true)],
        ),
      ],
    );
  }
}

// ── show 함수 ──────────────────────────────────────────────────────────────

/// 예약 생성 모달 표시.
///
/// 편집 모드로 시작하며, 저장 탭 시 [onSaved]를 통해 생성할 [Reservation]을 전달받는다.
Future<void> showReservationCreateModal(
  BuildContext context,
  Reservation initialReservation, {
  List<StoreSummary>? availableStores,
  List<SpaceOption>? initialSpaceOptions,
  required void Function(Reservation) onSaved,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    enableDrag: false,
    backgroundColor: Colors.transparent,
    barrierColor: modalBarrierColor,
    builder: (ctx) => LayoutBuilder(
      builder: (_, constraints) => ReservationCreateModal(
        initialReservation: initialReservation,
        availableStores: availableStores,
        initialSpaceOptions: initialSpaceOptions,
        onSaved: onSaved,
        maxAvailableHeight: constraints.maxHeight,
      ),
    ),
  );
}
