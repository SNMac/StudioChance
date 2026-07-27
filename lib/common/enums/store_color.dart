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
}
