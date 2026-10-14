import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio_chance/domain/entities/price_breakdown.dart';
import 'package:studio_chance/presentation/home/widgets/three_day_calendar/price_breakdown_sheet.dart';

/// 버튼을 눌러 [open]으로 시트를 띄우는 테스트 앱.
Future<void> _pumpAndOpen(
  WidgetTester tester,
  Future<void> Function(BuildContext context) open,
) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => open(context),
            child: const Text('열기'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('열기'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('공간 요금이 없으면 계산 내역 대신 그 원인을 보여준다', (tester) async {
    await _pumpAndOpen(
      tester,
      (context) => showPriceBreakdownSheet(
        context,
        breakdown: null,
        unavailableReason: PriceBreakdownUnavailableReason.noSpacePrice,
        calculatedPrice: 0,
        adjustment: 0,
      ),
    );

    expect(find.textContaining('점포에 등록된 공간 요금이 없어'), findsOneWidget);
  });

  testWidgets('계산 내역의 항목과 공휴일 이름, 최종 요금을 보여준다', (tester) async {
    final breakdown = PriceBreakdown(
      days: [
        PricedDay(
          date: DateTime(2026, 10, 9),
          holidayRateApplied: true,
          items: const [
            PriceItem.slot(
              startMinute: 0,
              endMinute: 1440,
              unitPrice: 200000,
              isHourly: false,
              amount: 200000,
            ),
          ],
        ),
      ],
    );

    await _pumpAndOpen(
      tester,
      (context) => showPriceBreakdownSheet(
        context,
        breakdown: breakdown,
        basis: PriceBreakdownBasis.saved,
        calculatedPrice: 200000,
        adjustment: -20000,
        holidayNamesOf: (date) => date.day == 9 ? ['한글날'] : const [],
      ),
    );

    expect(find.text('예약 당시 요금 기준'), findsOneWidget);
    expect(find.textContaining('한글날'), findsOneWidget);
    expect(find.text('하루종일'), findsOneWidget);
    expect(find.text('180,000원'), findsOneWidget); // 최종 요금
  });

  testWidgets('계산 요금은 모달이 넘긴 값이 아니라 내역 항목의 합계로 보여준다', (tester) async {
    // 모달이 공간 목록을 불러오기 전이면 저장된 요금을 넘길 수 있다 — 시트 안에서는
    // 항목 합과 계산 요금이 어긋나면 안 된다
    final breakdown = PriceBreakdown(
      days: [
        PricedDay(
          date: DateTime(2026, 10, 14),
          holidayRateApplied: false,
          items: const [
            PriceItem.slot(
              startMinute: 600,
              endMinute: 720,
              unitPrice: 10000,
              isHourly: true,
              amount: 20000,
            ),
          ],
        ),
      ],
    );

    await _pumpAndOpen(
      tester,
      (context) => showPriceBreakdownSheet(
        context,
        breakdown: breakdown,
        calculatedPrice: 99999,
        adjustment: -5000,
      ),
    );

    expect(find.text('99,999원'), findsNothing);
    expect(find.text('15,000원'), findsOneWidget); // 최종 요금 = 20,000 - 5,000
  });

  testWidgets('닫기를 누르면 시트가 닫힌다', (tester) async {
    await _pumpAndOpen(
      tester,
      (context) => showPriceBreakdownSheet(
        context,
        breakdown: null,
        unavailableReason: PriceBreakdownUnavailableReason.notLoaded,
        calculatedPrice: 0,
        adjustment: 0,
      ),
    );
    expect(find.text('요금 계산 내역'), findsOneWidget);

    await tester.tap(find.text('닫기'));
    await tester.pumpAndSettle();

    expect(find.text('요금 계산 내역'), findsNothing);
  });

  group('요금 설정 바로가기', () {
    /// 오전은 요금이 있고 오후는 요금표가 비어 있는 내역
    final partlyUnpriced = PriceBreakdown(
      days: [
        PricedDay(
          date: DateTime(2026, 10, 14),
          holidayRateApplied: false,
          items: const [
            PriceItem.slot(
              startMinute: 600,
              endMinute: 720,
              unitPrice: 10000,
              isHourly: true,
              amount: 20000,
            ),
            PriceItem.unpriced(startMinute: 720, endMinute: 840),
          ],
        ),
      ],
    );

    testWidgets('요금이 없는 시간이 있으면 안내와 버튼을 보여주고, 누르면 시트를 닫고 이동한다', (tester) async {
      var opened = 0;
      await _pumpAndOpen(
        tester,
        (context) => showPriceBreakdownSheet(
          context,
          breakdown: partlyUnpriced,
          calculatedPrice: 20000,
          adjustment: 0,
          onOpenPriceSetting: () => opened++,
        ),
      );

      expect(find.textContaining('요금이 설정되지 않은 시간'), findsOneWidget);
      await tester.tap(find.text('요금 설정'));
      await tester.pumpAndSettle();

      expect(find.text('요금 계산 내역'), findsNothing);
      expect(opened, 1);
    });

    testWidgets('이동 콜백이 없으면(관리자가 아니면) 버튼을 보여주지 않는다', (tester) async {
      await _pumpAndOpen(
        tester,
        (context) => showPriceBreakdownSheet(
          context,
          breakdown: partlyUnpriced,
          calculatedPrice: 20000,
          adjustment: 0,
        ),
      );

      expect(find.text('요금 설정'), findsNothing);
    });

    testWidgets('모든 시간에 요금이 있으면 버튼을 보여주지 않는다', (tester) async {
      await _pumpAndOpen(
        tester,
        (context) => showPriceBreakdownSheet(
          context,
          breakdown: PriceBreakdown(
            days: [
              PricedDay(
                date: DateTime(2026, 10, 14),
                holidayRateApplied: false,
                items: const [
                  PriceItem.slot(
                    startMinute: 600,
                    endMinute: 720,
                    unitPrice: 10000,
                    isHourly: true,
                    amount: 20000,
                  ),
                ],
              ),
            ],
          ),
          calculatedPrice: 20000,
          adjustment: 0,
          onOpenPriceSetting: () {},
        ),
      );

      expect(find.text('요금 설정'), findsNothing);
    });

    testWidgets('점포에 공간 요금이 없으면 버튼을 보여준다', (tester) async {
      await _pumpAndOpen(
        tester,
        (context) => showPriceBreakdownSheet(
          context,
          breakdown: null,
          unavailableReason: PriceBreakdownUnavailableReason.noSpacePrice,
          calculatedPrice: 0,
          adjustment: 0,
          onOpenPriceSetting: () {},
        ),
      );
      expect(find.text('요금 설정'), findsOneWidget);
    });

    testWidgets('요금 정보를 불러오지 못했으면 버튼을 보여주지 않는다', (tester) async {
      await _pumpAndOpen(
        tester,
        (context) => showPriceBreakdownSheet(
          context,
          breakdown: null,
          unavailableReason: PriceBreakdownUnavailableReason.notLoaded,
          calculatedPrice: 0,
          adjustment: 0,
          onOpenPriceSetting: () {},
        ),
      );

      expect(find.text('요금 설정'), findsNothing);
    });
  });
}
