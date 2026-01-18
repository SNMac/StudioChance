import 'package:flutter/material.dart';

import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.systemBackground,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: Placeholder(color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}
