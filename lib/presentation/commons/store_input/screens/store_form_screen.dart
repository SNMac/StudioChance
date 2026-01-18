import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/common/exceptions/app_exception.dart';
import 'package:studio_chance/domain/entities/day_group.dart';
import 'package:studio_chance/domain/entities/store.dart';
import 'package:studio_chance/presentation/commons/extensions/store_form_state_formatter.dart';
import 'package:studio_chance/presentation/commons/store_input/controllers/store_creation_controller.dart';
import 'package:studio_chance/presentation/commons/store_input/controllers/store_form_controllerable.dart';
import 'package:studio_chance/presentation/commons/store_input/controllers/states/store_form_state.dart';
import 'package:studio_chance/presentation/commons/store_input/controllers/store_update_controller.dart';
import 'package:studio_chance/presentation/commons/widgets/app_bar/app_bar_action_button.dart';
import 'package:studio_chance/presentation/commons/widgets/app_bar/custom_app_bar.dart';
import 'package:studio_chance/presentation/commons/widgets/custom_alert_dialog.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/body_text_field.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/grouped_form_container.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/title_navigation_button.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/title_text_field.dart';
import 'package:studio_chance/presentation/commons/widgets/price_setting_item.dart';
import 'package:studio_chance/presentation/commons/widgets/safe_area_with_padding.dart';
import 'package:studio_chance/router/router_path.dart';

class StoreFormScreen extends ConsumerStatefulWidget {
  /// null이면 생성 모드, 값이 있으면 수정 모드
  final Store? storeToEdit;

  const StoreFormScreen({super.key, this.storeToEdit});

  @override
  ConsumerState<StoreFormScreen> createState() => _StoreFormScreenState();
}

class _StoreFormScreenState extends ConsumerState<StoreFormScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _memoController;

  ProviderListenable<StoreFormState> get _currentProvider {
    if (widget.storeToEdit != null) {
      return storeUpdateControllerProvider(widget.storeToEdit!);
    } else {
      return storeCreationControllerProvider;
    }
  }

  StoreFormControllerable get _currentNotifier {
    if (widget.storeToEdit != null) {
      return ref.read(
        storeUpdateControllerProvider(widget.storeToEdit!).notifier,
      );
    } else {
      return ref.read(storeCreationControllerProvider.notifier);
    }
  }

  void _showErrorDialog(String title, String content) {
    showCustomAlertDialog(
      context: context,
      title: title,
      content: content,
      showCancel: false,
      onConfirm: () => context.pop(),
    );
  }

  @override
  void initState() {
    super.initState();
    final initialState = ref.read(_currentProvider);

    _nameController = TextEditingController(text: initialState.name);
    _memoController = TextEditingController(text: initialState.memo);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.storeToEdit != null;

    final provider = _currentProvider;
    final state = ref.watch(_currentProvider);
    final notifier = _currentNotifier;

    ref.listen(provider.select((value) => value.status), (previous, next) {
      next.when(
        data: (_) {},
        loading: () {
          // 로딩 중 로직 (필요하다면 오버레이 로딩 표시)
        },
        error: (error, stackTrace) {
          // 에러 발생 시 다이얼로그 표시
          if (error is AppException) {
            _showErrorDialog(error.title, error.content);
          } else {
            _showErrorDialog('오류 발생', '개발자에게 문의해주세요.\n(${error.toString()})');
          }
        },
      );
    });

    return Scaffold(
      appBar: CustomAppBar(
        title: isEditMode ? '점포 수정' : '점포 생성',
        actions: [
          AppBarActionButton(
            label: '완료',
            onPressed: state.isValid
                ? () async {
                    await notifier.submit();

                    if (context.mounted) {
                      // 필요한 경우 Pop
                    }
                  }
                : null,
          ),
        ],
      ),
      body: SafeAreaWithPadding(
        child: SingleChildScrollView(
          child: Column(
            spacing: 20,
            children: [
              GroupedFormContainer(
                children: [
                  TitleTextField(
                    title: '점포명',
                    controller: _nameController,
                    onChanged: notifier.setName,
                    inputFormatters: [LengthLimitingTextInputFormatter(15)],
                  ),
                  TitleNavigationButton(
                    title: '색상',
                    content: state.color.displayName,
                    contentLeading: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Color(state.color.foregroundColorValue),
                        shape: BoxShape.circle,
                      ),
                    ),
                    onPressed: () {
                      context.push(
                        SCRoute.onboardingStoreColor.fullPath,
                        extra: widget.storeToEdit,
                      );
                    },
                  ),
                  TitleNavigationButton(
                    title: '주소',
                    content: state.formattedAddress,
                    onPressed: () {
                      context.push(
                        SCRoute.onboardingStoreAddress.fullPath,
                        extra: widget.storeToEdit,
                      );
                    },
                  ),
                  BodyTextField(
                    placeholder: '메모',
                    controller: _memoController,
                    onChanged: notifier.setMemo,
                    maxLines: null,
                    inputFormatters: [LengthLimitingTextInputFormatter(150)],
                    autocorrect: true,
                  ),
                ],
              ),

              ...state.priceSettings.dayGroups.asMap().entries.map((entry) {
                final int index = entry.key;
                final DayGroup dayGroup = entry.value;
                final bool isLast =
                    index == state.priceSettings.dayGroups.length - 1;

                return PriceSettingItem(
                  index: index,
                  dayGroup: dayGroup,
                  isLast: isLast,
                  onDelete: () {
                    // notifier.removeDayGroup(index);
                  },
                  onAdd: () {
                    // notifier.addDayGroup();
                  },
                  onPressedDaySetting: () {
                    // context.push(..., extra: index); // 몇 번째 그룹인지 전달
                  },
                  onPressedTimeSetting: () {
                    // context.push(..., extra: index);
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
