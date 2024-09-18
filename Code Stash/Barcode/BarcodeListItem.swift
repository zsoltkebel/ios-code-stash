//
//  CodeListItem.swift
//  Code Clone
//
//  Created by Zsolt Kébel on 11/09/2024.
//

import SwiftUI
import Vision

struct BarcodeListItem: View {
    var barcode: Item
    var showFavoriteMarker = true
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(barcode.name)
                    .font(.headline)
                    .lineLimit(1)
                Text(barcode.symbologyRawValue.replacing("VNBarcodeSymbology", with: "").toSentence())
                    .foregroundStyle(.secondary)
            }
            Spacer()
            let symbology = VNBarcodeSymbology(rawValue: barcode.symbologyRawValue)
            if !BarcodeGenerator.supports(symbology) && !BarcodeAPI.supports(symbology) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.tertiary)
            }
            barcode.type.image
//                .imageScale(.large)
                .foregroundStyle(.tertiary)
        }
        .contextMenu {
            Button(barcode.favorite ? "Remove Favorite" : "Mark as Favorite", systemImage: barcode.favorite ? "star.fill" : "star") {
                toggleFavorite()
            }
        }
    }
    
    private func toggleFavorite() {
        withAnimation {
            barcode.favorite.toggle()
        }
    }
}

#Preview {
    List {
        BarcodeListItem(barcode: .QR())
        BarcodeListItem(barcode: .Barcode())
        BarcodeListItem(barcode: .StudentID())
        BarcodeListItem(barcode: .Unknown())
        BarcodeListItem(barcode: .WIFI())
    }
}
