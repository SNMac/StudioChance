import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:studio_chance/common/exceptions/app_exception.dart';
import 'package:studio_chance/domain/enums/user_role.dart';
import 'package:studio_chance/presentation/commons/widgets/app_bar/app_bar_action_button.dart';
import 'package:studio_chance/presentation/commons/widgets/app_bar/custom_app_bar.dart';
import 'package:studio_chance/presentation/commons/widgets/custom_alert_dialog.dart';
import 'package:studio_chance/presentation/commons/widgets/loading_overlay.dart';
import 'package:studio_chance/presentation/commons/widgets/safe_area_with_padding.dart';
import 'package:studio_chance/presentation/onboarding/controllers/onboarding_session_controller.dart';
import 'package:studio_chance/presentation/onboarding/widgets/large_selection_button.dart';
import 'package:studio_chance/router/router_path.dart';

class OnboardingRoleScreen extends ConsumerWidget {
  const OnboardingRoleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingSessionControllerProvider);
    final notifier = ref.read(onboardingSessionControllerProvider.notifier);

    final selectedRole = state.selectedRole;
    final isLoading = state.status.isLoading;

    void showErrorDialog(String title, String content) => showCustomAlertDialog(
      context: context,
      title: title,
      content: content,
      showCancel: false,
    );

    ref.listen(onboardingSessionControllerProvider.select((s) => s.status), (
      previous,
      next,
    ) {
      next.when(
        data: (_) {},
        loading: () {},
        error: (error, stackTrace) {
          if (error is AppException) {
            showErrorDialog(error.title, error.content);
          } else {
            showErrorDialog('오류 발생', '개발자에게 문의해주세요.\n(${error.toString()})');
          }
        },
      );
    });

    Future<void> onNextPressed() async {
      if (isLoading) return;

      showCustomAlertDialog(
        context: context,
        title: '${selectedRole.displayName}로 진행할까요?',
        onConfirmBeforePop: () async {
          await notifier.saveNicknameToRemote();

          if (ref.read(onboardingSessionControllerProvider).status.hasError) {
            return;
          }

          if (!context.mounted) return;

          if (selectedRole == UserRole.admin) {
            context.push(SCRoute.onboardingAdmin.fullPath);
          } else {
            context.push(SCRoute.onboardingInvitation.fullPath);
          }
        },
      );
    }

    Future<void> onSkipPressed() async => showCustomAlertDialog(
      context: context,
      title: '홈으로 이동할까요?',
      content: '점포는 마이페이지에서 설정할 수 있어요.',
      onConfirmBeforePop: () async {
        if (isLoading) return;
        await notifier.submitNicknameOnly();
      },
    );

    return Scaffold(
      appBar: CustomAppBar(
        title: '역할 선택',
        actions: [
          AppBarActionButton(
            label: '다음',
            onPressed: (state.isRoleSelected && !isLoading)
                ? onNextPressed
                : null,
          ),
        ],
      ),
      body: Stack(
        children: [
          SafeAreaWithPadding(
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

          LoadingOverlay(isLoading: isLoading),
        ],
      ),
    );
  }
}
