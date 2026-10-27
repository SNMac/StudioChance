import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studio_chance/domain/use_cases/server_clock_use_case_provider.dart';

part 'server_clock_offset_provider.g.dart';

/// 서버 시각에서 기기 시각을 뺀 값. 초대 코드의 남은 유효 시간을 서버 시각
/// 기준으로 보여 주는 데 쓴다 (ADR-0006).
///
/// autoDispose라 초대 코드 화면을 열 때마다 새로 구한다 — 그 사이 기기 시각을
/// 바꿔도 다음에 열 때 바로잡힌다. 응답 전이거나 조회에 실패하면 화면은 기기 시계를
/// 그대로 쓴다. 실패는 Repository가 로그로 남기며 화면에 알리지 않는다.
@riverpod
Future<Duration> serverClockOffset(Ref ref) async {
  final result = await ref
      .watch(serverClockUseCaseProvider)
      .getServerClockOffset();
  return result.fold((_) => Duration.zero, (offset) => offset);
}
