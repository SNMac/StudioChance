import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/domain/entities/price_setting.dart';
import 'package:studio_chance/domain/entities/store.dart';
import 'package:studio_chance/domain/enums/store_color.dart';
import 'package:studio_chance/presentation/components/store_input/view_models/store_input_form_state.dart';

part 'store_input_form_view_model.g.dart';

@riverpod
class StoreInputFormViewModel extends _$StoreInputFormViewModel {
  /// 초기값을 주입받아 상태를 생성 (수정 모드 지원)
  /// - [initialStore]: 수정 시 기존 점포 정보 (없으면 생성 모드)
  /// - [initialColor]: 수정 시 내가 설정했던 색상 (없으면 기본값)
  @override
  StoreInputFormState build({Store? initialStore, StoreColor? initialColor}) {
    return StoreInputFormState(
      name: initialStore?.name ?? '',
      address: initialStore?.address ?? '',
      memo: initialStore?.memo ?? '',
      color: initialColor ?? StoreColor.red,
      priceSettings:
          initialStore?.priceSettings ?? const PriceSetting(dayGroups: []),
    );
  }

  void setName(String name) => state = state.copyWith(name: name);
  void setAddress(String address) => state = state.copyWith(address: address);
  void setMemo(String memo) => state = state.copyWith(memo: memo);
  void setColor(StoreColor color) => state = state.copyWith(color: color);

  /// 유효한 경우 데이터 반환
  /// Store 객체와 사용자가 선택한 Color를 분리해서 반환합니다.
  /// 리턴 타입: ({Store store, StoreColor color})? (Record 타입)
  ({Store store, StoreColor color})? getFormData() {
    if (!state.isValid) return null;

    final store = Store(
      id: initialStore?.id ?? '',
      name: state.name,
      address: state.address,
      memo: state.memo,
      priceSettings: state.priceSettings,

      memberInfos: initialStore?.memberInfos ?? [],
      waitingMemberInfos: initialStore?.waitingMemberInfos ?? [],
      inviteInfo: initialStore?.inviteInfo,

      createdAt: initialStore?.createdAt,
      updatedAt: null,
    );

    return (store: store, color: state.color);
  }
}
