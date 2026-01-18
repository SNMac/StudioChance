import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:studio_chance/constants/ui_constants.dart';

class SelectionButton<T> extends StatelessWidget {
  final T value;
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;
  final Widget? leading;

  const SelectionButton({
    super.key,
    required this.value,
    required this.label,
    required this.isSelected,
    required this.onPressed,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return CupertinoButton(
      padding: EdgeInsetsDirectional.zero,
      onPressed: onPressed,
      child: Container(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: horizontalPadding),
        child: Row(
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 8)],
            Expanded(child: Text(label, style: textTheme.bodyLarge)),
            if (isSelected)
              const Icon(
                CupertinoIcons.checkmark,
                color: CupertinoColors.activeBlue,
                fontWeight: FontWeight.w600,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }
}
