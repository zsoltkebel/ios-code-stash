//
//  WifiConfiguration.swift
//  Code Stash
//
//  Created by Zsolt Kébel on 21/09/2024.
//

import Foundation
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
            print("error: \(String(describing: error))")
        }
    }
}
