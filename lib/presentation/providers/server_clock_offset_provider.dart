import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studio_chance/domain/use_cases/server_clock_use_case_provider.dart';

part 'server_clock_offset_provider.g.dart';

/// 서버 시각에서 기기 시각을 뺀 값. 초대 코드의 남은 유효 시간(ADR-0006)과 삭제 예정
/// 점포의 남은 기간(ADR-0007)을 서버 시각 기준으로 보여 주는 데 쓴다.
///
/// autoDispose라 보는 화면이 없어지면 버리고 다시 볼 때 새로 구한다 — 그 사이 기기
/// 시각을 바꿔도 다음에 열 때 바로잡힌다. 삭제 예정 점포가 있으면 사용자 정보
/// (`currentUserProvider`)가 보고 있으므로 그동안은 한 번 구한 값을 함께 쓴다. 응답 전이거나 조회에 실패하면 화면은 기기 시계를
/// 그대로 쓴다. 실패는 Repository가 로그로 남기며 화면에 알리지 않는다.
@riverpod
Future<Duration> serverClockOffset(Ref ref) async {
  final result = await ref
      .watch(serverClockUseCaseProvider)
      .getServerClockOffset();
  return result.fold((_) => Duration.zero, (offset) => offset);
}

/// 서버 시각으로 보정한 지금. 보정값을 받기 전이거나 받지 못했으면 기기 시계다.
/// 한 프레임 안에서 여러 번 읽으면 경계 순간에 판단이 엇갈리므로 build마다 한 번만 읽는다
DateTime serverCorrectedNow(WidgetRef ref) => DateTime.now().add(
  ref.watch(serverClockOffsetProvider).value ?? Duration.zero,
);
