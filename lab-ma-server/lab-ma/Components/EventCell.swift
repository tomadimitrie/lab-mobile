//
//  EventCell.swift
//  lab-ma
//
//  Created by Dimitrie-Toma Furdui on 07.11.2022.
//

import SwiftUI

struct EventCell: View {
    @EnvironmentObject var storage: Storage
    @AppStorage("username") var username: String = ""
    @State var confirmDelete = false
    @State var showNetworkAlert = false
    
    let event: Event
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter
    }
    
    private func updateFavorite() {
        guard storage.connected else {
            showNetworkAlert = true
            return
        }
        Task {
            var request = URLRequest(url: URL(string: "http://tomadimitrie.com:3000/\(event.isFavorite ? "unfavorite" : "favorite")/\(event.id)")!)
            request.httpMethod = "PUT"
            request.httpBody = try! JSONSerialization.data(withJSONObject: [
                "username": username
            ])
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            _ = try! await URLSession.shared.data(for: request)
        }
    }
    
    private func delete() {
        guard storage.connected else {
            showNetworkAlert = true
            return
        }
        Task {
            var request = URLRequest(url: URL(string: "http://tomadimitrie.com:3000/\(event.id)?username=\(username)")!)
            request.httpMethod = "DELETE"
            
            _ = try! await URLSession.shared.data(for: request)
        }
    }
    
    var body: some View {
        return ZStack(alignment: .bottomLeading) {
            if let data = event.imageData {
                Image(uiImage: UIImage(data: data)!)
                    .resizable()
                    .frame(width: 150, height: 400)
            } else {
                AsyncImage(
                    url: URL(string: "http://tomadimitrie.com:3000/static/\(event.imageUrl)")!,
                    content: { image in
                        image
                            .resizable()
                            .frame(width: 150, height: 400)
                    },
                    placeholder: {
                        ProgressView()
                    }
                )
            }
            VStack {
                HStack {
                    Spacer()
                    NavigationLink(destination: CreateEventView(event: event)) {
                        Image(systemName: "pencil")
                            .font(.system(size: 30))
                    }
                    Button(action: {
                        confirmDelete = true
                    }) {
                        Image(systemName: "trash")
                            .font(.system(size: 30))
                    }
                    Button(action: updateFavorite) {
                        Image(systemName: event.isFavorite ? "star.fill" : "star")
                            .font(.system(size: 30))
                    }
                }
                Spacer()
                ZStack {
                    VisualEffectView(effect: UIBlurEffect(style: .light))
                    VStack(alignment: .leading) {
                        Text(event.name)
                            .font(.title)
                            .fontWeight(.bold)
                        Text(dateFormatter.string(from: event.date))
                        Text(event.location)
                        Text(event.tags.joined(separator: ", "))
                    }
                    .padding(5)
                }
                .frame(width: 150, height: 150)
            }
        }
        .confirmationDialog("Confirm delete", isPresented: $confirmDelete) {
            Button("Confirm delete", role: .destructive) {
                delete()
            }
        }
        .alert("No network", isPresented: $showNetworkAlert) {
            Button("Ok") {
                
            }
        }
    }
    
}
