import 'package:doc_scan_kit/src/models/doc_scan_kit_result_type.dart';

/// Represents the result of a document scanning operation.
/// 
/// This class encapsulates the information about a single scanned document,
/// including its file type and the path where it's stored on the device.
/// 
/// Each [DocScanKitResult] corresponds to either:
/// - A single JPEG image file (when format is [DocScanKitFormat.images])
/// - A PDF document containing multiple pages (when format is [DocScanKitFormat.document])
/// 
/// Example usage:
/// ```dart
/// final results = await docScanKit.scanner();
/// for (final result in results) {
///   print('Scanned ${result.type.name}: ${result.path}');
///   if (result.path != null) {
///     final file = File(result.path!);
///     // Process the scanned file...
///   }
/// }
/// ```
class DocScanKitResult {
  /// Creates a new [DocScanKitResult] with the specified type and file path.
  /// 
  /// [type] - The format/type of the scanned document file.
  /// [path] - The file system path where the scanned document is stored.
  const DocScanKitResult({required this.type, required this.path});

  /// The type/format of the scanned document file.
  /// 
  /// This property indicates what kind of file was created during the scan:
  /// - [DocScanKitResultType.jpeg]: Individual JPEG image file
  /// - [DocScanKitResultType.pdf]: PDF document file
  /// 
  /// The type corresponds to the [DocScanKitFormat] setting used during scanning.
  final DocScanKitResultType type;

  /// The file system path where the scanned document is stored.
  /// 
  /// This path points to the location on the device where the scanned file
  /// has been saved. The file can be accessed using standard file I/O operations.
  /// 
  /// The path is typically in the app's documents directory and includes
  /// the full filename with appropriate extension (.jpg or .pdf).
  /// 
  /// May be null if the scanning operation failed to create a file.
  final String? path;
}
