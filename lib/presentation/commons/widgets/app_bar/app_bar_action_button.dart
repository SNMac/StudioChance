import 'package:flutter/material.dart';

import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';

class AppBarActionButton extends StatelessWidget {
  final String label;
  final TextStyle? style;
  final VoidCallback? onPressed;

  /// true: FontWeight.normal (regular), false: FontWeight.w600 (semibold)
  final bool isRegularWeight;

  const AppBarActionButton({
    super.key,
    required this.label,
    this.style,
    this.onPressed,
    this.isRegularWeight = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final baseStyle = style ?? textTheme.titleLarge;

    final color = onPressed != null
        ? colorScheme.primary
        : context.quaternaryLabel;

    final effectiveStyle = baseStyle?.copyWith(
      color: color,
      fontWeight: isRegularWeight ? FontWeight.normal : FontWeight.w600,
    );

    return TextButton(
      onPressed: onPressed,
      child: Text(label, style: effectiveStyle),
    );
  }
}
