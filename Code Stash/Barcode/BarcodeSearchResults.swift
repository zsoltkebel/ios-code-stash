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
    @Query private var items: [Barcode]
    
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
            Section(isExpanded: $favoritesExpanded) {
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
            } header: {
                Text("Favorites")
                    .font(.headline)
                    .foregroundStyle(Color(UIColor.label))
                    .textCase(nil)
                    .listRowInsets(.init(top: 10.0, leading: 10.0, bottom: 10.0, trailing: 10.0))
            }
        }
        
        if !nonFavoriteItems.isEmpty {
            Section(isExpanded: $historyExpanded) {
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
            } header: {
                Text("History")
                    .font(.headline)
                    .foregroundStyle(Color(UIColor.label))
                    .textCase(nil)
                    .listRowInsets(.init(top: 10.0, leading: 10.0, bottom: 10.0, trailing: 10.0))
            }
        }
    }
    
    var favoriteItems: [Barcode] {
        return items.filter({ $0.favorite })
    }
    
    var nonFavoriteItems: [Barcode] {
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
