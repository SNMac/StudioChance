import 'package:fpdart/fpdart.dart';

abstract interface class ServerClockRepository {
  /// 서버 시각에서 기기 시각을 뺀 값. 초대 코드의 남은 유효 시간·삭제 예정 점포의 남은 기간
  /// 표시 보정과 점포 삭제 전 기기 시계 확인에 쓴다
  Future<Either<Exception, Duration>> getServerClockOffset();
}
