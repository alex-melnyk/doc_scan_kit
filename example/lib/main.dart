import 'package:flutter/material.dart';
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

  double compressionQuality = 0.2;
  bool saveImage = true;
  bool useQrCodeScanner = true;
  bool useTextRecognizer = true;
  Color color = Colors.orange;
  ModalPresentationStyle modalPresentationStyle =
      ModalPresentationStyle.overFullScreen;

  int pageLimit = 3;
  bool recognizerText = false;
  bool recognizerTextAndroid = false;
  bool saveImageAndroid = true;
  bool isGalleryImport = true;
  ScannerModeAndroid scannerMode = ScannerModeAndroid.full;

  List<ScanResult> imageData = [];
  bool isLoading = false;
  Future<void> scan() async {
    DocScanKit instance = DocScanKit(
      iosOptions: DocumentScanKitOptionsiOS(
        compressionQuality: compressionQuality,
        saveImage: saveImage,
        useQrCodeScanner: useQrCodeScanner,
        useTextRecognizer: useTextRecognizer,
        color: color,
        modalPresentationStyle: modalPresentationStyle,
      ),
      androidOptions: DocumentScanKitOptionsAndroid(
        pageLimit: pageLimit,
        recognizerText: recognizerTextAndroid,
        saveImage: saveImageAndroid,
        isGalleryImport: isGalleryImport,
        scannerMode: scannerMode,
      ),
    );
    try {
      isLoading = true;

      setState(() {});

      final List<ScanResult> images = await instance.scanner();
      imageData = images;
    } on PlatformException catch (e) {
      debugPrint('Failed $e');
    } finally {
      isLoading = false;
      instance.close();
      setState(() {});
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('DocScanKit example app'),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_forever),
              onPressed: () {
                setState(() {
                  imageData.clear();
                });
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            scan();
          },
          icon: const Icon(Icons.camera_alt),
          label: const Text('Scan'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 10, right: 10, bottom: 100),
          child: Column(
            children: [
              if (isLoading) const CircularProgressIndicator(),
              const SizedBox(height: 10),
              ExpansionTile(
                title: const Text(
                  'iOS Options',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                children: [
                  SwitchListTile(
                    title: const Text('Save Image'),
                    value: saveImage,
                    onChanged: (value) => setState(() => saveImage = value),
                  ),
                  SwitchListTile(
                    title: const Text('Use QR Code Scanner'),
                    value: useQrCodeScanner,
                    onChanged: (value) =>
                        setState(() => useQrCodeScanner = value),
                  ),
                  SwitchListTile(
                    title: const Text('Use Text Recognizer'),
                    value: useTextRecognizer,
                    onChanged: (value) =>
                        setState(() => useTextRecognizer = value),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Compression Quality:'),
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          if (compressionQuality > 0.1) {
                            setState(() => compressionQuality -= 0.1);
                          }
                        },
                      ),
                      Text(compressionQuality.toStringAsFixed(1)),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          if (compressionQuality < 1.0) {
                            setState(() => compressionQuality += 0.1);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Select Color:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.circle, color: Colors.orange),
                        onPressed: () => setState(() => color = Colors.orange),
                      ),
                      IconButton(
                        icon: const Icon(Icons.circle, color: Colors.blue),
                        onPressed: () => setState(() => color = Colors.blue),
                      ),
                      IconButton(
                        icon: const Icon(Icons.circle, color: Colors.green),
                        onPressed: () => setState(() => color = Colors.green),
                      ),
                      IconButton(
                        icon: const Icon(Icons.circle, color: Colors.red),
                        onPressed: () => setState(() => color = Colors.red),
                      ),
                    ],
                  ),
                ],
              ),
              ExpansionTile(
                title: const Text(
                  'Android Options',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Page Limit:'),
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          if (pageLimit > 1) {
                            setState(() => pageLimit -= 1);
                          }
                        },
                      ),
                      Text(pageLimit.toString()),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          if (pageLimit < 10) {
                            setState(() => pageLimit += 1);
                          }
                        },
                      ),
                    ],
                  ),
                  SwitchListTile(
                    title: const Text('Recognizer Text'),
                    value: recognizerTextAndroid,
                    onChanged: (value) =>
                        setState(() => recognizerTextAndroid = value),
                  ),
                  SwitchListTile(
                    title: const Text('Save Image'),
                    value: saveImageAndroid,
                    onChanged: (value) =>
                        setState(() => saveImageAndroid = value),
                  ),
                  SwitchListTile(
                    title: const Text('Gallery Import'),
                    value: isGalleryImport,
                    onChanged: (value) =>
                        setState(() => isGalleryImport = value),
                  ),
                ],
              ),
              const Divider(),
              const Text(
                'Scan Results',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
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
                      if (imageData[index].imagePath != null)
                        Column(
                          children: [
                            const Text('Image By Path'),
                            Text(
                              imageData[index].imagePath!,
                              style: const TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                      if (imageData[index].text != null &&
                          imageData[index].text!.isNotEmpty)
                        Column(
                          children: [
                            const Text('Scanned Text'),
                            Text(
                              imageData[index].text!,
                              style: const TextStyle(fontSize: 10),
                            ),
                          ],
                        )
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
