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
}
