import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:studio_chance/constants/ui_constants.dart';

class InputFormBodyButton extends StatelessWidget {
  final String placeholder;
  final String? title;
  final String? description;
  final VoidCallback onPressed;

  const InputFormBodyButton({
    super.key,
    required this.placeholder,
    this.title,
    this.description,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final hasContent = title != null || description != null;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 48),
      child: CupertinoButton(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        alignment: Alignment.centerLeft,
        onPressed: onPressed,
        child: hasContent
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                spacing: 4,
                children: [
                  if (title != null) Text(title!, style: textTheme.bodyLarge),
                  if (description != null)
                    Text(
                      description!,
                      style: textTheme.bodyMedium?.copyWith(
                        color: CupertinoDynamicColor.resolve(
                          CupertinoColors.secondaryLabel,
                          context,
                        ),
                      ),
                    ),
                ],
              )
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
