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
}
