import 'package:flutter/material.dart';

import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';

class AppBarActionButton extends StatelessWidget {
  final String label;
  final TextStyle? style;
  final VoidCallback? onPressed;

  const AppBarActionButton({
    super.key,
    required this.label,
    this.style,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final baseStyle = style ?? textTheme.titleLarge;

    final color = onPressed != null
        ? colorScheme.primary
        : context.quaternaryLabel;

    final effectiveStyle = baseStyle?.copyWith(color: color);

    return TextButton(
      onPressed: onPressed,
      child: Text(label, style: effectiveStyle),
    );
  }
}
