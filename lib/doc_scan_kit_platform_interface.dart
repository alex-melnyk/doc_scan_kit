import 'dart:typed_data';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'doc_scan_kit_method_channel.dart';

abstract class DocScanKitPlatform extends PlatformInterface {
  /// Constructs a DocScanKitPlatform.
  DocScanKitPlatform() : super(token: _token);

  static final Object _token = Object();

  static DocScanKitPlatform _instance = MethodChannelDocScanKit();

  /// The default instance of [DocScanKitPlatform] to use.
  ///
  /// Defaults to [MethodChannelDocScanKit].
  static DocScanKitPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [DocScanKitPlatform] when
  /// they register themselves.
  static set instance(DocScanKitPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<List<Uint8List>> scanner();
}
