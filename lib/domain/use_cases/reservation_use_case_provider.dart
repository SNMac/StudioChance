import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studio_chance/data/repositories/reservation_repository_impl.dart';
import 'package:studio_chance/data/repositories/store_repository_impl.dart';
import 'package:studio_chance/data/repositories/user_repository_impl.dart';
import 'package:studio_chance/domain/use_cases/reservation_use_case.dart';

part 'reservation_use_case_provider.g.dart';

@riverpod
ReservationUseCase reservationUseCase(Ref ref) {
  final reservationRepository = ref.watch(reservationRepositoryProvider);
  final userRepository = ref.watch(userRepositoryProvider);
  final storeRepository = ref.watch(storeRepositoryProvider);

  return ReservationUseCaseImpl(
    reservationRepository: reservationRepository,
    userRepository: userRepository,
    storeRepository: storeRepository,
  );
}
