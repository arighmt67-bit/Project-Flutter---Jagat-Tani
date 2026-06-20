import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraView extends StatelessWidget {
  const CameraView({
    super.key,
    required this.controller,
    required this.onCapture,
  });

  final CameraController controller;
  final VoidCallback onCapture;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CameraPreview(controller),
        Positioned(
          bottom: 32.0,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FloatingActionButton(
                heroTag: 'capture',
                onPressed: onCapture,
                child: const Icon(Icons.camera),
              ),
            ],
          ),
        ),
      ],
    );
  }
}