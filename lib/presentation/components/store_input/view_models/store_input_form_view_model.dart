import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/domain/entities/price_setting.dart';
import 'package:studio_chance/domain/entities/store.dart';
import 'package:studio_chance/domain/enums/store_color.dart';
import 'package:studio_chance/presentation/components/store_input/view_models/store_input_form_state.dart';

part 'store_input_form_view_model.g.dart';

@riverpod
class StoreInputFormViewModel extends _$StoreInputFormViewModel {
  /// 초기값을 주입받아 상태를 생성 (수정 모드 지원)
  @override
  StoreInputFormState build(Store? initialStore) {
    return StoreInputFormState(
      name: initialStore?.name ?? '',
      address: initialStore?.address ?? '',
      memo: initialStore?.memo ?? '',
      color: initialStore?.color ?? StoreColor.red,
      priceSettings:
          initialStore?.priceSettings ?? const PriceSetting(dayGroups: []),
    );
  }

  void setName(String name) => state = state.copyWith(name: name);
  void setAddress(String address) => state = state.copyWith(address: address);
  void setMemo(String memo) => state = state.copyWith(memo: memo);

  /// 유효한 경우 데이터 반환
  Store? getFormData() {
    if (!state.isValid) return null;

    // 호출하는 쪽에서 ID나 나머지 필드를 채워야 함
    return Store(
      id: initialStore?.id ?? '',
      name: state.name,
      address: state.address,
      memo: state.memo,
      color: state.color,
      priceSettings: state.priceSettings,
      members: initialStore?.members ?? [],
      waitingMembers: initialStore?.waitingMembers ?? [],
      inviteInfo: initialStore?.inviteInfo,
      createdAt: initialStore?.createdAt,
      updatedAt: null,
    );
  }
}
