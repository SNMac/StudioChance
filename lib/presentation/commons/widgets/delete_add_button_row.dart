import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DeleteAddButtonRow extends StatelessWidget {
  final bool isLast;
  final VoidCallback? onPressedDelete;
  final VoidCallback? onPressedAdd;

  const DeleteAddButtonRow({
    super.key,
    this.isLast = true,
    this.onPressedAdd,
    this.onPressedDelete,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      height: 48,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: onPressedDelete,
              child: Text(
                '삭제',
                style: textTheme.titleMedium?.copyWith(
                  color: CupertinoDynamicColor.resolve(
                    CupertinoColors.destructiveRed,
                    context,
                  ),
                ),
              ),
            ),
          ),
          if (isLast)
            Expanded(
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: onPressedAdd,
                child: Text(
                  '추가',
                  style: textTheme.titleMedium?.copyWith(
                    color: CupertinoDynamicColor.resolve(
                      CupertinoColors.systemBlue,
                      context,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
