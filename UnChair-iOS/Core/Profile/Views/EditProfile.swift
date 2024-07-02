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
                
                
                TextField("Name", text: $name)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .padding(.top)
                
                TextField("Email", text: $email)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .disabled(true)
                    .padding(.top)
                
                Text("Update Password")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 20)
                    .foregroundColor(.gray)
                
                SecureField("Enter old password", text: $oldPassword)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    
                
                SecureField("Enter new password", text: $newPassword)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .padding(.top)
                
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
