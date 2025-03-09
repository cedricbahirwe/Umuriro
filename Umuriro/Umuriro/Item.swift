//
//  Item.swift
//  Umuriro
//
//  Created by Cédric Bahirwe on 09/03/2025.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
