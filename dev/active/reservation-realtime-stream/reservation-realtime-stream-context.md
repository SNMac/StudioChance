# 예약 실시간 스트림 전환 — 컨텍스트

Last Updated: 2026-05-19 (구현 완료)

## 수정 대상 파일

| 파일 | 변경 내용 | 레이어 |
|------|----------|--------|
| `lib/data/data_sources/reservation_data_source.dart` | `watchReservationsByDateRange` 메서드 추가 (Stream 반환) | Data |
| `lib/domain/repository_interfaces/reservation_repository.dart` | `watchReservationsByDateRange` 메서드 추가 (interface) | Domain |
| `lib/data/repositories/reservation_repository_impl.dart` | `watchReservationsByDateRange` 구현 (asyncMap 변환) | Data |
| `lib/domain/use_cases/reservation_use_case.dart` | `watchReservationsByDateRange` 추가 (interface + impl) | Domain |
| `lib/presentation/providers/home_reservations_provider.dart` | `storeReservationsStreamProvider` 추가, `homeReservationsProvider` 재구성 | Presentation |
| `lib/presentation/providers/home_reservation_actions_controller.dart` | `ref.invalidate(homeReservationsProvider)` 제거 | Presentation |

## 참조 파일 (읽기 전용)

| 파일 | 참조 이유 |
|------|----------|
| `lib/data/data_sources/auth_data_source.dart` | 기존 Stream 사용 패턴 참조 (`authStateChanges`) |
| `lib/domain/use_cases/use_case_helpers.dart` | `getCurrentUserOrThrow` 헬퍼 시그니처 확인 |
| `lib/presentation/home/widgets/three_day_calendar/time_grid.dart` | `homeReservationsProvider` 소비 위젯 — 변경 불필요 확인용 |
| `lib/presentation/home/widgets/monthly_calendar/monthly_calendar_grid.dart` | 동일 |

## 아키텍처 결정

### Stream + Either 혼용 안 함
Repository 이상 계층에서 `Stream<Either<Exception, T>>` 패턴은 사용하지 않는다.  
에러는 스트림 에러로 전파하고 Riverpod의 `AsyncError`로 소비한다.  
**근거**: Stream에서 Either를 래핑하면 `handleError`, `onError` 처리가 이중화되어 복잡도가 높아진다.

### UseCase의 currentUser 처리
`getCurrentUserOrThrow`는 `TaskEither`를 반환하므로 `Stream.fromFuture + asyncExpand + fold` 패턴으로 연결:

```dart
Stream.fromFuture(getCurrentUserOrThrow(_userRepository).run())
  .asyncExpand((result) => result.fold(
    (error) => Stream.error(error),
    (user) => _repo.watchReservationsByDateRange(...),
  ));
```

### 복수 점포 결합 전략 (rxdart 없이)
Riverpod family + `.future` watch 패턴:
- `storeReservationsStreamProvider(storeId, month)` → 점포별 StreamProvider
- `homeReservationsProvider(month)` → `Future.wait([...각 점포 스트림.future])` 병합

어느 점포 스트림이 방출되면 Riverpod이 `homeReservationsProvider`를 자동 재실행.

### asyncMap writer 조회 성능
스냅샷마다 writer Firestore 조회 발생. Firestore SDK 로컬 캐시(`source: Source.cache` 기본 동작)로 대부분 처리됨. 현재 규모에서 허용 가능.

## 의존성

- `cloud_firestore`: `.snapshots()` — 이미 사용 중
- `rxdart`: **불필요** — Riverpod family로 대체
- `package:async`: **불필요** — Dart 네이티브 `asyncExpand`로 처리

## 구현 완료 상태 (2026-05-19)

모든 코드 변경 완료. `dart analyze` — No issues found.

### 실제 구현된 코드 패턴

**DataSource** (`.snapshots()` + `.handleError`):
```dart
Stream<List<ReservationModel>> watchReservationsByDateRange(...) {
  return _reservationsRef(storeId)
    .where(...).orderBy('startTime').snapshots()
    .map((snap) => snap.docs.map((doc) { ...; return ReservationModel.fromJson(data); }).toList())
    .handleError((Object e) => throw handleFirestoreError(e));
}
```

**Repository** (`.asyncMap` + writer enrichment):
```dart
Stream<List<Reservation>> watchReservationsByDateRange({...}) {
  return _reservationDataSource.watchReservationsByDateRange(...)
    .asyncMap((models) async { /* currentUserModel + writerById 구성 + toEntity */ });
}
```

**UseCase** (`Stream.fromFuture + asyncExpand + fold`):
```dart
Stream<List<Reservation>> watchReservationsByDateRange({...}) {
  return Stream.fromFuture(getCurrentUserOrThrow(_userRepository).run())
    .asyncExpand((result) => result.fold(
      (error) => Stream.error(error),
      (user) => _reservationRepository.watchReservationsByDateRange(currentUid: user.id, ...),
    ));
}
```

**Provider** (family StreamProvider + `.future` watch 조합):
```dart
@riverpod
Stream<List<Reservation>> storeReservationsStream(Ref ref, String storeId, DateTime month) { ... }

@riverpod
Future<List<Reservation>> homeReservations(Ref ref, DateTime month) async {
  // 각 점포 스트림의 .future를 ref.watch → 스트림 방출 시 자동 재실행
  final results = await Future.wait(
    storeIds.map((id) => ref.watch(storeReservationsStreamProvider(id, month).future)),
  );
  return [for (final list in results) ...list];
}
```

### 추가 변경 사항 (동 세션)

- `reservation_create_modal.dart`: `ModalGrabber`를 `Opacity(opacity: 0.0)`로 래핑하여 여백은 유지하되 pill 비표시 (수정 모달 편집 모드와 동일한 패턴)

## 남은 검증 항목

- [ ] 앱 실행 후 예약 생성 → 캘린더 자동 반영 확인 (실기기)
- [ ] Firebase 콘솔/다른 기기에서 예약 변경 → 캘린더 반영 확인
- [ ] `AsyncError` 케이스 UI 처리 확인
