import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studio_chance/domain/enums/user_role.dart';
import 'package:studio_chance/presentation/onboarding/sessions/onboarding_session.dart';

part 'onboarding_role_view_model.g.dart';

@riverpod
class OnboardingRoleViewModel extends _$OnboardingRoleViewModel {
  @override
  UserRole build() {
    return ref.read(onboardingSessionProvider).selectedRole;
  }

  /// 역할 선택 (버튼 클릭 시)
  void selectRole(UserRole role) {
    state = role;
  }

  /// 역할 선택 여부 확인 (Getter)
  bool get isRoleSelected => state != UserRole.none;

  /// 세션에 저장 (다음 단계로 넘어갈 때 호출)
  void saveToSession() {
    if (!isRoleSelected) return;
    ref.read(onboardingSessionProvider.notifier).setRole(state);
  }
}