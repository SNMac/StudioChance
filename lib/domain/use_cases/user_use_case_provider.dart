import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studio_chance/data/repositories/user_repository_impl.dart';
import 'package:studio_chance/domain/use_cases/user_use_case.dart';

part 'user_use_case_provider.g.dart';

@riverpod
UserUseCase userUseCase(Ref ref) {
  final repository = ref.watch(userRepositoryProvider);
  return UserUseCaseImpl(repository);
}
