import 'dart:io';

import 'package:flutter/material.dart';

/// Legacy UI removed. The app now uses provider-based screens under
/// `lib/provider/screens/` (CameraScreen, ResultScreen, etc.).
///
/// This file is retained as a lightweight stub to avoid breaking imports
/// elsewhere while the UI is migrated.

class ResultPage extends StatelessWidget {
  const ResultPage({super.key, required this.image});

  final File image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Result (legacy stub)')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.info_outline, size: 56),
            SizedBox(height: 12),
            Text('This UI has been migrated. Use the provider screens.'),
          ],
        ),
      ),
    );
  }
}
