//
//  CodeDetails.swift
//  Code Stash
//
//  Created by Zsolt Kébel on 18/09/2024.
//

import SwiftUI
import SwiftData

struct CodeDetails: View {
    @Binding var itemId: PersistentIdentifier
    
    var body: some View {
        Text("hello")
    }
}

#Preview {
    CodeDetails(itemId: .constant(Item.Barcode().id))
        .modelContainer(for: Item.self, inMemory: true)
}
