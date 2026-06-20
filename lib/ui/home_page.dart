import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../controller/home_controller.dart';
import '../widget/camera_view.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Food Recognizer App'),
      ),
      body: SafeArea(
        child: Consumer<HomeController>(
          builder: (context, controller, child) {
            if (controller.isCameraInitialized) {
              return CameraView(
                controller: controller.cameraService.controller!,
                onCapture: () => controller.takePicture(context),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: _HomeBody(controller: controller),
            );
          },
        ),
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (controller.selectedImage != null) ...[
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: Image.file(controller.selectedImage!, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 16.0),
        ] else
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.image, size: 100),
                  const SizedBox(height: 16.0),
                  const Text(
                    'No image selected',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FilledButton.tonalIcon(
                        onPressed:
                            () => controller.pickImage(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Gallery'),
                      ),
                      const SizedBox(width: 16.0),
                      FilledButton.tonalIcon(
                        onPressed:
                            () => controller.pickImage(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Camera'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        if (controller.selectedImage != null)
          Row(
            children: [
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: () => controller.pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Change Image'),
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: FilledButton(
                  onPressed: () => controller.navigateToResult(context),
                  child: const Text('Analyze'),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
