//
//  Barcode+Wifi.swift
//  Code Stash
//
//  Created by Zsolt Kébel on 21/09/2024.
//

import Foundation

extension Barcode {
    var wifi: Wifi? {
        let regex = /^WIFI:S:(.*?);T:(WEP|WPA|);P:(.*?)(?:;H:(true|false))?;;$/
        if let result = try? regex.wholeMatch(in: self.payloadStringValue) {
            let ssid = String(result.1)
            let t = String(result.2)
            let password = String(result.3)
            return Wifi(ssid: ssid, t: t, password: password)
        }
        return nil
    }
}
