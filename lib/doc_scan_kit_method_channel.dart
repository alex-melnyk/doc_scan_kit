import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'doc_scan_kit_platform_interface.dart';

/// An implementation of [DocScanKitPlatform] that uses method channels.
class MethodChannelDocScanKit extends DocScanKitPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('doc_scan_kit');

  @override
  Future<List<Uint8List>> scanner() async {
    return (await methodChannel.invokeMethod<List<Object?>>('scanner'))
            ?.map((e) => e as Uint8List)
            .toList() ??
        [];
    
  }
}
