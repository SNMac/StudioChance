import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:studio_chance/router/app_router.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GoRouter router = ref.watch(goRouterProvider);
    return MaterialApp.router(
      routerConfig: router,

      title: 'StudioChance',
      themeMode: ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Pretendard',
        brightness: Brightness.light,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),

        cupertinoOverrideTheme: const CupertinoThemeData(
          barBackgroundColor: CupertinoColors.systemBackground,
          scaffoldBackgroundColor: CupertinoColors.secondarySystemBackground,
          primaryColor: CupertinoColors.systemBlue,
          textTheme: CupertinoTextThemeData(
            textStyle: TextStyle(
              fontFamily: 'Pretendard',
              color: CupertinoColors.label
            ),
          ),
        ),
      ),

      darkTheme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Pretendard',
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),

        cupertinoOverrideTheme: const CupertinoThemeData(
          barBackgroundColor: CupertinoColors.systemBackground,
          scaffoldBackgroundColor: CupertinoColors.secondarySystemBackground,
          primaryColor: CupertinoColors.systemBlue,
          textTheme: CupertinoTextThemeData(
            textStyle: TextStyle(
              fontFamily: 'Pretendard',
              color: CupertinoColors.label,
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> setPreferredOrientations() {
  return SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
}
