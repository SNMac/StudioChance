import 'package:studio_chance/domain/entities/day_group.dart';
import 'package:studio_chance/domain/entities/store.dart';
import 'package:studio_chance/domain/entities/time_slot.dart';
import 'package:studio_chance/domain/enums/store_color.dart';
import 'package:studio_chance/domain/enums/weekday.dart';
import 'package:studio_chance/presentation/commons/store_input/controllers/states/store_form_state.dart';

/// 생성/수정 컨트롤러가 공통으로 구현해야 할 인터페이스
abstract interface class StoreFormControllerable {
  void setName(String name);
  void setAddress(String address);
  void setAddressDetail(String addressDetail);
  void setAddressGuide(String addressGuide);
  void setMemo(String memo);
  void setColor(StoreColor color);
  void setBankName(String bankName);
  void setBankAccountNumber(String bankAccountNumber);
  void setBankAccountHolder(String bankAccountHolder);
  void setPaymentDeadlineMinutes(int? paymentDeadlineMinutes);

  void addDayGroup();
  void copyDayGroup(int index);
  void removeDayGroup(int index);

  /// 특정 그룹(groupIndex)의 특정 요일(day)을 토글(추가/삭제)
  void toggleDayGroupDay(int groupIndex, Weekday day);
  void setDayGroup(int index, DayGroup dayGroup);

  /// 특정 DayGroup(groupIndex)에 새로운 TimeSlot 추가
  void addTimeSlot(int groupIndex);

  /// 특정 TimeSlot 복사
  void copyTimeSlot(int groupIndex, int slotIndex);

  /// 특정 TimeSlot 삭제
  void removeTimeSlot(int groupIndex, int slotIndex);

  /// 현재 폼 데이터를 반환 (유효하지 않으면 null)
  ({Store store, StoreColor color, String memo})? getFormData();

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
  void setBankName(String bankName) =>
      state = state.copyWith(bankName: bankName);
  void setBankAccountNumber(String bankAccountNumber) =>
      state = state.copyWith(bankAccountNumber: bankAccountNumber);
  void setBankAccountHolder(String bankAccountHolder) =>
      state = state.copyWith(bankAccountHolder: bankAccountHolder);
  void setPaymentDeadlineMinutes(int? paymentDeadlineMinutes) =>
      state = state.copyWith(paymentDeadlineMinutes: paymentDeadlineMinutes);

  void addDayGroup() {
    final newGroups = [...state.priceSettings.dayGroups, DayGroup.empty()];
    state = state.copyWith(
      priceSettings: state.priceSettings.copyWith(dayGroups: newGroups),
    );
  }

  void copyDayGroup(int index) {
    if (index < 0 || index >= state.priceSettings.dayGroups.length) return;

    final currentGroups = [...state.priceSettings.dayGroups];
    final targetGroup = currentGroups[index];
    final copiedGroup = targetGroup.copyWith(days: []);
    currentGroups.insert(index + 1, copiedGroup);

    state = state.copyWith(
      priceSettings: state.priceSettings.copyWith(dayGroups: currentGroups),
    );
  }

  void removeDayGroup(int index) {
    final currentGroups = [...state.priceSettings.dayGroups];
    if (currentGroups.length > 1) {
      currentGroups.removeAt(index);
    } else {
      currentGroups[index] = DayGroup.empty();
    }

    state = state.copyWith(
      priceSettings: state.priceSettings.copyWith(dayGroups: currentGroups),
    );
  }

  void toggleDayGroupDay(int groupIndex, Weekday day) {
    if (groupIndex >= state.priceSettings.dayGroups.length) return;

    final currentGroups = [...state.priceSettings.dayGroups];
    final targetGroup = currentGroups[groupIndex];
    final currentDays = [...targetGroup.days];

    if (currentDays.contains(day)) {
      currentDays.remove(day);
    } else {
      currentDays.add(day);
    }

    currentGroups[groupIndex] = targetGroup.copyWith(days: currentDays);

    state = state.copyWith(
      priceSettings: state.priceSettings.copyWith(dayGroups: currentGroups),
    );
  }

  void setDayGroup(int index, DayGroup dayGroup) {
    if (index < 0 || index >= state.priceSettings.dayGroups.length) return;

    final currentGroups = [...state.priceSettings.dayGroups];
    currentGroups[index] = dayGroup;

    state = state.copyWith(
      priceSettings: state.priceSettings.copyWith(dayGroups: currentGroups),
    );
  }

  void addTimeSlot(int groupIndex) {
    if (groupIndex >= state.priceSettings.dayGroups.length) return;

    final currentGroups = [...state.priceSettings.dayGroups];
    final targetGroup = currentGroups[groupIndex];

    final newSlots = [...targetGroup.timeSlots, TimeSlot.empty()];

    currentGroups[groupIndex] = targetGroup.copyWith(timeSlots: newSlots);

    state = state.copyWith(
      priceSettings: state.priceSettings.copyWith(dayGroups: currentGroups),
    );
  }

  void copyTimeSlot(int groupIndex, int slotIndex) {
    if (groupIndex >= state.priceSettings.dayGroups.length) return;

    final currentGroups = [...state.priceSettings.dayGroups];
    final targetGroup = currentGroups[groupIndex];
    if (slotIndex >= targetGroup.timeSlots.length) return;

    final currentSlots = [...targetGroup.timeSlots];
    final targetSlot = currentSlots[slotIndex];

    currentSlots.insert(slotIndex + 1, targetSlot.copyWith());

    currentGroups[groupIndex] = targetGroup.copyWith(timeSlots: currentSlots);
    state = state.copyWith(
      priceSettings: state.priceSettings.copyWith(dayGroups: currentGroups),
    );
  }

  void removeTimeSlot(int groupIndex, int slotIndex) {
    if (groupIndex >= state.priceSettings.dayGroups.length) return;

    final currentGroups = [...state.priceSettings.dayGroups];
    final targetGroup = currentGroups[groupIndex];

    final currentSlots = [...targetGroup.timeSlots];
    if (currentSlots.length <= 1) {
      currentSlots[slotIndex] = TimeSlot.empty();
    } else {
      currentSlots.removeAt(slotIndex);
    }

    currentGroups[groupIndex] = targetGroup.copyWith(timeSlots: currentSlots);
    state = state.copyWith(
      priceSettings: state.priceSettings.copyWith(dayGroups: currentGroups),
    );
  }
}
