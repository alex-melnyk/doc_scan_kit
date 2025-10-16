import 'dart:typed_data';

/// ScanResult is a class that represents the result of a document scan.
class ScanResult {
  const ScanResult({
    required this.imagePath,
    required this.imagesBytes,
  });

  /// Path to the scanned image.
  final String? imagePath;

  /// Bytes of the scanned image.
  final Uint8List imagesBytes;
}
