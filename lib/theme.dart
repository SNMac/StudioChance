import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme = TextTheme(
    headlineLarge: TextStyle(
      fontSize: 24.0,
      height: 1.3,
      fontWeight: FontWeight.bold,
    ),
    headlineMedium: TextStyle(
      fontSize: 22.0,
      height: 1.3,
      fontWeight: FontWeight.bold,
    ),
    headlineSmall: TextStyle(
      fontSize: 20.0,
      height: 1.3,
      fontWeight: FontWeight.bold,
    ),
    titleLarge: TextStyle(
      fontSize: 18.0,
      height: 1.5,
      fontWeight: FontWeight.w600,
    ),
    titleMedium: TextStyle(
      fontSize: 16.0,
      height: 1.5,
      fontWeight: FontWeight.w600,
    ),
    titleSmall: TextStyle(
      fontSize: 14.0,
      height: 1.5,
      fontWeight: FontWeight.w600,
    ),
    bodyLarge: TextStyle(
      fontSize: 16.0,
      height: 1.5,
      fontWeight: FontWeight.w500,
    ),
    bodyMedium: TextStyle(
      fontSize: 14.0,
      height: 1.5,
      fontWeight: FontWeight.w500,
    ),
    bodySmall: TextStyle(
      fontSize: 12.0,
      height: 1.5,
      fontWeight: FontWeight.w500,
    ),
    labelLarge: TextStyle(
      fontSize: 14.0,
      height: 1.5,
      fontWeight: FontWeight.normal,
    ),
    labelMedium: TextStyle(
      fontSize: 12.0,
      height: 1.5,
      fontWeight: FontWeight.normal,
    ),
    labelSmall: TextStyle(
      fontSize: 10.0,
      height: 1.5,
      fontWeight: FontWeight.normal,
    ),
  );

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff005baf),
      surfaceTint: Color(0xff005eb3),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff0074db),
      onPrimaryContainer: Color(0xfffefcff),
      secondary: Color(0xff3f5f8f),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffa8c8fe),
      onSecondaryContainer: Color(0xff335382),
      tertiary: Color(0xff8a31ae),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xffa64dc9),
      onTertiaryContainer: Color(0xfffffbff),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff93000a),
      surface: Color(0xfff9f9ff),
      onSurface: Color(0xff181c23),
      onSurfaceVariant: Color(0xff404754),
      outline: Color(0xff717785),
      outlineVariant: Color(0xffc0c6d6),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2d3038),
      inversePrimary: Color(0xffa8c8ff),
      primaryFixed: Color(0xffd5e3ff),
      onPrimaryFixed: Color(0xff001b3c),
      primaryFixedDim: Color(0xffa8c8ff),
      onPrimaryFixedVariant: Color(0xff004689),
      secondaryFixed: Color(0xffd5e3ff),
      onSecondaryFixed: Color(0xff001b3c),
      secondaryFixedDim: Color(0xffa8c8fe),
      onSecondaryFixedVariant: Color(0xff264776),
      tertiaryFixed: Color(0xfff9d8ff),
      onTertiaryFixed: Color(0xff320046),
      tertiaryFixedDim: Color(0xffedb1ff),
      onTertiaryFixedVariant: Color(0xff721296),
      surfaceDim: Color(0xffd7dae4),
      surfaceBright: Color(0xfff9f9ff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff1f3fe),
      surfaceContainer: Color(0xffebedf8),
      surfaceContainerHigh: Color(0xffe5e8f2),
      surfaceContainerHighest: Color(0xffe0e2ec),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffa8c8ff),
      surfaceTint: Color(0xffa8c8ff),
      onPrimary: Color(0xff003061),
      primaryContainer: Color(0xff3491ff),
      onPrimaryContainer: Color(0xff002147),
      secondary: Color(0xffa8c8fe),
      onSecondary: Color(0xff07305e),
      secondaryContainer: Color(0xff264776),
      onSecondaryContainer: Color(0xff97b6ec),
      tertiary: Color(0xffedb1ff),
      onTertiary: Color(0xff530070),
      tertiaryContainer: Color(0xffc56ae8),
      onTertiaryContainer: Color(0xff3b0052),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xff10131a),
      onSurface: Color(0xffe0e2ec),
      onSurfaceVariant: Color(0xffc0c6d6),
      outline: Color(0xff8a919f),
      outlineVariant: Color(0xff404754),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe0e2ec),
      inversePrimary: Color(0xff005eb3),
      primaryFixed: Color(0xffd5e3ff),
      onPrimaryFixed: Color(0xff001b3c),
      primaryFixedDim: Color(0xffa8c8ff),
      onPrimaryFixedVariant: Color(0xff004689),
      secondaryFixed: Color(0xffd5e3ff),
      onSecondaryFixed: Color(0xff001b3c),
      secondaryFixedDim: Color(0xffa8c8fe),
      onSecondaryFixedVariant: Color(0xff264776),
      tertiaryFixed: Color(0xfff9d8ff),
      onTertiaryFixed: Color(0xff320046),
      tertiaryFixedDim: Color(0xffedb1ff),
      onTertiaryFixedVariant: Color(0xff721296),
      surfaceDim: Color(0xff10131a),
      surfaceBright: Color(0xff353941),
      surfaceContainerLowest: Color(0xff0a0e15),
      surfaceContainerLow: Color(0xff181c23),
      surfaceContainer: Color(0xff1c2027),
      surfaceContainerHigh: Color(0xff262a32),
      surfaceContainerHighest: Color(0xff31353d),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  ThemeData theme(ColorScheme colorScheme) {
    final isDark = colorScheme.brightness == Brightness.dark;

    final appBarBackgroundColor = isDark
        ? CupertinoColors.tertiarySystemBackground.darkColor
        : CupertinoColors.tertiarySystemBackground;

    final scaffoldBackgroundColor = isDark
        ? CupertinoColors.systemGroupedBackground.darkColor
        : CupertinoColors.systemGroupedBackground;

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Pretendard',
      brightness: colorScheme.brightness,
      colorScheme: colorScheme,
      textTheme: textTheme.apply(
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: appBarBackgroundColor,
        shape: Border(
          bottom: BorderSide(color: colorScheme.outlineVariant, width: 0.33),
        ),
      ),
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedIconTheme: IconThemeData(color: colorScheme.primary),
        unselectedIconTheme: IconThemeData(color: colorScheme.outline),
      ),
    );
  }

  List<ExtendedColor> get extendedColors => [];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}

extension PercentageLetterSpacing on TextStyle {
  TextStyle withLetterSpacing(double percentage) {
    double letterSpacing = double.parse(
      ((percentage / 100) * fontSize!).toStringAsFixed(2),
    );
    return copyWith(letterSpacing: letterSpacing);
  }
}
