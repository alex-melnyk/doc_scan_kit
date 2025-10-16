import 'package:doc_scan_kit/src/doc_scan_kit_method_channel.dart';

import 'doc_scan_kit_platform.dart';

/// Android implementation of [DocScanKitPlatform].
class DocScanKitPlatformAndroid extends DocScanKitMethodChannel {
  DocScanKitPlatformAndroid() : super();

  /// Registers this instance as the default platform implementation.
  static void registerWith() {
    DocScanKitPlatform.instance = DocScanKitPlatformAndroid();
  }
}
