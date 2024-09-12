//
//  BarcodeGenerator.swift
//  Code Clone
//
//  Created by Zsolt Kébel on 11/09/2024.
//

import CoreImage.CIFilterBuiltins
import SwiftUI
import Vision

protocol CodeGenerator {
    func generateBarcode(_ payloadStringValue: String) -> Image
}

struct BarcodeGenerator: CodeGenerator {
    let context = CIContext()
    let generator = CIFilter.code128BarcodeGenerator()
    
    func generateBarcode(_ payloadStringValue: String) -> Image {
        generator.message = Data(payloadStringValue.utf8)
        
        let transform = CGAffineTransform(scaleX: 2, y: 2)

        if let outputImage = generator.outputImage?.transformed(by: transform),
           let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
            
            let uiImage = UIImage(cgImage: cgImage)
            
            return Image(uiImage: uiImage)
        }
        
        return Image(systemName: "barcode")
        
    }
}

struct QRCodeGenerator: CodeGenerator {
    let context = CIContext()
    let generator = CIFilter.qrCodeGenerator()
    
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.utf8)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "message")
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        
        return nil
    }
    
    func generateBarcode(_ payloadStringValue: String) -> Image {
        generator.message = Data(payloadStringValue.utf8)
        
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        
        if let outputImage = generator.outputImage?.transformed(by: transform),
           let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
            
            let uiImage = UIImage(cgImage: cgImage)
            
            return Image(uiImage: uiImage)
        }
        
        return Image(systemName: "qrcode")
    }
}
