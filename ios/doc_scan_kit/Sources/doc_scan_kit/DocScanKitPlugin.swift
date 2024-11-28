import Flutter
import UIKit

@available(iOS 13.0, *)
public class DocScanKitPlugin: NSObject, FlutterPlugin {
  
  
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "doc_scan_kit", binaryMessenger: registrar.messenger())
    let instance = DocScanKitPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }
  
  
  func mapPresentationStyle(from string: String) -> UIModalPresentationStyle {
    switch string {
    case "automatic":
      return .automatic
    case "currentContext":
      return .currentContext
    case "overFullScreen":
      return .overFullScreen
    case "popover":
      return .popover
    default:
      return .overFullScreen
    }
  }
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "scanner":
      guard Bundle.main.object(forInfoDictionaryKey: "NSCameraUsageDescription") != nil else {
        return result(FlutterError(code: "configuration_error",
                                   message: "the NSCameraUsageDescription parameter needs to be configured in the Info.plist",
                                   details: "the NSCameraUsageDescription parameter needs to be configured in the Info.plist"))
      }
      guard let args = call.arguments as? [String: Any],
            let iosOptions = args["iosOptions"] as? [String: Any] else {
        return result(FlutterError(code: "invalid_arguments",
                                   message: "Invalid or missing arguments",
                                   details: "Expected iOS options and scanner parameters."))
      }
        let presentationStyleString = iosOptions["modalPresentationStyle"] as? String ?? "overFullScreen"
        let presentationStyle = mapPresentationStyle(from: presentationStyleString)
        let compressionQuality = iosOptions["compressionQuality"] as? CGFloat ?? 1.0
        let saveImage = iosOptions["saveImage"] as? Bool ?? true
        if let viewController = UIApplication.shared.delegate?.window??.rootViewController as? FlutterViewController {
            let scanController = ScanDocKitController(result: result, compressionQuality: compressionQuality, saveImage:saveImage)
            scanController.isModalInPresentation = true
            scanController.modalPresentationStyle = presentationStyle
            viewController.present(scanController, animated: true)
        } else {
            result(FlutterError(code: "view_controller_error",
                            message: "Unable to retrieve the root view controller.",
                            details: nil))
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
