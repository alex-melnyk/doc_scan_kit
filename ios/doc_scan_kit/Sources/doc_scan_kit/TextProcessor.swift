import UIKit
import Vision

@available(iOS 13.0, *)
class TextProcessor {
    
    /// Recognizes text from the provided UIImage
    /// Returns the recognized text as a string
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
    
    /// Detects barcodes/QR codes from the provided UIImage
    /// Returns the barcode content as a string
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
}
