//
//  VNBarcodeSymbology+BarcodeAPI.swift
//  Code Stash
//
//  Created by Zsolt Kébel on 21/09/2024.
//

import Foundation
import Vision

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
