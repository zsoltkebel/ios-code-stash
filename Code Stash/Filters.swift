//
//  Filters.swift
//  Code Stash
//
//  Created by Zsolt Kébel on 21/09/2024.
//

import SwiftUI
import Vision

enum CodeFilter: RawRepresentable, Equatable, Hashable {
    case all
    case favorites
    case symbology(VNBarcodeSymbology)
    case content(CodeContent)
    
    init?(rawValue: String) {
        switch rawValue {
        case "All": self = .all
        case "Favorites": self = .favorites
        default:
            if let content = CodeContent(rawValue: rawValue) {
                self = .content(content)
            } else {
                self = .symbology(VNBarcodeSymbology(rawValue: rawValue))
            }
        }
    }
    
    var rawValue: String {
        switch self {
        case .all: return "All"
        case .favorites: return "Favorites"
        case .symbology(let symbology):
            return symbology.rawValue
        case .content(let content):
            return content.rawValue
        }
    }
    
    var symbology: VNBarcodeSymbology? {
        switch self {
        case .symbology(let symbology): return symbology
        default: return nil
        }
    }
    
    var isSymbology: Bool {
        self.symbology != nil
    }
    
    var content: CodeContent? {
        switch self {
        case .content(let content): return content
        default: return nil
        }
    }
    
    var isContent: Bool {
        self.content != nil
    }
    
    func isSimilar(to other: CodeFilter) -> Bool {
        switch (self, other) {
        case (.all, .all), (.favorites, .favorites): return true
        case (.symbology(_), .symbology(_)): return true
        default: return false
        }
    }
    
//    func accepts(_ item: Item) -> Bool {
//        switch self {
//        case .all: return true
//        case .favorites: return item.favorite
//        case .symbology(let vnSymbology):
//            return item.symbologyRawValue == vnSymbology.rawValue
//        }
//    }
}

extension Barcode {
//    func satisfies(_ filter: CodeFilter) -> Bool {
//        switch filter {
//        case .all: return true
//        case .favorites: return self.favorite
//        case .symbology(let vnSymbology):
//            return self.symbologyRawValue == vnSymbology.rawValue
//        }
//    }
}

struct Filters: View {
    
    @Binding var activeFilter: CodeFilter
        
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
                ButtonFilter(filter: .all, activeFilter: $activeFilter)
                
                ButtonFilter(filter: .favorites, activeFilter: $activeFilter)
                
                let contentTitleKey: LocalizedStringKey = activeFilter.isContent ? "\(activeFilter.content?.rawValue.toSentence()  ?? "Unknown")" : "Content"
                PickerFilter(contentTitleKey, activeFilter: $activeFilter) {
                    ForEach(CodeContent.allCases, id: \.self) { content in
                        Text(content.rawValue.toSentence()).tag(CodeFilter.content(content))
                    }
                }
                .tint(activeFilter.isContent ? .accentColor : .secondary)
                
                let titleKey: LocalizedStringKey = activeFilter.isSymbology ? "\(activeFilter.symbology?.simpleName ?? "Unknown")" : "Type"
                PickerFilter(titleKey, activeFilter: $activeFilter) {
                    ForEach(VNBarcodeSymbology.allCases, id: \.self) { symbology in
                        Text(symbology.simpleName).tag(CodeFilter.symbology(symbology))
                    }
                }
                .tint(activeFilter.isSymbology ? .accentColor : .secondary)
            }
        }
        .font(.system(size: 16.0, weight: .bold))
    }
}


#Preview {
    @Previewable @State var filter: CodeFilter = .all
    
    List {
        Filters(activeFilter: $filter)
            .listRowInsets(.init())
    }
    .environment(\.defaultMinListRowHeight, 0)
}

struct ButtonFilter: View {
    let filter: CodeFilter
    
    @Binding var activeFilter: CodeFilter
    
    var body: some View {
        Button(filter.rawValue) {
            activeFilter = filter
        }
        .buttonStyle(.bordered)
        .buttonBorderShape(.capsule)
//        .font(.footnote)
        .tint(activeFilter == filter ? .accentColor : .secondary)
    }
}

struct PickerFilter<Content>: View where Content : View {
    
    let titleKey: LocalizedStringKey
    var content: () -> Content
    
    @Binding var activeFilter: CodeFilter

    init(_ titleKey: LocalizedStringKey, activeFilter: Binding<CodeFilter>, content: @escaping () -> Content) {
        self.titleKey = titleKey
        self._activeFilter = activeFilter
        self.content = content
    }
    
    var body: some View {
        Menu {
            Picker(selection: $activeFilter, content: content, label: {})
        } label: {
            HStack {
                Text(titleKey)
                    .lineLimit(1)
                    .frame(maxWidth: 120.0)
                Image(systemName: "chevron.up.chevron.down")
                    .imageScale(.small)
            }
        }
        .buttonStyle(.bordered)
        .clipShape(.capsule)
    }
}
