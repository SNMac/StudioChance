import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';

class AppBarNaviBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isEnabled;

  const AppBarNaviBackButton({
    super.key,
    this.onPressed,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (!isEnabled) {
      return IconButton(icon: const BackButtonIcon(), onPressed: null);
    }
    return BackButton(onPressed: onPressed, color: colorScheme.primary);
  }
}

class AppBarModalBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isEnabled;

  const AppBarModalBackButton({
    super.key,
    this.onPressed,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!isEnabled) {
      return IconButton(
        icon: const Icon(CupertinoIcons.xmark),
        color: context.quaternaryLabel,
        onPressed: null,
      );
    }
    return IconButton(
      icon: const Icon(CupertinoIcons.xmark),
      color: context.label,
      onPressed: onPressed,
    );
  }
}
