//
//  VNBarcodeSymbology+Image.swift
//  Code Stash
//
//  Created by Zsolt Kébel on 21/09/2024.
//

import Foundation
import Vision
import SwiftUICore

extension VNBarcodeSymbology {
    static let qrLike: [VNBarcodeSymbology] = [.aztec, .dataMatrix, .qr]
    static let barcodeLike: [VNBarcodeSymbology] = [.code128, .code39, .code93, .ean13, .ean8, .i2of5, .pdf417, .upce]
    
    var image: Image {
        if VNBarcodeSymbology.qrLike.contains(self) {
            return Image(systemName: "qrcode")
        } else if VNBarcodeSymbology.barcodeLike.contains(self) {
            return Image(systemName: "barcode")
        } else {
            return Image(systemName: "questionmark")
        }
    }
    
    var simpleName: String {
        self.rawValue.replacing("VNBarcodeSymbology", with: "").toSentence()
    }
    
    static let allCases: [VNBarcodeSymbology] = [
        .aztec,
        .codabar,
        .code128,
        .code39,
        .code39Checksum,
        .code39FullASCII,
        .code39FullASCIIChecksum,
        .code93,
        .code93i,
        .dataMatrix,
        .ean13,
        .ean8,
        .gs1DataBar,
        .gs1DataBarExpanded,
        .gs1DataBarLimited,
        .i2of5,
        .i2of5Checksum,
        .itf14,
        .microPDF417,
        .microQR,
        .msiPlessey,
        .pdf417,
        .qr,
        .upce
    ]
}
