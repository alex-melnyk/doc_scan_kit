import 'dart:typed_data';

import 'package:doc_scan_kit/src/options/android_options.dart';
import 'package:doc_scan_kit/src/options/ios_options.dart';

import 'doc_scan_kit_platform_interface.dart';

class DocScanKit {
  final DocumentScanKitOptionsAndroid? androidOptions;
  final DocumentScanKitOptionsiOS? iosOptions;

  DocScanKit({
    this.androidOptions,
    this.iosOptions,
  });
  Future<List<Uint8List>> scanner() {
    return DocScanKitPlatform.instance.scanner(
        androidOptions ?? DocumentScanKitOptionsAndroid(),
        iosOptions ?? DocumentScanKitOptionsiOS());
  }
}
