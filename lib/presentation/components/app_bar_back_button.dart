import 'package:flutter/material.dart';

class AppBarBackButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const AppBarBackButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return BackButton(
      onPressed: onPressed,
      color: Theme.of(context).colorScheme.primary,
    );
  }
}
