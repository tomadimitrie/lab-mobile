//
//  Storage.swift
//  lab-ma
//
//  Created by Dimitrie-Toma Furdui on 07.11.2022.
//

import SwiftUI
import RealmSwift
import Network

class Storage: NSObject, ObservableObject {
    @Published var events = [Event]()
    
    var pending = [() -> Task<(), Never>]()
    
    private var webSocket: URLSessionWebSocketTask?
    
    var connected = false
    
    func refresh() {
        DispatchQueue.main.async {
            Task {
                let realm = try! await Realm()
                let realmObjects = realm.objects(Event.self)
                do {
                    let url = URL(string: "http://tomadimitrie.com:3000/")!
                    let (data, _) = try await URLSession.shared.data(from: url)
                    try realm.write {
                        realm.delete(realmObjects)
                    }
                    let dtos = try! JSONDecoder().decode([EventDTO].self, from: data)
                    let newEvents = dtos.map { Event(dto: $0) }
                    try realm.write {
                        for event in newEvents {
                            realm.add(event)
                        }
                    }
                    self.events = newEvents
                } catch {
                    self.events = Array(realmObjects)
                }
            }
        }
    }
    
    func initSocket() {
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        webSocket = session.webSocketTask(with: URL(string: "ws://tomadimitrie.com:3000/socket")!)
        webSocket?.resume()
    }
    
    override init() {
        super.init()
        refresh()
        
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { path in
            self.connected = path.status == .satisfied
            if self.connected {
                self.initSocket()
                for operation in self.pending {
                    _ = operation()
                }
                self.pending = []
            }
        }
        monitor.start(queue: .init(label: "Network"))
        
        initSocket()
    }
    
    func receive() {
        let workItem = DispatchWorkItem { [weak self] in
            self?.webSocket?.receive(completionHandler: { result in
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
                switch json["action"] as! String {
                case "favorite":
                    let index = self.events.firstIndex { $0.id == data["id"] as! String }!
                    try! realm.write {
                        self.events[index].isFavorite = true
                    }
                case "unfavorite":
                    let index = self.events.firstIndex { $0.id == data["id"] as! String }!
                    try! realm.write {
                        self.events[index].isFavorite = false
                    }
                case "delete":
                    let index = self.events.firstIndex { $0.id == data["id"] as! String }!
                    let event = self.events[index]
                    self.events.remove(at: index)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        try! realm.write {
                            realm.delete(event)
                        }
                    }
                case "create":
                    let dto = try! JSONDecoder().decode(EventDTO.self, from: try! JSONSerialization.data(withJSONObject: data))
                    try! realm.write {
                        let event = Event(dto: dto)
                        self.events.append(event)
                        realm.add(event)
                    }
                case "update":
                    let dto = try! JSONDecoder().decode(EventDTO.self, from: try! JSONSerialization.data(withJSONObject: data))
                    let index = self.events.firstIndex { $0.id == dto.id }!
                    try! realm.write {
                        realm.delete(self.events[index])
                        let event = Event(dto: dto)
                        self.events[index] = event
                        realm.add(event)
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
