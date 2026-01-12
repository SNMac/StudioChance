import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:studio_chance/domain/entities/store.dart';
import 'package:studio_chance/domain/enums/store_color.dart';
import 'package:studio_chance/domain/enums/user_role.dart';

part 'onboarding_state.freezed.dart';

@freezed
abstract class OnboardingState with _$OnboardingState {
  const OnboardingState._();

  const factory OnboardingState({
    @Default('') String nickname,
    @Default(UserRole.none) UserRole selectedRole,

    /// 점포를 신규 생성하는 중인지 여부
    /// - 관리자 역할 선택인 경우 한정
    @Default(false) bool isCreatingStore,

    /// 점포 생성 시 입력받을 점포 정보
    Store? storeToMake,

    /// 점포 생성 시 선택한 점포 색상
    StoreColor? selectedStoreColor,

    /// Staff/Viewer일 때 입력받을 초대된 점포 ID
    String? invitedStoreId,
  }) = _OnboardingState;

  // ---------------------------------------------------------------------------
  // 유효성 검사 로직
  // ---------------------------------------------------------------------------

  bool get isNicknameValid {
    final text = nickname.trim();

    // 1. 빈 값 체크
    if (text.isEmpty) return false;
    // 2. 길이 체크 (10자 이내)
    if (text.length > 10) return false;
    // 3. 정규식 체크
    final regex = RegExp(r'^[a-zA-Z0-9가-힣]+$');

    return regex.hasMatch(text);
  }

  bool get isRoleSelected => selectedRole != UserRole.none;

  /// 최종 제출 가능 여부 (SubmitController에서 사용)
  bool get canSubmit {
    if (!isNicknameValid || !isRoleSelected) return false;

    if (isCreatingStore) {
      return storeToMake != null && selectedStoreColor != null;
    } else {
      return invitedStoreId != null;
    }
  }
}
