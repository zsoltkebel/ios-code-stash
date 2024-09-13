//
//  BarcodeImage.swift
//  Code Stash
//
//  Created by Zsolt Kébel on 12/09/2024.
//

import SwiftUI
import Vision

struct BarcodeImage: View {
    @Bindable var item: Item
    
    let generator = BarcodeGenerator()
    let squareCodes: [VNBarcodeSymbology] = [.qr, .aztec]
    
    var body: some View {
        let symbology = VNBarcodeSymbology(rawValue: item.symbologyRawValue)
        
        Group {
            if let imageData = item.barcodeImageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: squareCodes.contains(symbology) ? 220 : 400, minHeight: 120)
                    .background(.white)
            } else if let image = generator.generate(item.payloadStringValue, symbology) {
                image
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: squareCodes.contains(symbology) ? 220 : 400, minHeight: 120)
                    .background(.white)
            } else if BarcodeAPI.supports(symbology: symbology) {
                ProgressView()
                    .task {
                        item.barcodeImageData = await BarcodeAPI.loadBarcode(item.payloadStringValue, symbology: symbology.toBarcodeAPISymbology()!)
                    }
                    .frame(maxWidth: squareCodes.contains(symbology) ? 220 : 400, minHeight: 120)
            } else {
                ContentUnavailableView("Cannot display this code", systemImage: "exclamationmark.triangle.fill")
            }
        }
    }
}

#Preview {
    BarcodeImage(item: .StudentID())
}
