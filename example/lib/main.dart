import 'dart:io';

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
  @override
  void initState() {
    super.initState();
  }

  List<ScanResult> imageData = [];
  Future<void> scan() async {
    final docScanKitPlugin = DocScanKit(
        iosOptions: DocumentScanKitOptionsiOS(
            compressionQuality: 0.2,
            saveImage: true,
            modalPresentationStyle: ModalPresentationStyle.overFullScreen),
        androidOptions: DocumentScanKitOptionsAndroid(
          pageLimit: 3,
          saveImage: false,
          isGalleryImport: true,
          scannerMode: ScannerModeAndroid.full,
        ));

    try {
      final List<ScanResult> images = await docScanKitPlugin.scanner();
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
                  return Column(
                    children: [
                      const Text('Image Bytes'),
                      Image.memory(
                        imageData[index].imagesBytes,
                        width: 200,
                      ),
                      const SizedBox(height: 10),
                      const Text('Image Path'),
                      if (imageData[index].imagePath != null)
                        Image.file(
                          File(imageData[index].imagePath!),
                          width: 200,
                        ),
                    ],
                  );
                },
              ),
            )
          ],
        )),
      ),
    );
  }
}
