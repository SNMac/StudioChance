import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/presentation/onboarding/sessions/onboarding_session.dart';

part 'onboarding_nickname_view_model.g.dart';

@riverpod
class OnboardingNicknameViewModel extends _$OnboardingNicknameViewModel {
  @override
  String build() {
    return ref.read(onboardingSessionProvider).nickname;
  }

  /// 입력값 변경 시 상태 업데이트
  void onNicknameChanged(String value) {
    state = value;
  }

  /// 유효성 검사 (Getter)
  bool get isValid {
    if (state.isEmpty) return false;
    if (state.length > 10) return false;

    // 정규식: 영문, 숫자, 한글(자음/모음 포함)만 허용
    final regExp = RegExp(r'^[a-zA-Z0-9가-힣ㄱ-ㅎㅏ-ㅣ]+$');
    return regExp.hasMatch(state);
  }

  /// 세션에 저장 (다음 단계로 넘어갈 때 호출)
  void saveToSession() {
    if (!isValid) return;
    ref.read(onboardingSessionProvider.notifier).setNickname(state);
  }
}
