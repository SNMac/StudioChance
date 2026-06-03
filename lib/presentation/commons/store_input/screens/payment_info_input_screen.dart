import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/domain/entities/store.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';
import 'package:studio_chance/presentation/commons/store_input/controllers/states/store_form_state.dart';
import 'package:studio_chance/presentation/commons/store_input/controllers/store_creation_controller.dart';
import 'package:studio_chance/presentation/commons/store_input/controllers/store_form_controllerable.dart';
import 'package:studio_chance/presentation/commons/store_input/controllers/store_update_controller.dart';
import 'package:studio_chance/presentation/commons/widgets/app_bar/app_bar_action_button.dart';
import 'package:studio_chance/presentation/commons/widgets/app_bar/custom_app_bar.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/grouped_form_container.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/text_action_button.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/title_text_field.dart';
import 'package:studio_chance/presentation/commons/widgets/safe_area_with_padding.dart';
import 'package:studio_chance/router/router_path.dart';

/// 0(설정 안함), 5분 단위 5~55분, 1시간 단위 1~24시간
const List<int> _deadlineOptions = [
  0,
  5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55,
  60, 120, 180, 240, 300, 360, 420, 480, 540, 600,
  660, 720, 780, 840, 900, 960, 1020, 1080, 1140, 1200,
  1260, 1320, 1380, 1440,
];

String _formatDuration(int minutes) {
  if (minutes == 0) return '설정 안함';
  if (minutes < 60) return '$minutes분';
  final hours = minutes ~/ 60;
  final remaining = minutes % 60;
  if (remaining == 0) return '$hours시간';
  return '$hours시간 $remaining분';
}

class PaymentInfoInputScreen extends ConsumerStatefulWidget {
  const PaymentInfoInputScreen({super.key});

  @override
  ConsumerState<PaymentInfoInputScreen> createState() =>
      _PaymentInfoInputScreenState();
}

class _PaymentInfoInputScreenState
    extends ConsumerState<PaymentInfoInputScreen> {
  late final TextEditingController _bankNameController;
  late final TextEditingController _bankAccountNumberController;
  late final TextEditingController _bankAccountHolderController;
  late FixedExtentScrollController _deadlineScrollController;

  int? _selectedMinutes;
  bool _isDeadlinePickerOpen = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _bankNameController = TextEditingController();
    _bankAccountNumberController = TextEditingController();
    _bankAccountHolderController = TextEditingController();
    _deadlineScrollController = FixedExtentScrollController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialized) {
      final storeToEdit = GoRouterState.of(context).extra as Store?;

      StoreFormState formState;
      if (storeToEdit != null) {
        formState = ref.read(storeUpdateControllerProvider(storeToEdit));
      } else {
        formState = ref.read(storeCreationControllerProvider);
      }

      _bankNameController.text = formState.bankName;
      _bankAccountNumberController.text = formState.bankAccountNumber;
      _bankAccountHolderController.text = formState.bankAccountHolder;

      // null(미설정)이면 0("설정 안함")을 기본값으로 사용
      final initialMinutes = formState.paymentDeadlineMinutes ?? 0;
      _selectedMinutes = initialMinutes;
      final index = _deadlineOptions.indexOf(initialMinutes);
      if (index != -1) {
        _deadlineScrollController.dispose();
        _deadlineScrollController =
            FixedExtentScrollController(initialItem: index);
      }

      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _bankNameController.dispose();
    _bankAccountNumberController.dispose();
    _bankAccountHolderController.dispose();
    _deadlineScrollController.dispose();
    super.dispose();
  }

  void _save(StoreFormControllerable notifier) {
    notifier.setBankName(_bankNameController.text);
    notifier.setBankAccountNumber(_bankAccountNumberController.text);
    notifier.setBankAccountHolder(_bankAccountHolderController.text);
    final minutes = _selectedMinutes;
    notifier.setPaymentDeadlineMinutes(
      (minutes == null || minutes == 0) ? null : minutes,
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final storeToEdit = GoRouterState.of(context).extra as Store?;

    final StoreFormControllerable notifier;
    if (storeToEdit != null) {
      notifier =
          ref.read(storeUpdateControllerProvider(storeToEdit).notifier);
    } else {
      notifier = ref.read(storeCreationControllerProvider.notifier);
    }

    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: CustomAppBar(
        title: '입금 정보',
        actions: [
          AppBarActionButton(
            label: '완료',
            onPressed: () => _save(notifier),
          ),
        ],
      ),
      body: SafeAreaWithPadding(
        child: SingleChildScrollView(
          child: Column(
            spacing: 20,
            children: [
            GroupedFormContainer(
              footer: Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: 8,
                  top: 6,
                ),
                child: Text(
                  '예약 등록 시간 기준으로 설정해주세요',
                  style: textTheme.labelMedium?.copyWith(
                    color: context.secondaryLabel,
                  ),
                ),
              ),
              children: [
                TitleTextField(
                  title: '은행',
                  controller: _bankNameController,
                  returnButtonType: TextInputAction.next,
                ),
                TitleTextField(
                  title: '계좌번호',
                  controller: _bankAccountNumberController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  returnButtonType: TextInputAction.next,
                ),
                TitleTextField(
                  title: '예금주',
                  controller: _bankAccountHolderController,
                  returnButtonType: TextInputAction.done,
                ),
                _DeadlinePickerRow(
                  selectedMinutes: _selectedMinutes,
                  isOpen: _isDeadlinePickerOpen,
                  scrollController: _deadlineScrollController,
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    setState(() {
                      _isDeadlinePickerOpen = !_isDeadlinePickerOpen;
                      if (_isDeadlinePickerOpen && _selectedMinutes == null) {
                        _selectedMinutes = _deadlineOptions.first;
                      }
                    });
                  },
                  onSelectedItemChanged: (index) {
                    setState(() {
                      _selectedMinutes = _deadlineOptions[index];
                    });
                  },
                ),
              ],
            ),
            GroupedFormContainer(
              children: [
                TextActionButton(
                  title: '입금 안내문',
                  onPressed: () {
                    // 현재 입력값을 폼 컨트롤러에 임시 반영 (pop 없이)
                    notifier.setBankName(_bankNameController.text);
                    notifier.setBankAccountNumber(
                      _bankAccountNumberController.text,
                    );
                    notifier.setBankAccountHolder(
                      _bankAccountHolderController.text,
                    );
                    final m = _selectedMinutes;
                    notifier.setPaymentDeadlineMinutes(
                      (m == null || m == 0) ? null : m,
                    );
                    // storeToEdit을 전달해 어느 폼 컨트롤러를 읽을지 결정
                    SCRoute.paymentInstruction.pushChild(
                      context,
                      extra: storeToEdit,
                    );
                  },
                ),
              ],
            ),
          ],
          ),
        ),
      ),
    );
  }
}

class _DeadlinePickerRow extends StatelessWidget {
  const _DeadlinePickerRow({
    required this.selectedMinutes,
    required this.isOpen,
    required this.scrollController,
    required this.onPressed,
    required this.onSelectedItemChanged,
  });

  final int? selectedMinutes;
  final bool isOpen;
  final FixedExtentScrollController scrollController;
  final VoidCallback onPressed;
  final ValueChanged<int> onSelectedItemChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    const double pickerHeight = 200.0;
    const double dividerHeight = 1.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: inputFormComponentHeight,
          child: CupertinoButton(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: horizontalPadding,
            ),
            onPressed: onPressed,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('입금 마감 기한', style: textTheme.bodyLarge),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: context.tertiarySystemFill,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    selectedMinutes != null
                        ? _formatDuration(selectedMinutes!)
                        : '선택',
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.normal,
                      color: isOpen
                          ? context.systemBlue
                          : (selectedMinutes != null
                                ? context.label
                                : context.tertiaryLabel),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        ClipRect(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: isOpen ? (pickerHeight + dividerHeight) : 0,
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                children: [
                  Divider(
                    height: dividerHeight,
                    thickness: 0.5,
                    color: context.separator,
                  ),
                  SizedBox(
                    height: pickerHeight,
                    child: CupertinoPicker(
                      scrollController: scrollController,
                      itemExtent: 40,
                      onSelectedItemChanged: onSelectedItemChanged,
                      children: [
                        for (final minutes in _deadlineOptions)
                          Center(
                            child: Text(
                              _formatDuration(minutes),
                              style: textTheme.bodyLarge,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
