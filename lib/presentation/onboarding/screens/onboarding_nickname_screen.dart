import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:studio_chance/presentation/commons/nickname_input/screens/nickname_form_screen.dart';
import 'package:studio_chance/presentation/commons/widgets/custom_alert_dialog.dart';
import 'package:studio_chance/presentation/onboarding/controllers/onboarding_session_controller.dart';
import 'package:studio_chance/router/router_path.dart';

class OnboardingNicknameScreen extends ConsumerWidget {
  const OnboardingNicknameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionNickname = ref
        .watch(onboardingSessionControllerProvider)
        .nickname;

    void showLogoutDialog() => showCustomAlertDialog(
      context: context,
      title: '로그인 화면으로 돌아갈까요?',
      onConfirmBeforePop: () async {
        await ref
            .read(onboardingSessionControllerProvider.notifier)
            .cancelOnboarding();
        if (context.mounted && context.canPop()) {
          context.pop();
        }
      },
    );

    return NicknameFormScreen(
      initialNickname: sessionNickname,
      title: '닉네임 설정',
      submitLabel: '다음',
      enableBackGesture: false,
      onBackPress: () => showLogoutDialog(),

      onComplete: (nickname) async {
        ref
            .read(onboardingSessionControllerProvider.notifier)
            .setNickname(nickname);
        context.push(SCRoute.onboardingRole.fullPath);
      },
    );
  }
}
