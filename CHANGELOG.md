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
