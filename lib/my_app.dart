import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:studio_chance/router/app_router.dart';
import 'package:studio_chance/theme.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final materialTheme = MaterialTheme();
    final GoRouter router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      routerConfig: router,
      title: 'StudioChance',
      theme: materialTheme.light(),
      darkTheme: materialTheme.dark(),
      themeMode: ThemeMode.system,
    );
  }
}
