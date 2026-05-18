// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_reservations_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 현재 사용자가 접근 가능한 모든 점포의 [month] 기간 예약을 병합하여 반환한다.
///
/// - 조회 범위: [month]의 1일 00:00 ~ 다음달 1일 00:00
/// - 복수 점포 병렬 조회 후 결과 병합
/// - 일부 점포 조회 실패 시 실패 점포는 빈 목록으로 처리 (부분 성공 허용)

@ProviderFor(homeReservations)
final homeReservationsProvider = HomeReservationsFamily._();

/// 현재 사용자가 접근 가능한 모든 점포의 [month] 기간 예약을 병합하여 반환한다.
///
/// - 조회 범위: [month]의 1일 00:00 ~ 다음달 1일 00:00
/// - 복수 점포 병렬 조회 후 결과 병합
/// - 일부 점포 조회 실패 시 실패 점포는 빈 목록으로 처리 (부분 성공 허용)

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
  /// 현재 사용자가 접근 가능한 모든 점포의 [month] 기간 예약을 병합하여 반환한다.
  ///
  /// - 조회 범위: [month]의 1일 00:00 ~ 다음달 1일 00:00
  /// - 복수 점포 병렬 조회 후 결과 병합
  /// - 일부 점포 조회 실패 시 실패 점포는 빈 목록으로 처리 (부분 성공 허용)
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

String _$homeReservationsHash() => r'6526ee3beab33bfce573d16a23c08d4fb895aae6';

/// 현재 사용자가 접근 가능한 모든 점포의 [month] 기간 예약을 병합하여 반환한다.
///
/// - 조회 범위: [month]의 1일 00:00 ~ 다음달 1일 00:00
/// - 복수 점포 병렬 조회 후 결과 병합
/// - 일부 점포 조회 실패 시 실패 점포는 빈 목록으로 처리 (부분 성공 허용)

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

  /// 현재 사용자가 접근 가능한 모든 점포의 [month] 기간 예약을 병합하여 반환한다.
  ///
  /// - 조회 범위: [month]의 1일 00:00 ~ 다음달 1일 00:00
  /// - 복수 점포 병렬 조회 후 결과 병합
  /// - 일부 점포 조회 실패 시 실패 점포는 빈 목록으로 처리 (부분 성공 허용)

  HomeReservationsProvider call(DateTime month) =>
      HomeReservationsProvider._(argument: month, from: this);

  @override
  String toString() => r'homeReservationsProvider';
}
