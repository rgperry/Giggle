//
//  Item.swift
//  Giggle
//
//  Created by Karan Arora on 10/25/24.
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
