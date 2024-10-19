import 'dart:typed_data';
import 'package:doc_scan_kit/doc_scan_kit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:doc_scan_kit/src/doc_scan_kit_platform_interface.dart';
import 'package:doc_scan_kit/src/doc_scan_kit_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockDocScanKitPlatform
    with MockPlatformInterfaceMixin
    implements DocScanKitPlatform {

  @override
  Future<List<Uint8List>> scanner(
    final DocumentScanKitOptionsAndroid optionsAndroid,
    final DocumentScanKitOptionsiOS optionsIos,
  ) async {
    final list = await Future.value([Uint8List(0x00)]);
    return list;
  }  
}

void main() {
  final DocScanKitPlatform initialPlatform = DocScanKitPlatform.instance;

  test('$MethodChannelDocScanKit is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelDocScanKit>());
  });

  test('scanner', () async {
    DocScanKit docScanKitPlugin = DocScanKit();
    MockDocScanKitPlatform fakePlatform = MockDocScanKitPlatform();
    DocScanKitPlatform.instance = fakePlatform;
    final result = await docScanKitPlugin.scanner();
    
    expect(result.first, isA<Uint8List>());
  });
}
