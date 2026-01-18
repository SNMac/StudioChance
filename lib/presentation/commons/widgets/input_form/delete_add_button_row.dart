import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';

class DeleteAddButtonRow extends StatelessWidget {
  final bool showAdd;
  final bool showDelete;
  final VoidCallback? onPressedDelete;
  final VoidCallback? onPressedAdd;

  const DeleteAddButtonRow({
    super.key,
    this.showAdd = true,
    this.showDelete = true,
    this.onPressedAdd,
    this.onPressedDelete,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      height: inputFormComponentHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showDelete)
            Expanded(
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: onPressedDelete,
                child: Text(
                  '삭제',
                  style: textTheme.titleMedium?.copyWith(
                    color: context.systemRed,
                  ),
                ),
              ),
            ),
          if (showAdd)
            Expanded(
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: onPressedAdd,
                child: Text(
                  '추가',
                  style: textTheme.titleMedium?.copyWith(
                    color: context.systemBlue,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
