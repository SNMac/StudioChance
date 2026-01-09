import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:studio_chance/presentation/components/app_bar_action_button.dart';

import 'package:studio_chance/presentation/components/body_text_field.dart';
import 'package:studio_chance/presentation/components/app_bar_back_button.dart';
import 'package:studio_chance/presentation/components/custom_alert_dialog.dart';
import 'package:studio_chance/presentation/components/grouped_form_container.dart';
import 'package:studio_chance/presentation/components/safe_area_with_padding.dart';
import 'package:studio_chance/presentation/onboarding/viewmodels/onboarding_viewmodel.dart';
import 'package:studio_chance/router/router_path.dart';

class OnboardingNicknameView extends ConsumerStatefulWidget {
  const OnboardingNicknameView({super.key});

  @override
  ConsumerState<OnboardingNicknameView> createState() =>
      _OnboardingNicknameViewState();
}

class _OnboardingNicknameViewState
    extends ConsumerState<OnboardingNicknameView> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final currentNickname =
        ref.read(onboardingViewModelProvider).value?.nickname ?? '';
    _controller = TextEditingController(text: currentNickname);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(onboardingViewModelProvider);
    final state = asyncState.value;

    final isValid = state?.isNicknameValid ?? false;

    void showExitDialog() {
      showCustomAlertDialog(
        context: context,
        title: '로그인 화면으로 돌아갈까요?',
        onConfirm: () {
          if (context.mounted && context.canPop()) {
            context.pop();
          }
          ref.read(onboardingViewModelProvider.notifier).cancelOnboarding();
        },
      );
    }

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text('닉네임 설정'),
          leading: AppBarBackButton(onPressed: showExitDialog),
          actions: [
            AppBarActionButton(
              label: '다음',
              onPressed: isValid
                  ? () {
                      context.push(SCRoute.onboardingRole.fullPath);
                    }
                  : null,
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

              GroupedFormContainer(
                children: [
                  BodyTextField(
                    controller: _controller,
                    autofocus: true,
                    onChanged: (value) {
                      ref
                          .read(onboardingViewModelProvider.notifier)
                          .setNickname(value);
                    },
                    hintText: '닉네임',
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(10),
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[a-zA-Z0-9가-힣ㄱ-ㅎㅏ-ㅣ]'),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 4),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '10자 이내 한글·영문·숫자 사용가능\n띄어쓰기, 특수문자 사용 불가',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
