import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:studio_chance/constants/ui_constants.dart';

class BodyButton extends StatelessWidget {
  final String placeholder;
  final String? content;
  final VoidCallback onPressed;

  const BodyButton({
    super.key,
    required this.placeholder,
    this.content,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: inputFormComponentHeight),
      child: CupertinoButton(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: horizontalPadding),
        alignment: Alignment.centerLeft,
        onPressed: onPressed,
        child: content != null
            ? Text(content!, style: textTheme.bodyLarge)
            : Text(
                placeholder,
                style: textTheme.bodyLarge?.copyWith(
                  color: CupertinoDynamicColor.resolve(
                    CupertinoColors.tertiaryLabel,
                    context,
                  ),
                ),
              ),
      ),
    );
  }
}
