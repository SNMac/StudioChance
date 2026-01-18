import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:studio_chance/domain/entities/day_group.dart';
import 'package:studio_chance/presentation/commons/extensions/day_group_formatter.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/grouped_form_container.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/delete_add_button_row.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/title_navigation_button.dart';

class PriceSettingItem extends StatelessWidget {
  final int index;
  final DayGroup dayGroup;
  final bool isLast;

  final VoidCallback onDelete;
  final VoidCallback onAdd;
  final VoidCallback onPressedDaySetting;
  final VoidCallback onPressedTimeSetting;

  const PriceSettingItem({
    super.key,
    required this.index,
    required this.dayGroup,
    required this.isLast,
    required this.onDelete,
    required this.onAdd,
    required this.onPressedDaySetting,
    required this.onPressedTimeSetting,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GroupedFormContainer(
      header: index == 0
          ? Padding(
              padding: const EdgeInsetsDirectional.only(start: 16),
              child: Text(
                '요금 설정 - 모든 영업 시간에 대해 설정해주세요',
                style: textTheme.labelMedium?.copyWith(
                  color: CupertinoDynamicColor.resolve(
                    CupertinoColors.secondaryLabel,
                    context,
                  ),
                ),
              ),
            )
          : null,

      footer: DeleteAddButtonRow(
        isLast: isLast,
        onPressedDelete: onDelete,
        onPressedAdd: onAdd,
      ),

      children: [
        TitleNavigationButton(
          title: '기준 요일',
          content: dayGroup.formattedDays,
          onPressed: onPressedDaySetting,
        ),
        TitleNavigationButton(
          title: '기준 시간',
          onPressed: onPressedTimeSetting,
        ),
      ],
    );
  }
}
