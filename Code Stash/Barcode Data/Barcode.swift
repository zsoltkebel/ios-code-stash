//
//  Item.swift
//  Code Clone
//
//  Created by Zsolt Kébel on 11/09/2024.
//

import Foundation
import SwiftData
import Vision
import SwiftUI

@Model
final class Barcode {
    var timestamp: Date = Date()
    var name: String = ""
    var payloadStringValue: String = ""
    var symbologyRawValue: String = VNBarcodeSymbology.qr.rawValue // the type of the code i.e. qr
    var barcodeImageData: Data?

    var favorite: Bool = false // new feature

    init() {
        self.timestamp = Date()
        self.name = ""
        self.payloadStringValue = ""
        self.symbologyRawValue = VNBarcodeSymbology.qr.rawValue
    }
    
    init(timestamp: Date) {
        self.timestamp = timestamp
        self.name = "Example"
        self.payloadStringValue = "Hello World"
        self.symbologyRawValue = VNBarcodeSymbology.qr.rawValue
    }
    
    init(payloadStringValue: String, symbologyRawValue: String) {
        self.timestamp = Date()
        self.name = "Scanned Code"
        self.payloadStringValue = payloadStringValue
        self.symbologyRawValue = symbologyRawValue
    }
    
    init(name: String, payloadStringValue: String, symbologyRawValue: String) {
        self.name = name
        self.payloadStringValue = payloadStringValue
        self.symbologyRawValue = symbologyRawValue
    }
    
    func clearImageData() {
        self.barcodeImageData = nil
    }
    
    func clear() {
        self.name = ""
        self.payloadStringValue = ""
        self.symbologyRawValue = VNBarcodeSymbology.qr.rawValue
    }
}

extension Barcode {
    
    var vnSymbology: VNBarcodeSymbology {
        VNBarcodeSymbology(rawValue: self.symbologyRawValue)
    }
    
    var image: Image? {
        if let imageData = self.barcodeImageData,
           let uiImage = UIImage(data: imageData) {
            return Image(uiImage: uiImage)
        }
        return nil
    }
    
    var url: URL? {
        return URL(string: self.payloadStringValue)
    }
    
    var content: CodeContent? {
        if self.wifi != nil { return .wifi }
        if self.payloadStringValue.hasPrefix("https:") { return .webLink }
        return nil
    }
}
