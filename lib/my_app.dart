import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:studio_chance/router/app_router.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GoRouter router = ref.watch(goRouterProvider);

    final textTheme = TextTheme(
      displayLarge: TextStyle(
        fontSize: 57.0,
        height: 1.2,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: TextStyle(
        fontSize: 45.0,
        height: 1.2,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: TextStyle(
        fontSize: 36.0,
        height: 1.2,
        fontWeight: FontWeight.bold,
      ),
      headlineLarge: TextStyle(
        fontSize: 24.0,
        height: 1.3,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        fontSize: 20.0,
        height: 1.3,
        fontWeight: FontWeight.bold,
      ),
      headlineSmall: TextStyle(
        fontSize: 18.0,
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

    return MaterialApp.router(
      routerConfig: router,

      title: 'StudioChance',
      themeMode: ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Pretendard',
        brightness: Brightness.light,
        textTheme: textTheme,
        appBarTheme: AppBarTheme(
          backgroundColor: CupertinoColors.tertiarySystemBackground.color,
          shape: const Border(
            bottom: BorderSide(color: Color(0x4D000000), width: 0.33),
          ),
        ),
        scaffoldBackgroundColor: CupertinoColors.systemGroupedBackground.color,
        colorScheme: ColorScheme.fromSeed(
          seedColor: CupertinoColors.systemBlue.color,
          brightness: Brightness.light,
        ),
      ),

      darkTheme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Pretendard',
        brightness: Brightness.dark,
        textTheme: textTheme,
        appBarTheme: AppBarTheme(
          backgroundColor: CupertinoColors.tertiarySystemBackground.darkColor,
          shape: const Border(
            bottom: BorderSide(color: Color(0x26FFFFFF), width: 0.33),
          ),
        ),
        scaffoldBackgroundColor:
            CupertinoColors.systemGroupedBackground.darkColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: CupertinoColors.systemBlue.darkColor,
          brightness: Brightness.dark,
        ),
      ),
    );
  }
}
