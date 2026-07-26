import 'package:flutter_test/flutter_test.dart';
import 'package:studio_chance/common/exceptions/ocr_exceptions.dart';
import 'package:studio_chance/data/data_sources/gemini_data_source.dart';

void main() {
  group('validateOcrRequiredFields', () {
    test('customerName, customerPhone, startTime이 모두 null이면 OcrParsingException을 던진다', () {
      expect(
        () => validateOcrRequiredFields(const {
          'customerName': null,
          'customerPhone': null,
          'startTime': null,
        }),
        throwsA(isA<OcrParsingException>()),
      );
    });

    test('customerName만 있어도 예외를 던지지 않는다', () {
      expect(
        () => validateOcrRequiredFields(const {
          'customerName': '홍길동',
          'customerPhone': null,
          'startTime': null,
        }),
        returnsNormally,
      );
    });

    test('startTime만 있어도 예외를 던지지 않는다', () {
      expect(
        () => validateOcrRequiredFields(const {
          'customerName': null,
          'customerPhone': null,
          'startTime': '2026-05-01T10:00:00',
        }),
        returnsNormally,
      );
    });
  });
}
