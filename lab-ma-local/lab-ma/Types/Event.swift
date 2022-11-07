//
//  Event.swift
//  lab-ma
//
//  Created by Dimitrie-Toma Furdui on 06.11.2022.
//

import Foundation
import RealmSwift

final class Event: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var _id: String = UUID().uuidString
    @Persisted var name: String
    @Persisted var date: Date
    @Persisted var location: String
    @Persisted var imageData: Data
    @Persisted var isFavorite = false
    @Persisted var tags: RealmSwift.List<String>
    @Persisted var username: String
    
    convenience init(name: String, date: Date, location: String, imageData: Data, isFavorite: Bool = false, tags: [String], username: String) {
        self.init()
        self.name = name
        self.date = date
        self.location = location
        self.imageData = imageData
        self.isFavorite = isFavorite
        self.username = username
        for tag in tags {
            self.tags.append(tag)
        }
    }
}
