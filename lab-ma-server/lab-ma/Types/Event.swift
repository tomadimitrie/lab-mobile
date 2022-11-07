//
//  Event.swift
//  lab-ma
//
//  Created by Dimitrie-Toma Furdui on 06.11.2022.
//

import Foundation
import RealmSwift

final class RealmEvent: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var _id: String = UUID().uuidString
    @Persisted var name: String
    @Persisted var date: Date
    @Persisted var location: String
    @Persisted var imageUrl: String
    @Persisted var imageData: Data?
    @Persisted var isFavorite = false
    @Persisted var tags: List<String>
    @Persisted var createdBy: String
    
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
        self.imageData = try? Data(contentsOf: URL(string: "http://tomadimitrie.com:3000/static/\(dto.imageUrl)")!)
    }
}

class Event: Identifiable {
    let id: String
    let name: String
    let date: Date
    let location: String
    let imageUrl: String
    var imageData: Data?
    var isFavorite: Bool
    let tags: [String]
    let createdBy: String
    
    init(dto: EventDTO) {
        let username = UserDefaults.standard.string(forKey: "username") ?? ""
        self.id = dto.id
        self.name = dto.name
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        self.date = formatter.date(from: dto.date)!
        self.location = dto.location
        self.imageUrl = dto.imageUrl
        self.isFavorite = dto.favoritedBy.contains(username)
        self.tags = dto.tags
        self.createdBy = dto.createdBy
        DispatchQueue.global(qos: .userInitiated).async {
            self.imageData = try? Data(contentsOf: URL(string: "http://tomadimitrie.com:3000/static/\(dto.imageUrl)")!)
        }
    }
    
    init(realmEvent: RealmEvent) {
        self.id = realmEvent._id
        self.name = realmEvent.name
        self.date = realmEvent.date
        self.location = realmEvent.location
        self.imageUrl = realmEvent.imageUrl
        self.imageData = realmEvent.imageData
        self.isFavorite = realmEvent.isFavorite
        self.tags = Array(realmEvent.tags)
        self.createdBy = realmEvent.createdBy
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

