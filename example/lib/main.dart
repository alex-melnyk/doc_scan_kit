import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:doc_scan_kit/doc_scan_kit.dart';
import 'package:image_picker/image_picker.dart';

// Classe para armazenar os resultados da digitalização
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

  List<CustomScanResult> imageData = [];
  bool isLoading = false;

  Future<void> scan() async {
    DocScanKit instance = DocScanKit(
      iosOptions: DocumentScanKitOptionsiOS(
        compressionQuality: compressionQuality,
        saveImage: saveImage,
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

      // Convertendo para nossa classe personalizada e processando texto/QR Code
      List<CustomScanResult> results = [];

      for (var image in images) {
        CustomScanResult customResult = CustomScanResult(
          imagesBytes: image.imagesBytes,
          imagePath: image.imagePath,
        );

        // Se o reconhecimento de texto foi habilitado, processamos o texto
        if (recognizerTextAndroid || useTextRecognizer) {
          try {
            customResult.text = await instance.recognizeText(image.imagesBytes);
          } catch (e) {
            debugPrint('Text recognition failed: $e');
          }
        }

        // Se o scanner de QR Code foi habilitado, processamos o QR Code
        if (useQrCodeScanner) {
          try {
            customResult.qrCode = await instance.scanQrCode(image.imagesBytes);
          } catch (e) {
            debugPrint('QR Code scanning failed: $e');
          }
        }

        results.add(customResult);
      }

      imageData = results;
    } on PlatformException catch (e) {
      debugPrint('Failed $e');
    } finally {
      isLoading = false;
      instance.close();
      setState(() {});
    }
  }

  Future<void> processImageFromLibrary() async {
    setState(() => isLoading = true);

    try {
      // Inicialização do ImagePicker
      final ImagePicker picker = ImagePicker();

      // Permitir seleção de múltiplas imagens
      final List<XFile> selectedImages = await picker.pickMultiImage();

      if (selectedImages.isEmpty) {
        debugPrint('Nenhuma imagem selecionada');
        return;
      }

      // Criamos instância do DocScanKit para processamento
      DocScanKit instance = DocScanKit(
        iosOptions: DocumentScanKitOptionsiOS(
          compressionQuality: compressionQuality,
          saveImage: saveImage,
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

      List<CustomScanResult> results = [];

      // Processamento de cada imagem selecionada
      for (var selectedImage in selectedImages) {
        // Lê os bytes da imagem
        final List<int> imageBytes = await selectedImage.readAsBytes();
        final Uint8List imageUint8List = Uint8List.fromList(imageBytes);

        // Criando objeto de resultado personalizado
        CustomScanResult customResult = CustomScanResult(
          imagesBytes: imageUint8List,
          imagePath: selectedImage.path,
        );

        // Reconhecimento de texto (se habilitado)
        if (recognizerTextAndroid || useTextRecognizer) {
          try {
            customResult.text = await instance.recognizeText(imageUint8List);
            debugPrint(
                'Texto reconhecido: ${customResult.text?.substring(0, math.min(50, (customResult.text?.length ?? 0)))}...');
          } catch (e) {
            debugPrint('Falha no reconhecimento de texto: $e');
          }
        }

        // Detecção de QR Code (se habilitado)
        if (useQrCodeScanner) {
          try {
            customResult.qrCode = await instance.scanQrCode(imageUint8List);
            if (customResult.qrCode != null &&
                customResult.qrCode!.isNotEmpty) {
              debugPrint('QR Code detectado: ${customResult.qrCode}');
            } else {
              debugPrint('Nenhum QR Code encontrado na imagem');
            }
          } catch (e) {
            debugPrint('Falha na leitura do QR Code: $e');
          }
        }

        results.add(customResult);
      }

      // Adiciona os novos resultados ao conjunto existente
      setState(() {
        imageData.addAll(results);
      });

      // Liberar recursos
      instance.close();
    } catch (e) {
      debugPrint('Erro ao processar imagens da galeria: $e');
    } finally {
      setState(() => isLoading = false);
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
              icon: const Icon(Icons.photo_library),
              onPressed: processImageFromLibrary,
              tooltip: 'Process from gallery',
            ),
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
              if (isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
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
                  const SizedBox(height: 10),
                  const Text(
                    'Modal Presentation Style:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  DropdownButton<ModalPresentationStyle>(
                    value: modalPresentationStyle,
                    onChanged: (ModalPresentationStyle? newValue) {
                      setState(() {
                        if (newValue != null) {
                          modalPresentationStyle = newValue;
                        }
                      });
                    },
                    items: ModalPresentationStyle.values
                        .map<DropdownMenuItem<ModalPresentationStyle>>(
                            (ModalPresentationStyle value) {
                      return DropdownMenuItem<ModalPresentationStyle>(
                        value: value,
                        child: Text(value.toString().split('.').last),
                      );
                    }).toList(),
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
                  const SizedBox(height: 10),
                  const Text(
                    'Scanner Mode:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  DropdownButton<ScannerModeAndroid>(
                    value: scannerMode,
                    onChanged: (ScannerModeAndroid? newValue) {
                      setState(() {
                        if (newValue != null) {
                          scannerMode = newValue;
                        }
                      });
                    },
                    items: ScannerModeAndroid.values
                        .map<DropdownMenuItem<ScannerModeAndroid>>(
                            (ScannerModeAndroid value) {
                      return DropdownMenuItem<ScannerModeAndroid>(
                        value: value,
                        child: Text(value.toString().split('.').last),
                      );
                    }).toList(),
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
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Image ${index + 1}',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          const Text('Image Preview'),
                          Image.memory(
                            imageData[index].imagesBytes,
                            width: 200,
                          ),
                          const SizedBox(height: 10),
                          if (imageData[index].imagePath != null)
                            Column(
                              children: [
                                const Text('Image Path'),
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
                                const Divider(),
                                const Text(
                                  'Recognized Text',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    imageData[index].text!,
                                  ),
                                ),
                              ],
                            ),
                          if (imageData[index].qrCode != null &&
                              imageData[index].qrCode!.isNotEmpty)
                            Column(
                              children: [
                                const Divider(),
                                const Text(
                                  'QR Code Content',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    imageData[index].qrCode!,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
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
