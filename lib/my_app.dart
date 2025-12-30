import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(title: 'StudioChance', themeMode: ThemeMode.system);
  }
}

Future<void> setPreferredOrientations() {
  return SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
}
