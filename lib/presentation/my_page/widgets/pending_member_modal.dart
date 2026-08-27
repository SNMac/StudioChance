import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/domain/entities/store_member_info.dart';
import 'package:studio_chance/presentation/colors.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';
import 'package:studio_chance/presentation/commons/widgets/custom_alert_dialog.dart';
import 'package:studio_chance/presentation/commons/widgets/app_bar/modal_app_bar.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/grouped_form_container.dart';
import 'package:studio_chance/presentation/commons/widgets/modal_grabber.dart';
import 'package:studio_chance/presentation/commons/widgets/safe_area_with_padding.dart';
import 'package:studio_chance/presentation/providers/pending_member_controller.dart';
import 'package:studio_chance/presentation/providers/store_detail_provider.dart';

const double _kModalInitialSize = 0.5;
const double _kModalMaxSize = 1.0;

/// 승인 대기 멤버 모달.
///
/// 각 항목: (닉네임) (신청 역할) (거절) (승인).
/// 승인 시 역할은 신청자가 초대 코드 단계에서 선택한 값을 그대로 사용한다.
///
/// 두 detent 시트 구조는 [StoreFilterModal]과 동일하다 (CLAUDE.md "모달 시트 패턴").
class PendingMemberModal extends ConsumerStatefulWidget {
  const PendingMemberModal({
    super.key,
    required this.storeId,
    required this.maxAvailableHeight,
  });

  final String storeId;
  final double maxAvailableHeight;

  @override
  ConsumerState<PendingMemberModal> createState() => _PendingMemberModalState();
}

class _PendingMemberModalState extends ConsumerState<PendingMemberModal>
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

  void _dismissModal() => Navigator.pop(context);

  void _animateTo(double target) {
    _sheetController.animateTo(
      target,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _snapToNearest() {
    const mid = (_kModalInitialSize + _kModalMaxSize) / 2;
    _animateTo(
      _sheetController.value >= mid ? _kModalMaxSize : _kModalInitialSize,
    );
  }

  String _displayName(StoreMemberInfo info) =>
      info.user.nickname ?? info.user.name;

  void _onApprove(StoreMemberInfo info) {
    showCustomAlertDialog(
      context: context,
      title: '${_displayName(info)}님을 승인할까요?',
      content: '${info.role.displayName} 역할로 점포에 참여하게 됩니다.',
      onConfirmAfterPop: () {
        ref
            .read(pendingMemberControllerProvider.notifier)
            .approve(
              storeId: widget.storeId,
              uid: info.user.id,
              role: info.role,
            );
      },
    );
  }

  void _onReject(StoreMemberInfo info) {
    showCustomAlertDialog(
      context: context,
      title: '${_displayName(info)}님의 신청을 거절할까요?',
      content: '거절한 신청은 되돌릴 수 없습니다.',
      confirmText: '거절',
      isDestructive: true,
      onConfirmAfterPop: () {
        ref
            .read(pendingMemberControllerProvider.notifier)
            .reject(storeId: widget.storeId, uid: info.user.id);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final storeAsync = ref.watch(storeDetailProvider(widget.storeId));
    final waitingInfos = storeAsync.asData?.value?.waitingMemberInfos ?? [];
    final isLoadingStore = storeAsync.isLoading;
    // storeDetailProvider는 조회 실패도 null로 흡수하므로(store_detail_provider.dart),
    // value == null && !isLoading은 "정말 대기자가 없음"과 구분되는 조회 실패/미존재 상태다.
    final hasLoadFailed = !isLoadingStore && storeAsync.asData?.value == null;
    // 승인/거절 처리 중에는 버튼을 비활성화해 같은 신청의 중복 제출을 막는다.
    final isMutating = ref.watch(pendingMemberControllerProvider).isLoading;

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
            Listener(
              behavior: HitTestBehavior.translucent,
              onPointerDown: (event) {
                _grabberDragStartSize = _sheetController.value;
                _grabberDragStartY = event.position.dy;
              },
              onPointerMove: (event) {
                final delta = -event.delta.dy / widget.maxAvailableHeight;
                _sheetController.value = (_sheetController.value + delta).clamp(
                  _kModalInitialSize,
                  _kModalMaxSize,
                );
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
                  ModalAppBar(title: '가입 신청'),
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
                  child: isLoadingStore
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Center(
                            child: CircularProgressIndicator.adaptive(),
                          ),
                        )
                      : hasLoadFailed || waitingInfos.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Text(
                            hasLoadFailed
                                ? '가입 신청 정보를 불러오지 못했습니다'
                                : '대기 중인 가입 신청이 없습니다',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: context.secondaryLabel),
                          ),
                        )
                      : GroupedFormContainer(
                          children: [
                            for (final info in waitingInfos)
                              _PendingMemberRow(
                                name: _displayName(info),
                                roleLabel: info.role.displayName,
                                disabled: isMutating,
                                onApprove: () => _onApprove(info),
                                onReject: () => _onReject(info),
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

/// 대기 멤버 한 줄: (닉네임) (신청 역할) (거절) (승인)
class _PendingMemberRow extends StatelessWidget {
  const _PendingMemberRow({
    required this.name,
    required this.roleLabel,
    required this.onApprove,
    required this.onReject,
    this.disabled = false,
  });

  final String name;
  final String roleLabel;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      height: inputFormComponentHeight,
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: horizontalPadding,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: textTheme.bodyLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              roleLabel,
              style: textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.normal,
                color: context.secondaryLabel,
              ),
            ),
            const SizedBox(width: 8),
            CupertinoButton(
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              onPressed: disabled ? null : onReject,
              child: Text(
                '거절',
                style: textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
            CupertinoButton(
              minimumSize: Size.zero,
              padding: const EdgeInsets.only(left: 8),
              onPressed: disabled ? null : onApprove,
              child: Text(
                '승인',
                style: textTheme.bodyLarge?.copyWith(color: context.systemBlue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 승인 대기 멤버 모달 표시.
Future<void> showPendingMemberModal(BuildContext context, String storeId) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    enableDrag: false,
    backgroundColor: Colors.transparent,
    barrierColor: modalBarrierColor,
    builder: (ctx) => LayoutBuilder(
      builder: (_, constraints) => PendingMemberModal(
        storeId: storeId,
        maxAvailableHeight: constraints.maxHeight,
      ),
    ),
  );
}
