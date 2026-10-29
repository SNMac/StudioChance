import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/common/exceptions/app_exception.dart';
import 'package:studio_chance/common/exceptions/store_exceptions.dart';
import 'package:studio_chance/constants/data_constants.dart';
import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/domain/entities/day_group.dart';
import 'package:studio_chance/domain/entities/space_option.dart';
import 'package:studio_chance/domain/entities/store.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';
import 'package:studio_chance/presentation/commons/extensions/address_formatter.dart';
import 'package:studio_chance/presentation/commons/store_input/controllers/store_creation_controller.dart';
import 'package:studio_chance/presentation/commons/store_input/controllers/store_form_controllerable.dart';
import 'package:studio_chance/presentation/commons/store_input/controllers/states/store_form_state.dart';
import 'package:studio_chance/presentation/commons/store_input/controllers/store_update_controller.dart';
import 'package:studio_chance/presentation/commons/store_input/widgets/price_setting_input_form.dart';
import 'package:studio_chance/presentation/commons/widgets/app_bar/app_bar_action_button.dart';
import 'package:studio_chance/presentation/commons/widgets/app_bar/app_bar_back_button.dart';
import 'package:studio_chance/presentation/commons/widgets/app_bar/custom_app_bar.dart';
import 'package:studio_chance/presentation/commons/widgets/app_toast.dart';
import 'package:studio_chance/presentation/commons/widgets/custom_alert_dialog.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/memo_text_field.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/grouped_form_container.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/title_navigation_button.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/title_text_field.dart';
import 'package:studio_chance/presentation/commons/widgets/loading_overlay.dart';
import 'package:studio_chance/presentation/commons/widgets/safe_area_with_padding.dart';
import 'package:studio_chance/router/router_path.dart';
import 'package:studio_chance/presentation/commons/widgets/store_color_dot.dart';

/// 점포 수정 화면(`/store-edit`) 진입 인자
class StoreEditArgs {
  const StoreEditArgs({required this.store, this.spaceOptionId});

  /// 진입 직전에 새로 조회한 점포 — 저장 시 동시 수정 판정의 기준이 된다 (D13)
  final Store store;

  /// 처음 보여줄 공간. 화면을 열면 이 공간 섹션으로 스크롤한다
  final String? spaceOptionId;
}

/// 점포 수정 화면을 연다. 저장하고 닫혔으면 true.
///
/// 최상위 라우트라 마이페이지에서도, 예약 모달을 연 채로도 그 위에 쌓였다가 돌아온다.
Future<bool> pushStoreEdit(
  BuildContext context,
  Store store, {
  String? spaceOptionId,
}) async =>
    await context.push<bool>(
      SCRoute.storeEdit.fullPath,
      extra: StoreEditArgs(store: store, spaceOptionId: spaceOptionId),
    ) ??
    false;

class StoreFormScreen extends ConsumerStatefulWidget {
  /// null이면 생성 모드, 값이 있으면 수정 모드
  final Store? storeToEdit;

  /// 수정 모드에서 처음 보여줄 공간 id
  final String? initialSpaceOptionId;

  const StoreFormScreen({
    super.key,
    this.storeToEdit,
    this.initialSpaceOptionId,
  });

  @override
  ConsumerState<StoreFormScreen> createState() => _StoreFormScreenState();
}

class _StoreFormScreenState extends ConsumerState<StoreFormScreen> {
  late final ScrollController _scrollController;
  late final TextEditingController _nameController;
  late final TextEditingController _memoController;
  final Set<String> _expandedSpaceIds = {};
  final Map<String, TextEditingController> _spaceNameControllers = {};
  final Map<String, GlobalKey> _spaceSectionKeys = {};

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

  /// 처음 보여줄 공간 섹션으로 스크롤한다 — 공간 섹션은 모두 펼친 채 시작한다
  void _scrollToInitialSpace() {
    final spaceId = widget.initialSpaceOptionId;
    if (spaceId == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sectionContext = _spaceSectionKeys[spaceId]?.currentContext;
      if (sectionContext == null || !sectionContext.mounted) return;
      Scrollable.ensureVisible(
        sectionContext,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  /// 다른 관리자가 먼저 저장했을 때 최신 점포로 폼과 입력창을 다시 채운다 (D13)
  Future<void> _reloadLatest() async {
    await ref
        .read(storeUpdateControllerProvider(widget.storeToEdit!).notifier)
        .reloadLatest();
    if (!mounted) return;

    final latest = ref.read(_currentProvider);
    _nameController.text = latest.name;
    _memoController.text = latest.memo;

    // 아직 TextField에 붙어 있는 컨트롤러는 다음 프레임에 해제한다
    final latestIds = latest.spaceOptions.map((s) => s.id).toSet();
    final staleIds = _spaceNameControllers.keys
        .where((id) => !latestIds.contains(id))
        .toList();
    final stale = [
      for (final id in staleIds) _spaceNameControllers.remove(id)!,
    ];
    for (final space in latest.spaceOptions) {
      (_spaceNameControllers[space.id] ??= TextEditingController()).text =
          space.name;
    }
    setState(() {
      _expandedSpaceIds
        ..clear()
        ..addAll(latestIds);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final controller in stale) {
        controller.dispose();
      }
    });
  }

  Future<void> _submit(StoreFormControllerable notifier) async {
    final succeeded = await notifier.submit();
    if (!succeeded || widget.storeToEdit == null || !mounted) return;

    // 예약 모달 위에서 열렸어도 보이도록 앱 최상단 토스트로 알린다
    showAppToast(context, '점포 정보를 저장했습니다');
    context.pop(true);
  }

  @override
  void initState() {
    super.initState();
    final initialState = ref.read(_currentProvider);

    _scrollController = ScrollController();
    _nameController = TextEditingController(text: initialState.name);
    _memoController = TextEditingController(text: initialState.memo);
    for (final space in initialState.spaceOptions) {
      _expandedSpaceIds.add(space.id);
      _spaceNameControllers[space.id] = TextEditingController(text: space.name);
    }
    _scrollToInitialSpace();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _nameController.dispose();
    _memoController.dispose();
    for (final c in _spaceNameControllers.values) {
      c.dispose();
    }
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
          if (error is StoreUpdateConflictException) {
            showCustomAlertDialog(
              context: context,
              title: error.title,
              content: error.content,
              showCancel: false,
              onConfirmAfterPop: _reloadLatest,
            );
          } else if (error is AppException) {
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
          title: isEditMode ? '점포 수정을 취소할까요?' : '점포 등록 화면으로 돌아갈까요?',
          content: isEditMode ? '수정한 내용은 저장되지 않습니다.' : null,
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
                  ? () => _submit(notifier)
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
                          // 점포 색상·점포 메모는 멤버마다 따로 두는 값이라, 수정 때는
                          // 점포 정보와 함께 고치지 않고 점포 상세의 '내 설정'에서 고친다
                          if (!isEditMode)
                            TitleNavigationButton(
                              title: '색상',
                              content: state.color.displayName,
                              contentLeading: StoreColorDot(color: state.color),
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
                            title: '안내•주의사항',
                            onPressed: () {
                              SCRoute.storeGuide.pushChild(
                                context,
                                extra: widget.storeToEdit,
                              );
                            },
                          ),
                          if (!isEditMode)
                            MemoTextField(
                              placeholder: '메모',
                              controller: _memoController,
                              onChanged: notifier.setMemo,
                              maxLength: maxMemoCharCount,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(
                                  maxMemoCharCount,
                                ),
                              ],
                            ),
                        ],
                      ),

                      ...state.spaceOptions.asMap().entries.map((spaceEntry) {
                        final int si = spaceEntry.key;
                        final SpaceOption so = spaceEntry.value;
                        final bool isExpanded = _expandedSpaceIds.contains(
                          so.id,
                        );
                        final controller = _spaceNameControllers.putIfAbsent(
                          so.id,
                          () => TextEditingController(text: so.name),
                        );

                        return Column(
                          key: _spaceSectionKeys.putIfAbsent(
                            so.id,
                            GlobalKey.new,
                          ),
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _SpaceOptionHeader(
                              isExpanded: isExpanded,
                              showDelete: state.spaceOptions.length > 1,
                              canAdd: state.spaceOptions.length < 5,
                              nameController: controller,
                              onToggle: () => setState(() {
                                if (isExpanded) {
                                  _expandedSpaceIds.remove(so.id);
                                } else {
                                  _expandedSpaceIds.add(so.id);
                                }
                              }),
                              onNameChanged: (v) =>
                                  notifier.setSpaceOptionName(si, v),
                              onDelete: () {
                                _spaceNameControllers.remove(so.id)?.dispose();
                                setState(() => _expandedSpaceIds.remove(so.id));
                                notifier.removeSpaceOption(si);
                              },
                              onCopy: () {
                                notifier.copySpaceOption(si);
                                final newSo = ref
                                    .read(_currentProvider)
                                    .spaceOptions
                                    .last;
                                _spaceNameControllers[newSo.id] =
                                    TextEditingController(text: newSo.name);
                                setState(() => _expandedSpaceIds.add(newSo.id));
                                _scrollAfterBuild(toBottom: false);
                              },
                              onAdd: () {
                                notifier.addSpaceOption();
                                final newSo = ref
                                    .read(_currentProvider)
                                    .spaceOptions
                                    .last;
                                _spaceNameControllers[newSo.id] =
                                    TextEditingController(text: newSo.name);
                                setState(() => _expandedSpaceIds.add(newSo.id));
                                _scrollAfterBuild();
                              },
                            ),
                            ClipRect(
                              child: AnimatedSize(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeInOut,
                                alignment: Alignment.topCenter,
                                child: isExpanded
                                    ? Padding(
                                        padding: const EdgeInsets.only(top: 20),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          spacing: 20,
                                          children: [
                                            ...so.priceSetting.dayGroups
                                                .asMap()
                                                .entries
                                                .map((groupEntry) {
                                                  final int gi = groupEntry.key;
                                                  final DayGroup dg =
                                                      groupEntry.value;
                                                  return PriceSettingInputForm(
                                                    index: gi,
                                                    dayGroup: dg,
                                                    showAdd:
                                                        so
                                                            .priceSetting
                                                            .dayGroups
                                                            .length <
                                                        8,
                                                    showDelete: true,
                                                    onDelete: () => notifier
                                                        .removeDayGroup(si, gi),
                                                    onCopy: () {
                                                      notifier.copyDayGroup(
                                                        si,
                                                        gi,
                                                      );
                                                      _scrollAfterBuild(
                                                        toBottom: false,
                                                      );
                                                    },
                                                    onAdd: () {
                                                      notifier.addDayGroup(si);
                                                      _scrollAfterBuild();
                                                    },
                                                    onPressedDaySetting: () {
                                                      SCRoute.storePriceDays
                                                          .pushChild(
                                                            context,
                                                            extra: {
                                                              'store': widget
                                                                  .storeToEdit,
                                                              'spaceIndex': si,
                                                              'groupIndex': gi,
                                                            },
                                                          );
                                                    },
                                                    onPressedTimeSetting: () {
                                                      SCRoute.storePriceTime
                                                          .pushChild(
                                                            context,
                                                            extra: {
                                                              'store': widget
                                                                  .storeToEdit,
                                                              'spaceIndex': si,
                                                              'groupIndex': gi,
                                                            },
                                                          );
                                                    },
                                                  );
                                                }),
                                          ],
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ),
                          ],
                        );
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

/// 공간 옵션 헤더 (항상 표시 — 좌측 chevron + 인라인 이름 입력 + 삭제/복사/추가)
class _SpaceOptionHeader extends StatelessWidget {
  final bool isExpanded;
  final bool showDelete;
  final bool canAdd;
  final TextEditingController nameController;
  final VoidCallback onToggle;
  final ValueChanged<String> onNameChanged;
  final VoidCallback onDelete;
  final VoidCallback onCopy;
  final VoidCallback onAdd;

  const _SpaceOptionHeader({
    required this.isExpanded,
    required this.showDelete,
    required this.canAdd,
    required this.nameController,
    required this.onToggle,
    required this.onNameChanged,
    required this.onDelete,
    required this.onCopy,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: inputFormComponentHeight,
          child: Row(
            children: [
              // 접기/펼치기 chevron — 터치 범위 30×44
              SizedBox(
                width: 30,
                height: inputFormComponentHeight,
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  onPressed: onToggle,
                  child: Icon(
                    isExpanded
                        ? CupertinoIcons.chevron_down
                        : CupertinoIcons.chevron_right,
                    size: 16,
                    color: context.systemBlue,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              // 공간명 인라인 TextField — titleMedium
              Expanded(
                child: TextField(
                  controller: nameController,
                  onChanged: onNameChanged,
                  style: textTheme.titleMedium,
                  maxLength: 20,
                  maxLines: 1,
                  inputFormatters: [LengthLimitingTextInputFormatter(20)],
                  decoration: InputDecoration(
                    hintText: '공간명',
                    hintStyle: textTheme.titleMedium?.copyWith(
                      color: context.tertiaryLabel,
                      fontWeight: FontWeight.w500,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isCollapsed: true,
                    counterText: '',
                  ),
                ),
              ),
              const SizedBox(width: 4),
              // 삭제 버튼 — 터치 범위 44×44
              if (showDelete) ...[
                SizedBox(
                  width: 44,
                  height: 44,
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: onDelete,
                    child: Icon(
                      CupertinoIcons.trash,
                      size: 18,
                      color: context.systemRed,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
              ],
              // 복사 버튼 — 터치 범위 44×44
              SizedBox(
                width: 44,
                height: 44,
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: onCopy,
                  child: Icon(
                    CupertinoIcons.doc_on_doc,
                    size: 18,
                    color: context.systemBlue,
                  ),
                ),
              ),
              // 추가 버튼 — 터치 범위 44×44
              if (canAdd) ...[
                const SizedBox(width: 4),
                SizedBox(
                  width: 44,
                  height: 44,
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: onAdd,
                    child: Icon(
                      CupertinoIcons.plus,
                      size: 24,
                      color: context.systemBlue,
                    ),
                  ),
                ),
              ],
              const SizedBox(width: 4),
            ],
          ),
        ),
        // 접힌 상태에서만 하단 구분선 표시
        if (!isExpanded)
          Divider(height: 0.5, thickness: 0.5, color: context.separator),
      ],
    );
  }
}
