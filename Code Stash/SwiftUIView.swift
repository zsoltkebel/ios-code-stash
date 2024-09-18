//
//  SwiftUIView.swift
//  Code Stash
//
//  Created by Zsolt Kébel on 15/09/2024.
//

import SwiftUI

struct SwiftUIView: View {
//    @Environment(\.editMode) private var editMode
    
    @Bindable var item: Item
    
    @Namespace var barcodeView
    
    @State var editMode = EditMode.inactive
    
    var body: some View {
//        let isEditing = editMode?.wrappedValue.isEditing ?? false
        let isEditing = editMode.isEditing
        Group {
            if isEditing == true {
                EditBarcodeView(item: item, namespace: barcodeView)
            } else {
                BarcodeView(namespace: barcodeView, item: item)
            }
        }
        .navigationTitle(isEditing ? "Edit Code" : item.name)
        .navigationBarTitleDisplayMode(.inline)
//        .navigationBarBackButtonHidden(isEditing)
        .toolbar {
            ToolbarItem {
                Button(action: { item.favorite.toggle() },
                       label: {
                    Image(systemName: item.favorite ? "star.fill" : "star")
                })
            }
            
            if editMode.isEditing {
                ToolbarItem {
                    EditButton()
                }
            } else {
                ToolbarItem {
                    Menu("More", systemImage: "ellipsis.circle") {
                        Button("Edit", systemImage: "pencil") {
                            withAnimation {
                                editMode = .active
                            }
                        }
                    }
                }
            }
        }
        .environment(\.editMode, $editMode)
        .id(item.id)
        .onDisappear {
            editMode = .inactive
        }
    }
}

#Preview {
    NavigationStack {
        EditButton()
        SwiftUIView(item: .Barcode())
    }
}
