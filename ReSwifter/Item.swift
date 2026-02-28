//
//  Item.swift
//  ReSwifter
//
//  Created by Jeffrey Bakker on 2026-02-27.
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
