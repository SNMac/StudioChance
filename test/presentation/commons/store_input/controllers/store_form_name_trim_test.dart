import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio_chance/presentation/commons/store_input/controllers/store_creation_controller.dart';
import 'package:studio_chance/presentation/commons/store_input/controllers/store_update_controller.dart';

import '../../../../helpers/fake_entities.dart';

void main() {
  late ProviderContainer container;

  setUp(() => container = ProviderContainer());
  tearDown(() => container.dispose());

  group('점포명 공백 처리', () {
    test('생성 시 앞뒤 공백을 제거하고 저장한다', () {
      final notifier = container.read(storeCreationControllerProvider.notifier);
      notifier.setName('  스튜디오찬스 1호점 ');
      notifier.setAddress('경기 오산시 경기대로 1');

      expect(notifier.getFormData()?.store.name, '스튜디오찬스 1호점');
    });

    test('수정 시에도 앞뒤 공백을 제거하고 저장한다', () {
      // fakeStore의 공간은 이름이 비어 있어 isValid를 통과하지 못한다
      final target = fakeStore.copyWith(
        spaceOptions: [fakeStore.spaceOptions.first.copyWith(name: '기본 공간')],
      );
      final notifier = container.read(
        storeUpdateControllerProvider(target).notifier,
      );
      notifier.setName('스튜디오찬스 1호점  ');

      expect(notifier.getFormData()?.store.name, '스튜디오찬스 1호점');
    });

    test('공백만 입력하면 저장할 수 없다', () {
      final notifier = container.read(storeCreationControllerProvider.notifier);
      notifier.setName('   ');
      notifier.setAddress('경기 오산시 경기대로 1');

      expect(container.read(storeCreationControllerProvider).isValid, isFalse);
      expect(notifier.getFormData(), isNull);
    });
  });
}
