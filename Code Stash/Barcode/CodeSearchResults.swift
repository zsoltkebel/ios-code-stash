//
//  CodeSearchResults.swift
//  Code Stash
//
//  Created by Zsolt Kébel on 21/09/2024.
//

import SwiftData
import SwiftUI

struct CodeSearchResults: View {
    @Binding var searchText: String
    @Binding var filter: CodeFilter
        
    @Query private var items: [Barcode]
    
    @State private var favoritesExpanded = true
    @State private var historyExpanded = true
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    init(searchText: Binding<String>, filter: Binding<CodeFilter>) {
        _searchText = searchText
        _filter = filter
        
//        var filterPredicate: Predicate<Item>
//        switch filter.wrappedValue {
//        case .all:
//            filterPredicate = .true
//        case .favorites:
//            filterPredicate = #Predicate<Item> { item in item.favorite }
//        case .symbology(let vnSymbology):
//            let rawValue = vnSymbology.rawValue
//            filterPredicate = #Predicate<Item> { item in item.symbologyRawValue == rawValue }
//        case .content(let content):
//            filterPredicate = #Predicate<Item> { item in
//                return item.content() == content
//            }
//        }
        
        if searchText.wrappedValue.isEmpty {
//            _items = Query(filter: filterPredicate, sort: \.timestamp, order: .reverse)
            _items = Query(sort: \.timestamp, order: .reverse)
        } else {
            let term = searchText.wrappedValue
            let searchTextPredicate = #Predicate<Barcode> { item in
                item.name.contains(term) || item.payloadStringValue.contains(term)
            }
            
            _items = Query(filter: #Predicate { item in
//                filterPredicate.evaluate(item) && searchTextPredicate.evaluate(item)
                searchTextPredicate.evaluate(item)
            }, sort: \.timestamp, order: .reverse)
        }
    }
    
    var body: some View {
        ForEach(results) { item in
            NavigationLink {
                SwiftUIView(item: item)
            } label: {
                BarcodeListItem(barcode: item, showFavoriteMarker: false)
            }
        }
        .onDelete(perform: deleteItem)
    }
    
    var results: [Barcode] {
        switch filter {
        case .all:
            return items
        case .favorites:
            return items.filter({ $0.favorite })
        case .symbology(let vnSymbology):
            return items.filter({ $0.symbologyRawValue == vnSymbology.rawValue })
        case .content(let content):
            return items.filter({ $0.content == content })
        }
    }
    
    var favoriteItems: [Barcode] {
        return items.filter({ $0.favorite })
    }
    
    var nonFavoriteItems: [Barcode] {
        return items.filter({ !$0.favorite })
    }
    
    private func deleteItem(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(results[index])
                dismiss()
            }
        }
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
