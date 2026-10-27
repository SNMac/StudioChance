import 'package:fpdart/fpdart.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/common/utils/exception_utils.dart';
import 'package:studio_chance/data/data_sources/server_clock_data_source.dart';
import 'package:studio_chance/domain/repository_interfaces/server_clock_repository.dart';

part 'server_clock_repository_impl.g.dart';

class ServerClockRepositoryImpl implements ServerClockRepository {
  final Logger _logger = Logger();
  final ServerClockDataSource _serverClockDataSource;

  ServerClockRepositoryImpl({required this._serverClockDataSource});

  @override
  Future<Either<Exception, Duration>> getServerClockOffset() async {
    try {
      final sentAt = DateTime.now();
      final serverNow = await _serverClockDataSource.getServerTime();
      final receivedAt = DateTime.now();
      // 서버가 응답을 만든 시각을 왕복의 한가운데로 본다
      final midpoint = sentAt.add(receivedAt.difference(sentAt) ~/ 2);
      return right(serverNow.difference(midpoint));
    } catch (e) {
      _logger.w('서버 시각 조회 실패', error: e);
      return left(toException(e));
    }
  }
}

@Riverpod(keepAlive: true)
ServerClockRepository serverClockRepository(Ref ref) {
  return ServerClockRepositoryImpl(
    serverClockDataSource: ref.watch(serverClockDataSourceProvider),
  );
}
