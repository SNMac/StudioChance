import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';

class DeleteCopyAddButtonRow extends StatelessWidget {
  final bool showDelete;
  final bool showCopy;
  final bool showAdd;
  final VoidCallback? onPressedDelete;
  final VoidCallback? onPressedCopy;
  final VoidCallback? onPressedAdd;

  const DeleteCopyAddButtonRow({
    super.key,
    this.showDelete = true,
    this.showCopy = true,
    this.showAdd = true,
    this.onPressedAdd,
    this.onPressedCopy,
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
          if (showCopy)
            Expanded(
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: onPressedCopy,
                child: Text(
                  '복사',
                  style: textTheme.titleMedium?.copyWith(
                    color: context.systemBlue,
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
