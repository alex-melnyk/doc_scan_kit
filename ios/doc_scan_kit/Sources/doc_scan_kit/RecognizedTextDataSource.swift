//
//  RecognizedTextDataSource.swift
//  doc_scan_kit
//
//  Created by IATec - Matheus Santos de Oliveira on 25/01/25.
//

import UIKit
import Vision

protocol RecognizedTextDataSource: AnyObject {
    @available(iOS 13.0, *)
    func addRecognizedText(recognizedText: [VNRecognizedTextObservation])
}
