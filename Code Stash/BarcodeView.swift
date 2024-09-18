//
//  BarcodeView.swift
//  Code Stash
//
//  Created by Zsolt Kébel on 15/09/2024.
//

import SwiftUI
import UniformTypeIdentifiers

struct BarcodeView: View {
    let namespace: Namespace.ID
    let item: Item
    
    @Environment(\.colorScheme) var colorScheme

    @State var linkReachable: Bool = false
    @State var wifiConfigured: Bool = false
    
    var body: some View {
        VStack {
            Spacer()
            BarcodeImage(item: item)
                .matchedGeometryEffect(id: "codeView", in: namespace)
                .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 10))
                .contextMenu(ContextMenu(menuItems: {
                    Button("Copy Content", systemImage: "doc.on.doc") {
                        UIPasteboard.general.setValue(item.payloadStringValue, forPasteboardType: UTType.plainText.identifier)
                    }
                    
                    Section {
                        Button("Reload Image", systemImage: "icloud.and.arrow.down") {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                withAnimation {
                                    item.clearImageData()
                                }
                            }
                        }
                        .disabled(item.barcodeImageData == nil)
                    }
                }))
                .frame(maxHeight: 250)
            Spacer()
            
            HStack {
                // Share Button
                if let imageData = item.barcodeImageData,
                   let uiImage = UIImage(data: imageData) {
                    let image = Image(uiImage: uiImage)
                    
                    ShareLink(item: image, preview: SharePreview(item.name, image: image))
                        .buttonStyle(.bordered)
                        .buttonBorderShape(.capsule)
//                        .tint(.accent)
                }
                
                if let url = item.url,
                   linkReachable {
                    Link(destination: url) {
                        Label("Open Link", systemImage: "link")
                    }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.capsule)
                }
                
                if let wifi = item.wifi {
                    Button("Connect to Wi-Fi", systemImage: "wifi") {
                        wifi.connect()
                    }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.capsule)
                    .disabled(wifiConfigured)
                    .task {
                        wifiConfigured = await wifi.isConfigured()
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .safeAreaPadding()
        .background {
            Color(colorScheme == .dark ? UIColor.systemBackground : UIColor.secondarySystemBackground)
                .ignoresSafeArea()
        }
        .task {
            if let url = URL(string: item.payloadStringValue) {
                url.isReachable { success in
                    linkReachable = success
                }
            }
        }
        .autoIncreaseBrightness()
    }
}

#Preview {
    @Namespace var sample
    
    return NavigationStack {
        BarcodeView(namespace: sample, item: .QR())
    }
}

extension URL {
    func isReachable(completion: @escaping (Bool) -> ()) {
        var request = URLRequest(url: self)
        request.httpMethod = "HEAD"
        URLSession.shared.dataTask(with: request) { _, response, _ in
//            print("response: \(response)")
//            completion((response as? HTTPURLResponse)?.statusCode == 200)
            completion(response != nil)
        }.resume()
    }
}
