import './../options/scan_result.dart';

class DocumentScanKitOptionsAndroid {
  DocumentScanKitOptionsAndroid(
      {this.pageLimit = 1,
      this.scannerMode = ScannerModeAndroid.full,
      this.isGalleryImport = true,
      this.saveImage = true});

  /// Sets a page limit for the maximum number of pages that can be scanned in a single scanning session. default = 1.
  final int pageLimit;

  /// Sets the scanner mode which determines what features are enabled. default = ScannerModel.full.
  final ScannerModeAndroid scannerMode;

  /// Enable or disable the capability to import from the photo gallery. default = true.
  final bool isGalleryImport;

  /// Enable save image and return image path in [ScanResult.imagePath]
  /// if you set false, the image is not saved in device and return empty,
  /// Default is true
  final bool saveImage;

  Map<String, dynamic> toJson() => {
        'pageLimit': pageLimit,
        'scannerMode': scannerMode.name,
        'isGalleryImport': isGalleryImport,
        'saveImage': saveImage
      };
}

enum ScannerModeAndroid {
  base,
  filter,
  full,
}
