# 예약 실시간 스트림 전환 계획

Last Updated: 2026-05-19

## Executive Summary

현재 캘린더 예약 데이터는 `Future` 기반 일회성 조회 방식이다. 앱 내부 액션(생성/수정/삭제) 후 `ref.invalidate()`로만 갱신되며, **외부 기기나 다른 관리자가 예약을 변경해도 캘린더에 자동 반영되지 않는다.**

Firestore `.snapshots()` 스트림을 DataSource → Repository → UseCase → Provider 계층 순으로 추가하여, 예약 컬렉션 변경 시 캘린더가 실시간으로 갱신되도록 전환한다.

---

## 현재 상태 분석

### 데이터 흐름 (현재)

```
Firestore.get() ──→ ReservationFirestoreDataSource
  Future<List<Model>>  ──→ ReservationRepositoryImpl
    Future<Either<E, List<Entity>>> ──→ ReservationUseCaseImpl
      Future<Either<E, List<Entity>>> ──→ homeReservationsProvider
        Future<List<Reservation>>  ──→ Calendar Widget
```

### 핵심 문제

| 파일 | 현재 반환 타입 | 문제 |
|------|--------------|------|
| `reservation_data_source.dart` | `Future<List<ReservationModel>>` | `.get()` 일회성 조회 |
| `reservation_repository.dart` (interface) | `Future<Either<Exception, List<Reservation>>>` | 스트림 메서드 없음 |
| `reservation_repository_impl.dart` | `Future<Either<Exception, List<Reservation>>>` | asyncMap 변환 없음 |
| `reservation_use_case.dart` | `Future<Either<Exception, List<Reservation>>>` | 스트림 메서드 없음 |
| `home_reservations_provider.dart` | `Future<List<Reservation>>` | 단발 조회, 스트림 미구독 |

### 현재 갱신 방식

`HomeReservationActionsController`에서 예약 생성/수정 후 `ref.invalidate(homeReservationsProvider)` 호출로만 갱신됨.  
→ 앱 내부 액션은 반영되지만, **외부 변경은 감지 불가.**

---

## 목표 상태

### 데이터 흐름 (변경 후)

```
Firestore.snapshots() ──→ ReservationFirestoreDataSource
  Stream<List<Model>>  ──→ ReservationRepositoryImpl (.asyncMap으로 엔티티 변환)
    Stream<List<Entity>> ──→ ReservationUseCaseImpl
      Stream<List<Entity>> ──→ storeReservationsStreamProvider (family)
        AsyncValue<List<Reservation>> ──→ homeReservationsProvider (.future 구독)
          Future<List<Reservation>> ──→ Calendar Widget (자동 갱신)
```

### 아키텍처 결정 사항

**1. Repository 스트림 에러 처리**  
Stream에서 `Either` 래핑은 불자연스럽다. Repository는 `Stream<List<Reservation>>`을 반환하고, 에러는 스트림 에러로 전파한다. Provider의 `AsyncError`가 처리한다.

**2. UseCase에서 currentUser 조회**  
`getCurrentUserOrThrow()`는 `TaskEither`를 반환한다. Stream과 결합 시:

```dart
Stream.fromFuture(getCurrentUserOrThrow(_userRepository).run())
  .asyncExpand((result) => result.fold(
    (error) => Stream.error(error),
    (user) => _reservationRepository.watchReservationsByDateRange(
      storeId: storeId,
      currentUid: user.id,
      start: start,
      end: end,
    ),
  ));
```

**3. 복수 점포 스트림 결합**  
rxdart 없이 Riverpod family 패턴으로 해결:

- `storeReservationsStreamProvider(storeId, month)` — 점포별 StreamProvider (family)
- `homeReservationsProvider(month)` — 각 점포 스트림의 `.future`를 `ref.watch`하여 `Future.wait`로 병합

어떤 점포 스트림이 새 값을 방출하면 Riverpod이 자동으로 `homeReservationsProvider`를 재실행한다.

**4. `ref.invalidate` 제거**  
스트림이 Firestore 변경을 자동 감지하므로, `HomeReservationActionsController`의 `ref.invalidate(homeReservationsProvider)` 호출은 불필요해진다. 삭제하여 코드를 단순화한다.

---

## 구현 단계

### Phase 1 — DataSource (M)

`ReservationDataSource` 인터페이스와 `ReservationFirestoreDataSource` 구현체에 스트림 메서드 추가.

```dart
// 인터페이스 추가
Stream<List<ReservationModel>> watchReservationsByDateRange(
  String storeId,
  DateTime start,
  DateTime end,
);

// 구현체 — 기존 getReservationsByDateRange의 쿼리를 .snapshots()로 변경
Stream<List<ReservationModel>> watchReservationsByDateRange(...) {
  return _reservationsRef(storeId)
    .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
    .where('startTime', isLessThan: Timestamp.fromDate(end))
    .orderBy('startTime')
    .snapshots()
    .map((snapshot) => snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return ReservationModel.fromJson(data);
    }).toList());
}
```

**주의**: 에러 처리는 기존 `handleFirestoreError`를 stream의 `.handleError`로 적용.

### Phase 2 — Repository (M)

인터페이스와 구현체에 스트림 메서드 추가.

```dart
// reservation_repository.dart (interface)
Stream<List<Reservation>> watchReservationsByDateRange({
  required String storeId,
  required String currentUid,
  required DateTime start,
  required DateTime end,
});

// reservation_repository_impl.dart
Stream<List<Reservation>> watchReservationsByDateRange({...}) {
  return _reservationDataSource
    .watchReservationsByDateRange(storeId, start, end)
    .asyncMap((models) async {
      if (models.isEmpty) return <Reservation>[];
      final currentUserModel = await _userDataSource.getUser(currentUid);
      final storeSummary = _buildStoreSummary(
        storeId: storeId,
        currentUserModel: currentUserModel,
      );
      final writerIds = models.map((m) => m.writerId).toSet().toList();
      final writerModels = await Future.wait(
        writerIds.map((uid) => _userDataSource.getUser(uid)),
      );
      final writerById = {
        for (var i = 0; i < writerIds.length; i++)
          if (writerModels[i] != null) writerIds[i]: writerModels[i]!,
      };
      return models.map((model) {
        final writerModel = writerById[model.writerId];
        if (writerModel == null) throw ReservationNotFoundException(
          message: '작성자 정보를 찾을 수 없습니다. writerId: ${model.writerId}',
        );
        return model.toEntity(
          storeSummary,
          _buildWriter(writerUserModel: writerModel, writerRole: model.writerRole),
        );
      }).toList();
    });
}
```

**참고**: `asyncMap`은 각 스냅샷 방출마다 writer 유저 정보를 Firestore에서 조회한다. 이는 Firestore SDK 로컬 캐시로 대부분 처리되므로 허용 가능한 비용이다.

### Phase 3 — UseCase (M)

인터페이스와 구현체에 스트림 메서드 추가.

```dart
// reservation_use_case.dart (interface)
Stream<List<Reservation>> watchReservationsByDateRange({
  required String storeId,
  required DateTime start,
  required DateTime end,
});

// reservation_use_case.dart (impl)
Stream<List<Reservation>> watchReservationsByDateRange({
  required String storeId,
  required DateTime start,
  required DateTime end,
}) {
  return Stream.fromFuture(getCurrentUserOrThrow(_userRepository).run())
    .asyncExpand((result) => result.fold(
      (error) => Stream.error(error),
      (user) => _reservationRepository.watchReservationsByDateRange(
        storeId: storeId,
        currentUid: user.id,
        start: start,
        end: end,
      ),
    ));
}
```

### Phase 4 — Provider 재구성 (L)

#### 4-1. 점포별 StreamProvider 추가

`home_reservations_provider.dart`에 family StreamProvider 추가:

```dart
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
```

#### 4-2. homeReservationsProvider 재구성

```dart
@riverpod
Future<List<Reservation>> homeReservations(Ref ref, DateTime month) async {
  final user = await ref.watch(currentUserProvider.future);
  if (user == null || user.storeInfos.isEmpty) return [];

  final storeIds = user.storeInfos.map((info) => info.id).toList();
  final results = await Future.wait(
    storeIds.map((id) =>
      ref.watch(storeReservationsStreamProvider(id, month).future)
    ),
  );

  return [for (final list in results) ...list];
}
```

**동작 원리**: `storeReservationsStreamProvider(id, month).future`를 `ref.watch`하므로, 해당 스트림이 새 값을 방출할 때마다 Riverpod이 `homeReservationsProvider`를 자동 재실행한다.

#### 4-3. HomeReservationActionsController에서 invalidate 제거

```dart
// 변경 전
(_) {
  ref.invalidate(homeReservationsProvider);
  return true;
}

// 변경 후 — 스트림이 자동 반영하므로 invalidate 불필요
(_) => true,
```

---

## 위험 요소 및 완화

| 위험 | 심각도 | 완화 방안 |
|------|--------|----------|
| asyncMap에서 writer 조회 빈도 증가 | 낮음 | Firestore 로컬 캐시가 대부분 처리. 실제 네트워크 요청은 캐시 만료 시만 발생 |
| 복수 점포 스트림 동시 구독으로 연결 수 증가 | 낮음 | Firestore는 점포당 쿼리 리스너 1개. 점포 수가 많아져도 관리 가능 |
| Stream 에러 시 UI 처리 누락 | 중간 | Calendar 위젯에서 `AsyncError` 케이스 명시적 처리 필요 확인 |
| `homeReservationsProvider` 파라미터가 `DateTime` 객체 동일성 | 낮음 | 월 단위로 `DateTime(year, month, 1)` 정규화하여 전달 — 기존 패턴 유지 |

---

## 성공 지표

- [ ] 다른 기기에서 예약 생성 시 1~2초 내 캘린더에 반영
- [ ] 앱 내부 예약 생성/수정/삭제 후 캘린더 자동 갱신 (invalidate 없이)
- [ ] `dart analyze` 에러 없음
- [ ] 기존 `getReservationsByDateRange` Future 메서드 제거 없이 공존 (하위 호환)
