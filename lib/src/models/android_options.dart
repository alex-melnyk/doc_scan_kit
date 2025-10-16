import 'package:doc_scan_kit/src/models/doc_scan_kit_options.dart';
import 'package:doc_scan_kit/src/models/scanner_mode_android.dart';

/// DocumentScanKitOptionsAndroid is a class that represents the options
/// for the document scanner on Android.
class DocumentScanKitOptionsAndroid extends DocScanKitOptions {
  const DocumentScanKitOptionsAndroid({
    super.saveImage = true,
    this.pageLimit = 1,
    this.scannerMode = ScannerModeAndroid.full,
    this.isGalleryImport = true,
  });

  /// Sets a page limit for the maximum number of pages that can be scanned in a single scanning session. default = 1.
  final int pageLimit;

  /// Sets the scanner mode which determines what features are enabled. default = ScannerModel.full.
  final ScannerModeAndroid scannerMode;

  /// Enable or disable the capability to import from the photo gallery. default = true.
  final bool isGalleryImport;

  /// Converts the object to a JSON map.
  Map<String, dynamic> toJson() => {
        'saveImage': saveImage,
        'pageLimit': pageLimit,
        'scannerMode': scannerMode.name,
        'isGalleryImport': isGalleryImport,
      };
}
