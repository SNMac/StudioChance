import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:studio_chance/domain/entities/price_setting.dart';
import 'package:studio_chance/domain/enums/store_color.dart';
import 'package:studio_chance/domain/enums/user_role.dart';

part 'onboarding_state.freezed.dart';

@freezed
abstract class OnboardingState with _$OnboardingState {
  const OnboardingState._();

  const factory OnboardingState({
    @Default('') String nickname,
    @Default(UserRole.none) UserRole selectedRole,

    // --- 점포 생성용 필드 (Store 객체 대신 낱개로 관리) ---
    @Default('') String storeName,
    @Default('') String storeAddress,
    @Default('') String storeMemo,
    StoreColor? selectedStoreColor,

    // 가격 설정 (기본값 필요 시 factory constructor에서 초기화 가능)
    PriceSetting? tempPriceSettings,

    // --- 점포 참가용 필드 ---
    String? invitedStoreId,
  }) = _OnboardingState;

  // ---------------------------------------------------------------------------
  // 유효성 검사 로직
  // ---------------------------------------------------------------------------

  bool get isNicknameValid {
    final text = nickname.trim();
    if (text.isEmpty || text.length > 10) return false;
    return RegExp(r'^[a-zA-Z0-9가-힣]+$').hasMatch(text);
  }

  bool get isRoleSelected => selectedRole != UserRole.none;

  /// 점포 생성 시 필수 정보가 다 채워졌는지 확인
  bool get isStoreInfoValid {
    if (storeName.trim().isEmpty) return false;
    if (storeAddress.trim().isEmpty) return false;
    if (selectedStoreColor == null) return false;
    if (tempPriceSettings == null) return false; // 가격 설정도 필수라면
    return true;
  }

  /// 최종 제출 가능 여부
  bool get canSubmitComplete {
    if (!isNicknameValid || !isRoleSelected) return false;

    if (selectedRole == UserRole.admin) {
      return isStoreInfoValid;
    } else {
      return invitedStoreId != null;
    }
  }
}
