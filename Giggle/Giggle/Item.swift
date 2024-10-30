//
//  Item.swift
//  Giggle
//
//  Created by Karan Arora on 10/25/24.
//

// FINISH: DELETE THIS ONCE WE HAVE OUR OWN MODEL SET UP
// THIS IS JUST FOR REFERENCE

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
