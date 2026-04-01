import 'package:flutter/material.dart';

import 'package:studio_chance/constants/ui_constants.dart';

class SafeAreaWithPadding extends StatelessWidget {
  final Widget? child;
  final EdgeInsetsDirectional padding;
  final bool top;

  const SafeAreaWithPadding({
    super.key,
    this.child,
    this.padding = const EdgeInsetsDirectional.symmetric(
      vertical: verticalPadding,
      horizontal: horizontalPadding,
    ),
    this.top = true,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: top,
      child: Padding(padding: padding, child: child),
    );
  }
}
