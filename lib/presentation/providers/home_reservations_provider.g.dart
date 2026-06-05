// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_reservations_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 현재 사용자가 접근 가능한 점포 중 필터에서 선택된 점포의 [month] 기간 예약을
/// 실시간으로 병합하여 스트림으로 반환한다.
///
/// - 각 점포의 Firestore 변경을 직접 구독 → fetch 없이 즉시 반영
/// - [ReservationNetworkException] 발생 시 5초 후 재연결 시도
/// - 그 외 에러(권한 거부 등)는 해당 점포를 빈 목록으로 처리하고 재연결 없이 종료
/// - 필터/사용자 변경 시 provider 재실행으로 새 구독 세트 생성

@ProviderFor(homeReservations)
final homeReservationsProvider = HomeReservationsFamily._();

/// 현재 사용자가 접근 가능한 점포 중 필터에서 선택된 점포의 [month] 기간 예약을
/// 실시간으로 병합하여 스트림으로 반환한다.
///
/// - 각 점포의 Firestore 변경을 직접 구독 → fetch 없이 즉시 반영
/// - [ReservationNetworkException] 발생 시 5초 후 재연결 시도
/// - 그 외 에러(권한 거부 등)는 해당 점포를 빈 목록으로 처리하고 재연결 없이 종료
/// - 필터/사용자 변경 시 provider 재실행으로 새 구독 세트 생성

final class HomeReservationsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Reservation>>,
          List<Reservation>,
          Stream<List<Reservation>>
        >
    with
        $FutureModifier<List<Reservation>>,
        $StreamProvider<List<Reservation>> {
  /// 현재 사용자가 접근 가능한 점포 중 필터에서 선택된 점포의 [month] 기간 예약을
  /// 실시간으로 병합하여 스트림으로 반환한다.
  ///
  /// - 각 점포의 Firestore 변경을 직접 구독 → fetch 없이 즉시 반영
  /// - [ReservationNetworkException] 발생 시 5초 후 재연결 시도
  /// - 그 외 에러(권한 거부 등)는 해당 점포를 빈 목록으로 처리하고 재연결 없이 종료
  /// - 필터/사용자 변경 시 provider 재실행으로 새 구독 세트 생성
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
  $StreamProviderElement<List<Reservation>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Reservation>> create(Ref ref) {
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

String _$homeReservationsHash() => r'c00566afb04a221190d187418842ba39bf04cb6a';

/// 현재 사용자가 접근 가능한 점포 중 필터에서 선택된 점포의 [month] 기간 예약을
/// 실시간으로 병합하여 스트림으로 반환한다.
///
/// - 각 점포의 Firestore 변경을 직접 구독 → fetch 없이 즉시 반영
/// - [ReservationNetworkException] 발생 시 5초 후 재연결 시도
/// - 그 외 에러(권한 거부 등)는 해당 점포를 빈 목록으로 처리하고 재연결 없이 종료
/// - 필터/사용자 변경 시 provider 재실행으로 새 구독 세트 생성

final class HomeReservationsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Reservation>>, DateTime> {
  HomeReservationsFamily._()
    : super(
        retry: null,
        name: r'homeReservationsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 현재 사용자가 접근 가능한 점포 중 필터에서 선택된 점포의 [month] 기간 예약을
  /// 실시간으로 병합하여 스트림으로 반환한다.
  ///
  /// - 각 점포의 Firestore 변경을 직접 구독 → fetch 없이 즉시 반영
  /// - [ReservationNetworkException] 발생 시 5초 후 재연결 시도
  /// - 그 외 에러(권한 거부 등)는 해당 점포를 빈 목록으로 처리하고 재연결 없이 종료
  /// - 필터/사용자 변경 시 provider 재실행으로 새 구독 세트 생성

  HomeReservationsProvider call(DateTime month) =>
      HomeReservationsProvider._(argument: month, from: this);

  @override
  String toString() => r'homeReservationsProvider';
}
