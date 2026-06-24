import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio_chance/constants/data_constants.dart';
import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/router/router_path.dart';
import 'package:studio_chance/domain/entities/reservation.dart';
import 'package:studio_chance/domain/entities/space_option.dart';
import 'package:studio_chance/domain/entities/store_summary.dart';
import 'package:studio_chance/domain/enums/payment_method.dart';
import 'package:studio_chance/domain/enums/reservation_platform.dart';
import 'package:studio_chance/domain/enums/reservation_status.dart';
import 'package:studio_chance/domain/enums/user_role.dart';
import 'package:studio_chance/presentation/providers/app_auth_controller.dart';
import 'package:studio_chance/presentation/colors.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';
import 'package:studio_chance/presentation/commons/extensions/phone_formatter.dart';
import 'package:studio_chance/presentation/commons/extensions/price_formatter.dart';
import 'package:studio_chance/presentation/commons/widgets/app_bar/app_bar_action_button.dart';
import 'package:studio_chance/presentation/commons/widgets/app_bar/modal_app_bar.dart';
import 'package:studio_chance/presentation/providers/home_reservation_actions_controller.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/grouped_form_container.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/memo_text_field.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/title_date_time_button.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/text_action_button.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/title_popup_button.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/title_switch_button.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/title_text_field.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/title_text_label.dart';
import 'package:studio_chance/presentation/commons/widgets/modal_grabber.dart';
import 'package:studio_chance/presentation/commons/widgets/safe_area_with_padding.dart';
import 'package:studio_chance/common/exceptions/app_exception.dart';
import 'package:studio_chance/domain/entities/reservation_ocr_result.dart';
import 'package:studio_chance/presentation/commons/widgets/custom_alert_dialog.dart';
import 'package:studio_chance/presentation/commons/widgets/image_preview_page.dart';
import 'package:studio_chance/presentation/providers/reservation_ocr_controller.dart';

/// 예약 확인 모달 (읽기 전용 ↔ 편집 모드 인라인 전환).
///
/// - 읽기 전용: 모든 필드 표시 전용, AppBar에 '편집' 버튼
/// - 편집 모드: 필드 편집 가능, '완료' 탭 시 [onSaved] 콜백 후 읽기 전용 복귀
class ReservationDetailModal extends ConsumerStatefulWidget {
  const ReservationDetailModal({
    super.key,
    required this.reservation,
    required this.onSaved,
    required this.onDeleted,
    required this.maxAvailableHeight,
    this.availableStores,
    this.initialSpaceOptions,
  });

  final Reservation reservation;

  /// 완료 탭 시 수정된 Reservation을 전달하는 콜백.
  final void Function(Reservation) onSaved;

  /// 삭제 확인 시 호출되는 콜백.
  final VoidCallback onDeleted;

  final double maxAvailableHeight;

  /// 예약 점포 선택 팝업에 표시할 점포 목록.
  /// null이면 [reservation.storeSummary] 단일 항목으로 fallback.
  /// TODO: 실제 데이터 연결 시 Home Provider에서 전달.
  final List<StoreSummary>? availableStores;

  /// 모달 진입 전 미리 조회된 공간 옵션. non-null이면 내부 fetch를 생략한다.
  final List<SpaceOption>? initialSpaceOptions;

  @override
  ConsumerState<ReservationDetailModal> createState() =>
      _ReservationDetailModalState();
}

class _ReservationDetailModalState
    extends ConsumerState<ReservationDetailModal>
    with SingleTickerProviderStateMixin {
  // ── 모드 상태 ─────────────────────────────────────────────────────────────
  bool _isEditing = false;

  // ── 시트 애니메이션 ───────────────────────────────────────────────────────
  late final AnimationController _sheetController;
  double _grabberDragStartSize = _kModalInitialSize;
  double _grabberDragStartY = 0;

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

  // ── 스크롤 컨트롤러 ──────────────────────────────────────────────────────
  //
  // 모드별 독립 ScrollController + Stack + Offstage
  //   - 두 ScrollView가 항상 트리에 존재 → 각자의 ScrollPosition 보존
  //   - Offstage(offstage: true): layout은 유지, paint/hit-test 제외
  //   - 전환 전 _syncScrollPosition()으로 오프셋 수동 동기화
  late final ScrollController _ownReadOnlyController;
  ScrollController get _readOnlyController => _ownReadOnlyController;
  late final ScrollController _editController;

  // ── 텍스트 컨트롤러 ──────────────────────────────────────────────────────
  late final TextEditingController _nameController;
  late final TextEditingController _headCountController;
  late final TextEditingController _phoneController;
  late final TextEditingController _memoController;
  late final TextEditingController _adjustmentController;
  late final FocusNode _adjustmentFocusNode;

  // ── 공간 옵션 / 가격 설정 ──────────────────────────────────────────────────
  List<SpaceOption>? _spaceOptions;
  String? _spaceOptionId;
  int _calculatedPrice = 0;
  String? _pendingSpaceNameFromOcr;

  // ── 방문 횟수 ─────────────────────────────────────────────────────────────
  int _reservationCount = 1;

  // ── 유효성 ───────────────────────────────────────────────────────────────
  bool get _isValid {
    final headCount = int.tryParse(_headCountController.text) ?? 0;
    return _nameController.text.trim().isNotEmpty &&
        headCount > 0 &&
        _phoneController.text.trim().isNotEmpty &&
        (_isAllDay || _startTime.isBefore(_endTime));
  }

  List<StoreSummary> get _availableStores =>
      widget.availableStores ?? [widget.reservation.storeSummary];

  /// 현재 사용자가 이 예약의 점포에 대해 수정 권한(admin/staff)을 가지는지 여부.
  bool get _canEdit {
    final storeInfos = ref.watch(
      currentUserProvider.select((u) => u.asData?.value?.storeInfos),
    );
    if (storeInfos == null) return false;
    final storeId = widget.reservation.storeSummary.id;
    final info = storeInfos.where((i) => i.id == storeId).firstOrNull;
    return info?.role == UserRole.admin || info?.role == UserRole.staff;
  }

  @override
  void initState() {
    super.initState();
    _sheetController = AnimationController(
      vsync: this,
      value: _kModalInitialSize,
      lowerBound: _kModalInitialSize,
      upperBound: _kModalMaxSize,
    );
    _ownReadOnlyController = ScrollController();
    _editController = ScrollController();
    _adjustmentFocusNode = FocusNode();
    _adjustmentFocusNode.addListener(_onAdjustmentFocusChanged);
    _initFields(widget.reservation);
    _spaceOptionId = widget.reservation.spaceOptionId;
    final preloaded = widget.initialSpaceOptions;
    if (preloaded != null) {
      _spaceOptions = preloaded;
      if (preloaded.isNotEmpty && _spaceOptionId == null) {
        _spaceOptionId = preloaded.first.id;
      }
      // initState에서 직접 계산 (setState 호출 불가)
      _applyInitialPrice(preloaded);
    } else {
      _loadSpaceOptions(widget.reservation.storeSummary.id);
    }
    _loadReservationCount();
  }

  @override
  void dispose() {
    _sheetController.dispose();
    _ownReadOnlyController.dispose();
    _editController.dispose();
    _adjustmentFocusNode.dispose();
    _nameController.dispose();
    _headCountController.dispose();
    _phoneController.dispose();
    _memoController.dispose();
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
    _platform = r.platform;
    _paymentMethod = r.paymentMethod;

    _nameController = TextEditingController(text: r.customerName);
    _headCountController = TextEditingController(
      text: r.headCount > 0 ? r.headCount.toString() : '',
    );
    _phoneController = TextEditingController(text: r.customerPhone.formattedPhone);
    _memoController = TextEditingController(text: r.memo);
    _calculatedPrice = r.calculatedPrice;
    _adjustmentController = TextEditingController(
      text: r.priceAdjustment != 0 ? r.priceAdjustment.formattedPrice : '',
    );
  }

  void _resetFields() {
    final r = widget.reservation;
    _storeSummary = r.storeSummary;
    _status = r.status;
    _isAllDay = r.isAllDay;
    _startTime = r.startTime;
    _endTime = r.endTime;
    _platform = r.platform;
    _paymentMethod = r.paymentMethod;

    _nameController.text = r.customerName;
    _headCountController.text = r.headCount > 0 ? r.headCount.toString() : '';
    _phoneController.text = r.customerPhone.formattedPhone;
    _memoController.text = r.memo;
    _calculatedPrice = r.calculatedPrice;
    _adjustmentController.text =
        r.priceAdjustment != 0 ? r.priceAdjustment.formattedPrice : '';
    _spaceOptionId = r.spaceOptionId;
  }

  void _onAdjustmentFocusChanged() {
    final raw = _adjustmentController.text.replaceAll(',', '').replaceAll('원', '');
    if (_adjustmentFocusNode.hasFocus) {
      _adjustmentController.value = TextEditingValue(
        text: raw,
        selection: TextSelection.collapsed(offset: raw.length),
      );
    } else {
      final price = int.tryParse(raw);
      if (price != null && price != 0) {
        final formatted = price.formattedPrice;
        _adjustmentController.value = TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      }
    }
  }

  // ── 스크롤 위치 동기화 ────────────────────────────────────────────────────

  /// 모드 전환 전 비활성 뷰의 오프셋을 활성 뷰에 맞춰 동기화한다.
  /// setState() 호출 전에 실행해야 한다.
  void _syncScrollPosition({required bool toEdit}) {
    final from = toEdit ? _readOnlyController : _editController;
    final to = toEdit ? _editController : _readOnlyController;
    if (!from.hasClients || !to.hasClients) return;
    if (!from.position.haveDimensions || !to.position.haveDimensions) return;
    to.jumpTo(from.offset.clamp(0.0, to.position.maxScrollExtent));
  }

  // ── 가격 계산 ─────────────────────────────────────────────────────────────

  void _loadSpaceOptions(String storeId, {List<String> ocrUnmatched = const []}) {
    ref
        .read(homeReservationActionsControllerProvider.notifier)
        .getStoreSpaceOptions(storeId)
        .then((spaces) {
          if (!mounted) return;
          final pending = _pendingSpaceNameFromOcr;
          final unmatched = List<String>.from(ocrUnmatched);
          setState(() {
            _spaceOptions = spaces;
            if (spaces != null && spaces.isNotEmpty) {
              if (pending != null) {
                final matched = spaces.where((s) => s.name == pending).firstOrNull;
                if (matched != null) {
                  _spaceOptionId = matched.id;
                } else {
                  _spaceOptionId ??= spaces.first.id;
                  unmatched.add('공간');
                }
              } else {
                _spaceOptionId ??= spaces.first.id;
              }
            }
            _pendingSpaceNameFromOcr = null;
          });
          _recalculatePrice();
          _showOcrUnmatchedAlert(unmatched);
        });
  }

  void _loadReservationCount({String? customerName, String? customerPhone}) {
    final r = widget.reservation;
    ref
        .read(homeReservationActionsControllerProvider.notifier)
        .getReservationCountByCustomer(
          storeId: _storeSummary.id,
          customerName: customerName ?? r.customerName,
          customerPhone: customerPhone ?? r.customerPhone,
        )
        .then((count) {
          if (!mounted) return;
          setState(() => _reservationCount = count);
        });
  }

  void _recalculatePrice() {
    final spaces = _spaceOptions;
    if (spaces == null || spaces.isEmpty) return;
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

  // initState에서 setState 없이 초기 가격을 계산할 때만 사용
  void _applyInitialPrice(List<SpaceOption> spaces) {
    if (spaces.isEmpty) return;
    final priceSetting = _spaceOptionId != null
        ? (spaces.where((s) => s.id == _spaceOptionId).firstOrNull?.priceSetting ?? spaces.first.priceSetting)
        : spaces.first.priceSetting;
    final headCount = int.tryParse(_headCountController.text) ?? 0;
    _calculatedPrice = priceSetting.calculatePrice(
      start: _startTime,
      end: _endTime,
      headCount: headCount,
      isAllDay: _isAllDay,
      isHoliday: false,
    );
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
        unmatched.add('예약자명');
      }
      if (result.customerPhone != null) {
        _phoneController.text = result.customerPhone!.formattedPhone;
      } else {
        unmatched.add('연락처');
      }
      if (result.headCount != null) {
        _headCountController.text = result.headCount.toString();
      }
      if (result.startTime != null) {
        _startTime = result.startTime!;
      } else {
        unmatched.add('시작 시간');
      }
      if (result.endTime != null) _endTime = result.endTime!;
      if (result.isAllDay != null) _isAllDay = result.isAllDay!;
      if (result.platform != null) _platform = result.platform!;
      if (result.memo != null) _memoController.text = result.memo!;
    });

    final ocrStoreName = result.storeName;
    StoreSummary? matchedStore;
    if (ocrStoreName != null && _availableStores.length > 1) {
      matchedStore = _availableStores
          .where((s) => s.name == ocrStoreName)
          .firstOrNull;
      if (matchedStore != null) {
        setState(() {
          _storeSummary = matchedStore!;
          _spaceOptions = null;
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
      if (ocrSpaceName != null) {
        final spaces = _spaceOptions;
        if (spaces != null && spaces.isNotEmpty) {
          final matched = spaces
              .where((s) => s.name == ocrSpaceName)
              .firstOrNull;
          if (matched != null) {
            setState(() => _spaceOptionId = matched.id);
          } else {
            unmatched.add('공간');
          }
        }
      }
      _recalculatePrice();
      _showOcrUnmatchedAlert(unmatched);
    }
  }

  // ── 액션 ─────────────────────────────────────────────────────────────────

  void _dismissModal() {
    Navigator.pop(context);
  }

  void _onCancelPressed() {
    if (_isEditing) {
      // 편집 중 취소 → 변경 내용 폐기 + 읽기 전용 복귀
      _resetFields();
      _syncScrollPosition(toEdit: false);
      setState(() {
        _isEditing = false;
        _isStartPickerOpen = false;
        _isEndPickerOpen = false;
      });
    } else {
      // 읽기 전용 중 취소 → 모달 닫기
      _dismissModal();
    }
  }

  void _onComplete() {
    FocusScope.of(context).unfocus();
    final calculatedPrice = _calculatedPrice;
    final priceAdjustment =
        int.tryParse(_adjustmentController.text.replaceAll(',', '').replaceAll('원', '')) ?? 0;

    final updated = widget.reservation.copyWith(
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
    widget.onSaved(updated);
    _loadReservationCount(
      customerName: _nameController.text.trim(),
      customerPhone: _phoneController.text.replaceAll('-', '').trim(),
    );
    _syncScrollPosition(toEdit: false);
    setState(() {
      _isEditing = false;
      _isStartPickerOpen = false;
      _isEndPickerOpen = false;
    });
  }

  void _onDeletePressed() {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('예약 삭제'),
        content: const Text('이 예약을 삭제하시겠습니까?\n삭제된 예약은 복구할 수 없습니다.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('취소'),
            onPressed: () => Navigator.pop(ctx),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('삭제'),
            onPressed: () {
              Navigator.pop(ctx);
              widget.onDeleted();
              _dismissModal();
            },
          ),
        ],
      ),
    );
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
        // _endTime.day 기준으로 설정하면 endTime이 이미 day+1일 때 2일짜리로 늘어나는 버그 발생.
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
    final textTheme = Theme.of(context).textTheme;

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
                if (_isEditing) return;
                final delta =
                    -event.delta.dy / widget.maxAvailableHeight;
                _sheetController.value =
                    (_sheetController.value + delta)
                        .clamp(_kModalInitialSize, _kModalMaxSize);
              },
              onPointerUp: (event) {
                if (_isEditing) return;
                final totalDy = event.position.dy - _grabberDragStartY;
                if (totalDy.abs() < 10) return;
                if (totalDy > 30) {
                  if (_grabberDragStartSize <= _kModalInitialSize + 0.05) {
                    _dismissModal();
                  } else {
                    _sheetController.animateTo(
                      _kModalInitialSize,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                } else if (totalDy < -30) {
                  _sheetController.animateTo(
                    _kModalMaxSize,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                } else {
                  const mid = (_kModalInitialSize + _kModalMaxSize) / 2;
                  _sheetController.animateTo(
                    _sheetController.value >= mid
                        ? _kModalMaxSize
                        : _kModalInitialSize,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                }
              },
              onPointerCancel: (_) {
                if (_isEditing) return;
                const mid = (_kModalInitialSize + _kModalMaxSize) / 2;
                _sheetController.animateTo(
                  _sheetController.value >= mid
                      ? _kModalMaxSize
                      : _kModalInitialSize,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Opacity(
                    opacity: _isEditing ? 0.0 : 1.0,
                    child: const ModalGrabber(),
                  ),
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
                      else if (_canEdit)
                        AppBarActionButton(
                          label: '편집',
                          onPressed: () {
                            _sheetController.animateTo(
                              _kModalMaxSize,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                            );
                            _syncScrollPosition(toEdit: true);
                            setState(() => _isEditing = true);
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                // 편집 모드에서 키보드 높이만큼 스크롤 뷰포트를 줄여
                // ensureVisible이 키보드 위로 필드를 정확히 스크롤하게 함
                padding: EdgeInsets.only(
                  bottom: _isEditing
                      ? MediaQuery.of(context).viewInsets.bottom
                      : 0,
                ),
                child: _buildScrollArea(textTheme),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 스크롤 영역 ───────────────────────────────────────────────────────────

  // 플랫폼 공통: 독립 ScrollView 두 개 + Stack + Offstage
  // Offstage(offstage: true)는 layout을 유지하므로 ScrollPosition이 보존된다.
  Widget _buildScrollArea(TextTheme textTheme) {
    return Stack(
      children: [
        Positioned.fill(
          child: Offstage(
            offstage: _isEditing,
            child: SingleChildScrollView(
              controller: _readOnlyController,
              keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.manual,
              child: _buildReadOnlyBody(textTheme),
            ),
          ),
        ),
        Positioned.fill(
          child: Offstage(
            offstage: !_isEditing,
            child: SingleChildScrollView(
              controller: _editController,
              keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
              child: _buildEditBody(textTheme),
            ),
          ),
        ),
      ],
    );
  }

  // ── 읽기 전용 본문 ────────────────────────────────────────────────────────

  Widget _buildReadOnlyBody(TextTheme textTheme) {
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
          _buildSection1ReadOnly(),
          _buildSection2ReadOnly(),
          _buildSection3ReadOnly(),
          _buildSection4ReadOnly(),
          _buildSection5(textTheme),
        ],
      ),
    );
  }

  // ── 편집 본문 ─────────────────────────────────────────────────────────────

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

    final storeSpaceMap = <String, List<String>>{};
    for (var i = 0; i < _availableStores.length; i++) {
      final spaces = allSpaceOptions[i];
      if (spaces != null && spaces.isNotEmpty) {
        storeSpaceMap[_availableStores[i].name] = spaces.map((s) => s.name).toList();
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

  Widget _buildEditBody(TextTheme textTheme) {
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
          _buildSection1Edit(),
          _buildSection2Edit(),
          _buildSection3Edit(),
          _buildSection4Edit(textTheme),
          GroupedFormContainer(
            children: [
              TextActionButton(
                title: '예약 삭제',
                isDestructive: true,
                onPressed: _onDeletePressed,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── 섹션 1: 기본 정보 ────────────────────────────────────────────────────

  Widget _buildSection1ReadOnly() {
    final spaceOptions = _spaceOptions;
    final spaceName = spaceOptions != null && spaceOptions.isNotEmpty
        ? (spaceOptions.where((s) => s.id == _spaceOptionId).firstOrNull?.name ?? spaceOptions.first.name)
        : null;
    return GroupedFormContainer(
      children: [
        TitleTextLabel(
          title: '예약 점포',
          content: _storeSummary.name,
          leading: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Color(_storeSummary.color.foregroundColorValue),
              shape: BoxShape.circle,
            ),
          ),
        ),
        if (spaceName != null)
          TitleTextLabel(
            title: '예약 공간',
            content: spaceName,
          ),
        TitleTextLabel(
          title: '예약 상태',
          content: _status.displayName,
        ),
      ],
    );
  }

  Widget _buildSection1Edit() {
    final spaceOptions = _spaceOptions;
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
                _spaceOptions = null;
                _spaceOptionId = null;
              });
              _loadSpaceOptions(s.id);
            },
          ),
        ),
        if (spaceOptions != null && spaceOptions.isNotEmpty)
          Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: horizontalPadding,
            ),
            child: TitlePopupButton<SpaceOption>(
              title: '예약 공간',
              selectedValue: spaceOptions.where((s) => s.id == _spaceOptionId).firstOrNull ?? spaceOptions.first,
              items: spaceOptions,
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

  Widget _buildSection2ReadOnly() {
    return GroupedFormContainer(
      children: [
        TitleTextLabel(
          title: '예약자명',
          content: _nameController.text,
        ),
        TitleTextLabel(
          title: '인원',
          content: _headCountController.text,
        ),
        TitleTextLabel(
          title: '연락처',
          content: _phoneController.text, // 이미 하이픈 포맷 적용됨
        ),
        _ReadOnlyMemo(text: _memoController.text),
      ],
    );
  }

  Widget _buildSection2Edit() {
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

  Widget _buildSection3ReadOnly() {
    // 종일 이벤트는 iCal 관례상 endTime = 다음날 자정(exclusive) → 표시 시 -1일 보정
    final displayEnd = _isAllDay
        ? _endTime.subtract(const Duration(days: 1))
        : _endTime;

    return GroupedFormContainer(
      children: [
        TitleSwitchButton(
          title: '하루종일',
          value: _isAllDay,
          onChanged: null,
        ),
        TitleTextLabel(
          title: _isAllDay ? '입실 일' : '입실 일시',
          content: _formatDateTime(_startTime, dateOnly: _isAllDay),
        ),
        TitleTextLabel(
          title: _isAllDay ? '퇴실 일' : '퇴실 일시',
          content: _formatDateTime(displayEnd, dateOnly: _isAllDay),
        ),
      ],
    );
  }

  Widget _buildSection3Edit() {
    // 종일 이벤트 picker 표시용: endTime은 다음날 자정(exclusive)이므로 -1일 보정
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
              // 입실이 퇴실과 같거나 이후면 퇴실을 1시간/1일 뒤로 조정
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
          // 종일 이벤트: 사용자가 선택한 날짜에 +1일하여 iCal 관례(exclusive) 유지
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

  Widget _buildSection4ReadOnly() {
    final adjustment =
        int.tryParse(_adjustmentController.text.replaceAll(',', '').replaceAll('원', '')) ?? 0;
    return GroupedFormContainer(
      children: [
        TitleTextLabel(
          title: '예약 플랫폼',
          content: _platform.displayName,
        ),
        TitleTextLabel(
          title: '결제 방식',
          content: _paymentMethod.displayName,
        ),
        TitleTextLabel(
          title: '요금',
          content: _calculatedPrice.formattedPrice,
        ),
        TitleTextLabel(
          title: '추가 요금/할인',
          content: adjustment.formattedPrice,
        ),
        TitleTextLabel(
          title: '최종 요금',
          content: (_calculatedPrice + adjustment).formattedPrice,
        ),
      ],
    );
  }

  Widget _buildSection4Edit(TextTheme textTheme) {
    final adjustment =
        int.tryParse(_adjustmentController.text.replaceAll(',', '').replaceAll('원', '')) ?? 0;
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
          focusNode: _adjustmentFocusNode,
          onChanged: (_) => setState(() {}),
          keyboardType: const TextInputType.numberWithOptions(signed: true),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[-0-9]'))],
        ),
        TitleTextLabel(
          title: '최종 요금',
          content: (_calculatedPrice + adjustment).formattedPrice,
        ),
      ],
    );
  }

  // ── 섹션 5: 안내문 (읽기 전용 전용) ──────────────────────────────────────

  Widget _buildSection5(TextTheme textTheme) {
    return GroupedFormContainer(
      header: Padding(
        padding: const EdgeInsetsDirectional.only(
          start: horizontalPadding,
          bottom: 8,
        ),
        child: Text(
          '$_reservationCount번째 예약입니다.',
          style: textTheme.bodyMedium?.copyWith(
            color: context.secondaryLabel,
          ),
        ),
      ),
      children: [
        TextActionButton(
          title: '입금 안내문',
          onPressed: () => context.push(
            '${SCRoute.home.fullPath}/${SCRoute.paymentInstruction.path}',
            extra: widget.reservation,
          ),
        ),
        TextActionButton(
          title: '확정 안내문',
          onPressed: () => context.push(
            '${SCRoute.home.fullPath}/${SCRoute.confirmationNotice.path}',
            extra: widget.reservation,
          ),
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

const double _kModalInitialSize = 0.62;
const double _kModalMaxSize = 1.0;

/// 예약 확인 모달 표시.
///
/// 읽기 전용으로 시작하며, 편집 버튼으로 인라인 편집 모드 전환 가능.
/// [onSaved]는 편집 완료 탭 시 수정된 [Reservation]을 전달받는 콜백.
///
/// 두 개의 snap 위치:
/// - 소(초기): 메모 섹션이 보이는 높이 + 하루종일 row peek
/// - 대: 전체 높이 (편집 모드 진입 시 자동 확장)
Future<void> showReservationDetailModal(
  BuildContext context,
  Reservation reservation, {
  List<StoreSummary>? availableStores,
  List<SpaceOption>? initialSpaceOptions,
  required void Function(Reservation) onSaved,
  required VoidCallback onDeleted,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    enableDrag: false,
    backgroundColor: Colors.transparent,
    barrierColor: modalBarrierColor,
    builder: (ctx) => LayoutBuilder(
      builder: (_, constraints) => ReservationDetailModal(
        reservation: reservation,
        availableStores: availableStores,
        initialSpaceOptions: initialSpaceOptions,
        onSaved: onSaved,
        onDeleted: onDeleted,
        maxAvailableHeight: constraints.maxHeight,
      ),
    ),
  );
}
