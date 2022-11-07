//
//  MyEventsView.swift
//  lab-ma
//
//  Created by Dimitrie-Toma Furdui on 06.11.2022.
//

import SwiftUI

struct MyEventsView: View {
    @AppStorage("username") private var username: String = ""
    @EnvironmentObject var storage: Storage
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    EventList(events: Array(storage.events.filter { $0.createdBy == username }))
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
