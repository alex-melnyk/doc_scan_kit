import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:doc_scan_kit/doc_scan_kit_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelDocScanKit platform = MethodChannelDocScanKit();
  const MethodChannel channel = MethodChannel('doc_scan_kit');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return <Uint8List>[];
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('scanner', () async {
    expect((await platform.scanner()), <Uint8List>[]);
  });
}
