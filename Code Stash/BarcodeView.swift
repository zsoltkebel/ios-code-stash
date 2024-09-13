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
    let barcodeGenerator = BarcodeGenerator()
    
    @State var imageD: Data?
    
    init(barcode: Item) {
        self.barcode = barcode
    }
    
    var body: some View {
        VStack(spacing: 0) {
            BarcodeImage(item: barcode)
            Text(barcode.payloadStringValue.isEmpty ? "Empty String" : barcode.payloadStringValue)
        }
    }
    
}

#Preview {
    BarcodeView(barcode: .StudentID())
//        .modelContainer(for: Item.self, inMemory: true)
}
