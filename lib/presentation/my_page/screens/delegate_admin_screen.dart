import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:studio_chance/common/enums/user_role.dart';
import 'package:studio_chance/domain/entities/store_member_info.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';
import 'package:studio_chance/presentation/commons/widgets/app_bar/custom_app_bar.dart';
import 'package:studio_chance/presentation/commons/widgets/custom_alert_dialog.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/grouped_form_caption.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/grouped_form_container.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/title_navigation_button.dart';
import 'package:studio_chance/presentation/commons/widgets/loading_overlay.dart';
import 'package:studio_chance/presentation/commons/widgets/safe_area_with_padding.dart';
import 'package:studio_chance/presentation/providers/app_auth_controller.dart';
import 'package:studio_chance/presentation/providers/store_detail_provider.dart';
import 'package:studio_chance/presentation/providers/store_membership_controller.dart';

/// 관리자 위임 대상 선택. 대상(스태프·뷰어)을 고르면 위임 후 내 역할을 묻고,
/// 확인을 받은 뒤 위임한다. 대상자의 수락 없이 바로 적용된다 (CONTEXT.md "관리자 위임").
///
/// 위임에 성공하면 점포 상세로 돌아가고, 상세 화면은 내 새 역할 기준으로 다시 그려진다.
class DelegateAdminScreen extends ConsumerWidget {
  const DelegateAdminScreen({super.key, required this.storeId});

  final String storeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myUid = ref.watch(
      currentUserProvider.select((user) => user.asData?.value?.id),
    );
    final store = ref.watch(storeDetailProvider(storeId)).asData?.value;
    final isWorking = ref.watch(
      storeMembershipControllerProvider.select((s) => s.isLoading),
    );

    final candidates = [
      for (final member in store?.sortedMemberInfos ?? <StoreMemberInfo>[])
        if (member.user.id != myUid && member.role != UserRole.admin) member,
    ];

    return Stack(
      children: [
        Scaffold(
          backgroundColor: context.systemGroupedBackground,
          appBar: const CustomAppBar(title: '관리자 위임'),
          body: SingleChildScrollView(
            child: SafeAreaWithPadding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              child: GroupedFormContainer(
                header: const GroupedFormCaption.header(
                  '새 관리자를 선택하세요. 위임하면 바로 적용됩니다.',
                ),
                children: [
                  for (final member in candidates)
                    TitleNavigationButton(
                      title: member.user.displayName,
                      content: member.role.displayName,
                      isChangeable: true,
                      prioritizeContent: true,
                      showChevron: false,
                      onPressed: isWorking
                          ? null
                          : () => _askMyRole(context, ref, member),
                    ),
                ],
              ),
            ),
          ),
        ),
        LoadingOverlay(isLoading: isWorking),
      ],
    );
  }

  void _askMyRole(BuildContext context, WidgetRef ref, StoreMemberInfo target) {
    final name = target.user.displayName;

    showCupertinoModalPopup<void>(
      context: context,
      builder: (sheetContext) => CupertinoActionSheet(
        title: const Text('위임 후 내 역할'),
        message: Text('$name 님이 새 관리자가 되고, 나는 고른 역할로 남습니다.'),
        actions: [
          for (final role in [UserRole.staff, UserRole.viewer])
            CupertinoActionSheetAction(
              onPressed: () {
                sheetContext.pop();
                _confirm(context, ref, target, role);
              },
              child: Text(role.displayName),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => sheetContext.pop(),
          child: const Text('취소'),
        ),
      ),
    );
  }

  void _confirm(
    BuildContext context,
    WidgetRef ref,
    StoreMemberInfo target,
    UserRole myNewRole,
  ) {
    final name = target.user.displayName;

    showCustomAlertDialog(
      context: context,
      title: '$name 님에게 관리자를 위임할까요?',
      content:
          '바로 적용되며 내 역할은 ${myNewRole.displayName}가 됩니다. '
          '되돌리려면 $name 님이 다시 위임해야 합니다.',
      confirmText: '위임',
      isDestructive: true,
      onConfirmAfterPop: () async {
        final succeeded = await ref
            .read(storeMembershipControllerProvider.notifier)
            .delegateAdmin(
              storeId: storeId,
              uid: target.user.id,
              previousAdminRole: myNewRole,
            );
        if (succeeded && context.mounted) context.pop();
      },
    );
  }
}
