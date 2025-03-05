import 'dart:typed_data';

class ScanResult {
  String? imagePath;
  Uint8List imagesBytes;
  String? text;
  String? barcode;
  ScanResult({
    required this.imagePath,
    required this.imagesBytes,
    required this.text,
    required this.barcode,
  });
}
