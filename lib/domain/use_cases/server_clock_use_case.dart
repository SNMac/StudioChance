import 'package:fpdart/fpdart.dart';
import 'package:studio_chance/domain/repository_interfaces/server_clock_repository.dart';

abstract interface class ServerClockUseCase {
  /// 서버 시각에서 기기 시각을 뺀 값. 초대 코드의 남은 유효 시간·삭제 예정 점포의 남은 기간
  /// 표시 보정과 점포 삭제 전 기기 시계 확인에 쓴다
  Future<Either<Exception, Duration>> getServerClockOffset();
}

/// 화면이 Repository를 직접 부르지 않도록 하는 단순 위임 UseCase (D10).
class ServerClockUseCaseImpl implements ServerClockUseCase {
  final ServerClockRepository _repository;

  ServerClockUseCaseImpl(this._repository);

  @override
  Future<Either<Exception, Duration>> getServerClockOffset() =>
      _repository.getServerClockOffset();
}
