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
import 'package:studio_chance/presentation/onboarding/controllers/onboarding_submit_controller.dart';
import 'package:studio_chance/presentation/onboarding/sessions/onboarding_session.dart';
import 'package:studio_chance/router/router_path.dart';

class OnboardingNicknameView extends ConsumerWidget {
  const OnboardingNicknameView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionNickname = ref.watch(onboardingSessionProvider).nickname;

    final formProvider = nicknameInputFormViewModelProvider(sessionNickname);
    final formViewModel = ref.read(formProvider.notifier);

    // 유효성 체크 (Strict Validation)
    final isValid = ref.watch(
      formProvider.select((value) {
        // ViewModel 내부에 isValid getter 로직을 복제하거나,
        // ViewModel 상태 자체가 String이므로 여기서 직접 검사해도 됨.
        // 하지만 로직 파편화를 막기 위해 ViewModel 인스턴스의 getter를 쓰는 게 좋지만
        // Riverpod 상태 구독 안에서는 notifier 접근이 애매할 수 있으므로
        // 여기서는 깔끔하게 ViewModel의 로직을 그대로 사용하도록 유도합니다.
        return ref.read(formProvider.notifier).isValid;
      }),
    );

    // *참고: 위의 isValid 방식이 복잡하다면, ViewModel 상태를 객체로 만들거나
    // 아래처럼 build 안에서 watch 후 notifier.isValid 호출이 일반적입니다.
    // 여기서는 가장 간단한 방식(watch 후 접근)으로 처리하겠습니다.
    ref.watch(formProvider); // 리빌드 트리거
    final isFormValid = formViewModel.isValid;

    void showExitDialog() {
      showCustomAlertDialog(
        context: context,
        title: '로그인 화면으로 돌아갈까요?',
        onConfirm: () {
          ref.read(onboardingSubmitControllerProvider.notifier).cancel();
          if (context.mounted && context.canPop()) {
            context.pop();
          }
        },
      );
    }

    void onNextPressed() {
      final inputNickname = ref.read(formProvider);
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
