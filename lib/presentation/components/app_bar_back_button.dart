import 'package:flutter/material.dart';

class AppBarBackButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const AppBarBackButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BackButton(onPressed: onPressed, color: colorScheme.primary);
  }
}
