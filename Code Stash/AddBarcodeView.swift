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
    var completion: ((Item) -> Void)?
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    @FocusState private var focusedField: BarcodeField?
    
    var body: some View {
        Form {
            HStack {
                Spacer()
                BarcodeImage(item: item)
                    .frame(maxHeight: 120)
                Spacer()
            }
            .listRowInsets(.init())
            .listRowBackground(Color.clear)
            
            Section {
                BarcodeNameTypeContentInput(item: item, focusedField: _focusedField)
            }
        }
        .navigationTitle("New Code")
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
            dismiss()
            self.completion?(item)
        }
    }
    
    private func clearImageData() {
        item.barcodeImageData = nil
    }
}

#Preview {
    NavigationStack {
        AddBarcodeView(item: .StudentID())
            .modelContainer(for: Item.self, inMemory: true)
    }
}
