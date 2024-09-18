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
    
    static let supportedSymbology: [VNBarcodeSymbology] = [.code128, .qr]
    
    let context = CIContext()
    
    static func supports(_ symbology: VNBarcodeSymbology) -> Bool {
        return supportedSymbology.contains(symbology)
    }
    
    static func imageData(for item: Item) -> Data? {
        guard let data = item.payloadStringValue.data(using: String.Encoding.utf8) else {
            print("Can't parse payload data")
            return nil
        }
        let symbology = VNBarcodeSymbology(rawValue: item.symbologyRawValue)
        
        var filter: CIFilter?
        var transform: CGAffineTransform = .identity
        
        switch symbology {
        case .code128:
            filter = self.filter(code128: data)
            transform = CGAffineTransform(scaleX: 2, y: 2)
        case .qr:
            filter = self.filter(qr: data)
            transform = CGAffineTransform(scaleX: 8, y: 8)
        default:
            return nil
        }
        
        return imageData(from: filter!, transform: transform)

    }
    
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
    
    static func imageData(from filter: CIFilter?, transform: CGAffineTransform = .identity) -> Data? {
        let context = CIContext()
        
        if let outputImage = filter?.outputImage?.transformed(by: transform),
           let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
            
            let uiImage = UIImage(cgImage: cgImage)
            return uiImage.pngData()
        }
        return nil
    }
    
    func getImage(from filter: CIFilter, transform: CGAffineTransform) -> Image? {
        let context = CIContext()
        
        if let outputImage = filter.outputImage?.transformed(by: transform),
           let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
            return Image(uiImage: UIImage(cgImage: cgImage))
        }
        return nil
    }
    
    static func filter(code128 data: Data, quietSpace: Double = 4.0) -> CIFilter? {
        if let filter = CIFilter(name: "CICode128BarcodeGenerator"){
            // Documentation is inconsistent. It says key is message but in reality it is inputMessage
            // Not sure if this varies based on device or ios version
            filter.setValue(data, forKey: "inputMessage")
            filter.setValue(quietSpace, forKey: "inputQuietSpace")
            return filter
        }
        return nil
    }
    
    static func filter(qr data: Data) -> CIFilter? {
        if let filter = CIFilter(name: "CIQRCodeGenerator"){
            // Documentation is inconsistent. It says key is message but in reality it is inputMessage
            // Not sure if this varies based on device or ios version
            filter.setValue(data, forKey: "inputMessage")
            return filter
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
