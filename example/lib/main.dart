import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:doc_scan_kit/doc_scan_kit.dart';
import 'package:image_picker/image_picker.dart';

class CustomScanResult {
  final Uint8List imagesBytes;
  final String? imagePath;
  String? text;
  String? qrCode;

  CustomScanResult({
    required this.imagesBytes,
    this.imagePath,
    this.text,
    this.qrCode,
  });
}

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
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      home: const DocumentScannerScreen(),
    );
  }
}

class DocumentScannerScreen extends StatefulWidget {
  const DocumentScannerScreen({super.key});

  @override
  State<DocumentScannerScreen> createState() => _DocumentScannerScreenState();
}

class _DocumentScannerScreenState extends State<DocumentScannerScreen> {
  // iOS configuration options
  double compressionQuality = 0.2;
  bool saveImage = true;
  bool useQrCodeScanner = true;
  bool useTextRecognizer = true;
  Color color = Colors.orange;
  ModalPresentationStyleIOS modalPresentationStyle =
      ModalPresentationStyleIOS.overFullScreen;

  // Android configuration options
  int pageLimit = 3;
  bool recognizerTextAndroid = false;
  bool saveImageAndroid = true;
  bool isGalleryImport = true;
  ScannerModeAndroid scannerMode = ScannerModeAndroid.full;

  List<CustomScanResult> imageData = [];
  bool isLoading = false;

  Future<void> scan() async {
    DocScanKit instance = DocScanKit(
      iosOptions: DocumentScanKitOptionsIOS(
        compressionQuality: compressionQuality,
        saveImage: saveImage,
        color: color,
        modalPresentationStyle: modalPresentationStyle,
      ),
      androidOptions: DocumentScanKitOptionsAndroid(
        pageLimit: pageLimit,
        saveImage: saveImageAndroid,
        isGalleryImport: isGalleryImport,
        scannerMode: scannerMode,
      ),
    );
    try {
      setState(() => isLoading = true);

      final List<ScanResult> images = await instance.scanner();
      List<CustomScanResult> results = [];

      for (var image in images) {
        CustomScanResult customResult = CustomScanResult(
          imagesBytes: image.imagesBytes,
          imagePath: image.imagePath,
        );

        // Processing text recognition if enabled
        if ((recognizerTextAndroid && Platform.isAndroid) ||
            (useTextRecognizer && Platform.isIOS)) {
          try {
            customResult.text = await instance.recognizeText(image.imagesBytes);
          } catch (e) {
            debugPrint('Text recognition failed: $e');
          }
        }

        // Processing QR code if enabled
        if (useQrCodeScanner) {
          try {
            customResult.qrCode = await instance.scanQrCode(image.imagesBytes);
          } catch (e) {
            debugPrint('QR Code scanning failed: $e');
          }
        }

        results.add(customResult);
      }

      setState(() => imageData = results);
    } on PlatformException catch (e) {
      debugPrint('Failed $e');
    } finally {
      instance.close();
      setState(() => isLoading = false);
    }
  }

  Future<void> processImageFromLibrary() async {
    setState(() => isLoading = true);

    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> selectedImages = await picker.pickMultiImage();

      if (selectedImages.isEmpty) {
        debugPrint('No images selected');
        return;
      }

      DocScanKit instance = DocScanKit(
        iosOptions: DocumentScanKitOptionsIOS(
          compressionQuality: compressionQuality,
          saveImage: saveImage,
          color: color,
          modalPresentationStyle: modalPresentationStyle,
        ),
        androidOptions: DocumentScanKitOptionsAndroid(
          pageLimit: pageLimit,
          saveImage: saveImageAndroid,
          isGalleryImport: isGalleryImport,
          scannerMode: scannerMode,
        ),
      );

      List<CustomScanResult> results = [];

      for (var selectedImage in selectedImages) {
        final Uint8List imageUint8List =
            Uint8List.fromList(await selectedImage.readAsBytes());

        CustomScanResult customResult = CustomScanResult(
          imagesBytes: imageUint8List,
          imagePath: selectedImage.path,
        );

        // Text recognition
        if (recognizerTextAndroid || useTextRecognizer) {
          try {
            customResult.text = await instance.recognizeText(imageUint8List);
          } catch (e) {
            debugPrint('Text recognition failed: $e');
          }
        }

        // QR code detection
        if (useQrCodeScanner) {
          try {
            customResult.qrCode = await instance.scanQrCode(imageUint8List);
          } catch (e) {
            debugPrint('QR Code scanning failed: $e');
          }
        }

        results.add(customResult);
      }

      setState(() => imageData.addAll(results));
      instance.close();
    } catch (e) {
      debugPrint('Error processing gallery images: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _openSettingsScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConfigurationScreen(
          // iOS options
          compressionQuality: compressionQuality,
          saveImage: saveImage,
          useQrCodeScanner: useQrCodeScanner,
          useTextRecognizer: useTextRecognizer,
          color: color,
          modalPresentationStyle: modalPresentationStyle,
          // Android options
          pageLimit: pageLimit,
          recognizerTextAndroid: recognizerTextAndroid,
          saveImageAndroid: saveImageAndroid,
          isGalleryImport: isGalleryImport,
          scannerMode: scannerMode,
          // Callbacks for updating options
          onIOSOptionsChanged: (newCompressionQuality,
              newSaveImage,
              newUseQrCodeScanner,
              newUseTextRecognizer,
              newColor,
              newModalStyle) {
            setState(() {
              compressionQuality = newCompressionQuality;
              saveImage = newSaveImage;
              useQrCodeScanner = newUseQrCodeScanner;
              useTextRecognizer = newUseTextRecognizer;
              color = newColor;
              modalPresentationStyle = newModalStyle;
            });
          },
          onAndroidOptionsChanged: (newPageLimit, newRecognizerText,
              newSaveImage, newIsGalleryImport, newScannerMode) {
            setState(() {
              pageLimit = newPageLimit;
              recognizerTextAndroid = newRecognizerText;
              saveImageAndroid = newSaveImage;
              isGalleryImport = newIsGalleryImport;
              scannerMode = newScannerMode;
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Scanner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_library),
            onPressed: processImageFromLibrary,
            tooltip: 'Import from gallery',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openSettingsScreen,
            tooltip: 'Scanner Settings',
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: imageData.isEmpty
                ? null
                : () => setState(() => imageData.clear()),
            tooltip: 'Clear results',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: scan,
        icon: const Icon(Icons.camera_alt),
        label: const Text('Scan'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : imageData.isEmpty
              ? const Center(child: Text('No documents scanned yet'))
              : ScanResultsList(imageData: imageData),
    );
  }
}

class ScanResultsList extends StatelessWidget {
  final List<CustomScanResult> imageData;

  const ScanResultsList({super.key, required this.imageData});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: imageData.length,
      itemBuilder: (context, index) {
        final result = imageData[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: ExpansionTile(
            title: Text('Document ${index + 1}'),
            leading: SizedBox(
              width: 60,
              child: Image.memory(
                result.imagesBytes,
                fit: BoxFit.cover,
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Image.memory(
                        result.imagesBytes,
                        width: 250,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (result.imagePath != null) ...[
                      const Text('Image Path:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(result.imagePath!,
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[600])),
                      const SizedBox(height: 8),
                    ],
                    if (result.text != null && result.text!.isNotEmpty) ...[
                      const Text('Recognized Text:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(result.text!),
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (result.qrCode != null && result.qrCode!.isNotEmpty) ...[
                      const Text('QR Code Content:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(result.qrCode!),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ConfigurationScreen extends StatefulWidget {
  // iOS options
  final double compressionQuality;
  final bool saveImage;
  final bool useQrCodeScanner;
  final bool useTextRecognizer;
  final Color color;
  final ModalPresentationStyleIOS modalPresentationStyle;

  // Android options
  final int pageLimit;
  final bool recognizerTextAndroid;
  final bool saveImageAndroid;
  final bool isGalleryImport;
  final ScannerModeAndroid scannerMode;

  // Callbacks
  final Function(double, bool, bool, bool, Color, ModalPresentationStyleIOS)
      onIOSOptionsChanged;
  final Function(int, bool, bool, bool, ScannerModeAndroid)
      onAndroidOptionsChanged;

  const ConfigurationScreen({
    super.key,
    required this.compressionQuality,
    required this.saveImage,
    required this.useQrCodeScanner,
    required this.useTextRecognizer,
    required this.color,
    required this.modalPresentationStyle,
    required this.pageLimit,
    required this.recognizerTextAndroid,
    required this.saveImageAndroid,
    required this.isGalleryImport,
    required this.scannerMode,
    required this.onIOSOptionsChanged,
    required this.onAndroidOptionsChanged,
  });

  @override
  State<ConfigurationScreen> createState() => _ConfigurationScreenState();
}

class _ConfigurationScreenState extends State<ConfigurationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Local state variables
  late double _compressionQuality;
  late bool _saveImage;
  late bool _useQrCodeScanner;
  late bool _useTextRecognizer;
  late Color _color;
  late ModalPresentationStyleIOS _modalPresentationStyle;

  late int _pageLimit;
  late bool _recognizerTextAndroid;
  late bool _saveImageAndroid;
  late bool _isGalleryImport;
  late ScannerModeAndroid _scannerMode;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Initialize with widget values
    _compressionQuality = widget.compressionQuality;
    _saveImage = widget.saveImage;
    _useQrCodeScanner = widget.useQrCodeScanner;
    _useTextRecognizer = widget.useTextRecognizer;
    _color = widget.color;
    _modalPresentationStyle = widget.modalPresentationStyle;

    _pageLimit = widget.pageLimit;
    _recognizerTextAndroid = widget.recognizerTextAndroid;
    _saveImageAndroid = widget.saveImageAndroid;
    _isGalleryImport = widget.isGalleryImport;
    _scannerMode = widget.scannerMode;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner Configuration'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              text: 'iOS',
              icon: Icon(Icons.apple),
            ),
            Tab(
              text: 'Android',
              icon: Icon(Icons.android),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              widget.onIOSOptionsChanged(
                _compressionQuality,
                _saveImage,
                _useQrCodeScanner,
                _useTextRecognizer,
                _color,
                _modalPresentationStyle,
              );
              widget.onAndroidOptionsChanged(
                _pageLimit,
                _recognizerTextAndroid,
                _saveImageAndroid,
                _isGalleryImport,
                _scannerMode,
              );
              Navigator.pop(context);
            },
            tooltip: 'Save Settings',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // iOS Configuration Tab
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Scanner Options',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SwitchListTile(
                  title: const Text('Save Image'),
                  subtitle: const Text('Save scanned image to gallery'),
                  value: _saveImage,
                  onChanged: (value) => setState(() => _saveImage = value),
                ),
                SwitchListTile(
                  title: const Text('Use QR Code Scanner'),
                  subtitle: const Text('Detect QR codes in images'),
                  value: _useQrCodeScanner,
                  onChanged: (value) =>
                      setState(() => _useQrCodeScanner = value),
                ),
                SwitchListTile(
                  title: const Text('Use Text Recognizer'),
                  subtitle: const Text('Extract text from images'),
                  value: _useTextRecognizer,
                  onChanged: (value) =>
                      setState(() => _useTextRecognizer = value),
                ),
                const Divider(),
                const Text('Compression Quality',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Slider(
                  value: _compressionQuality,
                  min: 0.1,
                  max: 1.0,
                  divisions: 9,
                  label: _compressionQuality.toStringAsFixed(1),
                  onChanged: (value) =>
                      setState(() => _compressionQuality = value),
                ),
                const Divider(),
                const Text('Scanner Color',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _colorOption(Colors.orange),
                    _colorOption(Colors.blue),
                    _colorOption(Colors.green),
                    _colorOption(Colors.red),
                  ],
                ),
                const Divider(),
                const Text('Modal Presentation Style',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                DropdownButtonFormField<ModalPresentationStyleIOS>(
                  initialValue: _modalPresentationStyle,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _modalPresentationStyle = value);
                    }
                  },
                  items: ModalPresentationStyleIOS.values
                      .map((style) => DropdownMenuItem(
                            value: style,
                            child: Text(style.toString().split('.').last),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),

          // Android Configuration Tab
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Scanner Options',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ListTile(
                  title: const Text('Page Limit'),
                  subtitle: const Text('Maximum number of pages to scan'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: _pageLimit > 1
                            ? () => setState(() => _pageLimit--)
                            : null,
                      ),
                      Text('$_pageLimit'),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _pageLimit < 10
                            ? () => setState(() => _pageLimit++)
                            : null,
                      ),
                    ],
                  ),
                ),
                SwitchListTile(
                  title: const Text('Text Recognition'),
                  subtitle: const Text('Extract text from scanned images'),
                  value: _recognizerTextAndroid,
                  onChanged: (value) =>
                      setState(() => _recognizerTextAndroid = value),
                ),
                SwitchListTile(
                  title: const Text('Use QR Code Scanner'),
                  subtitle: const Text('Detect QR codes in images'),
                  value: _useQrCodeScanner,
                  onChanged: (value) =>
                      setState(() => _useQrCodeScanner = value),
                ),
                SwitchListTile(
                  title: const Text('Save Image'),
                  subtitle: const Text('Save scanned image to gallery'),
                  value: _saveImageAndroid,
                  onChanged: (value) =>
                      setState(() => _saveImageAndroid = value),
                ),
                SwitchListTile(
                  title: const Text('Gallery Import'),
                  subtitle: const Text('Allow importing from gallery'),
                  value: _isGalleryImport,
                  onChanged: (value) =>
                      setState(() => _isGalleryImport = value),
                ),
                const Divider(),
                const Text('Scanner Mode',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                DropdownButtonFormField<ScannerModeAndroid>(
                  initialValue: _scannerMode,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _scannerMode = value);
                    }
                  },
                  items: ScannerModeAndroid.values
                      .map((mode) => DropdownMenuItem(
                            value: mode,
                            child: Text(mode.toString().split('.').last),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _colorOption(Color color) {
    return GestureDetector(
      onTap: () => setState(() => _color = color),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: _color == color ? Colors.black : Colors.transparent,
            width: 3,
          ),
        ),
      ),
    );
  }
}
