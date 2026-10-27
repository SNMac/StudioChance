// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server_clock_offset_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 서버 시각에서 기기 시각을 뺀 값. 초대 코드의 남은 유효 시간을 서버 시각
/// 기준으로 보여 주는 데 쓴다 (ADR-0006).
///
/// autoDispose라 초대 코드 화면을 열 때마다 새로 구한다 — 그 사이 기기 시각을
/// 바꿔도 다음에 열 때 바로잡힌다. 응답 전이거나 조회에 실패하면 화면은 기기 시계를
/// 그대로 쓴다. 실패는 Repository가 로그로 남기며 화면에 알리지 않는다.

@ProviderFor(serverClockOffset)
final serverClockOffsetProvider = ServerClockOffsetProvider._();

/// 서버 시각에서 기기 시각을 뺀 값. 초대 코드의 남은 유효 시간을 서버 시각
/// 기준으로 보여 주는 데 쓴다 (ADR-0006).
///
/// autoDispose라 초대 코드 화면을 열 때마다 새로 구한다 — 그 사이 기기 시각을
/// 바꿔도 다음에 열 때 바로잡힌다. 응답 전이거나 조회에 실패하면 화면은 기기 시계를
/// 그대로 쓴다. 실패는 Repository가 로그로 남기며 화면에 알리지 않는다.

final class ServerClockOffsetProvider
    extends
        $FunctionalProvider<AsyncValue<Duration>, Duration, FutureOr<Duration>>
    with $FutureModifier<Duration>, $FutureProvider<Duration> {
  /// 서버 시각에서 기기 시각을 뺀 값. 초대 코드의 남은 유효 시간을 서버 시각
  /// 기준으로 보여 주는 데 쓴다 (ADR-0006).
  ///
  /// autoDispose라 초대 코드 화면을 열 때마다 새로 구한다 — 그 사이 기기 시각을
  /// 바꿔도 다음에 열 때 바로잡힌다. 응답 전이거나 조회에 실패하면 화면은 기기 시계를
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

String _$serverClockOffsetHash() => r'ec2f1c009398de526c7ec65bd2c74e2917734933';
