//
//  EditBarcodeView.swift
//  Code Clone
//
//  Created by Zsolt Kébel on 11/09/2024.
//

import SwiftUI
import Vision


struct EditBarcodeView: View {
    @Bindable var code: Item
    
    var body: some View {
        Form {
            //            TextField("Name", text: $code.name)
            Section("Payload & Presentation") {
                TextField("Code Payload", text: $code.payloadStringValue, axis: .vertical)
                    .multilineTextAlignment(.leading)
                    .lineLimit(5, reservesSpace: false)
                Picker("Symbology", selection: $code.symbologyRawValue) {
                    ForEach(VNBarcodeSymbology.allCases, id: \.self) { symbology in
                        Text(symbology.rawValue.replacing("VNBarcodeSymbology", with: "").toSentence()).tag(symbology.rawValue)
                    }
                }
            }
        }
        .navigationTitle($code.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        EditBarcodeView(code: .QR())
            .modelContainer(for: Item.self, inMemory: true)
    }
}

extension VNBarcodeSymbology {
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

extension String {
    
    // turn a pascal case string into a sentence
    func toSentence() -> String {
        var sentence = ""
        for c in self {
            if let prev = sentence.last {
                if prev.isLetter && prev.isLowercase && c.isUppercase {
                    sentence += " \(c)"
                } else if prev.isNumber && c.isLetter {
                    sentence += " \(c)"
                } else if prev.isLetter && c.isNumber {
                    sentence += " \(c)"
                } else {
                    sentence += "\(c)"
                }
            } else {
                sentence += "\(c)"
            }
        }
        return sentence
    }
}
