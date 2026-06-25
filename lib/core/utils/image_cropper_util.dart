/// Image utility for picking and cropping images.
///
/// Wraps image_picker and image_cropper packages.
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter/material.dart';

class ImageCropperUtil {
  final ImagePicker _picker = ImagePicker();

  /// Pick an image from the camera and crop it.
  Future<File?> pickAndCropFromCamera(BuildContext context) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (pickedFile == null) return null;
    return _cropImage(pickedFile.path, context);
  }

  /// Pick an image from the gallery and crop it.
  Future<File?> pickAndCropFromGallery(BuildContext context) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (pickedFile == null) return null;
    return _cropImage(pickedFile.path, context);
  }

  /// Crop the image at the given path.
  Future<File?> _cropImage(String sourcePath, BuildContext context) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: sourcePath,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Recadrer l\'image',
          toolbarColor: const Color(0xFF1565C0),
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
          activeControlsWidgetColor: const Color(0xFF1565C0),
        ),
        IOSUiSettings(
          title: 'Recadrer l\'image',
          cancelButtonTitle: 'Annuler',
          doneButtonTitle: 'Valider',
        ),
      ],
    );

    if (croppedFile == null) return null;
    return File(croppedFile.path);
  }
}
