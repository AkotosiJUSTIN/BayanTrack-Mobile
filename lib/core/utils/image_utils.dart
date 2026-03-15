import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

/// Utility helpers for client-side image compression.
class ImageUtils {
  /// Compress the image file if it exceeds a threshold (e.g., 800KB),
  /// or resize if dimensions are large. Returns a new File when compressed,
  /// or null if no compression was performed.
  static Future<File?> maybeCompressFile(
    File file, {
    int minCompressBytes = 64 * 1024,
    int targetBytes = 300 * 1024,
  }) async {
    try {
      final bytes = await file.length();
      // Try compression for most photos; skip only very small files.
      if (bytes < minCompressBytes) return null;

      final basename = file.uri.pathSegments.isNotEmpty ? file.uri.pathSegments.last : DateTime.now().millisecondsSinceEpoch.toString();
      final targetPathBase = '${file.parent.path}/${DateTime.now().millisecondsSinceEpoch}_$basename';

      // Iteratively reduce quality until we reach the target size or quality floor.
      int quality = 75;
      const int minQuality = 45;
      const int qualityStep = 5;

      File? lastSuccessful;
      while (quality >= minQuality) {
        final targetPath = '${targetPathBase}_q$quality';
        final compressed = await FlutterImageCompress.compressAndGetFile(
          file.absolute.path,
          targetPath,
          quality: quality,
          minWidth: 1024,
          minHeight: 720,
        );

        if (compressed == null) {
          quality -= qualityStep;
          continue;
        }

        // Normalize type (some plugin versions return XFile)
        File compressedFile;
        if (compressed is File) {
          compressedFile = compressed as File;
        } else {
          compressedFile = File(compressed.path);
        }

        final compressedSize = await compressedFile.length();
        lastSuccessful = compressedFile;
        if (compressedSize <= targetBytes) {
          return compressedFile;
        }

        // If not small enough, try with lower quality
        quality -= qualityStep;
      }

      // If we made at least one compressed file smaller than original, return the smallest found
      if (lastSuccessful != null) {
        final lastSize = await lastSuccessful.length();
        if (lastSize < bytes) return lastSuccessful;
      }

      return null;
    } catch (e) {
      debugPrint('maybeCompressFile error: $e');
      return null;
    }
  }
}
