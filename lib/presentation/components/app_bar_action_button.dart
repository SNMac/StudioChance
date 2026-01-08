import 'package:flutter/material.dart';

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
    final baseStyle = style ?? Theme.of(context).textTheme.titleLarge;

    final color = onPressed != null
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).disabledColor;

    final effectiveStyle = baseStyle?.copyWith(color: color);

    return TextButton(
      onPressed: onPressed,
      child: Text(label, style: effectiveStyle),
    );
  }
}
