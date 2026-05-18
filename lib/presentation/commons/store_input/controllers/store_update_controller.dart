import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/domain/entities/store.dart';
import 'package:studio_chance/domain/enums/store_color.dart';
import 'package:studio_chance/domain/use_cases/store_use_case_provider.dart';
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
    String memo = '';

    if (currentUser != null) {
      try {
        color = currentUser.storeInfos
            .firstWhere((e) => e.id == store.id)
            .color;
        memo = currentUser.storeInfos.firstWhere((e) => e.id == store.id).memo;
      } catch (_) {}
    }

    return StoreFormState(
      name: store.name,
      address: store.address,
      addressDetail: store.addressDetail,
      addressGuide: store.addressGuide,
      memo: memo,
      color: color,
      priceSettings: store.priceSettings,
    );
  }

  @override
  ({Store store, StoreColor color, String memo})? getFormData() {
    if (!state.isValid) return null;

    final updatedStore = _targetStore.copyWith(
      name: state.name,
      address: state.address,
      addressDetail: state.addressDetail,
      addressGuide: state.addressGuide,
      priceSettings: state.priceSettings,
    );

    return (store: updatedStore, color: state.color, memo: state.memo);
  }

  @override
  Future<void> submit() async {
    final data = getFormData();
    if (data == null) return;

    state = state.copyWith(status: const AsyncLoading());

    try {
      final storeUseCase = ref.read(storeUseCaseProvider);
      final result = await storeUseCase.updateStore(
        store: data.store,
        color: data.color,
        memo: data.memo,
      );
      result.fold(
        (exception) =>
            state = state.copyWith(status: AsyncError(exception, StackTrace.current)),
        (_) => state = state.copyWith(status: const AsyncData(null)),
      );
    } catch (e, st) {
      state = state.copyWith(status: AsyncError(e, st));
    }
  }
}
