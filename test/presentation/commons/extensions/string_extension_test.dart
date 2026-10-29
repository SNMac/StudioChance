import 'package:flutter_test/flutter_test.dart';

import 'package:studio_chance/presentation/commons/extensions/string_extension.dart';

void main() {
  group('withObjectParticle', () {
    test('받침이 있으면 을을 붙인다', () {
      expect('수원아주대점'.withObjectParticle(), '수원아주대점을');
    });

    test('받침이 없으면 를을 붙인다', () {
      expect('파티룸 하루'.withObjectParticle(), '파티룸 하루를');
    });

    test('끝 글자가 한글이 아니면 을(를)을 붙인다', () {
      expect('Studio 1'.withObjectParticle(), 'Studio 1을(를)');
    });
  });
}
