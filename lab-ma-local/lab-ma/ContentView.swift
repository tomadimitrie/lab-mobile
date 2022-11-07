//
//  ContentView.swift
//  lab-ma
//
//  Created by Dimitrie-Toma Furdui on 06.11.2022.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            EventsView()
                .tabItem {
                    Label("Events", systemImage: "list.dash")
                }
            MyEventsView()
                .tabItem {
                    Label("My Events", systemImage: "list.dash")
                }
            CreateEventView()
                .tabItem {
                    Label("Create", systemImage: "list.dash")
                }
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "list.dash")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
