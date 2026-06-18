import 'dart:io';
import 'dart:convert';

class ImageUtils {
  /// Reads a File from disk and returns its base64-encoded string.
  /// Returns null if the file doesn't exist or can't be read.
  static Future<String?> fileToBase64(File file) async {
    try {
      final bytes = await file.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      return null;
    }
  }

  /// Converts all images in a screening session to base64.
  /// Returns a list in the same order as the input, with nulls
  /// for any file that failed to encode.
  static Future<List<String?>> encodeAll(List<File?> files) async {
    return Future.wait(
      files.map((f) => f != null ? fileToBase64(f) : Future.value(null)),
    );
  }
}