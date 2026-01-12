import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:studio_chance/domain/enums/user_role.dart';
import 'package:studio_chance/presentation/components/app_bar_action_button.dart';
import 'package:studio_chance/presentation/components/custom_alert_dialog.dart';
import 'package:studio_chance/presentation/components/custom_app_bar.dart';
import 'package:studio_chance/presentation/components/safe_area_with_padding.dart';
import 'package:studio_chance/presentation/onboarding/view_models/onboarding_role_view_model.dart';
import 'package:studio_chance/presentation/onboarding/views/components/selection_button.dart';
import 'package:studio_chance/router/router_path.dart';

class OnboardingRoleView extends ConsumerStatefulWidget {
  const OnboardingRoleView({super.key});

  @override
  ConsumerState<OnboardingRoleView> createState() => _OnboardingRoleViewState();
}

class _OnboardingRoleViewState extends ConsumerState<OnboardingRoleView> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingRoleViewModelProvider);
    final notifier = ref.read(onboardingRoleViewModelProvider.notifier);

    final isSelected = notifier.isRoleSelected;

    void onNextPressed() {
      showCustomAlertDialog(
        context: context,
        title: '${state.displayName}로 진행할까요?',
        onConfirm: () {
          notifier.saveToSession();

          if (state == UserRole.admin) {
            context.push(SCRoute.onboardingAdmin.fullPath);
          } else if (state == UserRole.staff || state == UserRole.viewer) {
            context.push(SCRoute.onboardingInvitation.fullPath);
          }
        },
      );
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: '역할 선택',
        actions: [
          AppBarActionButton(
            label: '다음',
            onPressed: isSelected ? onNextPressed : null,
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
              children: [
                SelectionButton(
                  title: UserRole.admin.displayName,
                  description: UserRole.admin.displayDescription,
                  isSelected: state == UserRole.admin,
                  onPressed: () => notifier.selectRole(UserRole.admin),
                ),
                SelectionButton(
                  title: UserRole.staff.displayName,
                  description: UserRole.staff.displayDescription,
                  isSelected: state == UserRole.staff,
                  onPressed: () => notifier.selectRole(UserRole.staff),
                ),
                SelectionButton(
                  title: UserRole.viewer.displayName,
                  description: UserRole.viewer.displayDescription,
                  isSelected: state == UserRole.viewer,
                  onPressed: () => notifier.selectRole(UserRole.viewer),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
