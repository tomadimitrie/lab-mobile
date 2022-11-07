//
//  Event.swift
//  lab-ma
//
//  Created by Dimitrie-Toma Furdui on 06.11.2022.
//

import Foundation

struct Event: Identifiable {
    var id: String = UUID().uuidString
    var name: String
    var date: Date
    var location: String
    var imageData: Data
    var isFavorite = false
    var tags: [String]
    var username: String
}
