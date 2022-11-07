//
//  ContentView.swift
//  lab-ma
//
//  Created by Dimitrie-Toma Furdui on 06.11.2022.
//

import SwiftUI

struct ContentView: View {
    @StateObject var storage = Storage()
    
    @State var isAlertShown = false
    @State var errorMessage: String? = nil
    
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
        .environmentObject(storage)
        .onReceive(storage.errorOccurred) { error in
            self.errorMessage = error.errorDescription
            self.isAlertShown = true
        }
        .alert(self.errorMessage ?? "", isPresented: self.$isAlertShown) {
            Button("OK") {
                self.isAlertShown = false
                self.errorMessage = nil
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
