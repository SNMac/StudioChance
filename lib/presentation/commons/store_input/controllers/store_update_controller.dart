import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/domain/entities/store.dart';
import 'package:studio_chance/domain/enums/store_color.dart';
import 'package:studio_chance/domain/use_cases/store_use_case.dart';
import 'package:studio_chance/presentation/commons/store_input/controllers/store_form_controllerable.dart';
import 'package:studio_chance/presentation/commons/store_input/controllers/states/store_form_state.dart';
import 'package:studio_chance/presentation/providers/app_auth_controller.dart';

part 'store_update_controller.g.dart';

@riverpod
class StoreUpdateController extends _$StoreUpdateController
    with StoreFormMixin
    implements StoreFormControllerable {
  late final Store _targetStore;

  @override
  StoreFormState build(Store store) {
    _targetStore = store;

    final currentUser = ref.read(currentUserProvider).value;
    StoreColor color = StoreColor.red;

    if (currentUser != null) {
      try {
        color = currentUser.storeInfos
            .firstWhere((e) => e.id == store.id)
            .color;
      } catch (_) {}
    }

    return StoreFormState(
      name: store.name,
      address: store.address,
      addressDetail: store.addressDetail,
      addressGuide: store.addressGuide,
      memo: store.memo,
      color: color,
      priceSettings: store.priceSettings,
    );
  }

  @override
  ({Store store, StoreColor color})? getFormData() {
    if (!state.isValid) return null;

    final updatedStore = _targetStore.copyWith(
      name: state.name,
      address: state.address,
      addressDetail: state.addressDetail,
      addressGuide: state.addressGuide,
      memo: state.memo,
      priceSettings: state.priceSettings,
    );

    return (store: updatedStore, color: state.color);
  }

  @override
  Future<void> submit() async {
    final data = getFormData();
    if (data == null) return;

    state = state.copyWith(status: const AsyncValue.loading());

    try {
      final storeUseCase = ref.read(storeUseCaseProvider);

      // TODO: Update 메서드 호출 (UseCase에 updateStore가 있다고 가정)
      // final result = await storeUseCase.updateStore(
      //   store: data.store,
      //   color: data.color,
      // );
      // if (result.isLeft()) throw result.getLeft().toNullable()!;
    } catch (e, st) {
      state = state.copyWith(status: AsyncValue.error(e, st));
    }
  }
}
