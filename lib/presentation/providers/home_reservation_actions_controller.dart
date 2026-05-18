import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/domain/entities/reservation.dart';
import 'package:studio_chance/domain/use_cases/reservation_use_case_provider.dart';

part 'home_reservation_actions_controller.g.dart';

@riverpod
class HomeReservationActionsController
    extends _$HomeReservationActionsController {
  final _logger = Logger();

  @override
  void build() {}

  Future<void> updateReservation(Reservation reservation) async {
    final result = await ref
        .read(reservationUseCaseProvider)
        .updateReservation(reservation: reservation);
    result.fold(
      (e) => _logger.e('예약 수정 실패', error: e),
      (_) {},
    );
  }

  Future<bool> createReservation(Reservation reservation) async {
    final result = await ref
        .read(reservationUseCaseProvider)
        .createReservation(reservation: reservation);
    return result.fold(
      (e) {
        _logger.e('예약 생성 실패', error: e);
        return false;
      },
      (_) => true,
    );
  }
}
