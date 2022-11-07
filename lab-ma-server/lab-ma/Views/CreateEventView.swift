//
//  CreateEventView.swift
//  lab-ma
//
//  Created by Dimitrie-Toma Furdui on 06.11.2022.
//

import SwiftUI
import PhotosUI
import MultipartForm

struct CreateEventView: View {
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var storage: Storage
    
    @AppStorage("username") private var username: String = ""
    
    @State private var title: String = ""
    @State private var tags: String = ""
    @State private var location: String = ""
    @State private var date: Date = .now
    @State private var image: PhotosPickerItem? = nil
    @State private var imageData: Data? = nil
    
    @State private var showInputAlert = false

    var event: Event?
    
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
        
        if let event {
            Task {
                let url = URL(string: "http://localhost:3000/\(event.id)")!
                var request = URLRequest(url: url)
                request.httpMethod = "PUT"
                let form = MultipartForm(parts: [
                    .init(name: "image", data: UIImage(data: imageData!)!.pngData()!, filename: "\(title).png", contentType: "image/png"),
                    .init(name: "name", data: title.data(using: .utf8)!),
                    .init(name: "location", data: location.data(using: .utf8)!),
                    .init(name: "date", data: date.ISO8601Format().data(using: .utf8)!),
                ] + tags.split(separator: ",").map { String($0).lowercased() }.map {
                    MultipartForm.Part(name: "tags", data: $0.data(using: .utf8)!)
                })
                request.setValue(form.contentType, forHTTPHeaderField: "Content-Type")
                request.httpBody = form.bodyData
                _ = try! await URLSession.shared.data(for: request)
                dismiss()
            }
        } else {
            Task {
                let url = URL(string: "http://localhost:3000/")!
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                let form = MultipartForm(parts: [
                    .init(name: "image", data: UIImage(data: imageData!)!.pngData()!, filename: "\(title).png", contentType: "image/png"),
                    .init(name: "name", data: title.data(using: .utf8)!),
                    .init(name: "location", data: location.data(using: .utf8)!),
                    .init(name: "date", data: date.ISO8601Format().data(using: .utf8)!),
                    .init(name: "username", data: username.data(using: .utf8)!),
                ] + tags.split(separator: ",").map { String($0).lowercased() }.map {
                    MultipartForm.Part(name: "tags", data: $0.data(using: .utf8)!)
                })
                request.setValue(form.contentType, forHTTPHeaderField: "Content-Type")
                request.httpBody = form.bodyData
                _ = try! await URLSession.shared.data(for: request)
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
                    imageData = try! Data(contentsOf: URL(string: "http://localhost:3000/static/\(event.imageUrl)")!)
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

