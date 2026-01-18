import 'package:flutter/material.dart';

import 'package:studio_chance/constants/ui_constants.dart';

class SafeAreaWithPadding extends StatelessWidget {
  final Widget? child;
  final EdgeInsetsDirectional padding;

  const SafeAreaWithPadding({
    super.key,
    this.child,
    this.padding = const EdgeInsetsDirectional.symmetric(
      vertical: verticalPadding,
      horizontal: horizontalPadding,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(padding: padding, child: child),
    );
  }
}
