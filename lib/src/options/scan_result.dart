import 'dart:typed_data';

class ScanResult {
  String imagePath;
  Uint8List imagesBytes;
  ScanResult({
    required this.imagePath,
    required this.imagesBytes,
  });
}
