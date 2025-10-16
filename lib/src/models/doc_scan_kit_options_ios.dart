import 'dart:ui';

import 'package:doc_scan_kit/src/models/doc_scan_kit_options.dart';
import 'package:doc_scan_kit/src/models/modal_presentation_style_ios.dart';

/// DocumentScanKitOptionsIOS is a class that represents the options
/// for the document scanner on iOS.
class DocScanKitOptionsIOS extends DocScanKitOptions {
  const DocScanKitOptionsIOS({
    super.format,
    this.modalPresentationStyle = ModalPresentationStyleIOS.overFullScreen,
    this.compressionQuality = 1.0,
    this.color,
  }) : assert(
          !(compressionQuality > 1.0 || compressionQuality < 0.0),
          'The comprehension value must be between 0 and 1',
        );

  ///Modal presentation styles available when presenting view controllers
  ///default: overFullScreen.
  final ModalPresentationStyleIOS modalPresentationStyle;

  ///return image as JPEG. May return nil if image has no CGImageRef or invalid bitmap format. compression is 0(most)..1(least)
  ///default = 1
  final double compressionQuality;

  /// Defines the color applied to buttons and the document detection overlay.
  ///
  /// **Note:** Setting `alpha = 0` makes the buttons fully transparent.
  final Color? color;

  /// Converts the object to a JSON map.
  @override
  Map<String, dynamic> toJson() => {
        'format': format.name,
        'modalPresentationStyle': modalPresentationStyle.name,
        'compressionQuality': compressionQuality,
        'color': color != null ? [color?.r, color?.g, color?.b, color?.a] : [],
      };
}
