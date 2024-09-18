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
    
    func clearImageData() {
        self.barcodeImageData = nil
    }

    static func QR() -> Item {
        let item = Item(timestamp: Date())
        item.symbologyRawValue = VNBarcodeSymbology.qr.rawValue
        item.payloadStringValue = "520923523"
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
    
    static func Unknown() -> Item {
        let item = Item()
        item.symbologyRawValue = VNBarcodeSymbology.code39Checksum.rawValue
        item.payloadStringValue = "520923523"
        return item
    }
    
    static func QRURL() -> Item {
        let item = Item()
        item.symbologyRawValue = VNBarcodeSymbology.qr.rawValue
        item.payloadStringValue = "https://google.com"
        return item
    }
    
    static func WIFI() -> Item {
        let item = Item()
        item.symbologyRawValue = VNBarcodeSymbology.qr.rawValue
        item.payloadStringValue = "WIFI:S:some wifi name;T:WPA;P:and a password;H:false;;"
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

extension Item {
    
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
    
    var wifi: Wifi? {
        let regex = /^WIFI:S:(.*?);T:(WEP|WPA|);P:(.*?)(?:;H:(true|false))?;;$/
        if let result = try? regex.wholeMatch(in: self.payloadStringValue) {
            print("SSID: \(result.1)")
            print("PASSWORD: \(result.3)")
            return Wifi(ssid: String(result.1), t: String(result.2), password: String(result.3))
        }
        return nil
    }
    
    var type: CodeType {
        if self.wifi != nil { return .wifi }
        if self.payloadStringValue.hasPrefix("https:") { return .url }
        if self.vnSymbology == .qr { return .qr }
        return .barcode
    }
}

enum CodeType {
    case qr, barcode, wifi, url
    
    var image: Image {
        switch self {
        case .qr: return Image(systemName: "qrcode")
        case .barcode: return Image(systemName: "barcode")
        case .wifi: return Image(systemName: "wifi")
        case .url: return Image(systemName: "link")
        default: return Image(systemName: "exclamationmark.triangle.fill")
        }
    }
}

import NetworkExtension

struct Wifi {
    var ssid: String
    var t: String
    var password: String
    
    func isConfigured() async -> Bool {
        return await withCheckedContinuation { continuation in
            NEHotspotConfigurationManager.shared.getConfiguredSSIDs { ssids in
                continuation.resume(returning: ssids.contains(self.ssid))
            }
        }
    }
    
    func connect() {
        print("Trying to connect to wifi: \(self)")
        let config = NEHotspotConfiguration(ssidPrefix: self.ssid, passphrase: self.password, isWEP: t == "WEP")
        
        NEHotspotConfigurationManager.shared.apply(config) { error in
            print("error: \(error)")
        }
    }
}
