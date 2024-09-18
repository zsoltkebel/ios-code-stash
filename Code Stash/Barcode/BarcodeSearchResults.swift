//
//  BarcodeSearchResults.swift
//  Code Stash
//
//  Created by Zsolt Kébel on 13/09/2024.
//

import SwiftUI
import SwiftData

struct BarcodeSearchResults: View {
    @Binding var searchText: String
    @Query private var items: [Item]
    
    @State private var favoritesExpanded = true
    @State private var historyExpanded = true
    
    @Environment(\.modelContext) var modelContext
    
    init(searchText: Binding<String>) {
        _searchText = searchText
        if searchText.wrappedValue.isEmpty {
            _items = Query(sort: \.timestamp, order: .reverse)
        } else {
            let term = searchText.wrappedValue
            _items = Query(filter: #Predicate { item in
                item.name.contains(term)
            }, sort: \.timestamp, order: .reverse)
        }
    }
    
    var body: some View {
        if !favoriteItems.isEmpty {
            Section("Favorites", isExpanded: $favoritesExpanded) {
                ForEach(favoriteItems) { item in
                    NavigationLink {
                        SwiftUIView(item: item)
                        //                        EditBarcodeView(item: item, namespace: )
                        //                            BarcodeView(barcode: item)
                    } label: {
                        BarcodeListItem(barcode: item, showFavoriteMarker: false)
                    }
                }
                .onDelete(perform: deleteFavoriteItems)
            }
        }
        
        if !nonFavoriteItems.isEmpty {
            Section("History", isExpanded: $historyExpanded) {
                ForEach(nonFavoriteItems) { item in
                    NavigationLink {
                        SwiftUIView(item: item)
                        //                        EditBarcodeView(item: item)
                        //                            BarcodeView(barcode: item)
                    } label: {
                        BarcodeListItem(barcode: item)
                    }
                }
                .onDelete(perform: deleteNonFavoriteItems)
            }
        }
    }
    
    var favoriteItems: [Item] {
        return items.filter({ $0.favorite })
    }
    
    var nonFavoriteItems: [Item] {
        return items.filter({ !$0.favorite })
    }
    
    private func deleteFavoriteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(favoriteItems[index])
            }
        }
    }
    
    private func deleteNonFavoriteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(nonFavoriteItems[index])
            }
        }
    }
}

#Preview {
    List {
        BarcodeSearchResults(searchText: .constant(""))
    }
}
