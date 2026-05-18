import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/domain/entities/reservation.dart';
import 'package:studio_chance/domain/use_cases/reservation_use_case_provider.dart';
import 'package:studio_chance/presentation/providers/app_auth_controller.dart';
import 'package:studio_chance/presentation/providers/home_store_filter_controller.dart';

part 'home_reservations_provider.g.dart';

/// [storeId] 점포의 [month] 기간 예약을 실시간으로 구독한다.
///
/// Firestore 변경 시 자동으로 새 값이 방출됩니다.
@riverpod
Stream<List<Reservation>> storeReservationsStream(
  Ref ref,
  String storeId,
  DateTime month,
) {
  final useCase = ref.watch(reservationUseCaseProvider);
  final start = DateTime(month.year, month.month, 1);
  final end = DateTime(month.year, month.month + 1, 1);

  return useCase.watchReservationsByDateRange(
    storeId: storeId,
    start: start,
    end: end,
  );
}

/// 현재 사용자가 접근 가능한 점포 중 필터에서 선택된 점포의 [month] 기간 예약을 병합하여 반환한다.
///
/// - [HomeStoreFilterController]의 selectedIds로 점포 필터링
/// - 각 점포의 [storeReservationsStreamProvider]를 구독
/// - 어느 점포 스트림이 새 값을 방출하면 자동으로 재실행됩니다.
@riverpod
Future<List<Reservation>> homeReservations(Ref ref, DateTime month) async {
  final user = await ref.watch(currentUserProvider.future);
  if (user == null || user.storeInfos.isEmpty) return [];

  final selectedIds = ref.watch(homeStoreFilterControllerProvider);
  final storeIds = user.storeInfos
      .map((info) => info.id)
      .where((id) => selectedIds.contains(id))
      .toList();

  if (storeIds.isEmpty) return [];

  final results = await Future.wait(
    storeIds.map(
      (id) => ref.watch(storeReservationsStreamProvider(id, month).future),
    ),
  );

  return [for (final list in results) ...list];
}
