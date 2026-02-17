import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/domain/enums/user_role.dart';
import 'package:studio_chance/presentation/providers/app_auth_controller.dart';

part 'role_selection_controller.g.dart';

@riverpod
class RoleSelectionController extends _$RoleSelectionController {
  @override
  UserRole build() => UserRole.none;

  void setRole(UserRole role) => state = role;

  /// '나중에 설정' 시 온보딩을 건너뛰고 홈으로 이동
  void skipOnboarding() {
    ref.invalidate(appAuthControllerProvider);
  }
}
