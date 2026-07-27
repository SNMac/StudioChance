import 'package:flutter_test/flutter_test.dart';
import 'package:studio_chance/common/enums/store_color.dart';
import 'package:studio_chance/presentation/commons/extensions/store_color_extensions.dart';

void main() {
  group('StoreColorPalette', () {
    test('red의 배경/전경/라벨 색상값', () {
      expect(StoreColor.red.backgroundColorValue, 0xFFFF9E99);
      expect(StoreColor.red.foregroundColorValue, 0xFFFF3B30);
      expect(StoreColor.red.labelColorValue, 0xFF990800);
    });

    test('blue의 배경/전경/라벨 색상값', () {
      expect(StoreColor.blue.backgroundColorValue, 0xFF99CAFF);
      expect(StoreColor.blue.foregroundColorValue, 0xFF007AFF);
      expect(StoreColor.blue.labelColorValue, 0xFF004999);
    });
  });
}
