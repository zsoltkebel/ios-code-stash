//
//  ContentView.swift
//  Code Clone
//
//  Created by Zsolt Kébel on 11/09/2024.
//

import SwiftUI
import SwiftData
import Vision

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    @State var isSearching: Bool = false
    
    @Query(sort: \Barcode.timestamp, order: .reverse) private var items: [Barcode]
    
    @State private var scanning = false
    @State private var enteringCodeDetails = false
    @State private var searchText = ""
    @State private var newItem = Barcode()
    @State private var favoritesExpanded = true
    @State private var historyExpanded = true
    
    @State private var editMode: EditMode = .inactive
    
    @State private var selection: Barcode.ID?
    
    @AppStorage("default_symbology") var default_symbology: String = "VNBarcodeSymbologyQR"
    
    @AppStorage("active_filter") var activeFilter: CodeFilter = .all
    
    var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                Section {
                    NewCodeButtons(selection: $selection)
                        .padding(.top, 20.0)
                } header: {
                    Filters(activeFilter: $activeFilter)
                        .textCase(nil)
                        .clipShape(RoundedRectangle(cornerRadius: 10.0))
                }
                .listRowInsets(.init())
                .listRowBackground(Color.clear)
                .listSectionSpacing(20.0)
                
                //                BarcodeSearchResults(searchText: $searchText)
                CodeSearchResults(searchText: $searchText, filter: $activeFilter)
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
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .automatic), prompt: searchPrompt)
    }
    
    var searchResults: [Barcode] {
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
        newItem = Barcode()
        newItem.symbologyRawValue = default_symbology
        enteringCodeDetails = true
    }
    
    var searchPrompt: LocalizedStringKey {
        switch activeFilter {
        case .all:
            return "Search"
        case .favorites:
            return "Search favorites"
        case .symbology(let vnSymbology):
            return "Search \(vnSymbology.simpleName) codes"
        case .content(let content):
            return "Search \(content.rawValue.toSentence()) codes"
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Barcode.self, inMemory: true)
}
