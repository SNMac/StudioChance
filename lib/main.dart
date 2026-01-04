import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

import 'package:studio_chance/my_app.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final provideAndroid = kDebugMode
      ? AndroidDebugProvider()
      : AndroidPlayIntegrityProvider();

  final provideApple = kDebugMode
      ? AppleDebugProvider()
      : AppleAppAttestProvider();

  await FirebaseAppCheck.instance.activate(
    providerAndroid: provideAndroid,
    providerApple: provideApple,
  );
  await setPreferredOrientations();

  if (Platform.isAndroid) {
    await FlutterDisplayMode.setHighRefreshRate();
  }

  runApp(ProviderScope(child: const MyApp()));
}
