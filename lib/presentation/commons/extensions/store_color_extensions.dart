import 'package:studio_chance/common/enums/store_color.dart';

extension StoreColorPalette on StoreColor {
  int get backgroundColorValue => switch (this) {
    StoreColor.red => 0xFFFF9E99,
    StoreColor.orange => 0xFFFFD599,
    StoreColor.yellow => 0xFFFFEB99,
    StoreColor.green => 0xFFAEEABD,
    StoreColor.blue => 0xFF99CAFF,
    StoreColor.indigo => 0xFFAEADEB,
    StoreColor.purple => 0xFFD7A9EF,
  };

  int get foregroundColorValue => switch (this) {
    StoreColor.red => 0xFFFF3B30,
    StoreColor.orange => 0xFFFF9500,
    StoreColor.yellow => 0xFFFFCC00,
    StoreColor.green => 0xFF34C759,
    StoreColor.blue => 0xFF007AFF,
    StoreColor.indigo => 0xFF5856D6,
    StoreColor.purple => 0xFFAF52DE,
  };

  int get labelColorValue => switch (this) {
    StoreColor.red => 0xFF990800,
    StoreColor.orange => 0xFF995900,
    StoreColor.yellow => 0xFF997A00,
    StoreColor.green => 0xFF207936,
    StoreColor.blue => 0xFF004999,
    StoreColor.indigo => 0xFF1F1E7B,
    StoreColor.purple => 0xFF5E1980,
  };
}
