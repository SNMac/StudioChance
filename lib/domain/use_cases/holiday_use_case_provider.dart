import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studio_chance/data/repositories/holiday_repository_impl.dart';
import 'package:studio_chance/domain/use_cases/holiday_use_case.dart';

part 'holiday_use_case_provider.g.dart';

@riverpod
HolidayUseCase holidayUseCase(Ref ref) {
  final repository = ref.watch(holidayRepositoryProvider);
  return HolidayUseCaseImpl(repository);
}
