/// Enum representing different methods for document scanning and processing.
enum DocScanKitMethod {
  startDocumentScanner,
  closeDocumentScanner,
  recognizeText,
  scanQrCode;

  String get platformName => 'scanKit#$name';
}
