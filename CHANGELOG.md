## 0.1.0
### BREAKING CHANGES
* **Major plugin architecture refactoring**: Separated text recognition and QR code scanning functionality from main document scanner
* **Simplified `ScanResult`**: Removed `text` and `barcode` fields - now returns only image data
* **Removed options**:
  - iOS: `useQrCodeScanner` and `useTextRecognizer` removed from `DocumentScanKitOptionsiOS`
  - Android: `recognizerText` removed from `DocumentScanKitOptionsAndroid`

### New Features
* **Added separate methods**:
  - `recognizeText()`: For text recognition on image bytes
  - `scanQrCode()`: For QR code scanning on image bytes
* **New workflow**: Document scanner now focuses solely on image capture with separate processing

### Technical Improvements
* Created new `TextProcessor.swift` utility class for iOS
* Implemented dedicated `DocScanBarcodeScanner.java` for Android
* Complete UI redesign of example app with configuration screen
* Updated tests to reflect new simplified structure

### Migration Required
If you were using integrated text/QR code options, you now need to:
1. Use scanner only for image capture
2. Call `recognizeText()` or `scanQrCode()` separately with image bytes
3. Remove `useQrCodeScanner`, `useTextRecognizer` and `recognizerText` options from configurations

## 0.0.13
* Update Android build dependencies to Gradle AGP 8.7.0 and add ML Kit text recognition.
* Add ML Kit text recognition support for Android and refactor DocumentScanner.
* Refactor document scanning options to android.

## 0.0.12
* Add color customization for iOS document scanning options.

## 0.0.11
* Refactor DocumentScanner options handling for improved clarity and default values.
* Update Gradle wrapper to version 8.10.2 for improved performance and features.

## 0.0.10
* Refactor DocumentScanner Android options handling for improved type safety.
* Add Gradle wrapper properties for version 8.5.

## 0.0.9
* Fix: return duplicate document on android.

## 0.0.8
* Updated `README.md` to include demo videos and screenshots for iOS and Android
* Added sample media files for Android and iOS document scanning demo
* Updated Kotlin plugin version to `1.8.10`; enabled image saving in `DocumentScanKit` options and improved loading state management in the UI
* Renamed scanner method to `scanKit#startDocumentScanner`
* Refactored `DocScanKit` implementation to improve resource management; added `close` method and updated `main.dart` for better plugin usage
* Implemented `DocumentScanner` and `DocScanKitPlugin` for Android; added method channel for document scanning functionality in Java, and committed the base code in Kotlin
* Updated Gradle wrapper to version `8.1.1` and Android plugin to version `8.1.0`

## 0.0.7
* Added options `useQrCodeScanner` and `useTextRecognizer` to `DocumentScanKitOptionsiOS`
* Updated `ScanResult` to include `text` and `barcode` fields
* Implemented QR code and text recognition in `ScanDocKitController`
* Updated method channel implementation to handle new options and fields
* Added new Swift files `RecognizedTextDataSource.swift` and `TextRecognize.swift` for text recognition functionality

## 0.0.6
* add support  swift package manager

## 0.0.5
* implementing saveImage = false for android

## 0.0.4
* Added ScanResult
* Added option saveImage, to return imagePath from ScanResult

## 0.0.3
* Add DocumentScanKitOptionsAndroid and DocumentScanKitOptionsiOS

## 0.0.1
* initial release.