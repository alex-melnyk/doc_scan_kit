import 'dart:io';

import 'package:doc_scan_kit/src/doc_scan_kit_platform.dart';
import 'package:doc_scan_kit/src/models/doc_scan_kit_options_android.dart';
import 'package:doc_scan_kit/src/models/doc_scan_kit_options_ios.dart';
import 'package:doc_scan_kit/src/models/doc_scan_kit_result.dart';

/// DocScanKit is a class that provides a platform-agnostic interface for
/// scanning documents and extracting text from them.
class DocScanKit {
  const DocScanKit({
    this.androidOptions,
    this.iosOptions,
  });

  /// The Android options.
  final DocScanKitOptionsAndroid? androidOptions;

  /// The iOS options.
  final DocScanKitOptionsIOS? iosOptions;

  /// Starts the document scanner and returns the scanned images
  /// as a list of [DocScanKitResult].
  Future<List<DocScanKitResult>> scanner() {
    return DocScanKitPlatform.instance.scanner(
      Platform.isAndroid
          ? (androidOptions ?? const DocScanKitOptionsAndroid())
          : (iosOptions ?? const DocScanKitOptionsIOS()),
    );
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

  /// Disposes of any resources used by the plugin on Android.
  Future<void> close() => DocScanKitPlatform.instance.close();
}
