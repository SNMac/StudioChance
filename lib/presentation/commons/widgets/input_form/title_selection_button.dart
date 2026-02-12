import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';

class TitleSelectionButton<T> extends StatelessWidget {
  final T value;
  final String title;
  final bool isSelected;
  final VoidCallback? onPressed;
  final Widget? leading;

  const TitleSelectionButton({
    super.key,
    required this.value,
    required this.title,
    required this.isSelected,
    required this.onPressed,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      height: inputFormComponentHeight,
      child: CupertinoButton(
        padding: EdgeInsetsDirectional.zero,
        onPressed: onPressed,
        borderRadius: BorderRadius.zero,
        child: Container(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: horizontalPadding,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 8)],
              Expanded(
                child: Text(
                  title,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.normal,
                    color: onPressed != null
                        ? context.label
                        : context.tertiaryLabel,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(
                  CupertinoIcons.checkmark,
                  fontWeight: FontWeight.w600,
                  size: 16,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
