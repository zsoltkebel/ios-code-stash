//
//  BarcodeGenerator.swift
//  Code Clone
//
//  Created by Zsolt Kébel on 11/09/2024.
//

import CoreImage.CIFilterBuiltins
import SwiftUI
import Vision

enum CICodeGeneratorFilter: String {
    case CICode128BarcodeGenerator, CIQRCodeGenerator, CIPDF417BarcodeGenerator, CIAztecCodeGenerator
}

struct BarcodeGenerator {
    
    let context = CIContext()
    
    func generate(_ payload: String, _ symbology: VNBarcodeSymbology) -> Image? {
        
        guard let data = payload.data(using: String.Encoding.utf8) else {
            print("Can't parse payload data")
            return nil
        }
        
        switch symbology {
        case .code128:
            return code128(data)
        case .qr:
            return qr(data)
        default:
            // Unsupported by build in code generator
            return nil
        }
    }
    
    func getImage(from filter: CIFilter, transform: CGAffineTransform) -> Image? {
        let context = CIContext()
        
        if let outputImage = filter.outputImage?.transformed(by: transform),
           let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
            return Image(uiImage: UIImage(cgImage: cgImage))
        }
        return nil
    }
    
    func code128(_ data: Data) -> Image? {
        if let filter = CIFilter(name: "CICode128BarcodeGenerator"){
            // Documentation is inconsistent. It says key is message but in reality it is inputMessage
            // Not sure if this varies based on device or ios version
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 2, y: 2)
            
            return getImage(from: filter, transform: transform)
        }
        return nil
    }
    
    func qr(_ data: Data) -> Image? {
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            // Same as above
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 8, y: 8)
            
            return getImage(from: filter, transform: transform)
        }
        return nil
    }
}
