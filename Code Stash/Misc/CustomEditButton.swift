//
//  CustomEditButton.swift
//  Code Stash
//
//  Created by Zsolt Kébel on 18/09/2024.
//

import SwiftUI

struct CustomEditButton: View {
    @Binding var editMode: EditMode
    
    let systemImage: String = "pencil"
    
    var body: some View {
        Button("Edit", systemImage: systemImage) {
            withAnimation {
                editMode = .active
            }
        }
    }
}

#Preview {
    @Previewable @State var editMode: EditMode = .inactive
    CustomEditButton(editMode: $editMode)
}
