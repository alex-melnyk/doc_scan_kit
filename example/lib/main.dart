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

  final docScanKitPlugin = DocScanKit(
      iosOptions: DocumentScanKitOptionsiOS(
          compressionQuality: 0.2,
          saveImage: true,
          modalPresentationStyle: ModalPresentationStyle.overFullScreen),
      androidOptions: DocumentScanKitOptionsAndroid(
        pageLimit: 3,
        saveImage: true,
        isGalleryImport: true,
        scannerMode: ScannerModeAndroid.full,
      ));

  List<ScanResult> imageData = [];
  bool isLoading = false;
  Future<void> scan() async {
    try {
      isLoading = true;
      setState(() {});
      final List<ScanResult> images = await docScanKitPlugin.scanner();
      for (var element in images) {
        imageData.add(element);
      }
    } on PlatformException catch (e) {
      debugPrint('Failed $e');
    } finally {
      isLoading = false;
      setState(() {});
    }
  }

  @override
  void dispose() {
    docScanKitPlugin.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('DocScanKit example app'),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: scan,
          icon: const Icon(Icons.camera_alt),
          label: const Text('Scan'),
        ),
        body: Center(
            child: Column(
          children: [
            if (isLoading) const CircularProgressIndicator(),
            Expanded(
              child: ListView.builder(
                itemCount: imageData.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      const Text('Image By Bytes'),
                      Image.memory(
                        imageData[index].imagesBytes,
                        width: 200,
                      ),
                      const SizedBox(height: 10),
                      const Text('Image ByPath'),
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
