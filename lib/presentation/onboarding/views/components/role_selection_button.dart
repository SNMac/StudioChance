import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RoleSelectionButton extends StatelessWidget {
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback? onPressed;

  const RoleSelectionButton({
    super.key,
    required this.title,
    required this.description,
    this.isSelected = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final backgroundColor = isSelected
        ? colorScheme.primary
        : colorScheme.primaryContainer;

    final titleColor = isSelected
        ? colorScheme.onPrimary
        : colorScheme.onPrimaryContainer;

    final descriptionColor = isSelected
        ? colorScheme.onPrimary
        : colorScheme.onPrimaryContainer;

    return CupertinoButton(
      color: backgroundColor,
      onPressed: onPressed,
      child: Column(
        spacing: 4,
        children: [
          Text(title, style: textTheme.titleLarge?.copyWith(color: titleColor)),
          Text(
            description,
            style: textTheme.labelLarge?.copyWith(color: descriptionColor),
          ),
        ],
      ),
    );
  }
}
