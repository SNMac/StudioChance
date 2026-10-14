import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:studio_chance/presentation/providers/app_auth_controller.dart';
import 'package:studio_chance/presentation/providers/home_store_filter_controller.dart';

import '../../helpers/fake_entities.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  ProviderContainer buildContainer({required List<String> storeIds}) {
    final container = ProviderContainer(
      overrides: [
        currentUserProvider.overrideWith(
          (ref) async => fakeUserWithStores(storeIds),
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('선택되지 않은 점포를 선택에 추가한다', () async {
    final container = buildContainer(storeIds: ['s1', 's2']);
    await container.read(currentUserProvider.future);

    final notifier = container.read(homeStoreFilterControllerProvider.notifier);
    notifier.toggle('s1'); // s1 해제
    expect(container.read(homeStoreFilterControllerProvider), {'s2'});

    notifier.ensureSelected('s1');

    expect(container.read(homeStoreFilterControllerProvider), {'s1', 's2'});
  });

  test('이미 선택된 점포면 상태가 그대로다', () async {
    final container = buildContainer(storeIds: ['s1', 's2']);
    await container.read(currentUserProvider.future);

    final before = container.read(homeStoreFilterControllerProvider);
    container
        .read(homeStoreFilterControllerProvider.notifier)
        .ensureSelected('s1');

    expect(container.read(homeStoreFilterControllerProvider), before);
  });

  test('사용자 정보를 다시 불러오는 동안에도 선택 상태를 유지한다', () async {
    final container = buildContainer(storeIds: ['s1', 's2']);
    final sub = container.listen(homeStoreFilterControllerProvider, (_, _) {});
    addTearDown(sub.close);
    await container.read(currentUserProvider.future);
    expect(container.read(homeStoreFilterControllerProvider), {'s1', 's2'});

    // 점포 수정 저장 등으로 currentUser를 갱신하면 새 값이 올 때까지 로딩 상태가 된다
    container.invalidate(currentUserProvider);

    // 로딩 중 빈 선택이 되면 홈 캘린더가 빈 예약 목록을 내보낸다
    expect(container.read(homeStoreFilterControllerProvider), {'s1', 's2'});
  });
}
