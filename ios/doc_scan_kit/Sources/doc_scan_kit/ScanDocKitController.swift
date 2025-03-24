import Foundation
import VisionKit
import Vision
import Flutter

@available(iOS 13.0, *)
class ScanDocKitController: UIViewController, VNDocumentCameraViewControllerDelegate {
    
    let result: FlutterResult
    let compressionQuality: CGFloat
    let saveImage: Bool
    let useQrCodeScanner: Bool
    let useTextRecognizer: Bool
    let colorList : [NSNumber]
    var activityIndicator: UIActivityIndicatorView!
    
    
    init(result: @escaping FlutterResult, compressionQuality: CGFloat, saveImage: Bool, useTextRecognizer: Bool,useQrCodeScanner:Bool, colorList:[NSNumber] ) {
        self.result = result
        self.compressionQuality = compressionQuality
        self.saveImage = saveImage
        self.useQrCodeScanner = useQrCodeScanner
        self.useTextRecognizer = useTextRecognizer
        self.colorList = colorList
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        self.view.addSubview(activityIndicator)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if self.isBeingPresented {
            let documentCameraVC = VNDocumentCameraViewController()
            documentCameraVC.delegate = self
            
            //Apply tint color
            applyTintColor(controller: documentCameraVC)
            
            
            present(documentCameraVC, animated: true)
        }
    }
    
    
    
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        result(nil)
        controller.dismiss(animated: true)
        dismiss(animated: true)
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: any Error) {
        result(FlutterError(code: "SCAN_FAIL", message: error.localizedDescription, details: error.localizedDescription))
        controller.dismiss(animated: true)
        dismiss(animated: true)
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        
        controller.dismiss(animated: true){

      
            DispatchQueue.global(qos: .userInitiated).async {
                var resultArray: [[String: Any?]] = []
                for i in (0 ..< scan.pageCount) {
                    let image = scan.imageOfPage(at: i)
                    
                    if let imageData = image.jpegData(compressionQuality: self.compressionQuality) {
                        var dict = ["text": "", "path": "","barcode": "", "bytes": FlutterStandardTypedData(bytes: imageData)] as [String: Any?]
                        
                        let group = DispatchGroup()
                        
                        
                        if self.saveImage {
                            group.enter()
                            
                            DispatchQueue.global().async{
                                dict["path"] = self.saveImg(image: imageData)
                                group.leave()
                            }
                            
                        }
                        if self.useTextRecognizer{
                            group.enter()
                            
                            // Text Recognizer
                            DispatchQueue.global().async {
                                dict["text"] = self.recognizeText(from: image)
                                group.leave()
                            }
                        }
                        if self.useQrCodeScanner{
                            group.enter()
                            
                            // QrCode Recognizer
                            DispatchQueue.global().async {
                                dict["barcode"] = self.detectBarcode(from: image)
                                group.leave()
                            }
                            
                            
                        }
                        group.wait()
                        resultArray.append(dict)
                    } else {
                        print("Erro converter imagem para jpeg")
                    }
                }
                
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.result(resultArray)
                    
                    self.dismiss(animated: true)
                }}
    }
}
    func recognizeText(from image: UIImage) -> String {
        guard let cgImage = image.cgImage else {
            return ""
        }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let request = VNRecognizeTextRequest { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                return
            }
            
            let recognizedStrings = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }
        }
        
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        
        do {
            try requestHandler.perform([request])
            
            if let observations = request.results {
                return observations.compactMap {
                    $0.topCandidates(1).first?.string
                }.joined(separator: "\n")
            }
        } catch {
            print("Erro no reconhecimento de texto: \(error)")
        }
        
        return ""
    }
    func detectBarcode(from image: UIImage) -> String {
        guard let cgImage = image.cgImage else {
            return ""
        }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        var barcodeResults = ""
        
        let request = VNDetectBarcodesRequest { request, error in
            guard let results = request.results as? [VNBarcodeObservation] else {
                return
            }
            
            barcodeResults = results.compactMap { observation in
                observation.payloadStringValue
            }.joined(separator: ", ")
        }
        
        do {
            try requestHandler.perform([request])
        } catch {
            print("Erro na detecção de código de barras: \(error)")
        }
        
        return barcodeResults
    }
    func saveImg(image: Data) -> String? {
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
            return nil
        }
        let fileName = UUID().uuidString
        
        guard let filePath = directory.appendingPathComponent(fileName + ".jpeg") else {
            return nil
        }
        do {
            try image.write(to: filePath)
            return filePath.path
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func applyTintColor(controller:VNDocumentCameraViewController){
        if colorList.count >= 4 {
            let red = CGFloat(truncating: colorList[0])
            let green = CGFloat(truncating: colorList[1])
            let blue = CGFloat(truncating: colorList[2])
            let alpha = CGFloat(truncating: colorList[3])

            controller.view.tintColor = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        }
    }
}
