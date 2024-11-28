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
    let compressionQuality : CGFloat
    let saveImage : Bool
    
    init(result: @escaping FlutterResult,compressionQuality: CGFloat,saveImage : Bool ) {
        self.result = result
        self.compressionQuality = compressionQuality
        self.saveImage = saveImage
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
        var resultArray : [[String:Any?]] = []
        for i in (0 ..< scan.pageCount){
            
            let image = scan.imageOfPage(at: i)
            if let imageData = image.jpegData(compressionQuality: compressionQuality) {
                var dict = ["path":"", "bytes": FlutterStandardTypedData(bytes: imageData)] as [String : Any?]
                if saveImage {
                    let path = saveImg(image: imageData)
                    dict["path"] = path
                }else{
                    dict["path"] = nil
                }
                resultArray.append(dict)
            }
            else{
                print("Erro convert image to jpeg")
            }
        }
        result(resultArray)
        controller.dismiss(animated: true)
        dismiss(animated: true)
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
}
