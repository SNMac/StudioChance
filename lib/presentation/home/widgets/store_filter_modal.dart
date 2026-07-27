import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/presentation/colors.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';
import 'package:studio_chance/presentation/commons/extensions/store_color_extensions.dart';
import 'package:studio_chance/presentation/commons/widgets/app_bar/app_bar_action_button.dart';
import 'package:studio_chance/presentation/commons/widgets/app_bar/modal_app_bar.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/grouped_form_container.dart';
import 'package:studio_chance/presentation/commons/widgets/modal_grabber.dart';
import 'package:studio_chance/presentation/commons/widgets/safe_area_with_padding.dart';
import 'package:studio_chance/presentation/providers/app_auth_controller.dart';
import 'package:studio_chance/presentation/providers/home_store_filter_controller.dart';

const double _kModalInitialSize = 0.5;
const double _kModalMaxSize = 1.0;

/// 점포 필터 모달.
///
/// 각 항목: (색상 도트) (점포명) (역할) — checkmark로 선택 상태 표시.
/// 탭 시 [HomeStoreFilterController]를 통해 선택/해제 토글.
///
/// 두 detent 시트: [showModalBottomSheet]가 `maxAvailableHeight`를 전달하고,
/// 이 위젯이 [AnimationController]로 높이를 직접 제어한다 (CLAUDE.md "모달 시트 패턴").
class StoreFilterModal extends ConsumerStatefulWidget {
  const StoreFilterModal({super.key, required this.maxAvailableHeight});

  final double maxAvailableHeight;

  @override
  ConsumerState<StoreFilterModal> createState() => _StoreFilterModalState();
}

class _StoreFilterModalState extends ConsumerState<StoreFilterModal>
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
    final storeInfos = ref.watch(
      currentUserProvider.select((u) => u.asData?.value?.storeInfos ?? []),
    );
    final selectedIds = ref.watch(homeStoreFilterControllerProvider);
    final notifier = ref.read(homeStoreFilterControllerProvider.notifier);
    final isAllSelected = selectedIds.length == storeInfos.length;

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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const ModalGrabber(),
                  ModalAppBar(
                    title: '점포 선택',
                    actions: [
                      AppBarActionButton(
                        label: isAllSelected ? '전체 해제' : '전체 선택',
                        onPressed: notifier.toggleAll,
                        isRegularWeight: true,
                      ),
                    ],
                  ),
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
                      for (final info in storeInfos)
                        SizedBox(
                          height: inputFormComponentHeight,
                          child: CupertinoButton(
                            padding: const EdgeInsetsDirectional.symmetric(
                              horizontal: horizontalPadding,
                            ),
                            onPressed: () => notifier.toggle(info.id),
                            child: Row(
                              children: [
                                // 색상 도트
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(info.color.foregroundColorValue),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // 점포명
                                Expanded(
                                  child: Text(
                                    info.name,
                                    style: Theme.of(context).textTheme.bodyLarge,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                // 역할명
                                Text(
                                  info.role.displayName,
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.normal,
                                        color: context.secondaryLabel,
                                      ),
                                ),
                                const SizedBox(width: 12),
                                // 선택 checkmark — 항상 20px 폭을 점유하여 역할명 위치 고정
                                SizedBox(
                                  width: 20,
                                  child: selectedIds.contains(info.id)
                                      ? Icon(
                                          CupertinoIcons.checkmark_alt,
                                          size: 20,
                                          color: context.systemBlue,
                                        )
                                      : null,
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

/// 점포 필터 모달 표시.
Future<void> showStoreFilterModal(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    enableDrag: false,
    backgroundColor: Colors.transparent,
    barrierColor: modalBarrierColor,
    builder: (ctx) => LayoutBuilder(
      builder: (_, constraints) =>
          StoreFilterModal(maxAvailableHeight: constraints.maxHeight),
    ),
  );
}
