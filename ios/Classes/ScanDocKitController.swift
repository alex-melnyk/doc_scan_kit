//
//  ScanDocKitController.swift
//  doc_scan_kit
//
//  Created by  Matheus Santos de Oliveira on 17/10/24.
//

import Foundation
import VisionKit
import Flutter

@available(iOS 13.0, *)
class ScanDocKitController:UIViewController, VNDocumentCameraViewControllerDelegate{
    let result : FlutterResult
    
    init(result: @escaping FlutterResult) {
        self.result = result
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        return nil
    }
    
    override func viewWillAppear(_ animated:Bool){
        if self.isBeingPresented{
            let documentCameraVC = VNDocumentCameraViewController()
            documentCameraVC.delegate = self
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
        
        var flutterImgData: [FlutterStandardTypedData] = []
        for i in 0 ..< scan.pageCount{
            let image = scan.imageOfPage(at: i)
            if let imageData = image.jpegData(compressionQuality: 1) {
                flutterImgData.append(FlutterStandardTypedData(bytes: imageData))
            }else{
                print("Erro convert image to jpeg")
            }
        }
        
        result(flutterImgData)
        controller.dismiss(animated: true)
        dismiss(animated: true)
        
    }
    
    
}
