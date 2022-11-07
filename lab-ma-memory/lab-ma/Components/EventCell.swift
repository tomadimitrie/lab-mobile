//
//  EventCell.swift
//  lab-ma
//
//  Created by Dimitrie-Toma Furdui on 07.11.2022.
//

import SwiftUI

struct EventCell: View {
    @EnvironmentObject var storage: Storage
    
    @State var confirmDelete = false
    
    let event: Event
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter
    }
    
    private func updateFavorite() {
        storage.events[storage.events.firstIndex { $0.id == event.id }!].isFavorite.toggle()
    }
    
    private func delete() {
        storage.events.removeAll { $0.id == event.id }
    }
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image(
                uiImage: UIImage(data: event.imageData)!
            )
                .resizable()
                .frame(width: 150, height: 400)
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
    }
    
}
