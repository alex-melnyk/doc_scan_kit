## 0.0.1

* initial release.

## 0.0.3

* Add DocumentScanKitOptionsAndroid and DocumentScanKitOptionsiOS

## 0.0.4

* Added ScanResult
* Added option saveImage, to return imagePath from ScanResult

## 0.0.5
* implementing saveImage = false for android

## 0.0.6
* add support  swift package manager

## 0.0.7
* Added options `useQrCodeScanner` and `useTextRecognizer` to `DocumentScanKitOptionsiOS`
* Updated `ScanResult` to include `text` and `barcode` fields
* Implemented QR code and text recognition in `ScanDocKitController`
* Updated method channel implementation to handle new options and fields
* Added new Swift files `RecognizedTextDataSource.swift` and `TextRecognize.swift` for text recognition functionality

## 0.0.8
* Updated `README.md` to include demo videos and screenshots for iOS and Android
* Added sample media files for Android and iOS document scanning demo
* Updated Kotlin plugin version to `1.8.10`; enabled image saving in `DocumentScanKit` options and improved loading state management in the UI
* Renamed scanner method to `scanKit#startDocumentScanner`
* Refactored `DocScanKit` implementation to improve resource management; added `close` method and updated `main.dart` for better plugin usage
* Implemented `DocumentScanner` and `DocScanKitPlugin` for Android; added method channel for document scanning functionality in Java, and committed the base code in Kotlin
* Updated Gradle wrapper to version `8.1.1` and Android plugin to version `8.1.0`


## 0.0.9
* Fix: return duplicate document on android.