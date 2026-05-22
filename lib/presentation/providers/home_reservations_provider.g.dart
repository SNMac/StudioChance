// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_reservations_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// [storeId] 점포의 [month] 기간 예약을 실시간으로 구독한다.
///
/// Firestore 변경 시 자동으로 새 값이 방출됩니다.

@ProviderFor(storeReservationsStream)
final storeReservationsStreamProvider = StoreReservationsStreamFamily._();

/// [storeId] 점포의 [month] 기간 예약을 실시간으로 구독한다.
///
/// Firestore 변경 시 자동으로 새 값이 방출됩니다.

final class StoreReservationsStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Reservation>>,
          List<Reservation>,
          Stream<List<Reservation>>
        >
    with
        $FutureModifier<List<Reservation>>,
        $StreamProvider<List<Reservation>> {
  /// [storeId] 점포의 [month] 기간 예약을 실시간으로 구독한다.
  ///
  /// Firestore 변경 시 자동으로 새 값이 방출됩니다.
  StoreReservationsStreamProvider._({
    required StoreReservationsStreamFamily super.from,
    required (String, DateTime) super.argument,
  }) : super(
         retry: null,
         name: r'storeReservationsStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$storeReservationsStreamHash();

  @override
  String toString() {
    return r'storeReservationsStreamProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<Reservation>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Reservation>> create(Ref ref) {
    final argument = this.argument as (String, DateTime);
    return storeReservationsStream(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is StoreReservationsStreamProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$storeReservationsStreamHash() =>
    r'3583b0b14456da9e9795efb19eb5a10d45fa36bc';

/// [storeId] 점포의 [month] 기간 예약을 실시간으로 구독한다.
///
/// Firestore 변경 시 자동으로 새 값이 방출됩니다.

final class StoreReservationsStreamFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<Reservation>>,
          (String, DateTime)
        > {
  StoreReservationsStreamFamily._()
    : super(
        retry: null,
        name: r'storeReservationsStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// [storeId] 점포의 [month] 기간 예약을 실시간으로 구독한다.
  ///
  /// Firestore 변경 시 자동으로 새 값이 방출됩니다.

  StoreReservationsStreamProvider call(String storeId, DateTime month) =>
      StoreReservationsStreamProvider._(argument: (storeId, month), from: this);

  @override
  String toString() => r'storeReservationsStreamProvider';
}

/// 현재 사용자가 접근 가능한 점포 중 필터에서 선택된 점포의 [month] 기간 예약을 병합하여 반환한다.
///
/// - [HomeStoreFilterController]의 selectedIds로 점포 필터링
/// - 각 점포의 [storeReservationsStreamProvider]를 구독
/// - 어느 점포 스트림이 새 값을 방출하면 자동으로 재실행됩니다.

@ProviderFor(homeReservations)
final homeReservationsProvider = HomeReservationsFamily._();

/// 현재 사용자가 접근 가능한 점포 중 필터에서 선택된 점포의 [month] 기간 예약을 병합하여 반환한다.
///
/// - [HomeStoreFilterController]의 selectedIds로 점포 필터링
/// - 각 점포의 [storeReservationsStreamProvider]를 구독
/// - 어느 점포 스트림이 새 값을 방출하면 자동으로 재실행됩니다.

final class HomeReservationsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Reservation>>,
          List<Reservation>,
          FutureOr<List<Reservation>>
        >
    with
        $FutureModifier<List<Reservation>>,
        $FutureProvider<List<Reservation>> {
  /// 현재 사용자가 접근 가능한 점포 중 필터에서 선택된 점포의 [month] 기간 예약을 병합하여 반환한다.
  ///
  /// - [HomeStoreFilterController]의 selectedIds로 점포 필터링
  /// - 각 점포의 [storeReservationsStreamProvider]를 구독
  /// - 어느 점포 스트림이 새 값을 방출하면 자동으로 재실행됩니다.
  HomeReservationsProvider._({
    required HomeReservationsFamily super.from,
    required DateTime super.argument,
  }) : super(
         retry: null,
         name: r'homeReservationsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$homeReservationsHash();

  @override
  String toString() {
    return r'homeReservationsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Reservation>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Reservation>> create(Ref ref) {
    final argument = this.argument as DateTime;
    return homeReservations(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is HomeReservationsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$homeReservationsHash() => r'b849def4a4d463ac651192176000d4fbc2ac6cf0';

/// 현재 사용자가 접근 가능한 점포 중 필터에서 선택된 점포의 [month] 기간 예약을 병합하여 반환한다.
///
/// - [HomeStoreFilterController]의 selectedIds로 점포 필터링
/// - 각 점포의 [storeReservationsStreamProvider]를 구독
/// - 어느 점포 스트림이 새 값을 방출하면 자동으로 재실행됩니다.

final class HomeReservationsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Reservation>>, DateTime> {
  HomeReservationsFamily._()
    : super(
        retry: null,
        name: r'homeReservationsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 현재 사용자가 접근 가능한 점포 중 필터에서 선택된 점포의 [month] 기간 예약을 병합하여 반환한다.
  ///
  /// - [HomeStoreFilterController]의 selectedIds로 점포 필터링
  /// - 각 점포의 [storeReservationsStreamProvider]를 구독
  /// - 어느 점포 스트림이 새 값을 방출하면 자동으로 재실행됩니다.

  HomeReservationsProvider call(DateTime month) =>
      HomeReservationsProvider._(argument: month, from: this);

  @override
  String toString() => r'homeReservationsProvider';
}
