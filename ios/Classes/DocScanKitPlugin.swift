import Flutter
import UIKit

@available(iOS 13.0,*)
public class DocScanKitPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "doc_scan_kit", binaryMessenger: registrar.messenger())
    let instance = DocScanKitPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "scanner":
        guard Bundle.main.object(forInfoDictionaryKey:"NSCameraUsageDescription") is String
                
        else{
            return result(FlutterError(code: "configuration_error", message: "the NSCameraUsageDescription parameter needs to be configured in the Info.plist" , details:"the NSCameraUsageDescription parameter needs to be configured in the Info.plist"))
        }
        if let viewController = UIApplication.shared.delegate?.window??.rootViewController as? FlutterViewController {
            let scanController = ScanDocKitController(result: result)
            scanController.isModalInPresentation = true
            scanController.modalPresentationStyle = .popover
            viewController.present(scanController, animated: true)
        }
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
