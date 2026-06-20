import 'dart:io';

import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ImageHelper {
  ImageHelper({
    ImagePicker? imagePicker,
    ImageCropper? imageCropper,
  })  : _imagePicker = imagePicker ?? ImagePicker(),
        _imageCropper = imageCropper ?? ImageCropper();

  final ImagePicker _imagePicker;
  final ImageCropper _imageCropper;

  Future<File?> pickImage({
    required ImageSource source,
  }) async {
    final file = await _imagePicker.pickImage(source: source);
    if (file != null) {
      return File(file.path);
    }
    return null;
  }

  Future<File?> crop({
    required File file,
  }) async {
    final cropped = await _imageCropper.cropImage(
      sourcePath: file.path,
      aspectRatio: const CropAspectRatio(
        ratioX: 1,
        ratioY: 1,
      ),
    );

    if (cropped != null) {
      return File(cropped.path);
    }
    return null;
  }
}