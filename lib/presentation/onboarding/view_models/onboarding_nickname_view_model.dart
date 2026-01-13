import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studio_chance/presentation/onboarding/sessions/onboarding_session.dart';

part 'onboarding_nickname_view_model.g.dart';

@riverpod
class OnboardingNicknameViewModel extends _$OnboardingNicknameViewModel {
  @override
  String build() {
    return ref.read(onboardingSessionProvider).nickname;
  }

  void onNicknameChanged(String value) {
    state = value;
  }

  bool get isValid {
    if (state.isEmpty) return false;
    if (state.length > 10) return false;

    final regExp = RegExp(r'^[a-zA-Z0-9가-힣ㄱ-ㅎㅏ-ㅣ]+$');
    return regExp.hasMatch(state);
  }

  void saveToSession() {
    if (!isValid) return;
    ref.read(onboardingSessionProvider.notifier).setNickname(state);
  }

  /// 온보딩 취소 (로그아웃)
  Future<void> cancelOnboarding() async {
    await ref.read(onboardingSessionProvider.notifier).cancelOnboarding();
  }
}
