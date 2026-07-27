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

/// 점포 필터 모달.
///
/// 각 항목: (색상 도트) (점포명) (역할) — checkmark로 선택 상태 표시.
/// 탭 시 [HomeStoreFilterController]를 통해 선택/해제 토글.
class StoreFilterModal extends ConsumerWidget {
  const StoreFilterModal({super.key, this.scrollController});

  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeInfos = ref.watch(
      currentUserProvider.select((u) => u.asData?.value?.storeInfos ?? []),
    );
    final selectedIds = ref.watch(homeStoreFilterControllerProvider);
    final notifier = ref.read(homeStoreFilterControllerProvider.notifier);
    final isAllSelected = selectedIds.length == storeInfos.length;

    return Column(
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
        Expanded(
          child: SingleChildScrollView(
            controller: scrollController,
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
    );
  }
}

/// 점포 필터 모달 표시.
Future<void> showStoreFilterModal(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: context.systemGroupedBackground,
    barrierColor: modalBarrierColor,
    clipBehavior: Clip.antiAlias,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(modalTopCornerRadius),
      ),
    ),
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 1.0,
      expand: false,
      snap: true,
      snapSizes: const [0.5, 1.0],
      builder: (_, controller) =>
          StoreFilterModal(scrollController: controller),
    ),
  );
}
