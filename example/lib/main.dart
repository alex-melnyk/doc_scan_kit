import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:doc_scan_kit/doc_scan_kit.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _docScanKitPlugin = DocScanKit(iosOptions: DocumentScanKitOptionsiOS(
    compressionQuality: 0.2,
    modalPresentationStyle: ModalPresentationStyle.overFullScreen
  ), androidOptions: DocumentScanKitOptionsAndroid(
    pageLimit: 3,
    isGalleryImport: false,
    scannerMode: ScannerModeAndroid.full,
  ));

  @override
  void initState() {
    super.initState();
  }
List<Uint8List> imageData = [];
  Future<void> scan() async {
    try {
      final List<Uint8List> images = await _docScanKitPlugin.scanner();
      for (var element in images) {
        imageData.add(element);
      }
      setState(() {});
    } on PlatformException catch (e) {
      debugPrint('Failed $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('DocScanKit example app'),
        ),
        body: Center(
            child: Column(
          children: [
            ElevatedButton(
                onPressed: () {
                  scan();
                },
                child: const Text('Scan')),
            Expanded(
              child: ListView.builder(
                itemCount: imageData.length,
                itemBuilder: (context, index) {
                  return Image.memory(imageData[index]);
                },
              ),
            )
          ],
        )
        ),
      ),
    );
  }
}
