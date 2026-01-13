import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:studio_chance/domain/enums/user_role.dart';

part 'onboarding_session_state.freezed.dart';

@freezed
abstract class OnboardingSessionState with _$OnboardingSessionState {
  const OnboardingSessionState._();

  const factory OnboardingSessionState({
    @Default('') String nickname,
    @Default(UserRole.none) UserRole selectedRole,
    @Default(AsyncValue.data(null)) AsyncValue<void> status,
  }) = _OnboardingSessionState;

  // ---------------------------------------------------------------------------
  // 상태 확인 로직
  // ---------------------------------------------------------------------------

  /// 닉네임 입력 여부 확인
  bool get isNicknameExists => nickname.trim().isNotEmpty;

  /// 역할 선택 여부 확인
  bool get isRoleSelected => selectedRole != UserRole.none;
}
