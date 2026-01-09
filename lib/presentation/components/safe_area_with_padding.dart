import 'package:flutter/material.dart';

class SafeAreaWithPadding extends StatelessWidget {
  final Widget? child;

  const SafeAreaWithPadding({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        child: child,
      ),
    );
  }
}
