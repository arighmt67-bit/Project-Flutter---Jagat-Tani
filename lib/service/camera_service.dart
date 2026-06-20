import 'package:camera/camera.dart';

class CameraService {
  CameraController? _controller;
  CameraDescription? _camera;

  Future<void> initialize() async {
    if (_controller?.value.isInitialized ?? false) return;

    final cameras = await availableCameras();
    _camera = cameras.first;

    _controller = CameraController(
      _camera!,
      ResolutionPreset.high,
      enableAudio: false,
    );

    await _controller!.initialize();
  }

  Future<XFile?> takePicture() async {
    if (_controller?.value.isInitialized ?? false) {
      try {
        final image = await _controller?.takePicture();
        return image;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  void dispose() {
    _controller?.dispose();
  }

  CameraController? get controller => _controller;
}