import 'package:flutter/cupertino.dart';

extension ContextColors on BuildContext {
  Color get black => CupertinoDynamicColor.resolve(CupertinoColors.black, this);

  Color get white => CupertinoDynamicColor.resolve(CupertinoColors.white, this);

  Color get systemRed =>
      CupertinoDynamicColor.resolve(CupertinoColors.systemRed, this);

  Color get systemGreen =>
      CupertinoDynamicColor.resolve(CupertinoColors.systemGreen, this);

  Color get systemBlue =>
      CupertinoDynamicColor.resolve(CupertinoColors.systemBlue, this);

  Color get label => CupertinoDynamicColor.resolve(CupertinoColors.label, this);

  Color get secondaryLabel =>
      CupertinoDynamicColor.resolve(CupertinoColors.secondaryLabel, this);

  Color get tertiaryLabel =>
      CupertinoDynamicColor.resolve(CupertinoColors.tertiaryLabel, this);

  Color get quaternaryLabel =>
      CupertinoDynamicColor.resolve(CupertinoColors.quaternaryLabel, this);

  Color get tertiarySystemFill =>
      CupertinoDynamicColor.resolve(CupertinoColors.tertiarySystemFill, this);

  Color get quaternarySystemFill =>
      CupertinoDynamicColor.resolve(CupertinoColors.quaternarySystemFill, this);

  Color get separator =>
      CupertinoDynamicColor.resolve(CupertinoColors.separator, this);

  Color get placeholderText =>
      CupertinoDynamicColor.resolve(CupertinoColors.placeholderText, this);

  Color get systemBackground =>
      CupertinoDynamicColor.resolve(CupertinoColors.systemBackground, this);

  Color get tertiarySystemBackground => CupertinoDynamicColor.resolve(
    CupertinoColors.tertiarySystemBackground,
    this,
  );

  Color get systemGroupedBackground => CupertinoDynamicColor.resolve(
    CupertinoColors.systemGroupedBackground,
    this,
  );

  Color get secondarySystemGroupedBackground => CupertinoDynamicColor.resolve(
    CupertinoColors.secondarySystemGroupedBackground,
    this,
  );

  Color get tertiarySystemGroupedBackground => CupertinoDynamicColor.resolve(
    CupertinoColors.tertiarySystemGroupedBackground,
    this,
  );

  Color get darkBackgroundGray =>
      CupertinoDynamicColor.resolve(CupertinoColors.darkBackgroundGray, this);

  Color get transparent =>
      CupertinoDynamicColor.resolve(CupertinoColors.transparent, this);
}
