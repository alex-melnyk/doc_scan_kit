//
//  TextRecog.swift
//  doc_scan_kit
//
//  Created by  Matheus Santos de Oliveira on 25/01/25.
//

import UIKit
import Vision

class TextRecognizeViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView?
    var transcript = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        textView?.text = transcript
    }
}
// MARK: RecognizedTextDataSource
extension TextRecognizeViewController: RecognizedTextDataSource {
    @available(iOS 13.0, *)
    func addRecognizedText(recognizedText: [VNRecognizedTextObservation]) {
        // Create a full transcript to run analysis on.
        let maximumCandidates = 1
        for observation in recognizedText {
            guard let candidate = observation.topCandidates(maximumCandidates).first else { continue }
            transcript += candidate.string
            transcript += "\n"
        }
        textView?.text = transcript
    }
    
    @available(iOS 13.0, *)
    func recognizeText(from image: UIImage, recognitionLevel: VNRequestTextRecognitionLevel, usesLanguageCorrection: Bool, customWords: [String], recognitionLanguages: [String]) -> String {
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
        
        if #available(iOS 16.0, *) {
            request.revision = VNRecognizeTextRequestRevision3
        } else {
            if #available(iOS 14.0, *) {
                request.revision = VNRecognizeTextRequestRevision2
            } else {
                request.revision = VNRecognizeTextRequestRevision1
            }
        }

        request.recognitionLevel = recognitionLevel
        request.usesLanguageCorrection = usesLanguageCorrection
        request.customWords = customWords
        request.recognitionLanguages = recognitionLanguages



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
            
            if #available(iOS 17.0, *) {
                request.revision = VNDetectBarcodesRequestRevision4
            } else {
                if #available(iOS 16.0, *) {
                    request.revision = VNDetectBarcodesRequestRevision3
                    
                } else {
                    if #available(iOS 15.0, *) {
                        request.revision = VNDetectBarcodesRequestRevision2
                    } else {
                        request.revision = VNDetectBarcodesRequestRevision1
                    }
                }
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


