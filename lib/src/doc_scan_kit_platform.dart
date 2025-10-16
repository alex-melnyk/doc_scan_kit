import 'package:doc_scan_kit/src/doc_scan_kit_method_channel.dart';
import 'package:doc_scan_kit/src/models/doc_scan_kit_options.dart';
import 'package:doc_scan_kit/src/models/doc_scan_kit_result.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

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

  /// Scans documents and returns a list of scan results.
  Future<List<DocScanKitResult>> scanner(final DocScanKitOptions options);

  /// Recognizes text from image bytes
  Future<String> recognizeText(List<int> imageBytes);

  /// Scans for QR codes in image bytes
  Future<String> scanQrCode(List<int> imageBytes);

  /// Disposes of any resources used by the plugin on Android.
  Future<void> close();
}
