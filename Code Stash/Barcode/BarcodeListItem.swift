//
//  CodeListItem.swift
//  Code Clone
//
//  Created by Zsolt Kébel on 11/09/2024.
//

import SwiftUI
import Vision

struct BarcodeListItem: View {
    var barcode: Barcode
    var showFavoriteMarker = true
    
    var body: some View {
        HStack {
            barcode.imageSymbol
                .resizable()
                .scaledToFit()
                .frame(width: 18.0, height: 18.0)
                .padding(10.0)
                .foregroundColor(.white)
                .background(.accent)
                .clipShape(Circle())
//                .padding(.vertical, 2.0)
            
            VStack(alignment: .leading) {
                Text(barcode.name.isEmpty ? "Unnamed Code" : barcode.name)
                    .lineLimit(1)
                    .font(.headline)
                    .fontWeight(.regular)
                                
                Text(barcode.vnSymbology.simpleName)
                    .lineLimit(1)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.leading, 4.0)
            
            Spacer()
            
            let symbology = VNBarcodeSymbology(rawValue: barcode.symbologyRawValue)
            if !BarcodeGenerator.supports(symbology) && !BarcodeAPI.supports(symbology) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.leading, -2.0)
        .contextMenu {
            Button(barcode.favorite ? "Remove Favorite" : "Mark as Favorite", systemImage: barcode.favorite ? "star.fill" : "star") {
                toggleFavorite()
            }
        }
    }
    
    private func toggleFavorite() {
        withAnimation {
            barcode.favorite.toggle()
        }
    }
}

#Preview {
    List {
        BarcodeListItem(barcode: .qr)
        BarcodeListItem(barcode: .code128)
        BarcodeListItem(barcode: .code39)
        BarcodeListItem(barcode: .code39Checksum)
        BarcodeListItem(barcode: .wifi)
    }
}
