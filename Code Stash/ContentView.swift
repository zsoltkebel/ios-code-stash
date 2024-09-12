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
    @Query(sort: \Item.timestamp, order: .reverse) private var items: [Item]
    
    @State private var scanning = false
    @State private var enteringCodeDetails = false
    @State private var searchText = ""
    @State private var newItem = Item()
    
    var body: some View {
        NavigationSplitView {
            let columnGrid: [GridItem] =
            Array(repeating: .init(.flexible(), spacing: 16), count: 2)
            
            List {
                Section {
                    ForEach(searchResults) { item in
                        NavigationLink {
                            EditBarcodeView(code: item)
                            BarcodeView(barcode: item)
                        } label: {
                            BarcodeListItem(barcode: item)
                        }
                    }
                    .onDelete(perform: deleteItems)
                } header: {
                    LazyVGrid(columns: columnGrid, spacing: 16, content: {
                        

                        CustomButton(title: "Scan", systemName: "qrcode.viewfinder", action: scanItem)
                        
                        
                        CustomButton(title: "Enter Details", systemName: "rectangle.and.pencil.and.ellipsis", action: addItem)
                        
                    })
                    .listRowInsets(.init())
                    .padding(.vertical)
                }
                
                Section {
                    
                    
                }
                
            }
            .navigationTitle("Codes")
            .overlay {
                if items.isEmpty {
                    ContentUnavailableView("No Barcodes", systemImage: "tray", description: Text("Start by adding some items."))
                }
            }
            .toolbar {
                ToolbarItem {
                    EditButton()
                }
            }
            
            //            .toolbarTitleDisplayMode(.inline)
        } detail: {
            Text("Select an item")
        }
        .sheet(isPresented: $scanning, content: {
            SwiftUIView()
                .toolbarRole(.editor)
        })
        .sheet(isPresented: $enteringCodeDetails) {
            NavigationStack {
                AddBarcodeView(item: newItem)
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
        enteringCodeDetails = true
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}

struct CustomButton: View {
    var title: String
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
                        .tint(.accentColor)
                    Spacer()
                }
                Text(title)
                    .lineLimit(1)
                    .font(.headline)
                    .tint(.accentColor)
            }
            .padding()
            
        })
        .frame(maxWidth: .infinity)
        .background {
            Color(colorScheme == .dark ? UIColor.secondarySystemBackground : UIColor.systemBackground).clipShape(RoundedRectangle(cornerRadius: 10.0))
        }
    }
}
