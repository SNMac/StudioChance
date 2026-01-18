import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/domain/entities/day_group.dart';
import 'package:studio_chance/domain/entities/price_setting.dart';
import 'package:studio_chance/domain/entities/store.dart';
import 'package:studio_chance/domain/enums/store_color.dart';
import 'package:studio_chance/domain/use_cases/store_use_case.dart';
import 'package:studio_chance/presentation/commons/store_input/controllers/store_form_controllerable.dart';
import 'package:studio_chance/presentation/commons/store_input/controllers/states/store_form_state.dart';
import 'package:studio_chance/presentation/providers/app_auth_controller.dart';

part 'store_creation_controller.g.dart';

@riverpod
class StoreCreationController extends _$StoreCreationController
    with StoreFormMixin
    implements StoreFormControllerable {
  @override
  StoreFormState build() {
    return StoreFormState(
      color: StoreColor.red,
      priceSettings: PriceSetting.empty(),
    );
  }

  @override
  ({Store store, StoreColor color})? getFormData() {
    if (!state.isValid) return null;

    final store = Store(
      id: '',
      name: state.name,
      address: state.address,
      addressDetail: state.addressDetail,
      addressGuide: state.addressGuide,
      memo: state.memo,
      priceSettings: state.priceSettings,
      memberInfos: [],
      waitingMemberInfos: [],
      inviteInfo: null,
      createdAt: null,
      updatedAt: null,
    );

    return (store: store, color: state.color);
  }

  @override
  Future<void> submit() async {
    final data = getFormData();
    if (data == null) return;

    state = state.copyWith(status: const AsyncValue.loading());

    try {
      final storeUseCase = ref.read(storeUseCaseProvider);

      final result = await storeUseCase.createStore(
        store: data.store,
        color: data.color,
      );

      if (result.isLeft()) throw result.getLeft().toNullable()!;

      // 성공 시 온보딩 갱신을 위해 AuthController 갱신
      ref.invalidate(appAuthControllerProvider);
    } catch (e, st) {
      state = state.copyWith(status: AsyncValue.error(e, st));
    }
  }
}
