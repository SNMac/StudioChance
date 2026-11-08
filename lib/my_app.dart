import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/presentation/commons/widgets/app_toast.dart';
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

        // 기기 글자 크기 설정을 따르되 maxTextScaleFactor로 상한을 둔다. 하한은 두지
        // 않는다 — 작은 글자는 레이아웃을 깨지 않고 사용자가 직접 고른 값이다.
        // 크기가 고정된 위젯(캘린더, 앱바 버튼 등)은 각 위젯 범위에서 배율을 고정한다
        //
        // ToastHost: 토스트(showAppToast)가 바텀시트·다이얼로그를 포함한 모든 화면 위에 뜨도록
        // Navigator를 바깥 Scaffold로 감싼다
        builder: (context, child) {
          return MediaQuery.withClampedTextScaling(
            maxScaleFactor: maxTextScaleFactor,
            child: ToastHost(child: child!),
          );
        },

        localizationsDelegates: GlobalMaterialLocalizations.delegates,
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
            onError: CupertinoColors.white,
            errorContainer: const Color(0x26FF3B30),
            onErrorContainer: CupertinoColors.systemRed.color,
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
            onError: CupertinoColors.white,
            errorContainer: const Color(0x26FF453A),
            onErrorContainer: CupertinoColors.systemRed.darkColor,
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
