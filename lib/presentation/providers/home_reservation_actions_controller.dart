import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/domain/entities/reservation.dart';
import 'package:studio_chance/domain/entities/space_option.dart';
import 'package:studio_chance/domain/use_cases/reservation_use_case_provider.dart';
import 'package:studio_chance/domain/use_cases/store_use_case_provider.dart';

part 'home_reservation_actions_controller.g.dart';

@riverpod
class HomeReservationActionsController
    extends _$HomeReservationActionsController {
  final _logger = Logger();

  @override
  FutureOr<void> build() {}

  Future<void> updateReservation(Reservation reservation) async {
    final result = await ref
        .read(reservationUseCaseProvider)
        .updateReservation(reservation: reservation);
    final stackTrace = StackTrace.current;
    result.fold(
      (e) {
        _logger.e('예약 수정 실패', error: e);
        state = AsyncError(e, stackTrace);
      },
      (_) {},
    );
  }

  Future<void> createReservation(Reservation reservation) async {
    final result = await ref
        .read(reservationUseCaseProvider)
        .createReservation(reservation: reservation);
    final stackTrace = StackTrace.current;
    result.fold(
      (e) {
        _logger.e('예약 생성 실패', error: e);
        state = AsyncError(e, stackTrace);
      },
      (_) {},
    );
  }

  /// 점포의 공간 옵션 목록 조회 (요금 자동 계산용).
  Future<List<SpaceOption>?> getStoreSpaceOptions(String storeId) async {
    final result = await ref.read(storeUseCaseProvider).getStore(storeId);
    return result.fold(
      (e) {
        _logger.e('점포 공간 옵션 조회 실패', error: e);
        return null;
      },
      (store) => store?.spaceOptions,
    );
  }

  Future<void> deleteReservation(Reservation reservation) async {
    final result = await ref
        .read(reservationUseCaseProvider)
        .deleteReservation(
          storeId: reservation.storeSummary.id,
          reservationId: reservation.id,
        );
    final stackTrace = StackTrace.current;
    result.fold(
      (e) {
        _logger.e('예약 삭제 실패', error: e);
        state = AsyncError(e, stackTrace);
      },
      (_) {},
    );
  }

  /// 동일 고객(예약자명 + 연락처)의 해당 점포 예약 수 조회.
  ///
  /// 실패 시 1 반환 (최소 1번째 예약으로 표시).
  Future<int> getReservationCountByCustomer({
    required String storeId,
    required String customerName,
    required String customerPhone,
  }) async {
    final result = await ref
        .read(reservationUseCaseProvider)
        .getReservationCountByCustomer(
          storeId: storeId,
          customerName: customerName,
          customerPhone: customerPhone,
        );
    return result.fold(
      (e) {
        _logger.e('고객 예약 수 조회 실패', error: e);
        return 1;
      },
      (count) => count,
    );
  }
}
