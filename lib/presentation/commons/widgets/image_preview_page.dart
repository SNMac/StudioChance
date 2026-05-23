import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';

Future<bool> showImagePreviewPage(BuildContext context, Uint8List bytes) async {
  return await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => _ImagePreviewPage(bytes: bytes),
        ),
      ) ??
      false;
}

class _ImagePreviewPage extends StatelessWidget {
  const _ImagePreviewPage({required this.bytes});

  final Uint8List bytes;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
              bottom: false,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: Center(
                      child: Image.memory(bytes, fit: BoxFit.contain),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: context.systemBackground,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: TextButton.styleFrom(
                          backgroundColor: context.secondarySystemFill,
                          foregroundColor: context.label,
                          textStyle: textTheme.labelLarge,
                          minimumSize: const Size.fromHeight(44),
                        ),
                        child: const Text('취소'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(
                          backgroundColor: context.systemBlue,
                          foregroundColor: Colors.white,
                          textStyle: textTheme.bodyMedium,
                          minimumSize: const Size.fromHeight(44),
                        ),
                        child: const Text('확인'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
