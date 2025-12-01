import 'dart:io';

import 'package:dio/dio.dart';

/// Helper class for multipart form data and file uploads
class MultipartHelper {
  /// Upload a single file with optional additional fields
  static Future<FormData> createSingleFileFormData({
    required File file,
    String fieldName = 'file',
    Map<String, dynamic>? additionalFields,
    String? customFileName,
  }) async {
    final formData = FormData();

    // Add additional fields
    if (additionalFields != null) {
      additionalFields.forEach((key, value) {
        formData.fields.add(MapEntry(key, value.toString()));
      });
    }

    // Add file
    final fileName = customFileName ?? file.path.split('/').last;
    formData.files.add(
      MapEntry(
        fieldName,
        await MultipartFile.fromFile(file.path, filename: fileName),
      ),
    );

    return formData;
  }

  /// Upload multiple files with optional additional fields
  static Future<FormData> createMultipleFilesFormData({
    required List<File> files,
    String fieldName = 'files',
    Map<String, dynamic>? additionalFields,
    List<String>? customFileNames,
  }) async {
    final formData = FormData();

    // Add additional fields
    if (additionalFields != null) {
      additionalFields.forEach((key, value) {
        formData.fields.add(MapEntry(key, value.toString()));
      });
    }

    // Add files
    for (int i = 0; i < files.length; i++) {
      final file = files[i];
      final fileName = customFileNames != null && i < customFileNames.length
          ? customFileNames[i]
          : file.path.split('/').last;

      formData.files.add(
        MapEntry(
          fieldName,
          await MultipartFile.fromFile(file.path, filename: fileName),
        ),
      );
    }

    return formData;
  }

  /// Upload files with different field names
  static Future<FormData> createMixedFormData({
    required Map<String, File> fileFields,
    Map<String, dynamic>? additionalFields,
  }) async {
    final formData = FormData();

    // Add additional fields
    if (additionalFields != null) {
      additionalFields.forEach((key, value) {
        formData.fields.add(MapEntry(key, value.toString()));
      });
    }

    // Add files with custom field names
    for (final entry in fileFields.entries) {
      final fieldName = entry.key;
      final file = entry.value;
      final fileName = file.path.split('/').last;

      formData.files.add(
        MapEntry(
          fieldName,
          await MultipartFile.fromFile(file.path, filename: fileName),
        ),
      );
    }

    return formData;
  }

  /// Create multipart from bytes
  static FormData createFromBytes({
    required List<int> bytes,
    required String fileName,
    String fieldName = 'file',
    Map<String, dynamic>? additionalFields,
  }) {
    final formData = FormData();

    // Add additional fields
    if (additionalFields != null) {
      additionalFields.forEach((key, value) {
        formData.fields.add(MapEntry(key, value.toString()));
      });
    }

    // Add file from bytes
    formData.files.add(
      MapEntry(fieldName, MultipartFile.fromBytes(bytes, filename: fileName)),
    );

    return formData;
  }

  /// Create multipart from stream
  static FormData createFromStream({
    required Stream<List<int>> stream,
    required int length,
    required String fileName,
    String fieldName = 'file',
    Map<String, dynamic>? additionalFields,
  }) {
    final formData = FormData();

    // Add additional fields
    if (additionalFields != null) {
      additionalFields.forEach((key, value) {
        formData.fields.add(MapEntry(key, value.toString()));
      });
    }

    // Add file from stream
    formData.files.add(
      MapEntry(
        fieldName,
        MultipartFile.fromStream(() => stream, length, filename: fileName),
      ),
    );

    return formData;
  }

  /// Validate file size (in MB)
  static bool isFileSizeValid(File file, double maxSizeMB) {
    final fileSizeInBytes = file.lengthSync();
    final fileSizeInMB = fileSizeInBytes / (1024 * 1024);
    return fileSizeInMB <= maxSizeMB;
  }

  /// Validate file extension
  static bool isFileExtensionValid(File file, List<String> allowedExtensions) {
    final fileName = file.path.split('/').last;
    final extension = fileName.split('.').last.toLowerCase();
    return allowedExtensions.map((e) => e.toLowerCase()).contains(extension);
  }

  /// Get file size in MB
  static double getFileSizeMB(File file) {
    final fileSizeInBytes = file.lengthSync();
    return fileSizeInBytes / (1024 * 1024);
  }

  /// Get file extension
  static String getFileExtension(File file) {
    final fileName = file.path.split('/').last;
    return fileName.split('.').last.toLowerCase();
  }
}

/// Extension for easy file upload
extension FileUploadExtension on File {
  Future<MultipartFile> toMultipartFile({String? customFileName}) async {
    final fileName = customFileName ?? path.split('/').last;
    return MultipartFile.fromFile(path, filename: fileName);
  }
}
