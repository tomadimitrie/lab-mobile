//
//  CreateEventView.swift
//  lab-ma
//
//  Created by Dimitrie-Toma Furdui on 06.11.2022.
//

import SwiftUI
import PhotosUI
import RealmSwift

struct CreateEventView: View {    
    @AppStorage("username") private var username: String = ""
    
    @Environment(\.realm) var realm
    @Environment(\.dismiss) var dismiss
    
    var event: Event?
    
    @State private var title: String = ""
    @State private var tags: String = ""
    @State private var location: String = ""
    @State private var date: Date = .now
    @State private var image: PhotosPickerItem? = nil
    @State private var imageData: Data? = nil
    
    @State private var showInputAlert = false
    
    private func action() {
        if
            title == "" ||
            tags == "" ||
            location == "" ||
            imageData == nil
        {
            showInputAlert = true
            return
        }
        
        let tagsArray = tags.split(separator: ",").map { String($0) }
        
        if let event {
            try! realm.write {
                let thawedEvent = event.thaw()!
                thawedEvent.name = title
                thawedEvent.date = date
                thawedEvent.location = location
                thawedEvent.imageData = imageData!
                let realmTags = RealmSwift.List<String>()
                realmTags.append(objectsIn: tagsArray)
                thawedEvent.tags = realmTags
            }
            dismiss()
        } else {
            try! realm.write {
                realm.add(Event(
                    name: title,
                    date: date,
                    location: location,
                    imageData: imageData!,
                    tags: tagsArray,
                    username: username
                ))
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                HStack {
                    PhotosPicker(
                        selection: $image,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        if let imageData {
                            Image(uiImage: UIImage(data: imageData)!)
                                .resizable()
                                .frame(width: 100, height: 200)
                        } else {
                            AsyncImage(
                                url: URL(string: "https://via.placeholder.com/100x200")!,
                                content: { image in
                                    image
                                        .resizable()
                                        .frame(width: 100, height: 200)
                                },
                                placeholder: {
                                    ProgressView()
                                }
                            )
                        }
                    }
                    .onChange(of: image) { newImage in
                        Task {
                            if let data = try? await newImage?.loadTransferable(type: Data.self) {
                                imageData = data
                            }
                        }
                    }
                    VStack(alignment: .leading, spacing: 20) {
                        TextField("Title", text: $title)
                        TextField("Tags", text: $tags)
                        TextField("Location", text: $location)
                    }
                }
                DatePicker("Date", selection: $date)
                    .datePickerStyle(.graphical)
                HStack {
                    Spacer()
                    Button(action: action) {
                        Text(event == nil ? "Create" : "Edit")
                    }
                    .buttonStyle(.bordered)
                    Spacer()
                }
                Spacer()
            }
            .padding(.leading, 20)
            .navigationTitle(event == nil ? "Create" : "Edit")
            .alert("All fields are required", isPresented: $showInputAlert) {
                Button("OK", role: .cancel) {}
            }
            .onAppear {
                if let event {
                    title = event.name
                    tags = event.tags.joined(separator: ", ")
                    location = event.location
                    date = event.date
                    imageData = event.imageData
                }
            }
        }
    }
}

struct CreateEventView_Previews: PreviewProvider {
    static var previews: some View {
        CreateEventView()
    }
}

