import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:studio_chance/common/exceptions/app_exception.dart';
import 'package:studio_chance/presentation/commons/nickname_input/screens/nickname_save_screen.dart';
import 'package:studio_chance/presentation/commons/widgets/custom_alert_dialog.dart';
import 'package:studio_chance/presentation/onboarding/controllers/onboarding_nickname_controller.dart';
import 'package:studio_chance/router/router_path.dart';

class OnboardingNicknameScreen extends ConsumerWidget {
  const OnboardingNicknameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void showSaveError(Object error) {
      if (error is AppException) {
        showCustomAlertDialog(
          context: context,
          title: error.title,
          content: error.content,
          showCancel: false,
        );
      } else {
        showCustomAlertDialog(
          context: context,
          title: '에러가 발생했습니다',
          content: '개발자에게 문의해 주세요.\n(${error.toString()})',
          showCancel: false,
        );
      }
    }

    void showLogoutDialog() => showCustomAlertDialog(
      context: context,
      title: '로그인 화면으로 돌아갈까요?',
      onConfirmBeforePop: () async {
        await ref
            .read(onboardingNicknameControllerProvider.notifier)
            .cancelOnboarding();
        if (context.mounted && context.canPop()) {
          context.pop();
        }
      },
    );

    return NicknameSaveScreen(
      title: '닉네임 설정',
      submitLabel: '다음',
      enableBackGesture: false,
      onBackPress: () => showLogoutDialog(),
      onError: showSaveError,
      onSaved: () {
        if (context.mounted) {
          context.push('/onboarding/${SCRoute.role.path}');
        }
      },
    );
  }
}
