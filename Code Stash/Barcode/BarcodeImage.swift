//
//  BarcodeImage.swift
//  Code Stash
//
//  Created by Zsolt Kébel on 12/09/2024.
//

import SwiftUI
import UniformTypeIdentifiers
import Vision

struct BarcodeImage: View {
    @Bindable var item: Item
    
    let generator = BarcodeGenerator()
    let squareCodes: [VNBarcodeSymbology] = [.qr, .aztec]
    
    var body: some View {
        let symbology = VNBarcodeSymbology(rawValue: item.symbologyRawValue)
        
        HStack {
            if let imageData = item.barcodeImageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: squareCodes.contains(symbology) ? 220 : 400, minHeight: 120)
                    .background(.white)
            } else if let image = generator.generate(item.payloadStringValue, symbology) {
                VStack {
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: squareCodes.contains(symbology) ? 220 : 400, minHeight: 120)
                        .background(.white)
                    Text(item.payloadStringValue)
                }
            } else if BarcodeAPI.supports(symbology: symbology) {
                ProgressView()
                    .task {
                        item.barcodeImageData = await BarcodeAPI.load(barcode: item)
                    }
                    .frame(maxWidth: squareCodes.contains(symbology) ? 220 : 400, minHeight: 120)
            } else {
                ContentUnavailableView("Cannot display this code", systemImage: "exclamationmark.triangle.fill")
            }
        }
        .padding(8)
        .background {
            Color.white
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .contextMenu(menuItems: {
            Button("Copy Content", systemImage: "doc.on.doc") {
                UIPasteboard.general.setValue(item.payloadStringValue, forPasteboardType: UTType.plainText.identifier)
            }
        })
    }
}

#Preview {
    ZStack {
        Color.blue
        BarcodeImage(item: .QR())
    }
}
