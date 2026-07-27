import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/domain/entities/reservation.dart';
import 'package:studio_chance/domain/entities/store_member_info.dart';
import 'package:studio_chance/domain/entities/store_summary.dart';
import 'package:studio_chance/domain/entities/user.dart';
import 'package:studio_chance/domain/entities/space_option.dart';
import 'package:studio_chance/domain/entities/user_store_info.dart';
import 'package:studio_chance/common/enums/payment_method.dart';
import 'package:studio_chance/common/enums/reservation_platform.dart';
import 'package:studio_chance/common/enums/reservation_status.dart';
import 'package:studio_chance/common/enums/user_role.dart';
import 'package:studio_chance/common/exceptions/app_exception.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';
import 'package:studio_chance/presentation/commons/widgets/custom_alert_dialog.dart';
import 'package:studio_chance/presentation/commons/widgets/loading_overlay.dart';
import 'package:studio_chance/presentation/home/widgets/home_nav_bar.dart';
import 'package:studio_chance/presentation/home/widgets/home_tab_bar.dart';
import 'package:studio_chance/presentation/home/widgets/monthly_calendar/monthly_calendar.dart';
import 'package:studio_chance/presentation/home/widgets/three_day_calendar/reservation_create_modal.dart';
import 'package:studio_chance/presentation/home/widgets/three_day_calendar/reservation_detail_modal.dart';
import 'package:studio_chance/presentation/home/widgets/three_day_calendar/three_day_calendar.dart';
import 'package:studio_chance/presentation/providers/app_auth_controller.dart';
import 'package:studio_chance/presentation/providers/home_calendar_controller.dart';
import 'package:studio_chance/presentation/providers/home_reservation_actions_controller.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isLoadingForModal = false;
  bool _showLoadingOverlay = false;
  Timer? _overlayTimer;

  @override
  void dispose() {
    _overlayTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMonthlyCalendarVisible = ref.watch(
      homeCalendarControllerProvider.select((s) => s.isMonthlyCalendarVisible),
    );
    final displayedMonth = ref.watch(
      homeCalendarControllerProvider.select((s) => s.displayedMonth),
    );
    final calendarHeight = monthlyCalendarHeightForMonth(displayedMonth);
    final storeInfos = ref.watch(
      currentUserProvider.select((u) => u.asData?.value?.storeInfos ?? []),
    );
    final selectedStartDate = ref.watch(
      homeCalendarControllerProvider.select((s) => s.selectedStartDate),
    );

    ref.listen(homeReservationActionsControllerProvider, (_, next) {
      next.whenOrNull(
        error: (e, _) {
          if (!context.mounted) return;
          if (e is AppException && !e.isSilentable) {
            showCustomAlertDialog(
              context: context,
              title: e.title,
              content: e.content,
              showCancel: false,
            );
          } else if (e is! AppException) {
            showCustomAlertDialog(
              context: context,
              title: '오류',
              content: '잠시 후 다시 시도해 주세요.',
              showCancel: false,
            );
          }
        },
      );
    });

    // admin·staff만 예약 생성 가능
    final canCreateReservation = storeInfos.any(
      (info) => info.role == UserRole.admin || info.role == UserRole.staff,
    );

    return Stack(
      children: [
        Scaffold(
          backgroundColor: context.systemBackground,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                const HomeNavBar(),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  height: isMonthlyCalendarVisible ? calendarHeight : 0,
                  clipBehavior: Clip.hardEdge,
                  decoration: const BoxDecoration(),
                  child: OverflowBox(
                    maxHeight: calendarHeight,
                    alignment: Alignment.topCenter,
                    child: const MonthlyCalendar(),
                  ),
                ),
                Expanded(
                  child: ThreeDayCalendar(
                    onOpenDetailModal: _onOpenDetailModal,
                    isInteractionBlocked: _isLoadingForModal,
                  ),
                ),
              ],
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButton: canCreateReservation
              ? _AddReservationFab(
                  enabled: !_isLoadingForModal,
                  onPressed: () => _onAddReservation(storeInfos, selectedStartDate),
                )
              : null,
          bottomNavigationBar: const HomeTabBar(),
        ),
        LoadingOverlay(isLoading: _showLoadingOverlay),
      ],
    );
  }

  Future<void> _onOpenDetailModal(
    Reservation reservation,
    List<StoreSummary>? availableStores,
  ) async {
    if (_isLoadingForModal) return;

    setState(() => _isLoadingForModal = true);
    _overlayTimer = Timer(
      const Duration(seconds: 1),
      () { if (mounted) setState(() => _showLoadingOverlay = true); },
    );

    List<SpaceOption>? spaceOptions;
    try {
      spaceOptions = await ref
          .read(homeReservationActionsControllerProvider.notifier)
          .getStoreSpaceOptions(reservation.storeSummary.id);
    } finally {
      _overlayTimer?.cancel();
      _overlayTimer = null;
      if (mounted) {
        setState(() {
          _isLoadingForModal = false;
          _showLoadingOverlay = false;
        });
      }
    }

    if (!mounted) return;
    await showReservationDetailModal(
      context,
      reservation,
      availableStores: availableStores,
      initialSpaceOptions: spaceOptions,
      onSaved: (updated) {
        ref
            .read(homeReservationActionsControllerProvider.notifier)
            .updateReservation(updated);
      },
      onDeleted: () {
        ref
            .read(homeReservationActionsControllerProvider.notifier)
            .deleteReservation(reservation);
      },
    );
  }

  Future<void> _onAddReservation(
    List<UserStoreInfo> storeInfos,
    DateTime selectedStartDate,
  ) async {
    if (_isLoadingForModal) return;

    final creatableInfos = storeInfos
        .where((info) => info.role == UserRole.admin || info.role == UserRole.staff)
        .toList();
    final defaultInfo = creatableInfos.first;
    final defaultStoreSummary = StoreSummary(
      id: defaultInfo.id,
      name: defaultInfo.name,
      color: defaultInfo.color,
    );
    final availableStores = creatableInfos
        .map((info) => StoreSummary(id: info.id, name: info.name, color: info.color))
        .toList();

    final start = DateTime(
      selectedStartDate.year,
      selectedStartDate.month,
      selectedStartDate.day,
      10,
      0,
    );
    final initialReservation = Reservation(
      id: '',
      storeSummary: defaultStoreSummary,
      writer: StoreMemberInfo(
        user: const User(
          id: '',
          name: '',
          email: '',
          nickname: null,
          authProviders: [],
          storeInfos: [],
        ),
        role: defaultInfo.role,
      ),
      status: ReservationStatus.pending,
      customerName: '',
      headCount: 0,
      customerPhone: '',
      memo: '',
      isAllDay: false,
      startTime: start,
      endTime: start.add(const Duration(hours: 1)),
      platform: ReservationPlatform.naver,
      paymentMethod: PaymentMethod.bankTransfer,
      calculatedPrice: 0,
      priceAdjustment: 0,
      totalPrice: 0,
    );

    // 공간 옵션 선 조회 — fetch 중에만 버튼 비활성화, 1초 이상 지연 시 LoadingOverlay 표시
    setState(() => _isLoadingForModal = true);
    _overlayTimer = Timer(
      const Duration(seconds: 1),
      () { if (mounted) setState(() => _showLoadingOverlay = true); },
    );

    List<SpaceOption>? initialSpaceOptions;
    try {
      initialSpaceOptions = await ref
          .read(homeReservationActionsControllerProvider.notifier)
          .getStoreSpaceOptions(defaultInfo.id);
    } finally {
      // fetch 완료(성공·오류) 즉시 타이머 취소 및 로딩 상태 해제
      _overlayTimer?.cancel();
      _overlayTimer = null;
      if (mounted) {
        setState(() {
          _isLoadingForModal = false;
          _showLoadingOverlay = false;
        });
      }
    }

    if (!mounted) return;
    await showReservationCreateModal(
      context,
      initialReservation,
      availableStores: availableStores,
      initialSpaceOptions: initialSpaceOptions,
      onSaved: (reservation) {
        ref
            .read(homeReservationActionsControllerProvider.notifier)
            .createReservation(reservation);
      },
    );
  }
}

// ── FAB 위젯 ──────────────────────────────────────────────────────────────────

/// 예약 등록 버튼 (44×44 원형, systemBlue 배경, plus 아이콘)
class _AddReservationFab extends StatelessWidget {
  const _AddReservationFab({required this.onPressed, required this.enabled});

  final VoidCallback onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onPressed : null,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: context.systemBlue,
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: const Icon(CupertinoIcons.plus, size: 20, color: Colors.white),
      ),
    );
  }
}
