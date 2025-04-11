import 'dart:ui';

import './scan_result.dart';

class DocumentScanKitOptionsiOS {
  DocumentScanKitOptionsiOS(
      {this.modalPresentationStyle = ModalPresentationStyle.overFullScreen,
      this.compressionQuality = 1.0,
      this.saveImage = true,
      this.color})
      : assert(!(compressionQuality > 1.0 || compressionQuality < 0.0),
            'The comprehension value must be between 0 and 1');

  ///Modal presentation styles available when presenting view controllers
  ///default: overFullScreen.
  final ModalPresentationStyle modalPresentationStyle;

  ///return image as JPEG. May return nil if image has no CGImageRef or invalid bitmap format. compression is 0(most)..1(least)
  ///default = 1
  final double compressionQuality;

  /// Set to true to enable saving the image
  /// and returning the image path in [ScanResult.imagePath].
  /// The default is true.
  /// In Android imagePath is always returned
  final bool saveImage;

  /// Defines the color applied to buttons and the document detection overlay.
  ///
  /// **Note:** Setting `alpha = 0` makes the buttons fully transparent.
  final Color? color;

  Map<String, dynamic> toJson() => {
        'modalPresentationStyle': modalPresentationStyle.name,
        'compressionQuality': compressionQuality,
        'saveImage': saveImage,
        'color': color != null ? [color?.r, color?.g, color?.b, color?.a] : [],
      };
}

enum ModalPresentationStyle {
  /// The default presentation style chosen by the system.
  automatic,

  /// A presentation style where the content is displayed over another view controller’s content.
  currentContext,

  ///A view presentation style in which the presented view covers the screen.
  overFullScreen,

  /// A presentation style where the content is displayed in a popover view.
  popover,
}
