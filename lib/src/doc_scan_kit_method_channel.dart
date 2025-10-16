import 'package:doc_scan_kit/src/models/android_options.dart';
import 'package:doc_scan_kit/src/models/ios_options.dart';
import 'package:doc_scan_kit/src/models/scan_result.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'doc_scan_kit_platform_interface.dart';

/// An implementation of [DocScanKitPlatform] that uses method channels.
class MethodChannelDocScanKit extends DocScanKitPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('doc_scan_kit');

  /// Instance id.
  final id = DateTime.now().microsecondsSinceEpoch.toString();

  /// Starts the document scanner and returns the scanned images
  /// as a list of [ScanResult].
  @override
  Future<List<ScanResult>> scanner(
    final DocumentScanKitOptionsAndroid androidOptions,
    final DocumentScanKitOptionsIOS iosOptions,
  ) async {
    final result = await methodChannel.invokeMethod<List<Object?>>(
      'scanKit#startDocumentScanner',
      <String, dynamic>{
        'options': androidOptions.toJson(),
        'id': id,
        'iosOptions': iosOptions.toJson(),
      },
    );

    return result?.map((e) {
          e as Map;
          return ScanResult(imagePath: e['path'], imagesBytes: e['bytes']);
        }).toList() ??
        [];
  }

  /// Recognizes text from image bytes
  @override
  Future<String> recognizeText(List<int> imageBytes) async {
    final result = await methodChannel.invokeMethod<String>(
      'scanKit#recognizeText',
      {
        'imageBytes': imageBytes,
        'id': id,
      },
    );
    return result ?? '';
  }

  /// Scans for QR codes in image bytes
  @override
  Future<String> scanQrCode(List<int> imageBytes) async {
    final result = await methodChannel.invokeMethod<String>(
      'scanKit#scanQrCode',
      {
        'imageBytes': imageBytes,
        'id': id,
      },
    );
    return result ?? '';
  }

  /// Close the detector and release resources.
  @override
  Future<void> close() {
    return methodChannel.invokeMethod<void>(
      "scanKit#closeDocumentScanner",
      {'id': id},
    );
  }
}
