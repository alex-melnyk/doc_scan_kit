/// Modal presentation styles available when presenting view controllers.
enum ModalPresentationStyleIOS {
  /// The default presentation style chosen by the system.
  automatic,

  /// A presentation style where the content is displayed over another
  /// view controller’s content.
  currentContext,

  /// A view presentation style in which the presented view covers the screen.
  overFullScreen,

  /// A presentation style where the content is displayed in a popover view.
  popover,
}
