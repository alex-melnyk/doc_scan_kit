
# DocScanKit Plugin 

# [pub.dev](https://pub.dev/packages/doc_scan_kit)

## Description

A Flutter plugin that performs document scanning, using ML Kit on Android and Vision Kit on iOS.

---

## Feature Support

| Feature              | Android | iOS  |
|----------------------|---------|------|
| Document Scanning   | ✅       | ✅    |
| Auto Crop           | ✅       | ✅    |
| Filters             | ✅       | ✅    |
| Edge Detection      | ✅       | ✅    |
| Multi-page Scanning | ✅       | ✅    |
| Text Recognizer     | ✅       | ✅    |
| QrCode Recognizer   | ❌       | ✅    |

---

## 🚧 Pending Improvements

⚠️ **Areas that need improvement:**

- Improve error handling and return values.
- Improve viewing when scanning text android.

---


# Demo
### iOS
<p align="center">
	<img src="https://github.com/rajada1/doc_scan_kit/blob/master/demo/ios/video.gif?raw=true" width="200"  />
</p>

## Screenshots
| ![Screenshot 1](https://github.com/rajada1/doc_scan_kit/blob/master/demo/ios/scan.jpeg?raw=true) | ![Screenshot 2](https://github.com/rajada1/doc_scan_kit/blob/master/demo/ios/preview.jpeg?raw=true) | ![Screenshot 3](https://github.com/rajada1/doc_scan_kit/blob/master/demo/ios/filter.jpeg?raw=true) |
|----------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------|
| 

### Android
<p align="center">
	<img src="https://github.com/rajada1/doc_scan_kit/blob/master/demo/android/video.gif?raw=true" width="200"  />
</p>

## Screenshots
| ![Screenshot 1](https://github.com/rajada1/doc_scan_kit/blob/master/demo/android/scan.jpeg?raw=true) | ![Screenshot 2](https://github.com/rajada1/doc_scan_kit/blob/master/demo/android/preview.jpeg?raw=true) | ![Screenshot 3](https://github.com/rajada1/doc_scan_kit/blob/master/demo/android/filter.jpeg?raw=true) |
|----------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------|
| 



## Initial Setup

### Android

To configure Android, add the following settings to the `android/app/build.gradle` file:

#### Requirements

- minSdkVersion: 21
- targetSdkVersion: 33
- compileSdkVersion: 34

### iOS

For iOS, edit the `ios/Podfile` to set the minimum version:

```ruby
platform :ios, '13.0'
```

Also, add the camera usage permission in the `ios/Runner/Info.plist` file:

```xml
<key>NSCameraUsageDescription</key>
<string>Camera Usage is Required</string>
```

---

## Usage

Here's a simple example of how to use the plugin to scan documents:

```dart
import 'package:doc_scan_kit/doc_scan_kit.dart';

  try {
      final List<ScanResult> images = await docScanKitPlugin.scanner();
    } on PlatformException catch (e) {
      debugPrint('Failed $e');
    } finally {
      docScanKitPlugin.close();
    }
```

This example performs the scan and returns a list of images in `Uint8List` format.

---

## Contributions

Contributions are welcome! Feel free to open an issue or submit a pull request.

---

## Supported Versions

- **Android**: minSdkVersion 21+
- **iOS**: 13.0+
