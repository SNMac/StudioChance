import 'package:flutter_test/flutter_test.dart';
import 'package:studio_chance/data/data_sources/remote_config.dart';

void main() {
  group('resolveOcrModelName', () {
    test('콘솔 값이 비어 있으면 기본 모델을 쓴다', () {
      expect(resolveOcrModelName(''), defaultOcrModelName);
    });

    test('공백만 있어도 기본 모델을 쓴다', () {
      expect(resolveOcrModelName('  \n'), defaultOcrModelName);
    });

    test('콘솔 값이 있으면 앞뒤 공백을 지워 그대로 쓴다', () {
      expect(
        resolveOcrModelName(' gemini-9-flash-lite '),
        'gemini-9-flash-lite',
      );
    });
  });
}
