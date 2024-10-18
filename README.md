
# DocScanKit Plugin

## Description

Um plugin do Flutter que realiza a digitalização de documentos, usando o ML Kit no Android e o Vision Kit no iOS.

---

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
  final List<Uint8List> images = await DocScanKit().scanner();
} on PlatformException catch (e) {
  debugPrint('Failed: $e');
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
