import 'package:flutter/material.dart';

class SafeAreaWithPadding extends StatelessWidget {
  final Widget? child;
  final EdgeInsets padding;

  const SafeAreaWithPadding({
    super.key,
    this.child,
    this.padding = const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(padding: padding, child: child),
    );
  }
}
