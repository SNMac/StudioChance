import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GroupedFormContainer extends StatelessWidget {
  final List<Widget> children;

  const GroupedFormContainer({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: CupertinoDynamicColor.resolve(
          CupertinoColors.secondarySystemGroupedBackground,
          context,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
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
    );
  }
}
