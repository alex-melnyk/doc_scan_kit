class DocumentScanKitOptionsiOS {
  DocumentScanKitOptionsiOS({
    this.modalPresentationStyle = ModalPresentationStyle.overFullScreen,
    this.compressionQuality = 1.0,
  }) : assert(!(compressionQuality > 1.0 || compressionQuality < 0.0),
            'The comprehension value must be between 0 and 1');

  ///Modal presentation styles available when presenting view controllers
  ///default: overFullScreen.
  final ModalPresentationStyle modalPresentationStyle;

  ///return image as JPEG. May return nil if image has no CGImageRef or invalid bitmap format. compression is 0(most)..1(least)
  ///default = 1
  final double compressionQuality;

  Map<String, dynamic> toJson() => {
        'modalPresentationStyle': modalPresentationStyle.name,
        'compressionQuality': compressionQuality,
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
