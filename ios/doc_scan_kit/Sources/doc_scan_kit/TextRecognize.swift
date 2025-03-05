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
}


