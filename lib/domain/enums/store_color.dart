import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum StoreColor {
  @JsonValue('RED')
  red,
  @JsonValue('ORANGE')
  orange,
  @JsonValue('YELLOW')
  yellow,
  @JsonValue('GREEN')
  green,
  @JsonValue('BLUE')
  blue,
  @JsonValue('INDIGO')
  indigo,
  @JsonValue('PURPLE')
  purple;

  String get displayName => switch (this) {
    StoreColor.red => '빨간색',
    StoreColor.orange => '주황색',
    StoreColor.yellow => '노란색',
    StoreColor.green => '초록색',
    StoreColor.blue => '파란색',
    StoreColor.indigo => '남색',
    StoreColor.purple => '보라색',
  };

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
