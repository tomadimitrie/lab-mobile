//
//  SettingsView.swift
//  lab-ma
//
//  Created by Dimitrie-Toma Furdui on 06.11.2022.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("username") private var username: String = ""
    @AppStorage("interests") private var interests: String = ""
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                TextField("Username", text: $username)
                TextField("Interests", text: $interests)
                Spacer()
            }
            .padding(.leading, 20)
            .navigationTitle("Settings")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
