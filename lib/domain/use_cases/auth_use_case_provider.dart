import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studio_chance/data/repositories/auth_repository_impl.dart';
import 'package:studio_chance/data/repositories/user_repository_impl.dart';
import 'package:studio_chance/domain/use_cases/auth_use_case.dart';
import 'package:studio_chance/domain/use_cases/store_use_case_provider.dart';

part 'auth_use_case_provider.g.dart';

@riverpod
AuthUseCase authUseCase(Ref ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final userRepository = ref.watch(userRepositoryProvider);
  final storeUseCase = ref.watch(storeUseCaseProvider);

  return AuthUseCaseImpl(
    authRepository: authRepository,
    userRepository: userRepository,
    storeUseCase: storeUseCase,
  );
}
