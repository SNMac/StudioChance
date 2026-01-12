import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:studio_chance/constants/ui_constants.dart';

class GroupedFormContainer extends StatelessWidget {
  final Widget? header;
  final Widget? footer;
  final List<Widget> children;

  const GroupedFormContainer({
    super.key,
    required this.children,
    this.header,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 8,
      children: [
        if (header != null) header!,
        Container(
          decoration: BoxDecoration(
            color: CupertinoDynamicColor.resolve(
              CupertinoColors.secondarySystemGroupedBackground,
              context,
            ),
            borderRadius: BorderRadius.circular(formBorderRadius),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(formBorderRadius),
            child: Column(
              children: [
                for (int i = 0; i < children.length; i++) ...[
                  children[i],
                  if (i != children.length - 1)
                    Divider(
                      height: 1,
                      thickness: 0.5,
                      color: CupertinoDynamicColor.resolve(
                        CupertinoColors.separator,
                        context,
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
        if (footer != null) footer!,
      ],
    );
  }
}
