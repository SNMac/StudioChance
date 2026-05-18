import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studio_chance/data/repositories/store_repository_impl.dart';
import 'package:studio_chance/data/repositories/user_repository_impl.dart';
import 'package:studio_chance/domain/use_cases/store_use_case.dart';

part 'store_use_case_provider.g.dart';

@riverpod
StoreUseCase storeUseCase(Ref ref) {
  final storeRepository = ref.watch(storeRepositoryProvider);
  final userRepository = ref.watch(userRepositoryProvider);

  return StoreUseCaseImpl(
    storeRepository: storeRepository,
    userRepository: userRepository,
  );
}
