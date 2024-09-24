//
//  EditProfile.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 2/7/24.
//


import SwiftUI
import PhotosUI

struct EditProfile: View {
    @State private var first_name: String = "John"
    @State private var last_name: String = "Smith"
    @State private var email: String = "Johnsmithmobbin@gmail.com"
    @State private var avatarImage: UIImage?
    @State private var photosPickerItem: PhotosPickerItem?

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    ZStack(alignment: .bottomTrailing) {
                        if let avatarImage = avatarImage {
                            Image(uiImage: avatarImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                                .foregroundColor(.gray)
                        }
                        
                        PhotosPicker(selection: $photosPickerItem, matching: .images) {
                            Image(systemName: "pencil")
                                .foregroundColor(.white)
                                .frame(width: 30, height: 30)
                                .background(Color.blue)
                                .clipShape(Circle())
                        }
                        .onChange(of: photosPickerItem) { newValue in
                            Task {
                                if let photosPickerItem = photosPickerItem,
                                   let data = try? await photosPickerItem.loadTransferable(type: Data.self),
                                   let image = UIImage(data: data) {
                                    avatarImage = image
                                }
                            }
                        }
                    }
                    .padding(.bottom, 20)

                    VStack(alignment: .leading, spacing: 5) {
                        Text("First Name")
                            .foregroundColor(.gray)
                            .font(.caption)
                            .fontWeight(.bold)
                        TextField("", text: $first_name)
                            .padding(.leading)
                            .frame(height: 50)
                            .background(Color(.darkGray))
                            .cornerRadius(8)
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Last Name")
                            .foregroundColor(.gray)
                            .font(.caption)
                            .fontWeight(.bold)
                        TextField("", text: $last_name)
                            .padding(.leading)
                            .frame(height: 50)
                            .background(Color(.darkGray))
                            .cornerRadius(8)
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Email")
                            .foregroundColor(.gray)
                            .font(.caption)
                            .fontWeight(.bold)
                        TextField("", text: $email)
                            .padding(.leading)
                            .frame(height: 50)
                            .background(Color(.darkGray))
                            .cornerRadius(8)
                            .foregroundColor(.gray)
                            .disabled(true)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        // Save action
                    }) {
                        Text("Save")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(8)
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                }
                .padding()
            }
            .navigationBarTitle("Profile Info", displayMode: .inline)
        }
        .accentColor(.white)
    }
}

struct ProfileInfoView_Previews: PreviewProvider {
    static var previews: some View {
        EditProfile()
    }
}
