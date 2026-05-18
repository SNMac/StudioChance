import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/domain/entities/price_setting.dart';
import 'package:studio_chance/domain/entities/reservation.dart';
import 'package:studio_chance/domain/use_cases/reservation_use_case_provider.dart';
import 'package:studio_chance/domain/use_cases/store_use_case_provider.dart';

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

  /// 점포의 PriceSetting 조회 (요금 자동 계산용).
  Future<PriceSetting?> getStorePriceSetting(String storeId) async {
    final result = await ref.read(storeUseCaseProvider).getStore(storeId);
    return result.fold(
      (e) {
        _logger.e('점포 가격 설정 조회 실패', error: e);
        return null;
      },
      (store) => store?.priceSettings,
    );
  }

  Future<bool> deleteReservation(Reservation reservation) async {
    final result = await ref
        .read(reservationUseCaseProvider)
        .deleteReservation(
          storeId: reservation.storeSummary.id,
          reservationId: reservation.id,
        );
    return result.fold(
      (e) {
        _logger.e('예약 삭제 실패', error: e);
        return false;
      },
      (_) => true,
    );
  }
}
