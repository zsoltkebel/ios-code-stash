//
//  BarcodeImage.swift
//  Code Stash
//
//  Created by Zsolt Kébel on 12/09/2024.
//

import SwiftUI
import UniformTypeIdentifiers
import Vision

/// A view that displays a barcode image.
///
/// It generates or downloads image data automatically.
/// Image data is reloaded when ``Item``'s payload or symbology changes.
/// This view auto populates ``Item``'s barcodeImageData field.
///
/// Image download tasks are cancelled if unfinished when underlying data changes.
struct BarcodeImage: View {
    @Bindable var item: Item
    
    @State private var imageDownloadTask: Task<Void, Never>?
    
    var body: some View {
        
        HStack {
            if let image = item.image {
                
                image
                    .resizable()
                    .scaledToFit()
                    .padding(8)
                    .background {
                        Color.white
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                
            } else if symbologySupported {
                ProgressView()
                    .task {
                        reloadImageData()
                    }
            } else {
                ContentUnavailableView("Cannot display this code", systemImage: "exclamationmark.triangle.fill")
            }
        }
        .onChange(of: item.payloadStringValue, { _, _ in
            reloadImageData()
        })
        .onChange(of: item.symbologyRawValue, { _, _ in
            reloadImageData()
        })
        .frame(idealWidth: 200, idealHeight: 200)
        //        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 10))
        //        .contextMenu(menuItems: {
        //            Button("Copy Content", systemImage: "doc.on.doc") {
        //                UIPasteboard.general.setValue(item.payloadStringValue, forPasteboardType: UTType.plainText.identifier)
        //            }
        //        })
    }

    var symbologySupported: Bool {
        BarcodeGenerator.supports(item.vnSymbology) || BarcodeAPI.supports(item.vnSymbology)
    }
    
    private func reloadImageData() {
        item.clearImageData()
        
        if let imageData = BarcodeGenerator.imageData(for: item) {
            item.barcodeImageData = imageData
        } else {
            imageDownloadTask?.cancel()
            imageDownloadTask = Task.detached { @MainActor in
                item.barcodeImageData = await BarcodeAPI.load(barcode: item)
            }
        }
    }
}

#Preview {
    ScrollView {
        VStack {
            BarcodeImage(item: .Barcode())
            BarcodeImage(item: .QR())
            BarcodeImage(item: .StudentID())
            BarcodeImage(item: .Unknown())
        }
    }
    .background {
        Color.blue
            .ignoresSafeArea()
    }
    //    .modelContainer(for: Item.self, inMemory: true)
}

extension View {
    // This function changes our View to UIView, then calls another function
    // to convert the newly-made UIView to a UIImage.
    public func asUIImage() -> UIImage {
        let controller = UIHostingController(rootView: self)
        
        // Set the background to be transparent incase the image is a PNG, WebP or (Static) GIF
        controller.view.backgroundColor = .clear
        
        controller.view.frame = CGRect(x: 0, y: CGFloat(Int.max), width: 1, height: 1)
        UIApplication.shared.windows.first!.rootViewController?.view.addSubview(controller.view)
        
        let size = controller.sizeThatFits(in: UIScreen.main.bounds.size)
        controller.view.bounds = CGRect(origin: .zero, size: size)
        controller.view.sizeToFit()
        
        // here is the call to the function that converts UIView to UIImage: `.asUIImage()`
        let image = controller.view.asUIImage()
        controller.view.removeFromSuperview()
        return image
    }
}

extension UIView {
    // This is the function to convert UIView to UIImage
    public func asUIImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}
