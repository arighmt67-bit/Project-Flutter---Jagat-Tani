import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../service/camera_service.dart';
import '../service/image_helper.dart';
import '../ui/result_page.dart';

class HomeController extends ChangeNotifier {
  final ImageHelper _imageHelper;
  final CameraService _cameraService;

  HomeController({
    ImageHelper? imageHelper,
    CameraService? cameraService,
  })  : _imageHelper = imageHelper ?? ImageHelper(),
        _cameraService = cameraService ?? CameraService();

  File? _selectedImage;
  bool _isLoading = false;
  bool _isCameraInitialized = false;

  File? get selectedImage => _selectedImage;
  bool get isLoading => _isLoading;
  bool get isCameraInitialized => _isCameraInitialized;
  CameraService get cameraService => _cameraService;

  Future<void> pickImage(ImageSource source) async {
    try {
      _isLoading = true;
      notifyListeners();

      if (source == ImageSource.camera) {
        await _cameraService.initialize();
        _isCameraInitialized = true;
        notifyListeners();
        return;
      }

      final file = await _imageHelper.pickImage(source: source);
      if (file != null) {
        final croppedFile = await _imageHelper.crop(file: file);
        if (croppedFile != null) {
          _selectedImage = croppedFile;
        }
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> takePicture(BuildContext context) async {
    try {
      _isLoading = true;
      notifyListeners();

      final file = await _cameraService.takePicture();
      if (file != null) {
        final croppedFile = await _imageHelper.crop(file: File(file.path));
        if (croppedFile != null) {
          _selectedImage = croppedFile;
          _isCameraInitialized = false;
          _cameraService.dispose();
        }
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void navigateToResult(BuildContext context) {
    if (_selectedImage != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultPage(image: _selectedImage!),
        ),
      );
    }
  }

  @override
  void dispose() {
    _cameraService.dispose();
    super.dispose();
  }
}
