import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RoleSelectionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const RoleSelectionButton({super.key, required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return CupertinoButton.filled(
      color: Theme.of(context).colorScheme.primaryContainer,
      onPressed: onPressed,
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}
