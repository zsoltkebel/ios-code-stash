//
//  AddBarcodeView.swift
//  Code Stash
//
//  Created by Zsolt Kébel on 12/09/2024.
//

import SwiftUI
import Vision

struct AddBarcodeView: View {
    
    enum FocusedField {
        case name, payload
    }
    
    @Bindable var item: Item = Item()
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    @FocusState private var focusedField: FocusedField?

    var body: some View {
        Form {
            TextField("Name", text: $item.name)
                .focused($focusedField, equals: .name)

            CodeTypeAndContentInputSection(item: item, sectionExpanded: true)
            
            BarcodeImage(item: item)
                .frame(maxWidth: .infinity)
        }
        .navigationTitle("Add Code")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(content: {
            ToolbarItem(placement: .confirmationAction) {
                Button("Add", action: addItem)
            }
        })
        .onAppear {
            focusedField = .name
        }
    }
    
    private func addItem() {
        item.barcodeImageData = nil // to make sure written in palyload is loaded (can save item without submitting textfield)
        withAnimation {
            modelContext.insert(item)
        }
        dismiss()
    }
    
    private func clearImageData() {
        item.barcodeImageData = nil
    }
}

#Preview {
    NavigationStack {
        AddBarcodeView(item: Item())
            .modelContainer(for: Item.self, inMemory: true)
    }
}
