import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter/material.dart';
import 'package:photo_momento/core/services/firebase_service.dart';
import 'package:photo_momento/core/constants/app_constants.dart';
import 'package:photo_momento/core/exceptions/exceptions.dart';

class PhotoService {
  final ImagePicker _imagePicker = ImagePicker();

  Future<List<String>> pickAndUploadPhotos({
    required String userId,
    int maxPhotos = 10,
  }) async {
    try {
      final List<XFile> selectedFiles = await _imagePicker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (selectedFiles.isEmpty) {
        return []; // User cancelled selection
      }

      if (selectedFiles.length > maxPhotos) {
        throw PhotoException('En fazla $maxPhotos fotoğraf seçebilirsiniz');
      }

      final List<String> uploadedUrls = [];

      for (final file in selectedFiles) {
        // Check file size
        final fileSize = await _getFileSize(file.path);
        if (fileSize > AppConstants.maxFileSizeMB * 1024 * 1024) {
          throw PhotoException('Dosya boyutu ${AppConstants.maxFileSizeMB}MB\'dan küçük olmalıdır');
        }

        // Crop image if needed
        final String? croppedPath = await _cropImage(file.path);
        final String filePath = croppedPath ?? file.path;

        // Upload to Firebase Storage
        final String imageUrl = await FirebaseService.uploadPhoto(
          userId: userId,
          filePath: filePath,
          fileName: file.name,
        );

        uploadedUrls.add(imageUrl);

        // Clean up cropped file
        if (croppedPath != null) {
          await File(croppedPath).delete();
        }
      }

      return uploadedUrls;
    } catch (e) {
      if (e is PhotoException) {
        rethrow;
      }
      throw PhotoException('Fotoğraf yüklenirken hata oluştu: $e');
    }
  }

  Future<List<String>> pickPhotosFromCamera({
    required String userId,
  }) async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (photo == null) {
        return []; // User cancelled
      }

      // Check file size
      final fileSize = await _getFileSize(photo.path);
      if (fileSize > AppConstants.maxFileSizeMB * 1024 * 1024) {
        throw PhotoException('Dosya boyutu ${AppConstants.maxFileSizeMB}MB\'dan küçük olmalıdır');
      }

      // Crop image if needed
      final String? croppedPath = await _cropImage(photo.path);
      final String filePath = croppedPath ?? photo.path;

      // Upload to Firebase Storage
      final String imageUrl = await FirebaseService.uploadPhoto(
        userId: userId,
        filePath: filePath,
        fileName: photo.name,
      );

      // Clean up cropped file
      if (croppedPath != null) {
        await File(croppedPath).delete();
      }

      return [imageUrl];
    } catch (e) {
      if (e is PhotoException) {
        rethrow;
      }
      throw PhotoException('Kamera ile fotoğraf çekilirken hata oluştu: $e');
    }
  }

  Future<String?> _cropImage(String filePath) async {
    try {
      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: filePath,
        aspectRatio: const CropAspectRatio(ratioX: 3, ratioY: 2),
        compressQuality: 85,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Fotoğrafı Düzenle',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.ratio3x2,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Fotoğrafı Düzenle',
            aspectRatioLockEnabled: true,
            aspectRatioPickerButtonHidden: true,
          ),
        ],
      );

      return croppedFile?.path;
    } catch (e) {
      print('Image cropping failed: $e');
      return null;
    }
  }

  Future<double> _getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      final stat = await file.stat();
      return stat.size.toDouble();
    } catch (e) {
      throw PhotoException('Dosya boyutu alınamadı: $e');
    }
  }

  Future<void> deletePhotos(List<String> imageUrls) async {
    try {
      for (final url in imageUrls) {
        await FirebaseService.deletePhoto(url);
      }
    } catch (e) {
      throw PhotoException('Fotoğraflar silinirken hata oluştu: $e');
    }
  }

  // Get file size in MB
  Future<double> getFileSizeInMB(String filePath) async {
    final sizeInBytes = await _getFileSize(filePath);
    return sizeInBytes / (1024 * 1024);
  }

  // Check if file is supported image format
  bool isSupportedImageFormat(String filePath) {
    final extension = filePath.toLowerCase().split('.').last;
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension);
  }

  // Validate image before upload
  Future<void> validateImage(String filePath) async {
    // Check file size
    final fileSize = await _getFileSize(filePath);
    if (fileSize > AppConstants.maxFileSizeMB * 1024 * 1024) {
      throw PhotoException('Dosya boyutu ${AppConstants.maxFileSizeMB}MB\'dan küçük olmalıdır');
    }

    // Check file format
    if (!isSupportedImageFormat(filePath)) {
      throw PhotoException('Desteklenmeyen dosya formatı. Lütfen JPG, PNG veya GIF formatında yükleyin.');
    }
  }
}