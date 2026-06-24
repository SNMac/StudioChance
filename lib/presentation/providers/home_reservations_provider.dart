import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/common/exceptions/reservation_exceptions.dart';
import 'package:studio_chance/domain/entities/reservation.dart';
import 'package:studio_chance/domain/use_cases/reservation_use_case.dart';
import 'package:studio_chance/domain/use_cases/reservation_use_case_provider.dart';
import 'package:studio_chance/presentation/providers/app_auth_controller.dart';
import 'package:studio_chance/presentation/providers/home_store_filter_controller.dart';

part 'home_reservations_provider.g.dart';

/// 현재 사용자가 접근 가능한 점포 중 필터에서 선택된 점포의 [month] 기간 예약을
/// 실시간으로 병합하여 스트림으로 반환한다.
///
/// - 각 점포의 Firestore 변경을 직접 구독 → fetch 없이 즉시 반영
/// - [ReservationNetworkException] 발생 시 5초 후 재연결 시도
/// - 그 외 에러(권한 거부 등)는 해당 점포를 빈 목록으로 처리하고 재연결 없이 종료
/// - 필터/사용자 변경 시 provider 재실행으로 새 구독 세트 생성
@riverpod
Stream<List<Reservation>> homeReservations(Ref ref, DateTime month) async* {
  final user = await ref.watch(currentUserProvider.future);

  if (user == null || user.storeInfos.isEmpty) {
    yield [];
    return;
  }

  final selectedIds = ref.watch(homeStoreFilterControllerProvider);
  final storeIds = user.storeInfos
      .map((info) => info.id)
      .where((id) => selectedIds.contains(id))
      .toList();

  if (storeIds.isEmpty) {
    yield [];
    return;
  }

  final useCase = ref.read(reservationUseCaseProvider);
  final start = DateTime(month.year, month.month, 1);
  final end = DateTime(month.year, month.month + 1, 1);

  yield* _buildMergedStream(
    ref: ref,
    storeIds: storeIds,
    useCase: useCase,
    start: start,
    end: end,
  );
}

/// 여러 점포의 예약 스트림을 단일 스트림으로 병합한다.
///
/// - 모든 점포가 최소 1회 응답한 후 첫 방출
/// - 이후 어느 점포든 변경 시 즉시 방출
/// - [ReservationNetworkException] 발생 시 5초 후 재연결
Stream<List<Reservation>> _buildMergedStream({
  required Ref ref,
  required List<String> storeIds,
  required ReservationUseCase useCase,
  required DateTime start,
  required DateTime end,
}) {
  // 점포별 최신 예약 목록 (초기값 빈 목록)
  final latestByStore = <String, List<Reservation>>{
    for (final id in storeIds) id: [],
  };
  // 첫 방출은 모든 점포가 최소 1회 응답한 후에만 수행
  final respondedStores = <String>{};
  final controller = StreamController<List<Reservation>>();
  // 점포별 구독 Map — 에러 후 재연결 시 새 구독으로 교체
  final subscriptionByStore = <String, StreamSubscription<List<Reservation>>>{};

  void emitIfReady() {
    if (respondedStores.length == storeIds.length && !controller.isClosed) {
      controller.add([
        for (final list in latestByStore.values) ...list,
      ]);
    }
  }

  void connectStore(String id) {
    subscriptionByStore[id] = useCase
        .watchReservationsByDateRange(storeId: id, start: start, end: end)
        .listen(
          (reservations) {
            latestByStore[id] = reservations;
            respondedStores.add(id);
            emitIfReady();
          },
          onError: (Object e) {
            // 첫 에러 시 현재 데이터(빈 목록)로 응답 처리 → 나머지 점포 결과는 방출
            respondedStores.add(id);
            emitIfReady();
            // Firestore snapshots() 스트림은 에러 후 종료됨
            // 네트워크 에러만 재연결, 그 외(권한 거부·파싱 오류 등)는 재연결 없이 종료
            if (e is ReservationNetworkException && !controller.isClosed) {
              Future.delayed(const Duration(seconds: 5), () {
                if (!controller.isClosed) connectStore(id);
              });
            }
          },
        );
  }

  for (final id in storeIds) {
    connectStore(id);
  }

  ref.onDispose(() {
    for (final sub in subscriptionByStore.values) {
      sub.cancel();
    }
    controller.close();
  });

  return controller.stream;
}
