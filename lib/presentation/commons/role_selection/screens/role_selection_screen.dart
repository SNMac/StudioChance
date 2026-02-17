import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:studio_chance/domain/enums/user_role.dart';
import 'package:studio_chance/presentation/commons/role_selection/controllers/role_selection_controller.dart';
import 'package:studio_chance/presentation/commons/widgets/app_bar/app_bar_action_button.dart';
import 'package:studio_chance/presentation/commons/widgets/app_bar/app_bar_back_button.dart';
import 'package:studio_chance/presentation/commons/widgets/app_bar/custom_app_bar.dart';
import 'package:studio_chance/presentation/commons/widgets/custom_alert_dialog.dart';
import 'package:studio_chance/presentation/commons/widgets/safe_area_with_padding.dart';
import 'package:studio_chance/presentation/onboarding/widgets/large_selection_button.dart';
import 'package:studio_chance/router/router_path.dart';

class RoleSelectionScreen extends ConsumerWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedRole = ref.watch(roleSelectionControllerProvider);
    final notifier = ref.read(roleSelectionControllerProvider.notifier);

    Future<void> onNextPressed() async {
      showCustomAlertDialog(
        context: context,
        title: '${selectedRole.displayName}로 진행할까요?',
        content: '역할은 점포마다 다르게 설정할 수 있습니다',
        onConfirmBeforePop: () async {
          if (!context.mounted) return;

          if (selectedRole == UserRole.admin) {
            SCRoute.adminStoreRegistration.pushChild(context);
          } else {
            SCRoute.invitation.pushChild(context);
          }
        },
      );
    }

    Future<void> onSkipPressed() async => showCustomAlertDialog(
      context: context,
      title: '홈으로 이동할까요?',
      content: '점포는 마이페이지에서 설정할 수 있어요.',
      onConfirmBeforePop: () async {
        notifier.skipOnboarding();
      },
    );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(
        title: '역할 선택',
        leading: const AppBarNaviBackButton(),
        actions: [
          AppBarActionButton(
            label: '다음',
            onPressed: selectedRole != UserRole.none ? onNextPressed : null,
          ),
        ],
      ),
      body: SafeAreaWithPadding(
        child: Center(
          child: SizedBox(
            width: 240,
            child: Column(
              spacing: 32,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                LargeSelectionButton(
                  title: UserRole.admin.displayName,
                  description: UserRole.admin.displayDescription,
                  isSelected: selectedRole == UserRole.admin,
                  onPressed: () => notifier.setRole(UserRole.admin),
                ),
                LargeSelectionButton(
                  title: UserRole.staff.displayName,
                  description: UserRole.staff.displayDescription,
                  isSelected: selectedRole == UserRole.staff,
                  onPressed: () => notifier.setRole(UserRole.staff),
                ),
                LargeSelectionButton(
                  title: UserRole.viewer.displayName,
                  description: UserRole.viewer.displayDescription,
                  isSelected: selectedRole == UserRole.viewer,
                  onPressed: () => notifier.setRole(UserRole.viewer),
                ),
                LargeSelectionButton(
                  title: '나중에 설정',
                  isNavigation: true,
                  onPressed: onSkipPressed,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
