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
    @Persisted var imageUrl: String
    @Persisted var imageData: Data?
    @Persisted var isFavorite = false
    @Persisted var tags: List<String>
    @Persisted var createdBy: String
    
    var id: String {
        _id
    }
    
    convenience init(dto: EventDTO) {
        self.init()
        let username = UserDefaults.standard.string(forKey: "username") ?? ""
        self._id = dto.id
        self.name = dto.name
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        self.date = formatter.date(from: dto.date)!
        self.location = dto.location
        self.imageUrl = dto.imageUrl
        self.isFavorite = dto.favoritedBy.contains(username)
        for tag in dto.tags {
            self.tags.append(tag)
        }
        self.createdBy = dto.createdBy
        self.imageData = try! Data(contentsOf: URL(string: "http://tomadimitrie.com:3000/static/\(dto.imageUrl)")!)
    }
}

struct EventDTO: Decodable {
    var id: String
    var name: String
    var date: String
    var location: String
    var imageUrl: String
    var favoritedBy: [String]
    var tags: [String]
    var createdBy: String
}

