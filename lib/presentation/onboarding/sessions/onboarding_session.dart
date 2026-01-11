import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/domain/entities/store.dart';
import 'package:studio_chance/domain/enums/user_role.dart';
import 'package:studio_chance/presentation/onboarding/view_models/onboarding_state.dart';

part 'onboarding_session.g.dart';

@riverpod
class OnboardingSession extends _$OnboardingSession {
  @override
  OnboardingState build() {
    return const OnboardingState();
  }

  void setNickname(String nickname) {
    state = state.copyWith(nickname: nickname);
  }

  void setRole(UserRole role) {
    state = state.copyWith(selectedRole: role);
  }

  void setStoreToMake(Store store) {
    state = state.copyWith(storeToMake: store);
  }

  void setInvitedStoreId(String storeId) {
    state = state.copyWith(invitedStoreId: storeId);
  }
}
