//
//  EditProfile.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 2/7/24.
//

import SwiftUI
import PhotosUI

struct EditProfile: View {
    
    @State private var avatarImage : UIImage?
    @State private var photosPickerItem : PhotosPickerItem?
    @State private var name : String = "James Bond"
    @State private var email : String = "jamesbond007@gmail.com"
    @State private var oldPassword : String = ""
    @State private var newPassword : String = ""
    @State private var phoneNumber: String = "+91 9876543210"
    @State private var isOldPasswordVisible: Bool = false
    @State private var isNewPasswordVisible: Bool = false
    
    
    var body: some View {
        
        VStack {
            VStack {
                VStack{
                    PhotosPicker(selection: $photosPickerItem, matching: .images) {
                        if let avatarImage = avatarImage {
                            Image(uiImage: avatarImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 130, height: 130)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 130, height: 130)
                                .clipShape(Circle())
                                .foregroundColor(.gray)
                        }
                    }
                    
                }
                .padding(10)
                .onChange(of: photosPickerItem) { _, _ in
                    Task{
                        if let photosPickerItem,
                           let data = try? await photosPickerItem.loadTransferable(type: Data.self){
                            if let image = UIImage(data: data){
                                avatarImage = image
                            }
                        }
                        photosPickerItem = nil
                    }
                }
                Text("Profile Picture")
                    .foregroundColor(.gray)
                    .font(.subheadline)
                
                
                HStack {
                    Text("Name")
                        .foregroundColor(.gray)
                        .font(.caption)
                    Spacer()
                }.padding(.top)
                TextField("Name", text: $name)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .fontWeight(.light)
                    .overlay(
                        HStack {
                            Spacer()
                            Image(systemName: "person.circle")
                                .foregroundColor(.gray)
                                .padding(.trailing)
                        }
                    )
                
                
                
                
                HStack {
                    Text("Email")
                        .foregroundColor(.gray)
                        .font(.caption)
                    Spacer()
                }.padding(.top)
                TextField("Email", text: $email)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .foregroundColor(.gray)
                    .cornerRadius(8)
                    .disabled(true)
                    .fontWeight(.medium)
                    .overlay(
                        HStack {
                            Spacer()
                            Image(systemName: "envelope")
                                .foregroundColor(.gray)
                                .padding(.trailing)
                        }
                    )
                       
    
                
                HStack {
                    Text("Update Password")
                        .foregroundColor(.gray)
                        .font(.caption)
                    Spacer()
                }.padding(.top)
                
                
                HStack {
                    if isOldPasswordVisible {
                        TextField("Enter old password", text: $oldPassword)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                            .overlay(
                                HStack {
                                    Spacer()
                                    Button(action: {
                                        isOldPasswordVisible.toggle()
                                    }) {
                                        Image(systemName: isOldPasswordVisible ? "eye" : "eye.slash")
                                            .foregroundColor(.gray)
                                            .padding(.trailing)
                                    }
                                }
                            )
                        } else {
                            SecureField("Enter old password", text: $oldPassword)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                                .overlay(
                                    HStack {
                                        Spacer()
                                        Button(action: {
                                            isOldPasswordVisible.toggle()
                                        }) {
                                            Image(systemName: isOldPasswordVisible ? "eye" : "eye.slash")
                                                .foregroundColor(.gray)
                                                .padding(.trailing)
                                        }
                                    }
                                )
                        }
                }
                    
                
                HStack {
                    if isNewPasswordVisible {
                        TextField("Enter new password", text: $newPassword)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                            .overlay(
                                HStack {
                                    Spacer()
                                    Button(action: {
                                        isNewPasswordVisible.toggle()
                                    }) {
                                        Image(systemName: isNewPasswordVisible ? "eye" : "eye.slash")
                                            .foregroundColor(.gray)
                                            .padding(.trailing)
                                    }
                                }
                            )
                        } else {
                            SecureField("Enter new password", text: $newPassword)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                                .overlay(
                                    HStack {
                                        Spacer()
                                        Button(action: {
                                            isNewPasswordVisible.toggle()
                                        }) {
                                            Image(systemName: isNewPasswordVisible ? "eye" : "eye.slash")
                                                .foregroundColor(.gray)
                                                .padding(.trailing)
                                        }
                                    }
                                )
                        }
                }.padding(.top, 15)
                    
                
                
                
                
                
                Spacer()
                
                Button(action: {
                    // Save action
                }) {
                    Text("Save")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.black)
                        .cornerRadius(8)
                }
                .padding(.top)
            }
            .padding()
            
            Spacer()
        }
        .navigationTitle("Edit Profile")
  
    }
}

#Preview {
    EditProfile()
}
