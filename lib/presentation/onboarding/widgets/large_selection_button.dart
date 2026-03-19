import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LargeSelectionButton extends StatelessWidget {
  final String title;
  final String? description;
  final bool isSelected;
  final bool isNavigation;
  final VoidCallback? onPressed;

  const LargeSelectionButton({
    super.key,
    required this.title,
    this.description,
    this.isSelected = false,
    this.isNavigation = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final backgroundColor = isSelected
        ? colorScheme.primary
        : colorScheme.primaryContainer;

    final labelColor = isSelected
        ? colorScheme.onPrimary
        : colorScheme.onPrimaryContainer;

    return CupertinoButton(
      color: backgroundColor,
      onPressed: onPressed,
      child: SizedBox(
        width: double.infinity,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              spacing: 4,
              children: [
                Text(
                  title,
                  style: textTheme.titleLarge?.copyWith(color: labelColor),
                ),
                if (description != null)
                  Text(
                    description!,
                    style: textTheme.labelLarge?.copyWith(color: labelColor),
                  ),
              ],
            ),
            if (isNavigation)
              Positioned(
                right: 0,
                child: Icon(CupertinoIcons.chevron_forward, color: labelColor),
              ),
          ],
        ),
      ),
    );
  }
}
