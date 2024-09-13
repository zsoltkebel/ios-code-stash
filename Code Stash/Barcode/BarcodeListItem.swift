//
//  CodeListItem.swift
//  Code Clone
//
//  Created by Zsolt Kébel on 11/09/2024.
//

import SwiftUI

struct BarcodeListItem: View {
    var barcode: Item
    var showFavoriteMarker = true
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(barcode.name)
                .font(.headline)
            Text(barcode.symbologyRawValue.replacing("VNBarcodeSymbology", with: "").toSentence())
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    List {
        BarcodeListItem(barcode: .QR())
        BarcodeListItem(barcode: .Barcode())
    }
}
