import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppBarNaviBackButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const AppBarNaviBackButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return BackButton(onPressed: onPressed, color: colorScheme.primary);
  }
}

class AppBarModalBackButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const AppBarModalBackButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(CupertinoIcons.xmark),
      color: CupertinoDynamicColor.resolve(CupertinoColors.label, context),
      onPressed: onPressed,
    );
  }
}
