//
//  Item.swift
//  Code Clone
//
//  Created by Zsolt Kébel on 11/09/2024.
//

import Foundation
import SwiftData
import Vision

@Model
final class Item {
    var timestamp: Date
    var name: String
    var payloadStringValue: String
    var symbologyRawValue: String // the type of the code i.e. qr
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
    
    static func QR() -> Item {
        let item = Item(timestamp: Date())
        item.symbologyRawValue = VNBarcodeSymbology.qr.rawValue
        return item
    }
    
    static func Barcode() -> Item {
        let item = Item(timestamp: Date())
        item.symbologyRawValue = VNBarcodeSymbology.code128.rawValue
        item.payloadStringValue = "13587936"
        return item
    }
    
    static func StudentID() -> Item {
        let item = Item()
        item.symbologyRawValue = VNBarcodeSymbology.code39.rawValue
        item.payloadStringValue = "13587936"
        return item
    }
    
    func clear() {
        self.name = ""
        self.payloadStringValue = ""
        self.symbologyRawValue = VNBarcodeSymbology.qr.rawValue
    }
    
    func loadBarcode(symbology: String, payloadStringValue: String, format: String = "png") async -> Data? {
        guard let url = URL(string: "https://barcode.orcascan.com/?type=\(symbology)&data=\(payloadStringValue)&format=\(format)") else {
            print("Invalid URL")
            return nil
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)

            self.barcodeImageData = data
            print("Image downloaded")
            return data
        } catch {
            print("Invalid data")
        }
        return nil
    }
}
