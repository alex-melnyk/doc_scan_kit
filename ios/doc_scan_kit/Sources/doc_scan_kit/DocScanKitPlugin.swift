import Flutter
import Vision
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
    case "scanKit#startDocumentScanner":
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
        let colorList = iosOptions["color"] as? [NSNumber] ?? []
        if let viewController = UIApplication.shared.delegate?.window??.rootViewController as? FlutterViewController {
            let scanController = ScanDocKitController(result: result, compressionQuality: compressionQuality, saveImage:saveImage,colorList: colorList)
            scanController.isModalInPresentation = true
            scanController.modalPresentationStyle = presentationStyle
            viewController.present(scanController, animated: true)
        } else {
            result(FlutterError(code: "view_controller_error",
                            message: "Unable to retrieve the root view controller.",
                            details: nil))
      }
    case "scanKit#recognizeText":
      guard let args = call.arguments as? [String: Any],
            let imageBytes = args["imageBytes"] as? FlutterStandardTypedData,
            let iosOptions = args["iosOptions"] as? [String: Any] else {
        return result(FlutterError(code: "invalid_arguments",
                                   message: "Invalid or missing image data or iOS options",
                                   details: "Expected image bytes and iOS options for text recognition"))
      }

      // Extract recognition options
      let recognitionLevelInt = iosOptions["recognitionLevel"] as? Int ?? 0
      let recognitionLevel: VNRequestTextRecognitionLevel = recognitionLevelInt == 0 ? .accurate : .fast
      let usesLanguageCorrection = iosOptions["usesLanguageCorrection"] as? Bool ?? true
      let customWords = iosOptions["customWords"] as? [String] ?? []
      let recognitionLanguages = iosOptions["recognitionLanguages"] as? [String] ?? []

      // Convert FlutterStandardTypedData to UIImage
      if let image = UIImage(data: imageBytes.data) {

          let recognizedText = TextRecognizeViewController().recognizeText(from: image, recognitionLevel: recognitionLevel, usesLanguageCorrection: usesLanguageCorrection, customWords: customWords, recognitionLanguages: recognitionLanguages)
          result(recognizedText)
      } else {
          result(FlutterError(code: "image_error",
                             message: "Failed to create image from bytes",
                             details: nil))
      }
      
    case "scanKit#scanQrCode":
      guard let args = call.arguments as? [String: Any],
            let imageBytes = args["imageBytes"] as? FlutterStandardTypedData else {
        return result(FlutterError(code: "invalid_arguments",
                                   message: "Invalid or missing image data",
                                   details: "Expected image bytes for QR code scanning"))
      }

      // Convert FlutterStandardTypedData to UIImage
      if let image = UIImage(data: imageBytes.data) {

          let barcodeResults = TextRecognizeViewController().detectBarcode(from: image)
          result(barcodeResults)
      } else {
          result(FlutterError(code: "image_error",
                             message: "Failed to create image from bytes",
                             details: nil))
      }

    case "scanKit#closeDocumentScanner":
      if let viewController = UIApplication.shared.delegate?.window??.rootViewController {
        viewController.presentedViewController?.dismiss(animated: true)
      }
      result(nil)

    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
