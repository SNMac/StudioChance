import 'package:flutter_test/flutter_test.dart';
import 'package:studio_chance/data/data_sources/server_clock_data_source.dart';

import '../../helpers/callable_stub.dart';
import '../../helpers/mocks.dart';

void main() {
  test('서버가 돌려준 시각을 DateTime으로 옮긴다', () async {
    final functions = MockFirebaseFunctions();
    final serverNow = DateTime(2026, 8, 29, 9, 10);
    // Android 플랫폼 채널이 돌려주는 모양
    stubCallable(functions, 'getServerTime', <Object?, Object?>{
      'nowMillis': serverNow.millisecondsSinceEpoch,
    });

    final dataSource = ServerClockFunctionsDataSource(functions);

    expect(await dataSource.getServerTime(), serverNow);
  });
}
