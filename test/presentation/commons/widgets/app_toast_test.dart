import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio_chance/presentation/commons/widgets/app_toast.dart';

void main() {
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
    await tester.pumpAndSettle();
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
    await tester.pumpAndSettle();

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
    await tester.pumpAndSettle();
    expect(find.text('짧은 알림'), findsOneWidget);

    final toastCenter = tester.getCenter(find.text('짧은 알림'));
    await tester.tapAt(Offset(10, toastCenter.dy));
    expect(tapped, 1);
  });
}
