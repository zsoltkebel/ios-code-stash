//
//  NewCodeButtons.swift
//  Code Stash
//
//  Created by Zsolt Kébel on 21/09/2024.
//

import SwiftUI
import Vision

struct NewCodeButtons: View {
    @Environment(\.editMode) var editMode
    @Environment(\.isSearching) var isSearching

    @State private var scanning = false
    @State private var enteringCodeDetails = false
    @State private var newItem = Barcode()

    @Binding var selection: Barcode.ID?
    
    var body: some View {
        if isSearching {
            EmptyView()
        } else {
            LazyVGrid(columns: [.init(.adaptive(minimum: 140))]) {
                CustomButton(title: "Scan", systemName: "qrcode.viewfinder", action: scanItem)
                    .disabled(editMode?.wrappedValue.isEditing ?? false)
                
                CustomButton(title: "Create", systemName: "rectangle.and.pencil.and.ellipsis", action: addItem)
                    .disabled(editMode?.wrappedValue.isEditing ?? false)
            }
            
            .sheet(isPresented: $scanning, content: {
                BarcodeViewfinderView()
                    .toolbarRole(.editor)
            })
            .sheet(isPresented: $enteringCodeDetails) {
                NavigationStack {
                    AddBarcodeView(item: newItem, completion: { newItem in
                        selection = newItem.id
                    })
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel", action: {
                                enteringCodeDetails = false
                            })
                        }
                    }
                }
            }
        }
    }
    
    private func scanItem() {
        scanning = true
    }
    
    private func addItem() {
        newItem = Barcode()
        newItem.symbologyRawValue = VNBarcodeSymbology.qr.rawValue
        enteringCodeDetails = true
    }
}

struct CustomButton: View {
    var title: LocalizedStringKey
    var systemName: String
    var action: () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: action, label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: systemName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                    Spacer()
                }
                Text(title)
                    .lineLimit(1)
                    .font(.headline)
            }
            .padding()
            
        })
        
        .buttonStyle(.bordered)
        //        .buttonBorderShape(.roundedRectangle(radius: 10.0))
        .tint(.accent)
        
        //        .buttonStyle(.borderedProminent)
        //        .buttonBorderShape(.roundedRectangle(radius: 10.0))
        //        .foregroundStyle(.accent)
        //        .tint(Color(colorScheme == .dark ? UIColor.secondarySystemBackground : UIColor.systemBackground))
        
        .frame(maxWidth: .infinity)
        //        .background {
        //            Color(colorScheme == .dark ? UIColor.secondarySystemBackground : UIColor.systemBackground).clipShape(RoundedRectangle(cornerRadius: 10.0))
        //        }
    }
}

#Preview {
    @Previewable @State var selection: Barcode.ID?
    
    NewCodeButtons(selection: $selection)
}
