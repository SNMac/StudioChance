import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio_chance/presentation/commons/widgets/app_toast.dart';

void main() {
  /// 토스트 애니메이션은 표시 시간 내내 돌아서 pumpAndSettle은 사라질 때까지 진행한다 —
  /// 페이드 인이 끝난 시점까지만 진행한다
  Future<void> pumpUntilShown(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// 실제 앱처럼 MaterialApp.builder에서 ToastHost로 Navigator를 감싼다
  Future<void> pumpApp(WidgetTester tester, Widget home) => tester.pumpWidget(
    MaterialApp(
      builder: (context, child) => ToastHost(child: child!),
      home: home,
    ),
  );

  testWidgets('메시지를 보여주고 잠시 뒤 사라진다', (tester) async {
    await pumpApp(
      tester,
      Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => showAppToast(context, '저장했습니다'),
            child: const Text('띄우기'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('띄우기'));
    await pumpUntilShown(tester);
    expect(find.text('저장했습니다'), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(find.text('저장했습니다'), findsNothing);
  });

  testWidgets('바텀시트가 열려 있어도 시트에 가려지지 않는다', (tester) async {
    await pumpApp(
      tester,
      Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              builder: (sheetContext) => SizedBox.expand(
                child: Material(
                  child: Center(
                    child: TextButton(
                      onPressed: () => showAppToast(sheetContext, '시트 위 알림'),
                      child: const Text('시트에서 띄우기'),
                    ),
                  ),
                ),
              ),
            ),
            child: const Text('시트 열기'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('시트 열기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('시트에서 띄우기'));
    await pumpUntilShown(tester);

    // 가장 위에서 터치를 받는 위치에 있어야 사용자 눈에도 보인다
    expect(find.text('시트 위 알림').hitTestable(), findsOneWidget);
  });

  testWidgets('캡슐 바깥의 터치는 막지 않는다', (tester) async {
    var tapped = 0;
    await pumpApp(
      tester,
      Scaffold(
        body: Builder(
          builder: (context) => Column(
            children: [
              TextButton(
                onPressed: () => showAppToast(context, '짧은 알림'),
                child: const Text('띄우기'),
              ),
              const Spacer(),
              // 토스트와 같은 높이의 화면 왼쪽 끝 — 캡슐 바깥이다
              Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: 40,
                  height: 200,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => tapped++,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.text('띄우기'));
    await pumpUntilShown(tester);
    expect(find.text('짧은 알림'), findsOneWidget);

    final toastCenter = tester.getCenter(find.text('짧은 알림'));
    await tester.tapAt(Offset(10, toastCenter.dy));
    expect(tapped, 1);
  });

  testWidgets('키보드가 떠 있으면 키보드 바로 위에 뜬다', (tester) async {
    // iOS처럼 하단 안전 영역(34)이 있고 키보드(300)가 그 영역까지 덮은 상태
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = const Size(400, 800)
      ..viewPadding = const FakeViewPadding(bottom: 34)
      ..padding = FakeViewPadding.zero
      ..viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.reset);

    await pumpApp(
      tester,
      Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => showAppToast(context, '키보드 위 알림'),
            child: const Text('띄우기'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('띄우기'));
    await pumpUntilShown(tester);

    const keyboardTop = 800 - 300;
    final toastBottom = tester.getBottomLeft(find.text('키보드 위 알림')).dy;
    expect(toastBottom, lessThanOrEqualTo(keyboardTop));
    // 안전 영역·탭바 높이가 키보드 높이에 겹쳐 더해지면 키보드에서 동떨어져 뜬다
    expect(toastBottom, greaterThan(keyboardTop - 49));
  });
}
