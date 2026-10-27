import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studio_chance/data/repositories/server_clock_repository_impl.dart';
import 'package:studio_chance/domain/use_cases/server_clock_use_case.dart';

part 'server_clock_use_case_provider.g.dart';

@riverpod
ServerClockUseCase serverClockUseCase(Ref ref) {
  final repository = ref.watch(serverClockRepositoryProvider);
  return ServerClockUseCaseImpl(repository);
}
