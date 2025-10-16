import 'package:doc_scan_kit/src/models/doc_scan_kit_result_type.dart';

/// ScanResult is a class that represents the result of a document scan.
class DocScanKitResult {
  const DocScanKitResult({required this.type, required this.path});

  /// Type of the scanned document.
  final DocScanKitResultType type;

  /// Path to the scanned file.
  final String? path;
}
