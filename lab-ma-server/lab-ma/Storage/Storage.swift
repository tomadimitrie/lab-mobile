//
//  Storage.swift
//  lab-ma
//
//  Created by Dimitrie-Toma Furdui on 07.11.2022.
//

import SwiftUI
import RealmSwift
import Network
import Combine

class Storage: NSObject, ObservableObject {
    @Published var events = [Event]()
    
    @Published var errorOccurred = PassthroughSubject<LocalizedError, Never>()
    
    var pending = [() -> Task<(), Never>]()
    
    private var webSocket: URLSessionWebSocketTask!
    
    var connected = false
    var firstConnection = false
    
    func refresh() {
        DispatchQueue.main.async {
            Task {
                let realm = try! await Realm()
                let realmObjects = realm.objects(RealmEvent.self)
                if self.connected {
                    print("fetching new data...")
                    let url = URL(string: "http://tomadimitrie.com:3000/")!
                    let (data, _) = try! await URLSession.shared.data(from: url)
                    try realm.write {
                        realm.delete(realmObjects)
                    }
                    let dtos = try! JSONDecoder().decode([EventDTO].self, from: data)
                    try realm.write {
                        for event in dtos.map ({ RealmEvent(dto: $0) }) {
                            realm.add(event)
                        }
                    }
                    self.events = dtos.map { Event(dto: $0) }
                    print("finished fetching new data")
                } else {
                    print("loading from local db...")
                    self.events = Array(realmObjects.map { Event(realmEvent: $0) })
                }
            }
        }
    }
    
    func initSocket() {
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        webSocket = session.webSocketTask(with: URL(string: "ws://tomadimitrie.com:3000/socket")!)
        webSocket.resume()
    }
    
    override init() {
        super.init()
        
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { path in
            if self.connected == (path.status == .satisfied), self.firstConnection {
                return
            }
            self.connected = path.status == .satisfied
            print("new network state: \(self.connected)")
            if self.connected {
                if self.firstConnection {
                    DispatchQueue.main.async {
                        self.errorOccurred.send("Back online, refreshing...")
                    }
                }
                self.initSocket()
                for operation in self.pending {
                    print("performing pending operation...")
                    _ = operation()
                }
                self.pending = []
            } else {
                DispatchQueue.main.async {
                    self.errorOccurred.send("No connection, falling back to local db...")
                }
            }
            self.refresh()
            if !self.firstConnection {
                self.firstConnection = true
            }
        }
        monitor.start(queue: .init(label: "Network"))
        
        initSocket()
    }
    
    func receive() {
        print("ready to receive")
        let workItem = DispatchWorkItem { [weak self] in
            self?.webSocket.receive(completionHandler: { result in
                switch result {
                case .success(let message):
                    switch message {
                    case .data(let data):
                        print("Data received \(data)")
                    case .string(let string):
                        print("String received \(string)")
                        self?.processSocket(message: string)
                    default:
                        break
                    }
                case .failure(let error):
                    print("Error Receiving \(error)")
                }
                self?.receive()
            })
        }
        DispatchQueue.global().asyncAfter(deadline: .now() + 1 , execute: workItem)
    }
    
    func processSocket(message: String) {
        DispatchQueue.main.async { [unowned self] in
            Task {
                let realm = try! await Realm()
                let json = try! JSONSerialization.jsonObject(with: message.data(using: .utf8)!) as! [String: Any]
                let data = json["data"] as! [String: Any]
                print("received action \(json["action"]!) with data \(data)")
                switch json["action"] as! String {
                case "favorite":
                    let index = self.events.firstIndex { $0.id == data["id"] as! String }!
                    self.events[index].isFavorite = true
                    try! realm.write {
                        realm.object(ofType: RealmEvent.self, forPrimaryKey: data["id"])!.isFavorite = true
                    }
                case "unfavorite":
                    let index = self.events.firstIndex { $0.id == data["id"] as! String }!
                    self.events[index].isFavorite = false
                    try! realm.write {
                        realm.object(ofType: RealmEvent.self, forPrimaryKey: data["id"])!.isFavorite = false
                    }
                case "delete":
                    let index = self.events.firstIndex { $0.id == data["id"] as! String }!
                    self.events.remove(at: index)
                    try! realm.write {
                        realm.delete(realm.object(ofType: RealmEvent.self, forPrimaryKey: data["id"])!)
                    }
                case "create":
                    let dto = try! JSONDecoder().decode(EventDTO.self, from: try! JSONSerialization.data(withJSONObject: data))
                    try! realm.write {
                        let event = Event(dto: dto)
                        let realmEvent = RealmEvent(dto: dto)
                        self.events.append(event)
                        realm.add(realmEvent)
                    }
                case "update":
                    let dto = try! JSONDecoder().decode(EventDTO.self, from: try! JSONSerialization.data(withJSONObject: data))
                    let index = self.events.firstIndex { $0.id == data["id"] as! String }!
                    try! realm.write {
                        realm.delete(realm.object(ofType: RealmEvent.self, forPrimaryKey: dto.id)!)
                        let event = Event(dto: dto)
                        let realmEvent = RealmEvent(dto: dto)
                        self.events[index] = event
                        realm.add(realmEvent)
                    }
                default:
                    break
                }
                self.objectWillChange.send()
            }
        }
    }
}

extension Storage: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        self.receive()
    }
}
