import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studio_chance/data/repositories/server_clock_repository_impl.dart';

import '../../helpers/either_expectations.dart';
import '../../helpers/mocks.dart';

void main() {
  late MockServerClockDataSource mockDataSource;
  late ServerClockRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockServerClockDataSource();
    repository = ServerClockRepositoryImpl(
      serverClockDataSource: mockDataSource,
    );
  });

  test('서버 시각에서 기기 시각을 뺀 값을 돌려준다', () async {
    // 기기 시계가 서버보다 1시간 늦은 상황
    when(() => mockDataSource.getServerTime())
        .thenAnswer((_) async => DateTime.now().add(const Duration(hours: 1)));

    final offset = expectRight(await repository.getServerClockOffset());

    // 왕복 보정의 오차만큼 여유를 둔다
    expect(
      (offset - const Duration(hours: 1)).abs(),
      lessThan(const Duration(seconds: 1)),
    );
  });

  test('조회에 실패하면 Left', () async {
    when(() => mockDataSource.getServerTime()).thenThrow(
      FirebaseFunctionsException(message: '네트워크 오류', code: 'unavailable'),
    );

    expect(
      expectLeft(await repository.getServerClockOffset()),
      isA<FirebaseFunctionsException>(),
    );
  });
}
