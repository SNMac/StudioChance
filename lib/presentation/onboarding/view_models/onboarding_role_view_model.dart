import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/domain/enums/user_role.dart';
import 'package:studio_chance/presentation/onboarding/sessions/onboarding_session.dart';

part 'onboarding_role_view_model.g.dart';

@riverpod
class OnboardingRoleViewModel extends _$OnboardingRoleViewModel {
  @override
  UserRole build() {
    return ref.watch(onboardingSessionProvider.select((s) => s.selectedRole));
  }

  void selectRole(UserRole role) {
    ref.read(onboardingSessionProvider.notifier).setRole(role);
  }

  Future<void> saveAndNext() async {
    await ref.read(onboardingSessionProvider.notifier).saveNicknameToRemote();
  }

  Future<void> saveAndSkip() async {
    await ref.read(onboardingSessionProvider.notifier).submitNicknameOnly();
  }

  bool get isRoleSelected => state != UserRole.none;
}
