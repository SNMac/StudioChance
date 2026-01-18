import 'package:studio_chance/domain/entities/day_group.dart';
import 'package:studio_chance/domain/entities/store.dart';
import 'package:studio_chance/domain/enums/store_color.dart';
import 'package:studio_chance/presentation/commons/store_input/controllers/states/store_form_state.dart';

/// 생성/수정 컨트롤러가 공통으로 구현해야 할 인터페이스
abstract interface class StoreFormControllerable {
  void setName(String name);
  void setAddress(String address);
  void setAddressDetail(String addressDetail);
  void setAddressGuide(String addressGuide);
  void setMemo(String memo);
  void setColor(StoreColor color);

  void addDayGroup();
  void removeDayGroup(int index);

  /// 특정 그룹(groupIndex)의 특정 요일(dayValue)을 토글(추가/삭제)
  void toggleDayGroupDay(int groupIndex, int dayValue);

  /// 현재 폼 데이터를 반환 (유효하지 않으면 null)
  ({Store store, StoreColor color})? getFormData();

  /// API 요청 실행
  Future<void> submit();
}

mixin StoreFormMixin {
  StoreFormState get state;
  set state(StoreFormState value);

  void setName(String name) => state = state.copyWith(name: name);
  void setAddress(String address) => state = state.copyWith(address: address);
  void setAddressDetail(String addressDetail) =>
      state = state.copyWith(addressDetail: addressDetail);
  void setAddressGuide(String addressGuide) =>
      state = state.copyWith(addressGuide: addressGuide);
  void setMemo(String memo) => state = state.copyWith(memo: memo);
  void setColor(StoreColor color) => state = state.copyWith(color: color);

  void addDayGroup() {
    final newGroups = [...state.priceSettings.dayGroups, DayGroup.empty()];
    state = state.copyWith(
      priceSettings: state.priceSettings.copyWith(dayGroups: newGroups),
    );
  }

  void removeDayGroup(int index) {
    final currentGroups = [...state.priceSettings.dayGroups];

    if (currentGroups.length <= 1) {
      currentGroups[index] = DayGroup.empty();
      state = state.copyWith(
        priceSettings: state.priceSettings.copyWith(dayGroups: currentGroups),
      );
      return;
    }

    currentGroups.removeAt(index);
    state = state.copyWith(
      priceSettings: state.priceSettings.copyWith(dayGroups: currentGroups),
    );
  }

  void toggleDayGroupDay(int groupIndex, int dayValue) {
    if (groupIndex >= state.priceSettings.dayGroups.length) return;

    final currentGroups = [...state.priceSettings.dayGroups];
    final targetGroup = currentGroups[groupIndex];
    final currentDays = [...targetGroup.days];

    if (currentDays.contains(dayValue)) {
      currentDays.remove(dayValue);
    } else {
      currentDays.add(dayValue);
    }

    currentGroups[groupIndex] = targetGroup.copyWith(days: currentDays);

    state = state.copyWith(
      priceSettings: state.priceSettings.copyWith(dayGroups: currentGroups),
    );
  }
}
