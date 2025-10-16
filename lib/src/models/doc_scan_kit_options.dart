import 'package:doc_scan_kit/src/models/doc_scan_kit_format.dart';

/// DocScanKitOptions is a class that represents the options
/// for the document scanner.
abstract class DocScanKitOptions {
  const DocScanKitOptions({this.format = DocScanKitFormat.images});

  /// Format of the scanned document.
  final DocScanKitFormat format;

  /// Converts the object to a JSON map.
  Map<String, dynamic> toJson();
}
