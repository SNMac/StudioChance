import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:studio_chance/presentation/home/widgets/store_filter_modal.dart';
import 'package:studio_chance/presentation/providers/app_auth_controller.dart';

import '../../../helpers/fake_entities.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> openModal(
    WidgetTester tester, {
    required List<String> storeIds,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentUserProvider.overrideWith(
            (ref) async => fakeUserWithStores(storeIds),
          ),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => showStoreFilterModal(context),
                child: const Text('열기'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('열기'));
    await tester.pumpAndSettle();
  }

  testWidgets('점포가 없으면 전체 선택·해제 버튼 대신 빈 상태를 보여준다', (tester) async {
    await openModal(tester, storeIds: []);

    expect(find.text('표시할 점포가 없습니다'), findsOneWidget);
    expect(find.text('전체 해제'), findsNothing);
    expect(find.text('전체 선택'), findsNothing);
  });

  testWidgets('점포가 있으면 전체 해제로 모두 숨기고 전체 선택으로 되돌린다', (tester) async {
    await openModal(tester, storeIds: ['s1', 's2']);

    expect(find.text('표시할 점포가 없습니다'), findsNothing);
    await tester.tap(find.text('전체 해제'));
    await tester.pumpAndSettle();

    expect(find.text('전체 선택'), findsOneWidget);
  });
}
