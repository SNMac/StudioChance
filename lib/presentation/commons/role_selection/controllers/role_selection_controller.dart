import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/common/enums/user_role.dart';
import 'package:studio_chance/presentation/providers/app_auth_controller.dart' show currentUserProvider;

part 'role_selection_controller.g.dart';

@riverpod
class RoleSelectionController extends _$RoleSelectionController {
  @override
  UserRole build() => UserRole.none;

  void setRole(UserRole role) => state = role;

  /// '나중에 설정' 시 온보딩을 건너뛰고 홈으로 이동
  void skipOnboarding() {
    // currentUserProvider를 invalidate해야 Firestore에서 닉네임이 저장된 최신 유저를 가져옴.
    // appAuthControllerProvider는 currentUserProvider를 watch하므로 자동으로 함께 무효화됨.
    ref.invalidate(currentUserProvider);
  }
}
