/// DocScanKitOptions is a class that represents the options
/// for the document scanner.
abstract class DocScanKitOptions {
  const DocScanKitOptions({required this.saveImage});

  /// Set to true to enable saving the image
  /// and returning the image path in [ScanResult.imagePath].
  /// The default is true.
  /// In Android imagePath is always returned
  final bool saveImage;
}
