//
//  EventsView.swift
//  lab-ma
//
//  Created by Dimitrie-Toma Furdui on 06.11.2022.
//

import SwiftUI
import RealmSwift

struct EventsView: View {
    @EnvironmentObject var storage: Storage
    
    @AppStorage("interests") var interestsString: String = ""
    var interests: [String] {
        interestsString.split(separator: ",").map { $0.lowercased().trimmingCharacters(in: .whitespaces) }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    EventList(events: storage.events.sorted { a, b in
                        if
                            Set(
                                a.tags.map {
                                    $0.lowercased().trimmingCharacters(in: .whitespaces)
                                })
                                .intersection(Set(interests)
                            ).count
                                >
                            Set(
                                b.tags.map {
                                    $0.lowercased().trimmingCharacters(in: .whitespaces)
                                })
                                .intersection(Set(interests)
                            ).count
                        {
                            return true
                        }
                        return a.date < b.date
                    })
                    Text("Favorite events")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    EventList(events: storage.events.filter { $0.isFavorite })
                    Spacer()
                }
                .padding(.leading, 20)
            }
            .navigationTitle("Events")
        }
    }
}

struct EventsView_Previews: PreviewProvider {
    static var previews: some View {
        EventsView()
    }
}
