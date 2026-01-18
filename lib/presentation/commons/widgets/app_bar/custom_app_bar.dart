import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:studio_chance/presentation/commons/widgets/app_bar/app_bar_back_button.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;

  const CustomAppBar({
    super.key,
    required this.title,
    this.leading = const AppBarNaviBackButton(),
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      surfaceTintColor: Platform.isIOS ? Colors.transparent : null,
      shadowColor: Platform.isIOS ? CupertinoColors.darkBackgroundGray : null,
      scrolledUnderElevation: Platform.isIOS ? .1 : null,
      toolbarHeight: Platform.isIOS ? 44 : null,
      centerTitle: true,
      title: Text(title),
      leading: leading,
      actions: actions,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(Platform.isIOS ? 44.0 : kToolbarHeight);
}
