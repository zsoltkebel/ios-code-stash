//
//  Item+Image.swift
//  Code Stash
//
//  Created by Zsolt Kébel on 21/09/2024.
//

import Foundation
import SwiftUICore

extension Barcode {
    var imageSymbol: Image {
        if let contentIdentified = self.content {
            switch contentIdentified {
            case .webLink: return Image(systemName: "link")
            case .wifi: return Image(systemName: "wifi")
            }
        } else {
            return self.vnSymbology.image
        }
    }
}
