import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studio_chance/data/repositories/reservation_ocr_repository_impl.dart';
import 'package:studio_chance/domain/use_cases/reservation_ocr_use_case.dart';

part 'reservation_ocr_use_case_provider.g.dart';

@riverpod
ReservationOcrUseCase reservationOcrUseCase(Ref ref) {
  return ReservationOcrUseCaseImpl(
    repository: ref.watch(reservationOcrRepositoryProvider),
  );
}
