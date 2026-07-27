import 'package:uuid/uuid.dart';

import 'package:studio_chance/domain/entities/day_group.dart';
import 'package:studio_chance/domain/entities/price_setting.dart';
import 'package:studio_chance/domain/entities/space_option.dart';
import 'package:studio_chance/domain/entities/store.dart';
import 'package:studio_chance/domain/entities/time_slot.dart';
import 'package:studio_chance/common/enums/store_color.dart';
import 'package:studio_chance/common/enums/weekday.dart';
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
  void setInfoNotes(String infoNotes);
  void setCautionNotes(String cautionNotes);

  // ── SpaceOption CRUD ──────────────────────────────────────────────────────

  void addSpaceOption();
  void removeSpaceOption(int spaceIndex);
  void setSpaceOptionName(int spaceIndex, String name);
  void copySpaceOption(int spaceIndex);

  // ── DayGroup 관리 (spaceIndex 기반) ───────────────────────────────────────

  void addDayGroup(int spaceIndex);
  void copyDayGroup(int spaceIndex, int groupIndex);
  void removeDayGroup(int spaceIndex, int groupIndex);

  /// 특정 그룹(groupIndex)의 특정 요일(day)을 토글(추가/삭제)
  void toggleDayGroupDay(int spaceIndex, int groupIndex, Weekday day);
  void setDayGroup(int spaceIndex, int groupIndex, DayGroup dayGroup);

  /// 특정 DayGroup(groupIndex)에 새로운 TimeSlot 추가
  void addTimeSlot(int spaceIndex, int groupIndex);
  void copyTimeSlot(int spaceIndex, int groupIndex, int slotIndex);
  void removeTimeSlot(int spaceIndex, int groupIndex, int slotIndex);

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
  void setInfoNotes(String infoNotes) =>
      state = state.copyWith(infoNotes: infoNotes);
  void setCautionNotes(String cautionNotes) =>
      state = state.copyWith(cautionNotes: cautionNotes);

  // ── SpaceOption CRUD ──────────────────────────────────────────────────────

  void addSpaceOption() {
    final newId = const Uuid().v4();
    final newSpace = SpaceOption(
      id: newId,
      name: '',
      priceSetting: PriceSetting.empty(),
    );
    state = state.copyWith(spaceOptions: [...state.spaceOptions, newSpace]);
  }

  void removeSpaceOption(int spaceIndex) {
    final current = [...state.spaceOptions];
    if (current.length > 1) {
      current.removeAt(spaceIndex);
    } else {
      current[spaceIndex] = current[spaceIndex].copyWith(
        priceSetting: PriceSetting.empty(),
      );
    }
    state = state.copyWith(spaceOptions: current);
  }

  void setSpaceOptionName(int spaceIndex, String name) {
    if (spaceIndex >= state.spaceOptions.length) return;
    final current = [...state.spaceOptions];
    current[spaceIndex] = current[spaceIndex].copyWith(name: name);
    state = state.copyWith(spaceOptions: current);
  }

  void copySpaceOption(int spaceIndex) {
    if (spaceIndex >= state.spaceOptions.length) return;
    final current = [...state.spaceOptions];
    final target = current[spaceIndex];
    final newId = const Uuid().v4();
    final copied = target.copyWith(
      id: newId,
      name: target.name.isEmpty ? '' : '${target.name} (복사)',
    );
    current.insert(spaceIndex + 1, copied);
    state = state.copyWith(spaceOptions: current);
  }

  // ── DayGroup 관리 ─────────────────────────────────────────────────────────

  void addDayGroup(int spaceIndex) {
    if (spaceIndex >= state.spaceOptions.length) return;
    final currentSpaces = [...state.spaceOptions];
    final targetSpace = currentSpaces[spaceIndex];
    final newGroups = [...targetSpace.priceSetting.dayGroups, DayGroup.empty()];
    currentSpaces[spaceIndex] = targetSpace.copyWith(
      priceSetting: targetSpace.priceSetting.copyWith(dayGroups: newGroups),
    );
    state = state.copyWith(spaceOptions: currentSpaces);
  }

  void copyDayGroup(int spaceIndex, int groupIndex) {
    if (spaceIndex >= state.spaceOptions.length) return;
    final currentSpaces = [...state.spaceOptions];
    final targetSpace = currentSpaces[spaceIndex];
    final currentGroups = [...targetSpace.priceSetting.dayGroups];
    if (groupIndex < 0 || groupIndex >= currentGroups.length) return;

    final copiedGroup = currentGroups[groupIndex].copyWith(days: []);
    currentGroups.insert(groupIndex + 1, copiedGroup);

    currentSpaces[spaceIndex] = targetSpace.copyWith(
      priceSetting: targetSpace.priceSetting.copyWith(dayGroups: currentGroups),
    );
    state = state.copyWith(spaceOptions: currentSpaces);
  }

  void removeDayGroup(int spaceIndex, int groupIndex) {
    if (spaceIndex >= state.spaceOptions.length) return;
    final currentSpaces = [...state.spaceOptions];
    final targetSpace = currentSpaces[spaceIndex];
    final currentGroups = [...targetSpace.priceSetting.dayGroups];

    if (currentGroups.length > 1) {
      currentGroups.removeAt(groupIndex);
    } else {
      currentGroups[groupIndex] = DayGroup.empty();
    }

    currentSpaces[spaceIndex] = targetSpace.copyWith(
      priceSetting: targetSpace.priceSetting.copyWith(dayGroups: currentGroups),
    );
    state = state.copyWith(spaceOptions: currentSpaces);
  }

  void toggleDayGroupDay(int spaceIndex, int groupIndex, Weekday day) {
    if (spaceIndex >= state.spaceOptions.length) return;
    final currentSpaces = [...state.spaceOptions];
    final targetSpace = currentSpaces[spaceIndex];
    final currentGroups = [...targetSpace.priceSetting.dayGroups];
    if (groupIndex >= currentGroups.length) return;

    final targetGroup = currentGroups[groupIndex];
    final currentDays = [...targetGroup.days];
    if (currentDays.contains(day)) {
      currentDays.remove(day);
    } else {
      currentDays.add(day);
    }

    currentGroups[groupIndex] = targetGroup.copyWith(days: currentDays);
    currentSpaces[spaceIndex] = targetSpace.copyWith(
      priceSetting: targetSpace.priceSetting.copyWith(dayGroups: currentGroups),
    );
    state = state.copyWith(spaceOptions: currentSpaces);
  }

  void setDayGroup(int spaceIndex, int groupIndex, DayGroup dayGroup) {
    if (spaceIndex >= state.spaceOptions.length) return;
    final currentSpaces = [...state.spaceOptions];
    final targetSpace = currentSpaces[spaceIndex];
    final currentGroups = [...targetSpace.priceSetting.dayGroups];
    if (groupIndex < 0 || groupIndex >= currentGroups.length) return;

    currentGroups[groupIndex] = dayGroup;
    currentSpaces[spaceIndex] = targetSpace.copyWith(
      priceSetting: targetSpace.priceSetting.copyWith(dayGroups: currentGroups),
    );
    state = state.copyWith(spaceOptions: currentSpaces);
  }

  void addTimeSlot(int spaceIndex, int groupIndex) {
    if (spaceIndex >= state.spaceOptions.length) return;
    final currentSpaces = [...state.spaceOptions];
    final targetSpace = currentSpaces[spaceIndex];
    final currentGroups = [...targetSpace.priceSetting.dayGroups];
    if (groupIndex >= currentGroups.length) return;

    final targetGroup = currentGroups[groupIndex];
    final newSlots = [...targetGroup.timeSlots, TimeSlot.empty()];

    currentGroups[groupIndex] = targetGroup.copyWith(timeSlots: newSlots);
    currentSpaces[spaceIndex] = targetSpace.copyWith(
      priceSetting: targetSpace.priceSetting.copyWith(dayGroups: currentGroups),
    );
    state = state.copyWith(spaceOptions: currentSpaces);
  }

  void copyTimeSlot(int spaceIndex, int groupIndex, int slotIndex) {
    if (spaceIndex >= state.spaceOptions.length) return;
    final currentSpaces = [...state.spaceOptions];
    final targetSpace = currentSpaces[spaceIndex];
    final currentGroups = [...targetSpace.priceSetting.dayGroups];
    if (groupIndex >= currentGroups.length) return;

    final targetGroup = currentGroups[groupIndex];
    final currentSlots = [...targetGroup.timeSlots];
    if (slotIndex >= currentSlots.length) return;

    currentSlots.insert(slotIndex + 1, currentSlots[slotIndex].copyWith());

    currentGroups[groupIndex] = targetGroup.copyWith(timeSlots: currentSlots);
    currentSpaces[spaceIndex] = targetSpace.copyWith(
      priceSetting: targetSpace.priceSetting.copyWith(dayGroups: currentGroups),
    );
    state = state.copyWith(spaceOptions: currentSpaces);
  }

  void removeTimeSlot(int spaceIndex, int groupIndex, int slotIndex) {
    if (spaceIndex >= state.spaceOptions.length) return;
    final currentSpaces = [...state.spaceOptions];
    final targetSpace = currentSpaces[spaceIndex];
    final currentGroups = [...targetSpace.priceSetting.dayGroups];
    if (groupIndex >= currentGroups.length) return;

    final targetGroup = currentGroups[groupIndex];
    final currentSlots = [...targetGroup.timeSlots];

    if (currentSlots.length <= 1) {
      currentSlots[slotIndex] = TimeSlot.empty();
    } else {
      currentSlots.removeAt(slotIndex);
    }

    currentGroups[groupIndex] = targetGroup.copyWith(timeSlots: currentSlots);
    currentSpaces[spaceIndex] = targetSpace.copyWith(
      priceSetting: targetSpace.priceSetting.copyWith(dayGroups: currentGroups),
    );
    state = state.copyWith(spaceOptions: currentSpaces);
  }
}
