import 'package:doc_scan_kit/src/models/doc_scan_kit_options_ios.dart';
import 'package:doc_scan_kit/src/doc_scan_kit_method_channel.dart';

import 'doc_scan_kit_platform.dart';

/// iOS implementation of [DocScanKitPlatform].
class DocScanKitPlatformIOS extends DocScanKitMethodChannel {
  DocScanKitPlatformIOS() : super(options: const DocScanKitOptionsIOS());

  /// Registers this instance as the default platform implementation.
  static void registerWith() {
    DocScanKitPlatform.instance = DocScanKitPlatformIOS();
  }
}
