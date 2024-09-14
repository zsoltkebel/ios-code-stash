//
//  BarcodeAPI.swift
//  Code Stash
//
//  Created by Zsolt Kébel on 12/09/2024.
//

import Foundation
import Vision

// https://orcascan.com/guides/free-barcode-image-api-0e4a4fa6
class BarcodeAPI {
    
    static let supportedVNBarcodeSymbology: [VNBarcodeSymbology] = [.qr, .dataMatrix, .upce, .code39, .ean8, .ean13, .code93, .code128, .i2of5, .pdf417, .aztec]
    static let symbologyWithText: [Symbology] = [.ean13]
    
    enum Symbology: String {
        case qr, datamatrix, upca, code39, upce, ean8, ean13, code93, code128, interleaved2of5, pdf417, azteccode
    }
    
    enum Format: String {
        case svg, png, jpg, tiff
    }
    
    static func load(barcode item: Item) async -> Data? {
        guard let url = url(for: item) else {
            print("Invalid URL")
            return nil
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            print(response)
            print("Image downloaded")
            return data
        } catch {
            print("Invalid data")
        }
        return nil
    }
    
    static func loadBarcode(
        _ payloadStringValue: String,
        symbology: Symbology = .qr,
        format: Format = .png,
        text: String? = nil
    ) async -> Data? {
        guard let url = URL(string: "https://barcode.orcascan.com/?type=\(symbology.rawValue)&data=\(payloadStringValue)&format=\(format.rawValue)") else {
            print("Invalid URL")
            return nil
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            print(response)
            print("Image downloaded")
            return data
        } catch {
            print("Invalid data")
        }
        return nil
    }
    
    static func url(for item: Item) -> URL? {
        guard let type: Symbology = VNBarcodeSymbology(rawValue: item.symbologyRawValue).toBarcodeAPISymbology() else {
            // unsupported symbology
            return nil
        }
        let data = item.payloadStringValue
        let format: Format = .png
        
        var urlString = "https://barcode.orcascan.com/?type=\(type.rawValue)&data=\(data)&format=\(format.rawValue)"
        
        if !symbologyWithText.contains(type) {
            urlString += "&text=\(data)"
        }
        
        return URL(string: urlString)
    }
    
    static func supports(symbology: VNBarcodeSymbology) -> Bool {
        return supportedVNBarcodeSymbology.contains(symbology)
    }
}

extension VNBarcodeSymbology {
    
    func toBarcodeAPISymbology() -> BarcodeAPI.Symbology? {
        switch self {
        case .qr:
            return .qr
        case .dataMatrix:
            return .datamatrix
        case .code39:
            return .code39
        case .upce:
            return .upce
        case .ean8:
            return .ean8
        case .ean13:
            return .ean13
        case .code93:
            return .code93
        case .code128:
            return .code128
        case .i2of5:
            return .interleaved2of5
        case .pdf417:
            return .pdf417
        case .aztec:
            return .azteccode
        default:
            return nil
        }
    }
}
