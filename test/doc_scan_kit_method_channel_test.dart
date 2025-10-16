import 'package:doc_scan_kit/doc_scan_kit.dart';
import 'package:doc_scan_kit/src/doc_scan_kit_method_channel.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelDocScanKit platform = MethodChannelDocScanKit();
  const MethodChannel channel = MethodChannel('doc_scan_kit');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return <ScanResult>[];
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });
  const optionsAndroid = DocumentScanKitOptionsAndroid();
  const optionsIos = DocumentScanKitOptionsIOS();

  test('scanner', () async {
    expect(
        (await platform.scanner(optionsAndroid, optionsIos)), <ScanResult>[]);
  });
}
