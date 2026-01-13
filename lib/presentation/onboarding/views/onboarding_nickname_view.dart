import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:studio_chance/presentation/components/app_bar_action_button.dart';
import 'package:studio_chance/presentation/components/app_bar_back_button.dart';
import 'package:studio_chance/presentation/components/custom_alert_dialog.dart';
import 'package:studio_chance/presentation/components/custom_app_bar.dart';
import 'package:studio_chance/presentation/components/nickname_input/view_models/nickname_input_form_view_model.dart';
import 'package:studio_chance/presentation/components/nickname_input/views/nickname_input_form_view.dart';
import 'package:studio_chance/presentation/components/safe_area_with_padding.dart';
import 'package:studio_chance/presentation/onboarding/sessions/onboarding_session.dart';
import 'package:studio_chance/presentation/onboarding/view_models/onboarding_nickname_view_model.dart';
import 'package:studio_chance/router/router_path.dart';

class OnboardingNicknameView extends ConsumerWidget {
  const OnboardingNicknameView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionNickname = ref.watch(onboardingSessionProvider).nickname;
    final formProvider = nicknameInputFormViewModelProvider(sessionNickname);
    final viewModelProvider = onboardingNicknameViewModelProvider;

    final isFormValid = ref.watch(
      formProvider.select((state) => state.isValid),
    );

    void showExitDialog() {
      showCustomAlertDialog(
        context: context,
        title: '로그인 화면으로 돌아갈까요?',
        onConfirm: () async {
          await ref.read(viewModelProvider.notifier).cancelOnboarding();
          if (context.mounted && context.canPop()) {
            context.pop();
          }
        },
      );
    }

    void onNextPressed() {
      final currentFormState = ref.read(formProvider);
      final inputNickname = currentFormState.nickname;

      ref.read(onboardingSessionProvider.notifier).setNickname(inputNickname);
      context.push(SCRoute.onboardingRole.fullPath);
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        showExitDialog();
      },
      child: Scaffold(
        appBar: CustomAppBar(
          title: '닉네임 설정',
          leading: AppBarBackButton(onPressed: showExitDialog),
          actions: [
            AppBarActionButton(
              label: '다음',
              onPressed: isFormValid ? onNextPressed : null,
            ),
          ],
        ),
        body: SafeAreaWithPadding(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '사용하실 닉네임을 입력해주세요',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              NicknameInputFormView(initialNickname: sessionNickname),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}