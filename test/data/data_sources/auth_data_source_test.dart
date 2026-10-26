import 'package:flutter_test/flutter_test.dart';
import 'package:studio_chance/data/data_sources/auth_data_source.dart';

void main() {
  group('reauthProviderIdOf', () {
    test('Google만 연동되어 있으면 Google로 재인증한다', () {
      expect(reauthProviderIdOf(['google.com']), 'google.com');
    });

    test('Apple만 연동되어 있으면 Apple로 재인증한다', () {
      expect(reauthProviderIdOf(['apple.com']), 'apple.com');
    });

    // Apple revoke에 필요한 값을 재인증 한 번으로 얻는다 (ADR-0005)
    test('둘 다 연동되어 있으면 순서와 관계없이 Apple로 재인증한다', () {
      expect(reauthProviderIdOf(['google.com', 'apple.com']), 'apple.com');
      expect(reauthProviderIdOf(['apple.com', 'google.com']), 'apple.com');
    });

    test('지원하지 않는 제공자뿐이면 null', () {
      expect(reauthProviderIdOf(['password']), isNull);
    });
  });
}
