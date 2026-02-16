import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:studio_chance/domain/entities/day_group.dart';
import 'package:studio_chance/domain/entities/headcount_rule.dart';
import 'package:studio_chance/domain/entities/store.dart';
import 'package:studio_chance/domain/entities/time_slot.dart';
import 'package:studio_chance/presentation/commons/extensions/day_group_formatter.dart';
import 'package:studio_chance/presentation/commons/extensions/time_formatter.dart';
import 'package:studio_chance/presentation/commons/store_input/controllers/states/store_form_state.dart';
import 'package:studio_chance/presentation/commons/store_input/controllers/store_creation_controller.dart';
import 'package:studio_chance/presentation/commons/store_input/controllers/store_form_controllerable.dart';
import 'package:studio_chance/presentation/commons/store_input/controllers/store_update_controller.dart';
import 'package:studio_chance/presentation/commons/store_input/widgets/headcount_input_form.dart';
import 'package:studio_chance/presentation/commons/store_input/widgets/time_slot_input_form.dart';
import 'package:studio_chance/presentation/commons/widgets/app_bar/app_bar_action_button.dart';
import 'package:studio_chance/presentation/commons/widgets/app_bar/custom_app_bar.dart';
import 'package:studio_chance/presentation/commons/widgets/custom_alert_dialog.dart';
import 'package:studio_chance/presentation/commons/widgets/safe_area_with_padding.dart';

class PriceTimeInputScreen extends ConsumerStatefulWidget {
  const PriceTimeInputScreen({super.key});

  @override
  ConsumerState<PriceTimeInputScreen> createState() =>
      _PriceTimeInputScreenState();
}

class _PriceTimeInputScreenState extends ConsumerState<PriceTimeInputScreen> {
  late final ScrollController _scrollController;

  late HeadcountRule _currentHeadcountRule;
  late List<TimeSlot> _currentTimeSlots;

  bool _isHeadcountValid = false;
  bool _isInitialized = false;

  /// 초기 데이터 로드 (최초 1회)
  void _initializeData(DayGroup currentGroup) {
    if (_isInitialized) return;

    _currentHeadcountRule = currentGroup.headcountRule;
    _currentTimeSlots = List.from(currentGroup.timeSlots);

    _isHeadcountValid =
        _currentHeadcountRule.headcountBase != -1 &&
        _currentHeadcountRule.headcountExtraPrice != -1;

    _isInitialized = true;
  }

  void _addLocalTimeSlot() {
    setState(() {
      _currentTimeSlots.add(TimeSlot.empty());
    });
  }

  void _copyLocalTimeSlot(int index) {
    setState(() {
      final copiedSlot = _currentTimeSlots[index].copyWith();
      _currentTimeSlots.insert(index + 1, copiedSlot);
    });
  }

  void _removeLocalTimeSlot(int index) {
    setState(() {
      if (_currentTimeSlots.length > 1) {
        _currentTimeSlots.removeAt(index);
      } else {
        _currentTimeSlots[index] = TimeSlot.empty();
      }
    });
  }

  void _updateLocalTimeSlot(int index, TimeSlot newSlot) {
    setState(() {
      _currentTimeSlots[index] = newSlot;
    });
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = GoRouterState.of(context).extra as Map<String, dynamic>;
    final Store? storeToEdit = args['store'] as Store?;
    final int groupIndex = args['index'] as int;

    StoreFormState state;
    StoreFormControllerable notifier;

    if (storeToEdit != null) {
      state = ref.watch(storeUpdateControllerProvider(storeToEdit));
      notifier = ref.read(storeUpdateControllerProvider(storeToEdit).notifier);
    } else {
      state = ref.watch(storeCreationControllerProvider);
      notifier = ref.read(storeCreationControllerProvider.notifier);
    }

    if (groupIndex >= state.priceSettings.dayGroups.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showCustomAlertDialog(
          context: context,
          title: '에러가 발생했습니다',
          content: '데이터를 찾을 수 없습니다. (Index Error)',
          showCancel: false,
          onConfirmAfterPop: () => context.pop(),
        );
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    final currentDayGroup = state.priceSettings.dayGroups[groupIndex];
    _initializeData(currentDayGroup);

    void onSave() {
      // 시간 중복 검증
      for (int i = 0; i < _currentTimeSlots.length; i++) {
        for (int j = i + 1; j < _currentTimeSlots.length; j++) {
          final a = _currentTimeSlots[i];
          final b = _currentTimeSlots[j];

          // isAllDay == true인 슬롯은 다른 모든 슬롯과 중복
          final aStart = a.isAllDay ? 0 : a.startTime;
          final aEnd = a.isAllDay ? 1440 : a.endTime;
          final bStart = b.isAllDay ? 0 : b.startTime;
          final bEnd = b.isAllDay ? 1440 : b.endTime;

          final overlapStart = aStart > bStart ? aStart : bStart;
          final overlapEnd = aEnd < bEnd ? aEnd : bEnd;

          if (overlapStart < overlapEnd) {
            showCustomAlertDialog(
              context: context,
              title: '기준 시간 중복',
              content:
                  '${overlapStart.formattedTime} ~ ${overlapEnd.formattedTime}까지의 기준 시간이 중복됩니다',
              showCancel: false,
            );
            return;
          }
        }
      }

      final finalDayGroup = currentDayGroup.copyWith(
        headcountRule: _currentHeadcountRule,
        timeSlots: _currentTimeSlots,
      );

      notifier.setDayGroup(groupIndex, finalDayGroup);
      context.pop();
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (context.mounted && context.canPop()) {
          context.pop();
        }
      },

      child: Scaffold(
        appBar: CustomAppBar(
          title: currentDayGroup.formattedDays,
          actions: [
            AppBarActionButton(
              label: '완료',
              onPressed: _isHeadcountValid ? onSave : null,
            ),
          ],
        ),
        body: Scrollbar(
          controller: _scrollController,
          child: SingleChildScrollView(
            controller: _scrollController,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: SafeAreaWithPadding(
              child: Column(
                spacing: 20,
                children: [
                  HeadcountInputForm(
                    initialRule: _currentHeadcountRule,
                    onChanged: (updatedRule, isValid) {
                      setState(() {
                        _currentHeadcountRule = updatedRule;
                        _isHeadcountValid = isValid;
                      });
                    },
                  ),

                  ..._currentTimeSlots.asMap().entries.map((entry) {
                    final int slotIndex = entry.key;
                    final timeSlot = entry.value;

                    final bool showAdd = currentDayGroup.timeSlots.length < 23;

                    return TimeSlotInputForm(
                      index: slotIndex,
                      timeSlot: timeSlot,
                      showAdd: showAdd,
                      showDelete: true,
                      onAdd: _addLocalTimeSlot,
                      onCopy: () => _copyLocalTimeSlot(slotIndex),
                      onDelete: () => _removeLocalTimeSlot(slotIndex),
                      onChanged: (updatedSlot) {
                        _updateLocalTimeSlot(slotIndex, updatedSlot);
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
