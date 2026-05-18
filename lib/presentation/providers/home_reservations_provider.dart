import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/domain/entities/reservation.dart';
import 'package:studio_chance/domain/use_cases/reservation_use_case.dart';
import 'package:studio_chance/presentation/providers/app_auth_controller.dart';

part 'home_reservations_provider.g.dart';

/// 현재 사용자가 접근 가능한 모든 점포의 [month] 기간 예약을 병합하여 반환한다.
///
/// - 조회 범위: [month]의 1일 00:00 ~ 다음달 1일 00:00
/// - 복수 점포 병렬 조회 후 결과 병합
/// - 일부 점포 조회 실패 시 실패 점포는 빈 목록으로 처리 (부분 성공 허용)
@riverpod
Future<List<Reservation>> homeReservations(Ref ref, DateTime month) async {
  final user = await ref.watch(currentUserProvider.future);
  if (user == null || user.storeInfos.isEmpty) return [];

  final start = DateTime(month.year, month.month, 1);
  final end = DateTime(month.year, month.month + 1, 1);

  final useCase = ref.watch(reservationUseCaseProvider);

  final storeIds = user.storeInfos.map((info) => info.id).toList();
  final futures = storeIds
      .map((id) => useCase.getReservationsByDateRange(
            storeId: id,
            start: start,
            end: end,
          ))
      .toList();

  final results = await Future.wait(futures);

  return [
    for (final result in results)
      ...result.fold((_) => <Reservation>[], (r) => r),
  ];
}
