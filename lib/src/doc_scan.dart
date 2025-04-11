import '../doc_scan_kit.dart';
import 'doc_scan_kit_platform_interface.dart';

class DocScanKit {
  final DocumentScanKitOptionsAndroid? androidOptions;
  final DocumentScanKitOptionsiOS? iosOptions;

  DocScanKit({
    this.androidOptions,
    this.iosOptions,
  });

  Future<List<ScanResult>> scanner() {
    return DocScanKitPlatform.instance.scanner(
        androidOptions ?? DocumentScanKitOptionsAndroid(),
        iosOptions ?? DocumentScanKitOptionsiOS());
  }

  /// Recognizes text from the provided image bytes
  ///
  /// Returns the recognized text as a string
  Future<String> recognizeText(List<int> imageBytes) {
    return DocScanKitPlatform.instance.recognizeText(imageBytes);
  }

  /// Scans for QR codes in the provided image bytes
  ///
  /// Returns the detected QR code content as a string
  Future<String> scanQrCode(List<int> imageBytes) {
    return DocScanKitPlatform.instance.scanQrCode(imageBytes);
  }

  Future<void> close() => DocScanKitPlatform.instance.close();
}
