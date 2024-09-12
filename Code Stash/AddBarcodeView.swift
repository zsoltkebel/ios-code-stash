//
//  AddBarcodeView.swift
//  Code Stash
//
//  Created by Zsolt Kébel on 12/09/2024.
//

import SwiftUI
import Vision

struct AddBarcodeView: View {
    @Bindable var item: Item = Item()
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Form {
            TextField("Name", text: $item.name)
            
            Section("Payload & Presentation") {
                TextField("Code Payload", text: $item.payloadStringValue, axis: .vertical)
                    .multilineTextAlignment(.leading)
                    .lineLimit(5, reservesSpace: false)
                Picker("Symbology", selection: $item.symbologyRawValue) {
                    ForEach(VNBarcodeSymbology.allCases, id: \.self) { symbology in
                        Text(symbology.rawValue.replacing("VNBarcodeSymbology", with: "").toSentence()).tag(symbology.rawValue)
                    }
                }
            }
            BarcodeView(barcode: item)
        }
        .navigationTitle(item.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(content: {
            ToolbarItem(placement: .confirmationAction) {
                Button("Add", action: addItem)
            }
        })
    }
    
    private func addItem() {
        withAnimation {
            modelContext.insert(item)
        }
        dismiss()
    }
}

#Preview {
    NavigationStack {
        AddBarcodeView(item: Item())
            .modelContainer(for: Item.self, inMemory: true)
    }
}
