//
//  Barcode+Defaults.swift
//  Code Stash
//
//  Created by Zsolt Kébel on 21/09/2024.
//

import Foundation
import Vision

extension Barcode {
    static let qr: Barcode = .init(
        name: "Qr Code",
        payloadStringValue: "13587936",
        symbologyRawValue: VNBarcodeSymbology.qr.rawValue
    )
    
    static let code128: Barcode = .init(
        name: "Code 128",
        payloadStringValue: "13587936",
        symbologyRawValue: VNBarcodeSymbology.code128.rawValue
    )
    
    static let code39: Barcode = .init(
        name: "Code 39",
        payloadStringValue: "13587936",
        symbologyRawValue: VNBarcodeSymbology.code39.rawValue
    )
    
    static let code39Checksum: Barcode = .init(
        name: "Code 39 Checksum",
        payloadStringValue: "13587936",
        symbologyRawValue: VNBarcodeSymbology.code39Checksum.rawValue
    )
    
    static let webLink: Barcode = .init(
        name: "QR URL",
        payloadStringValue: "https://google.com",
        symbologyRawValue: VNBarcodeSymbology.qr.rawValue
    )
    
    static let wifi: Barcode = .init(
        name: "WIFI",
        payloadStringValue: "WIFI:S:some wifi name;T:WPA;P:and a password;H:false;;",
        symbologyRawValue: VNBarcodeSymbology.qr.rawValue
    )
}
