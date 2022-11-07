//
//  MyEventsView.swift
//  lab-ma
//
//  Created by Dimitrie-Toma Furdui on 06.11.2022.
//

import SwiftUI
import RealmSwift

struct MyEventsView: View {
    @AppStorage("username") private var username: String = ""
    
    @ObservedResults(Event.self) var events
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    EventList(events: Array(events.where { $0.username == username }))
                    Spacer()
                }
                .padding(.leading, 20)
            }
            .navigationTitle("Created by me")
        }
    }
}

struct MyEventsView_Previews: PreviewProvider {
    static var previews: some View {
        MyEventsView()
    }
}
