import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:studio_chance/presentation/providers/notification_controller.dart';
import 'package:studio_chance/router/app_router.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GoRouter router = ref.watch(goRouterProvider);

    // 알림 권한 요청·토큰 등록·딥링크 처리를 앱 생명주기 동안 유지한다.
    // (로그인 전에는 컨트롤러 내부에서 아무 동작도 하지 않는다)
    ref.watch(notificationControllerProvider);

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

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: MaterialApp.router(
        routerConfig: router,

        // 기기 시스템 글자 크기 설정을 따르면 24×24 오늘 날짜 버튼, 60px 고정
        // leadingWidth의 취소 버튼 등 고정 크기 위젯에서 텍스트가 넘치거나
        // 줄바꿈되어 레이아웃이 깨짐 → 배율을 1.0으로 고정해 기기 설정 전체 무시
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.noScaling),
            child: child!,
          );
        },

        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ko', 'KR')],
        title: 'StudioChance',
        themeMode: ThemeMode.system,
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'Pretendard',
          brightness: Brightness.light,
          textTheme: textTheme.apply(
            displayColor: CupertinoColors.label.color,
            bodyColor: CupertinoColors.label.color,
            decorationColor: CupertinoColors.label.color,
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: CupertinoColors.tertiarySystemBackground.color,
            shape: const Border(
              bottom: BorderSide(color: Color(0x4D000000), width: 0.33),
            ),
          ),
          scaffoldBackgroundColor:
              CupertinoColors.systemGroupedBackground.color,
          colorScheme: ColorScheme.light(
            brightness: Brightness.light,
            primary: CupertinoColors.systemBlue.color,
            onPrimary: CupertinoColors.white,
            primaryContainer: const Color(0x26007AFF),
            onPrimaryContainer: CupertinoColors.systemBlue.color,
            error: CupertinoColors.systemRed.color,
          ),

          cupertinoOverrideTheme: CupertinoThemeData(
            brightness: Brightness.light,
            primaryColor: CupertinoColors.systemBlue.color,
            primaryContrastingColor: CupertinoColors.white,
          ),
        ),

        darkTheme: ThemeData(
          useMaterial3: true,
          fontFamily: 'Pretendard',
          brightness: Brightness.dark,
          textTheme: textTheme.apply(
            displayColor: CupertinoColors.label.darkColor,
            bodyColor: CupertinoColors.label.darkColor,
            decorationColor: CupertinoColors.label.darkColor,
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: CupertinoColors.tertiarySystemBackground.darkColor,
            shape: const Border(
              bottom: BorderSide(color: Color(0x26FFFFFF), width: 0.33),
            ),
          ),
          scaffoldBackgroundColor:
              CupertinoColors.systemGroupedBackground.darkColor,
          colorScheme: ColorScheme.dark(
            brightness: Brightness.dark,
            primary: CupertinoColors.systemBlue.darkColor,
            onPrimary: CupertinoColors.white,
            primaryContainer: const Color(0x260091FF),
            onPrimaryContainer: CupertinoColors.systemBlue.darkColor,
            error: CupertinoColors.systemRed.darkColor,
          ),

          cupertinoOverrideTheme: CupertinoThemeData(
            brightness: Brightness.dark,
            primaryColor: CupertinoColors.systemBlue.darkColor,
            primaryContrastingColor: CupertinoColors.white,
          ),
        ),
      ),
    );
  }
}
