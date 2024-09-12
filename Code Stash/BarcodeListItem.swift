//
//  CodeListItem.swift
//  Code Clone
//
//  Created by Zsolt Kébel on 11/09/2024.
//

import SwiftUI

struct BarcodeListItem: View {
    var barcode: Item
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(barcode.name)
                .font(.headline)
//            Text(barcode.payloadStringValue)
            Text(barcode.symbologyRawValue.replacing("VNBarcodeSymbology", with: "").toSentence())
                .foregroundStyle(.secondary)
//            Text(barcode.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
        }
    }
}

#Preview {
    List {
        BarcodeListItem(barcode: Item(timestamp: Date()))
    }
}
