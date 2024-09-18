//
//  ContentView.swift
//  Code Clone
//
//  Created by Zsolt Kébel on 11/09/2024.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    
    @Query(sort: \Item.timestamp, order: .reverse) private var items: [Item]
    
    @State private var scanning = false
    @State private var enteringCodeDetails = false
    @State private var searchText = ""
    @State private var newItem = Item()
    @State private var favoritesExpanded = true
    @State private var historyExpanded = true
    
    @State private var editMode: EditMode = .inactive
    
    @State private var selection: Item.ID?
    
    @AppStorage("default_symbology") var default_symbology: String = "VNBarcodeSymbologyQR"
    
    
    var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                LazyVGrid(columns: [.init(.adaptive(minimum: 140))]) {
                    CustomButton(title: "Scan", systemName: "qrcode.viewfinder", action: scanItem)
                        .disabled(editMode.isEditing)
                    
                    CustomButton(title: "Enter Details", systemName: "rectangle.and.pencil.and.ellipsis", action: addItem)
                        .disabled(editMode.isEditing)
                }
                .listRowInsets(.init())
                .listRowBackground(Color.clear)
                
                //                Section {
                //                    EmptyView()
                //                } footer: {
                //                    LazyVGrid(columns: columnGrid, spacing: 16, content: {
                //                        CustomButton(title: "Scan", systemName: "qrcode.viewfinder", action: scanItem)
                //
                //                        CustomButton(title: "Enter Details", systemName: "rectangle.and.pencil.and.ellipsis", action: addItem)
                //                    })
                //                    .listRowInsets(.init())
                //                }
                
                BarcodeSearchResults(searchText: $searchText)
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Codes")
            .overlay {
                if items.isEmpty {
                    ContentUnavailableView("No Codes Yet", systemImage: "qrcode", description: Text("Start by scanning a code or entering code details manually."))
                }
            }
            .toolbar {
                if editMode.isEditing {
                    ToolbarItem {
                        EditButton()
                    }
                } else {
                    ToolbarItem {
                        Menu("More", systemImage: "ellipsis.circle") {
                            if !items.isEmpty {
                                CustomEditButton(editMode: $editMode)
                            }
                            
                            Section {
                                BrightnessToggle()
                            }
                        }
                    }
                }
            }
            .environment(\.editMode, $editMode)
            //            .toolbarTitleDisplayMode(.inline)
//            .navigationDestination(for: Item.self) { item in
//                SwiftUIView(item: item)
//            }
        } detail: {
            if let selectedItem = items.first(where: { $0.id == selection }) {
                SwiftUIView(item: selectedItem, onDelete: {
                    withAnimation {
                        selection = nil
                    }
                })
            } else {
                Text("Select an item.")
            }
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
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .automatic))
    }
    
    var searchResults: [Item] {
        if searchText.isEmpty {
            return items
        } else {
            return items.filter { $0.name.contains(searchText) }
        }
    }
    
    private func scanItem() {
        scanning = true
    }
    
    private func addItem() {
        newItem = Item()
        newItem.symbologyRawValue = default_symbology
        enteringCodeDetails = true
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
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
