//
//  EventList.swift
//  lab-ma
//
//  Created by Dimitrie-Toma Furdui on 06.11.2022.
//

import SwiftUI
import RealmSwift

struct EventList: View {
    @EnvironmentObject var storage: Storage
    @AppStorage("username") var username: String = ""
    
    let events: [Event]
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 20) {
                ForEach(events) { event in
                    EventCell(event: event)
                }
            }
        }
    }
}
