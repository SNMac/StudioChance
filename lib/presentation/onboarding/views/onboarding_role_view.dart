import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:studio_chance/domain/enums/user_role.dart';
import 'package:studio_chance/presentation/components/app_bar_action_button.dart';
import 'package:studio_chance/presentation/components/app_bar_back_button.dart';
import 'package:studio_chance/presentation/components/custom_alert_dialog.dart';
import 'package:studio_chance/presentation/components/custom_app_bar.dart';
import 'package:studio_chance/presentation/components/safe_area_with_padding.dart';
import 'package:studio_chance/presentation/onboarding/view_models/onboarding_role_view_model.dart';
import 'package:studio_chance/presentation/onboarding/views/components/role_selection_button.dart';
import 'package:studio_chance/router/router_path.dart';

class OnboardingRoleView extends ConsumerStatefulWidget {
  const OnboardingRoleView({super.key});

  @override
  ConsumerState<OnboardingRoleView> createState() => _OnboardingRoleViewState();
}

class _OnboardingRoleViewState extends ConsumerState<OnboardingRoleView> {
  @override
  Widget build(BuildContext context) {
    final currentRole = ref.watch(onboardingRoleViewModelProvider);
    final viewModel = ref.read(onboardingRoleViewModelProvider.notifier);

    final isSelected = viewModel.isRoleSelected;

    void onNextPressed() {
      showCustomAlertDialog(
        context: context,
        title: '${currentRole.displayName}로 진행할까요?',
        onConfirm: () {
          viewModel.saveToSession();

          if (currentRole == UserRole.admin) {
            context.push(SCRoute.onboardingStore.fullPath);
          } else if (currentRole == UserRole.staff ||
              currentRole == UserRole.viewer) {
            context.push(SCRoute.onboardingInvitation.fullPath);
          }
        },
      );
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: '역할 선택',
        leading: const AppBarBackButton(),
        actions: [
          AppBarActionButton(
            label: '다음',
            onPressed: isSelected ? onNextPressed : null,
          ),
        ],
      ),
      body: SafeAreaWithPadding(
        child: Center(
          child: Column(
            spacing: 32,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 200,
                child: RoleSelectionButton(
                  title: UserRole.admin.displayName,
                  description: UserRole.admin.displayDescription,
                  isSelected: currentRole == UserRole.admin,
                  onPressed: () {
                    viewModel.selectRole(UserRole.admin);
                  },
                ),
              ),
              SizedBox(
                width: 200,
                child: RoleSelectionButton(
                  title: UserRole.staff.displayName,
                  description: UserRole.staff.displayDescription,
                  isSelected: currentRole == UserRole.staff,
                  onPressed: () {
                    viewModel.selectRole(UserRole.staff);
                  },
                ),
              ),
              SizedBox(
                width: 200,
                child: RoleSelectionButton(
                  title: UserRole.viewer.displayName,
                  description: UserRole.viewer.displayDescription,
                  isSelected: currentRole == UserRole.viewer,
                  onPressed: () {
                    viewModel.selectRole(UserRole.viewer);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
