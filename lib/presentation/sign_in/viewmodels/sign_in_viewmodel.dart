import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/common/exceptions/auth_exceptions.dart';
import 'package:studio_chance/common/exceptions/extensions/auth_exception_extension.dart';
import 'package:studio_chance/domain/entities/user.dart';
import 'package:studio_chance/domain/usecases/auth_use_case.dart';

part 'sign_in_viewmodel.g.dart';

@riverpod
class SignInViewModel extends _$SignInViewModel {
  @override
  AsyncValue<User?> build() {
    return const AsyncValue.data(null);
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();

    final useCase = ref.read(authUseCaseProvider);
    final result = await useCase.signInWithGoogle();

    _handleAuthResult(result);
  }

  Future<void> signInWithApple() async {
    state = const AsyncValue.loading();

    final useCase = ref.read(authUseCaseProvider);
    final result = await useCase.signInWithApple();

    _handleAuthResult(result);
  }

  void _handleAuthResult(dynamic result) {
    result.fold(
      (exception) {
        if (exception is AuthException && exception.isSilent) {
          state = const AsyncValue.data(null);
        } else {
          state = AsyncValue.error(exception, StackTrace.current);
        }
      },
      (user) {
        state = AsyncValue.data(user);
      },
    );
  }
}
