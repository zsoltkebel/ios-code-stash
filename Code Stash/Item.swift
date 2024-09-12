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
    var symbologyRawValue: String //the type of the code i.e. qr

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
        return item
    }
    
    func clear() {
        self.name = ""
        self.payloadStringValue = ""
        self.symbologyRawValue = VNBarcodeSymbology.qr.rawValue
    }
}
