import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/domain/use_cases/auth_use_case_provider.dart';

part 'sign_out_controller.g.dart';

/// 로그아웃 액션을 UseCase에 위임한다.
/// (CLAUDE.md "Presentation → Domain 접근 규칙")
@riverpod
class SignOutController extends _$SignOutController {
  final _logger = Logger();

  @override
  FutureOr<void> build() {}

  Future<void> signOut() async {
    try {
      await ref.read(authUseCaseProvider).signOut();
    } catch (e, stackTrace) {
      _logger.e('로그아웃 실패', error: e);
      state = AsyncError(e, stackTrace);
    }
  }
}
