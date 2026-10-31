// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server_clock_offset_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 서버 시각에서 기기 시각을 뺀 값. 초대 코드의 남은 유효 시간(ADR-0006)과 삭제 예정
/// 점포의 남은 기간(ADR-0007)을 서버 시각 기준으로 보여 주는 데 쓴다.
///
/// autoDispose라 보는 화면이 없어지면 버리고 다시 볼 때 새로 구한다 — 그 사이 기기
/// 시각을 바꿔도 다음에 열 때 바로잡힌다. 삭제 예정 점포가 있으면 사용자 정보
/// (`currentUserProvider`)가 보고 있으므로 그동안은 한 번 구한 값을 함께 쓴다. 응답 전이거나 조회에 실패하면 화면은 기기 시계를
/// 그대로 쓴다. 실패는 Repository가 로그로 남기며 화면에 알리지 않는다.

@ProviderFor(serverClockOffset)
final serverClockOffsetProvider = ServerClockOffsetProvider._();

/// 서버 시각에서 기기 시각을 뺀 값. 초대 코드의 남은 유효 시간(ADR-0006)과 삭제 예정
/// 점포의 남은 기간(ADR-0007)을 서버 시각 기준으로 보여 주는 데 쓴다.
///
/// autoDispose라 보는 화면이 없어지면 버리고 다시 볼 때 새로 구한다 — 그 사이 기기
/// 시각을 바꿔도 다음에 열 때 바로잡힌다. 삭제 예정 점포가 있으면 사용자 정보
/// (`currentUserProvider`)가 보고 있으므로 그동안은 한 번 구한 값을 함께 쓴다. 응답 전이거나 조회에 실패하면 화면은 기기 시계를
/// 그대로 쓴다. 실패는 Repository가 로그로 남기며 화면에 알리지 않는다.

final class ServerClockOffsetProvider
    extends
        $FunctionalProvider<AsyncValue<Duration>, Duration, FutureOr<Duration>>
    with $FutureModifier<Duration>, $FutureProvider<Duration> {
  /// 서버 시각에서 기기 시각을 뺀 값. 초대 코드의 남은 유효 시간(ADR-0006)과 삭제 예정
  /// 점포의 남은 기간(ADR-0007)을 서버 시각 기준으로 보여 주는 데 쓴다.
  ///
  /// autoDispose라 보는 화면이 없어지면 버리고 다시 볼 때 새로 구한다 — 그 사이 기기
  /// 시각을 바꿔도 다음에 열 때 바로잡힌다. 삭제 예정 점포가 있으면 사용자 정보
  /// (`currentUserProvider`)가 보고 있으므로 그동안은 한 번 구한 값을 함께 쓴다. 응답 전이거나 조회에 실패하면 화면은 기기 시계를
  /// 그대로 쓴다. 실패는 Repository가 로그로 남기며 화면에 알리지 않는다.
  ServerClockOffsetProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'serverClockOffsetProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$serverClockOffsetHash();

  @$internal
  @override
  $FutureProviderElement<Duration> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Duration> create(Ref ref) {
    return serverClockOffset(ref);
  }
}

String _$serverClockOffsetHash() => r'f5d1e44631195d670bdaa4a76adc4766b2c763a0';
