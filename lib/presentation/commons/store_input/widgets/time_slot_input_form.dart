import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/domain/entities/time_slot.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';
import 'package:studio_chance/presentation/commons/extensions/time_formatter.dart';
import 'package:studio_chance/presentation/commons/widgets/custom_alert_dialog.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/delete_copy_add_button_row.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/grouped_form_container.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/title_date_time_button.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/title_switch_button.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/title_text_field.dart';

enum _ActivePicker { none, start, end }

class TimeSlotInputForm extends StatefulWidget {
  final int index;
  final TimeSlot timeSlot;
  final bool showAdd;
  final bool showDelete;

  final VoidCallback onDelete;
  final VoidCallback onCopy;
  final VoidCallback onAdd;

  /// 값이 변경될 때마다 부모에게 알리는 콜백
  final ValueChanged<TimeSlot> onChanged;

  const TimeSlotInputForm({
    super.key,
    required this.index,
    required this.timeSlot,
    required this.showAdd,
    required this.showDelete,
    required this.onDelete,
    required this.onCopy,
    required this.onAdd,
    required this.onChanged,
  });

  @override
  State<TimeSlotInputForm> createState() => _TimeSlotInputFormState();
}

class _TimeSlotInputFormState extends State<TimeSlotInputForm>
    with TickerProviderStateMixin {
  late final TextEditingController _priceController;

  _ActivePicker _activePicker = _ActivePicker.none;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(
      text: widget.timeSlot.price == -1 ? '' : widget.timeSlot.price.toString(),
    );

    _priceController.addListener(_onPriceChanged);
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  /// 요금 텍스트 변경 시 호출
  void _onPriceChanged() {
    final priceText = _priceController.text;
    final int price = int.tryParse(priceText) ?? -1;

    if (widget.timeSlot.price != price) {
      widget.onChanged(widget.timeSlot.copyWith(price: price));
    }
  }

  /// 피커 토글 로직
  void _togglePicker(_ActivePicker target) {
    setState(() {
      if (_activePicker == target) {
        _activePicker = _ActivePicker.none;
      } else {
        _activePicker = target;
      }
    });
  }

  DateTime _getInitialDate(int minutes) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, minutes ~/ 60, minutes % 60);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    void showDeleteDialog() => showCustomAlertDialog(
      context: context,
      title: '시간별 요금 설정 삭제',
      content:
          '${widget.timeSlot.startTime.formattedTime} ~ ${widget.timeSlot.endTime.formattedTime}에 해당하는 요금 설정을 삭제할까요?',
      isDestructive: true,
      confirmText: '삭제',
      onConfirmBeforePop: widget.onDelete,
    );

    return GroupedFormContainer(
      header: widget.index == 0
          ? Padding(
              padding: const EdgeInsetsDirectional.only(
                start: horizontalPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CupertinoButton(
                    alignment: Alignment.centerLeft,
                    minimumSize: Size.zero,
                    padding: EdgeInsets.zero,
                    onPressed: () => showCustomAlertDialog(
                      context: context,
                      title: '요일별 요금 설정',
                      content: '모든 영업시간에 대해 설정해 주세요\n(최대 23개)',
                      showCancel: false,
                    ),
                    child: Row(
                      spacing: 4,
                      children: [
                        Icon(
                          CupertinoIcons.info,
                          size: 12,
                          color: context.secondaryLabel,
                        ),
                        Text(
                          '요일별 요금 설정',
                          style: textTheme.labelMedium?.copyWith(
                            color: context.secondaryLabel,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            )
          : null,

      footer: DeleteCopyAddButtonRow(
        showAdd: widget.showAdd,
        showCopy: widget.showAdd,
        showDelete: widget.showDelete,
        onPressedDelete: showDeleteDialog,
        onPressedCopy: widget.onCopy,
        onPressedAdd: widget.onAdd,
      ),

      children: [
        TitleSwitchButton(
          title: '하루종일',
          value: widget.timeSlot.isAllDay,
          onChanged: (val) {
            widget.onChanged(widget.timeSlot.copyWith(isAllDay: val));
          },
        ),
        if (!widget.timeSlot.isAllDay) ...[
          TitleDateTimeButton(
            title: '기준 시작 시간',
            content: widget.timeSlot.startTime.formattedTime,
            isOpen: _activePicker == _ActivePicker.start,
            onPressed: () => _togglePicker(_ActivePicker.start),

            mode: CupertinoDatePickerMode.time,
            initialDateTime: _getInitialDate(widget.timeSlot.startTime),
            onDateTimeChanged: (newDate) {
              final int newMinutes = newDate.hour * 60 + newDate.minute;
              widget.onChanged(widget.timeSlot.copyWith(startTime: newMinutes));
            },
          ),

          TitleDateTimeButton(
            title: '기준 끝 시간',
            content: widget.timeSlot.endTime.formattedTime,
            isOpen: _activePicker == _ActivePicker.end,
            onPressed: () => _togglePicker(_ActivePicker.end),

            mode: CupertinoDatePickerMode.time,
            initialDateTime: _getInitialDate(widget.timeSlot.endTime),
            onDateTimeChanged: (newDate) {
              final int newMinutes = newDate.hour * 60 + newDate.minute;
              widget.onChanged(widget.timeSlot.copyWith(endTime: newMinutes));
            },
          ),
        ],

        TitleTextField(
          title: '요금',
          controller: _priceController,
          placeholder: '예: 7000',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        TitleSwitchButton(
          title: '시간당 부과',
          value: widget.timeSlot.isHourly,
          onChanged: (val) {
            widget.onChanged(widget.timeSlot.copyWith(isHourly: val));
          },
        ),
        TitleSwitchButton(
          title: '인원당 부과',
          value: widget.timeSlot.isPerPerson,
          onChanged: (val) {
            widget.onChanged(widget.timeSlot.copyWith(isPerPerson: val));
          },
        ),
      ],
    );
  }
}
