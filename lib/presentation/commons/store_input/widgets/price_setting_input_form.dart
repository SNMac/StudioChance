import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/domain/entities/day_group.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';
import 'package:studio_chance/presentation/commons/extensions/day_group_formatter.dart';
import 'package:studio_chance/presentation/commons/widgets/custom_alert_dialog.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/grouped_form_container.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/delete_copy_add_button_row.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/title_navigation_button.dart';

class PriceSettingInputForm extends StatelessWidget {
  final int index;
  final DayGroup dayGroup;
  final bool showAdd;
  final bool showDelete;

  final VoidCallback onDelete;
  final VoidCallback onCopy;
  final VoidCallback onAdd;
  final VoidCallback onPressedDaySetting;
  final VoidCallback onPressedTimeSetting;

  const PriceSettingInputForm({
    super.key,
    required this.index,
    required this.dayGroup,
    required this.showAdd,
    required this.showDelete,
    required this.onDelete,
    required this.onCopy,
    required this.onAdd,
    required this.onPressedDaySetting,
    required this.onPressedTimeSetting,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    void showInfoDialog() => showCustomAlertDialog(
      context: context,
      title: '요금 설정 삭제',
      content: '${dayGroup.formattedDays}에 해당하는 요금 설정을 삭제할까요?',
      isDestructive: true,
      confirmText: '삭제',
      onConfirmBeforePop: onDelete,
    );

    return GroupedFormContainer(
      header: index == 0
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
                      content: '모든 영업시간에 대해 설정해 주세요\n(최대 8개)',
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
        showAdd: showAdd,
        showCopy: showAdd,
        showDelete: showDelete,
        onPressedDelete: showInfoDialog,
        onPressedCopy: onCopy,
        onPressedAdd: onAdd,
      ),

      children: [
        TitleNavigationButton(
          title: '기준 요일',
          content: dayGroup.formattedDays,
          onPressed: onPressedDaySetting,
        ),
        TitleNavigationButton(title: '기준 시간', onPressed: onPressedTimeSetting),
      ],
    );
  }
}
