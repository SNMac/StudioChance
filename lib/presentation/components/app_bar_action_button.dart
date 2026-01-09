import 'package:flutter/cupertino.dart';
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final baseStyle = style ?? textTheme.titleLarge;

    final color = onPressed != null
        ? colorScheme.primary
        : CupertinoDynamicColor.resolve(CupertinoColors.quaternaryLabel, context);

    final effectiveStyle = baseStyle?.copyWith(color: color);

    return TextButton(
      onPressed: onPressed,
      child: Text(label, style: effectiveStyle),
    );
  }
}
