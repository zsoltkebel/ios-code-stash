//
//  BarcodeView.swift
//  Code Clone
//
//  Created by Zsolt Kébel on 11/09/2024.
//

import SwiftUI
import Vision

struct BarcodeView: View {
    var barcode: Item
    var barcodeGenerator: CodeGenerator?
    
    init(barcode: Item) {
        self.barcode = barcode
        switch VNBarcodeSymbology(rawValue: barcode.symbologyRawValue) {
        case .code128, .code39FullASCII, .code39:
            self.barcodeGenerator = BarcodeGenerator()
        case .qr:
            self.barcodeGenerator = QRCodeGenerator()
        default:
            print("new code type: \(barcode.symbologyRawValue)")
//            fatalError("Barcode symbology is not supported")
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if let generator = barcodeGenerator {
                generator.generateBarcode(barcode.payloadStringValue)
                    .resizable()
                    .scaledToFit()
            } else {
                ContentUnavailableView("Can't visualise this code", systemImage: "barcode")
            }
            Text(barcode.payloadStringValue.isEmpty ? "Unknown data" : barcode.payloadStringValue)
        }
    }
}

#Preview {
    BarcodeView(barcode: .QR())
}
