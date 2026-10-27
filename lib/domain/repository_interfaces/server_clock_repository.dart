import 'package:fpdart/fpdart.dart';

abstract interface class ServerClockRepository {
  /// 서버 시각에서 기기 시각을 뺀 값. 초대 코드의 남은 유효 시간 표시 보정용
  Future<Either<Exception, Duration>> getServerClockOffset();
}
