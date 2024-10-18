import 'dart:typed_data';

import 'doc_scan_kit_platform_interface.dart';

class DocScanKit {
  Future<List<Uint8List>> scanner() {
    return DocScanKitPlatform.instance.scanner();
  }
}
