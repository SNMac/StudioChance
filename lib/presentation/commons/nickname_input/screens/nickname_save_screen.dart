import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:studio_chance/presentation/commons/nickname_input/screens/nickname_form_screen.dart';
import 'package:studio_chance/presentation/onboarding/controllers/onboarding_nickname_controller.dart';

/// 닉네임을 저장하는 화면. 온보딩과 마이페이지가 공유한다.
///
/// 저장은 [OnboardingNicknameController]가 맡는다. 이 컨트롤러는 autoDispose라
/// 화면이 구독하지 않으면 저장 도중 dispose되어 state 갱신에서 예외가 나고, 저장 뒤
/// 처리(이동·사용자 정보 갱신)까지 가지 못한다. 그래서 구독·저장·실패 확인을 화면마다
/// 따로 두지 않고 여기 한 곳에 둔다.
class NicknameSaveScreen extends ConsumerWidget {
  const NicknameSaveScreen({
    super.key,
    required this.title,
    this.submitLabel = '완료',
    this.initialNickname,
    this.enableBackGesture = true,
    this.onBackPress,
    required this.onError,
    required this.onSaved,
  });

  final String title;
  final String submitLabel;
  final String? initialNickname;
  final bool enableBackGesture;
  final VoidCallback? onBackPress;

  /// 저장에 실패했을 때 사용자에게 알린다
  final void Function(Object error) onError;

  /// 저장에 성공한 뒤 실행한다 (화면 이동 등). 화면이 이미 닫혔을 수 있으므로
  /// context를 쓰기 전에 mounted를 확인한다
  final VoidCallback onSaved;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(onboardingNicknameControllerProvider, (_, next) {
      next.whenOrNull(error: (error, _) => onError(error));
    });

    return NicknameFormScreen(
      title: title,
      submitLabel: submitLabel,
      initialNickname: initialNickname,
      enableBackGesture: enableBackGesture,
      onBackPress: onBackPress,
      onComplete: (nickname) async {
        await ref
            .read(onboardingNicknameControllerProvider.notifier)
            .saveNicknameToRemote(nickname);

        if (ref.read(onboardingNicknameControllerProvider).hasError) return;
        onSaved();
      },
    );
  }
}
