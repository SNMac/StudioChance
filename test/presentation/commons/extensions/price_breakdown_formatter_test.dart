import 'package:flutter_test/flutter_test.dart';
import 'package:studio_chance/domain/entities/price_breakdown.dart';
import 'package:studio_chance/presentation/commons/extensions/price_breakdown_formatter.dart';

void main() {
  group('PriceItem 표시 문구 — 시간대 요금', () {
    test('시간당 요금은 시간대와 단가 × 시간으로 표시한다', () {
      const item = PriceItem.slot(
        startMinute: 600,
        endMinute: 725,
        unitPrice: 10000,
        isHourly: true,
        amount: 20833,
      );

      expect(item.title, '10:00 – 12:05');
      expect(item.formula, '10,000원 × 2시간 5분');
    });

    test('1인당 요금은 인원 수를 곱한 것으로 표시한다', () {
      const item = PriceItem.slot(
        startMinute: 1320,
        endMinute: 1440,
        unitPrice: 5000,
        isHourly: true,
        perPersonCount: 6,
        amount: 60000,
      );

      expect(item.title, '22:00 – 24:00');
      expect(item.formula, '5,000원 × 6명 × 2시간');
    });

    test('하루 전체를 덮는 고정 요금은 하루종일 1회 요금으로 표시한다', () {
      const item = PriceItem.slot(
        startMinute: 0,
        endMinute: 1440,
        unitPrice: 180000,
        isHourly: false,
        amount: 180000,
      );

      expect(item.title, '하루종일');
      expect(item.formula, '1회 요금');
    });
  });

  group('PriceItem 표시 문구 — 인원 추가 요금', () {
    test('1인당 시간당 요금은 초과 인원 × 단가 × 시간으로 표시한다', () {
      const item = PriceItem.headcount(
        headcountBase: 4,
        extraPeople: 2,
        unitPrice: 3000,
        isPerPerson: true,
        minutes: 300,
        amount: 30000,
      );

      expect(item.title, '인원 추가');
      expect(item.formula, '기준 4명 초과 2명 × 3,000원 × 5시간');
    });

    test('1인당이 아닌 1회 요금은 초과 여부와 1회 요금으로 표시한다', () {
      const item = PriceItem.headcount(
        headcountBase: 4,
        extraPeople: 2,
        unitPrice: 3000,
        isPerPerson: false,
        amount: 3000,
      );

      expect(item.formula, '기준 4명 초과 · 1회 요금');
    });
  });

  group('PriceItem 표시 문구 — 요금 설정 없음', () {
    test('요금 설정이 없는 시간대는 시간대와 요금 설정 없음으로 표시한다', () {
      const item = PriceItem.unpriced(startMinute: 720, endMinute: 840);

      expect(item.title, '12:00 – 14:00');
      expect(item.formula, '요금 설정 없음');
    });
  });
}
