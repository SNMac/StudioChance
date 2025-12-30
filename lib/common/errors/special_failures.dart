import 'package:studio_chance/common/errors/failures.dart';

/// 재로그인이 필요할 때 던지는 특수 에러
class RequiresRecentLoginFailure extends Failure {
  const RequiresRecentLoginFailure() : super('보안을 위해 다시 로그인이 필요합니다.');
}

/// UI 표시가 불필요할 때 던지는 특수 에러
class IgnoreableFailure extends Failure {
  const IgnoreableFailure() : super('UI 표시 불필요');
}