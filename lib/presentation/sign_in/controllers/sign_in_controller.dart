import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/common/exceptions/auth_exceptions.dart';
import 'package:studio_chance/domain/entities/user.dart';
import 'package:studio_chance/domain/use_cases/auth_use_case.dart';

part 'sign_in_controller.g.dart';

@riverpod
class SignInController extends _$SignInController {
  @override
  AsyncValue<User?> build() {
    return const AsyncData(null);
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();

    final useCase = ref.read(authUseCaseProvider);
    final result = await useCase.signInWithGoogle();

    _handleAuthResult(result);
  }

  Future<void> signInWithApple() async {
    state = const AsyncLoading();

    final useCase = ref.read(authUseCaseProvider);
    final result = await useCase.signInWithApple();

    _handleAuthResult(result);
  }

  void _handleAuthResult(Either<Exception, User> result) {
    result.fold(
      (exception) {
        if (exception is AuthException && exception.isSilentable) {
          state = const AsyncData(null);
        } else {
          state = AsyncError(exception, StackTrace.current);
        }
      },
      (user) {
        state = AsyncData(user);
      },
    );
  }
}
