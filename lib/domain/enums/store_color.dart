import 'dart:ui';

import 'package:json_annotation/json_annotation.dart';

@JsonEnum(alwaysCreate: true)
enum StoreColor {
  red,
  orange,
  yellow,
  green,
  blue,
  indigo,
  purple;

  String get displayName {
    switch (this) {
      case red:
        return '빨간색';
      case orange:
        return '주황색';
      case yellow:
        return '노란색';
      case green:
        return '초록색';
      case blue:
        return '파란색';
      case indigo:
        return '남색';
      case purple:
        return '보라색';
    }
  }

  Color get backgroundColor {
    switch (this) {
      case red:
        return Color(0xFFFF9E99);
      case orange:
        return Color(0xFFFFD599);
      case yellow:
        return Color(0xFFFFEB99);
      case green:
        return Color(0xFFAEEABD);
      case blue:
        return Color(0xFF99CAFF);
      case indigo:
        return Color(0xFFAEADEB);
      case purple:
        return Color(0xFFD7A9EF);
    }
  }

  Color get foregroundColor {
    switch (this) {
      case red:
        return Color(0xFFFF3B30);
      case orange:
        return Color(0xFFFF9500);
      case yellow:
        return Color(0xFFFFCC00);
      case green:
        return Color(0xFF34C759);
      case blue:
        return Color(0xFF007AFF);
      case indigo:
        return Color(0xFF5856D6);
      case purple:
        return Color(0xFFAF52DE);
    }
  }

  Color get labelColor {
    switch (this) {
      case red:
        return Color(0xFF990800);
      case orange:
        return Color(0xFF995900);
      case yellow:
        return Color(0xFF997A00);
      case green:
        return Color(0xFF207936);
      case blue:
        return Color(0xFF004999);
      case indigo:
        return Color(0xFF1F1E7B);
      case purple:
        return Color(0xFF5E1980);
    }
  }
}
