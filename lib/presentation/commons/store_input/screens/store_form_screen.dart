import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/common/exceptions/app_exception.dart';
import 'package:studio_chance/constants/data_constants.dart';
import 'package:studio_chance/domain/entities/day_group.dart';
import 'package:studio_chance/domain/entities/space_option.dart';
import 'package:studio_chance/domain/entities/store.dart';
import 'package:studio_chance/presentation/commons/extensions/store_form_state_formatter.dart';
import 'package:studio_chance/presentation/commons/store_input/controllers/store_creation_controller.dart';
import 'package:studio_chance/presentation/commons/store_input/controllers/store_form_controllerable.dart';
import 'package:studio_chance/presentation/commons/store_input/controllers/states/store_form_state.dart';
import 'package:studio_chance/presentation/commons/store_input/controllers/store_update_controller.dart';
import 'package:studio_chance/presentation/commons/store_input/widgets/price_setting_input_form.dart';
import 'package:studio_chance/presentation/commons/widgets/app_bar/app_bar_action_button.dart';
import 'package:studio_chance/presentation/commons/widgets/app_bar/app_bar_back_button.dart';
import 'package:studio_chance/presentation/commons/widgets/app_bar/custom_app_bar.dart';
import 'package:studio_chance/presentation/commons/widgets/custom_alert_dialog.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/memo_text_field.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/grouped_form_container.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/title_navigation_button.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/title_text_field.dart';
import 'package:studio_chance/presentation/commons/widgets/loading_overlay.dart';
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
  late final ScrollController _scrollController;
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

  void _scrollAfterBuild({bool toBottom = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      final target = toBottom
          ? _scrollController.position.maxScrollExtent
          : (_scrollController.offset + 300).clamp(
              0.0,
              _scrollController.position.maxScrollExtent,
            );
      _scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _showErrorDialog(String title, String content) => showCustomAlertDialog(
    context: context,
    title: title,
    content: content,
    showCancel: false,
  );

  @override
  void initState() {
    super.initState();
    final initialState = ref.read(_currentProvider);

    _scrollController = ScrollController();
    _nameController = TextEditingController(text: initialState.name);
    _memoController = TextEditingController(text: initialState.memo);
  }

  @override
  void dispose() {
    _scrollController.dispose();
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

    final isLoading = state.status.isLoading;

    ref.listen(provider.select((value) => value.status), (previous, next) {
      next.when(
        data: (_) {},
        loading: () {},
        error: (error, stackTrace) {
          if (error is AppException) {
            _showErrorDialog(error.title, error.content);
          } else {
            _showErrorDialog(
              '에러가 발생했습니다',
              '개발자에게 문의해 주세요.\n(${error.toString()})',
            );
          }
        },
      );
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        showCustomAlertDialog(
          context: context,
          title: '점포 등록 화면으로 돌아갈까요?',
          onConfirmBeforePop: () {
            if (context.mounted && context.canPop()) {
              context.pop();
            }
          },
        );
      },

      child: Scaffold(
        appBar: CustomAppBar(
          title: isEditMode ? '점포 수정' : '점포 생성',
          leading: AppBarNaviBackButton(
            isEnabled: !isLoading,
            onPressed: () {
              Navigator.maybePop(context);
            },
          ),
          actions: [
            AppBarActionButton(
              label: '완료',
              onPressed: (state.isValid && !isLoading)
                  ? () async {
                      await notifier.submit();
                    }
                  : null,
            ),
          ],
        ),
        body: Stack(
          children: [
            Scrollbar(
              controller: _scrollController,
              child: SingleChildScrollView(
                controller: _scrollController,
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: SafeAreaWithPadding(
                  child: Column(
                    spacing: 20,
                    children: [
                      GroupedFormContainer(
                        children: [
                          TitleTextField(
                            title: '점포명',
                            controller: _nameController,
                            onChanged: notifier.setName,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(15),
                            ],
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
                              SCRoute.storeColor.pushChild(
                                context,
                                extra: widget.storeToEdit,
                              );
                            },
                          ),
                          TitleNavigationButton(
                            title: '주소',
                            content: state.formattedAddress,
                            onPressed: () {
                              SCRoute.storeAddress.pushChild(
                                context,
                                extra: widget.storeToEdit,
                              );
                            },
                          ),
                          TitleNavigationButton(
                            title: '입금 정보',
                            content: state.bankName.isEmpty
                                ? null
                                : state.bankName,
                            onPressed: () {
                              SCRoute.storePaymentInfo.pushChild(
                                context,
                                extra: widget.storeToEdit,
                              );
                            },
                          ),
                          TitleNavigationButton(
                            title: '안내사항',
                            onPressed: () {
                              SCRoute.storeGuide.pushChild(
                                context,
                                extra: widget.storeToEdit,
                              );
                            },
                          ),
                          MemoTextField(
                            placeholder: '메모',
                            controller: _memoController,
                            onChanged: notifier.setMemo,
                            maxLength: maxMemoCharCount,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(maxMemoCharCount),
                            ],
                          ),
                        ],
                      ),

                      ...state.spaceOptions.asMap().entries.expand((
                        spaceEntry,
                      ) {
                        final int spaceIndex = spaceEntry.key;
                        final SpaceOption spaceOption = spaceEntry.value;
                        final bool multipleSpaces = state.spaceOptions.length > 1;

                        return [
                          // 공간 이름 입력 + 삭제/복사 버튼
                          GroupedFormContainer(
                            children: [
                              TitleTextField(
                                title: '공간명',
                                controller: TextEditingController(
                                  text: spaceOption.name,
                                ),
                                onChanged: (v) =>
                                    notifier.setSpaceOptionName(spaceIndex, v),
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(20),
                                ],
                              ),
                            ],
                          ),

                          // 이 공간의 요일별 요금 설정
                          ...spaceOption.priceSetting.dayGroups
                              .asMap()
                              .entries
                              .map((groupEntry) {
                            final int groupIndex = groupEntry.key;
                            final DayGroup dayGroup = groupEntry.value;
                            final bool showAdd =
                                spaceOption.priceSetting.dayGroups.length < 8;

                            return PriceSettingInputForm(
                              index: groupIndex,
                              dayGroup: dayGroup,
                              showAdd: showAdd,
                              showDelete: true,
                              onDelete: () {
                                notifier.removeDayGroup(spaceIndex, groupIndex);
                              },
                              onCopy: () {
                                notifier.copyDayGroup(spaceIndex, groupIndex);
                                _scrollAfterBuild(toBottom: false);
                              },
                              onAdd: () {
                                notifier.addDayGroup(spaceIndex);
                                _scrollAfterBuild();
                              },
                              onPressedDaySetting: () {
                                SCRoute.storePriceDays.pushChild(
                                  context,
                                  extra: {
                                    'store': widget.storeToEdit,
                                    'spaceIndex': spaceIndex,
                                    'groupIndex': groupIndex,
                                  },
                                );
                              },
                              onPressedTimeSetting: () {
                                SCRoute.storePriceTime.pushChild(
                                  context,
                                  extra: {
                                    'store': widget.storeToEdit,
                                    'spaceIndex': spaceIndex,
                                    'groupIndex': groupIndex,
                                  },
                                );
                              },
                            );
                          }),

                          // 공간 삭제/복사/추가 버튼 행
                          _SpaceOptionButtonRow(
                            showDelete: multipleSpaces,
                            canAdd: state.spaceOptions.length < 5,
                            isLastSpace:
                                spaceIndex == state.spaceOptions.length - 1,
                            onDelete: () => notifier.removeSpaceOption(spaceIndex),
                            onCopy: () {
                              notifier.copySpaceOption(spaceIndex);
                              _scrollAfterBuild(toBottom: false);
                            },
                            onAdd: () {
                              notifier.addSpaceOption();
                              _scrollAfterBuild();
                            },
                          ),
                        ];
                      }),
                    ],
                  ),
                ),
              ),
            ),

            LoadingOverlay(isLoading: isLoading),
          ],
        ),
      ),
    );
  }
}

/// 공간 옵션 하단 삭제/복사/추가 버튼 행
class _SpaceOptionButtonRow extends StatelessWidget {
  final bool showDelete;
  final bool canAdd;
  final bool isLastSpace;
  final VoidCallback onDelete;
  final VoidCallback onCopy;
  final VoidCallback onAdd;

  const _SpaceOptionButtonRow({
    required this.showDelete,
    required this.canAdd,
    required this.isLastSpace,
    required this.onDelete,
    required this.onCopy,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (showDelete)
          TextButton(
            onPressed: onDelete,
            child: const Text('공간 삭제'),
          ),
        TextButton(onPressed: onCopy, child: const Text('복사')),
        if (isLastSpace && canAdd)
          TextButton(onPressed: onAdd, child: const Text('공간 추가')),
      ],
    );
  }
}
