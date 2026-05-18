import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studio_chance/data/repositories/auth_repository_impl.dart';
import 'package:studio_chance/data/repositories/user_repository_impl.dart';
import 'package:studio_chance/domain/use_cases/auth_use_case.dart';

part 'auth_use_case_provider.g.dart';

@riverpod
AuthUseCase authUseCase(Ref ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final userRepository = ref.watch(userRepositoryProvider);

  return AuthUseCaseImpl(
    authRepository: authRepository,
    userRepository: userRepository,
  );
}
