import 'dart:typed_data';
import 'package:doc_scan_kit/doc_scan_kit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:doc_scan_kit/src/doc_scan_kit_platform_interface.dart';
import 'package:doc_scan_kit/src/doc_scan_kit_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockDocScanKitPlatform
    with MockPlatformInterfaceMixin
    implements DocScanKitPlatform {
  bool closeCalled = false;
  int scannerCallCount = 0;

  @override
  Future<String> recognizeText(List<int> imageBytes) async {
    return Future.value("Mocked recognized text");
  }

  @override
  Future<String> scanQrCode(List<int> imageBytes) async {
    return Future.value("Mocked QR code result");
  }

  @override
  Future<List<ScanResult>> scanner(
    final DocumentScanKitOptionsAndroid optionsAndroid,
    final DocumentScanKitOptionsiOS optionsIos,
  ) async {
    scannerCallCount++;
    final list = await Future.value([
      ScanResult(
        imagePath: 'test/path',
        imagesBytes: Uint8List(0),
      )
    ]);
    return list;
  }

  @override
  Future<void> close() async {
    closeCalled = true;
  }
}

void main() {
  late MockDocScanKitPlatform fakePlatform;
  late DocScanKit docScanKitPlugin;

  setUp(() {
    fakePlatform = MockDocScanKitPlatform();
    DocScanKitPlatform.instance = fakePlatform;
    docScanKitPlugin = DocScanKit();
  });

  test('$MethodChannelDocScanKit is the default instance', () {
    expect(
        DocScanKitPlatform.instance, isInstanceOf<MethodChannelDocScanKit>());
  });

  test('scanner returns scan results', () async {
    final result = await docScanKitPlugin.scanner();

    expect(fakePlatform.scannerCallCount, 1);
    expect(result.length, 1);
    expect(result.first, isA<ScanResult>());
    expect(result.first.imagePath, 'test/path');
  });

  test('close should call platform implementation', () async {
    await docScanKitPlugin.close();

    expect(fakePlatform.closeCalled, true);
  });
}
