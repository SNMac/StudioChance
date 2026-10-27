import 'package:cloud_functions/cloud_functions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/data/data_sources/callable_helpers.dart';

part 'server_clock_data_source.g.dart';

abstract interface class ServerClockDataSource {
  /// 서버의 현재 시각 (Callable `getServerTime`)
  Future<DateTime> getServerTime();
}

/// 실패는 [FirebaseFunctionsException]을 그대로 던진다. 서버 시각은 초대 코드의
/// 남은 시간 표시를 보정하는 데만 쓰고 실패해도 화면은 기기 시계로 표시하므로,
/// 사용자에게 보여 줄 도메인 예외로 옮길 필요가 없다.
class ServerClockFunctionsDataSource implements ServerClockDataSource {
  final FirebaseFunctions _functions;

  ServerClockFunctionsDataSource(this._functions);

  @override
  Future<DateTime> getServerTime() async {
    final data = await _functions.callForMap('getServerTime');
    return dateTimeFromCallableMillis(data['nowMillis']);
  }
}

@Riverpod(keepAlive: true)
ServerClockDataSource serverClockDataSource(Ref ref) {
  return ServerClockFunctionsDataSource(
    // Functions 리전과 일치시킨다 (functions/src/time/)
    FirebaseFunctions.instanceFor(region: 'asia-northeast3'),
  );
}
