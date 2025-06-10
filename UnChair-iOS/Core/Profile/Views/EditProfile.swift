//
//  EditProfile.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 2/7/24.
//


import SwiftUI
import PhotosUI
import FirebaseAuth
import FirebaseFirestore


struct EditProfile: View {
    @State private var full_name: String = ""
    @State private var email: String = ""
    @State private var avatarImage: UIImage?
    @State private var isLoading: Bool = false
    @Environment(\.presentationMode) var presentationMode
    private var db = Firestore.firestore()
    
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 20) {
                    if let user = Auth.auth().currentUser, let profileImageURL = user.photoURL {
                        
                        AsyncImage(url: URL(string: profileImageURL.absoluteString)) { phase in
                            switch phase {
                            case .failure:
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 200, height: 200)
                                    .clipShape(Circle())
                                    .foregroundColor(.gray)
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 200, height: 200)
                                    .clipShape(Circle())
                                    .foregroundColor(.gray)
                            default:
                                ProgressView()
                            }
                        }
                        
                        
                    } else {
                        VStack {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 200, height: 200)
                                .clipShape(Circle())
                                .foregroundColor(.gray)
                        }
                        
                        
                    }
                    Text("To change your profile picture, update your Google account.")
                        .foregroundColor(.gray)
                        .font(.caption2)
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Full Name")
                            .foregroundColor(.gray)
                            .font(.caption)
                            .fontWeight(.bold)
                        TextField("", text: $full_name)
                            .padding(.leading)
                            .frame(height: 50)
                            .background(.ultraThinMaterial)
                            .cornerRadius(8)
                        
                    }
                    
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Email")
                            .foregroundColor(.gray)
                            .font(.caption)
                            .fontWeight(.bold)
                        TextField("", text: $email)
                            .padding(.leading)
                            .frame(height: 50)
                            .background(.ultraThinMaterial)
                            .cornerRadius(8)
                            .foregroundColor(.gray)
                            .disabled(true)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        saveProfileData()
                    }) {
                        Text("Save")
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.blue)
                            .cornerRadius(8)
                            .font(.title2)
                            .bold()
                    }
                }
                .padding()
                
                if isLoading {
                    LoadingScreen()
                }
            }
            .navigationBarTitle("Profile Info", displayMode: .inline)
            .onAppear {
                fetchUserData()
            }
        }
        .accentColor(.white)
    }
    
    
    private func fetchUserData() {
        if let currentUser = Auth.auth().currentUser {
                    Task {
                        do {
                            if let userData = try await UserManager.shared.fetchUserData(uid: currentUser.uid) {
                                full_name = userData["name"] as? String ?? ""
                                email = userData["email"] as? String ?? ""
                            }
                        } catch {
                            print("Error loading user data: \(error)")
                        }
                    }
                }
        }
    
    
    
    private func saveProfileData() {
        isLoading = true
        UserDefaults.standard.set(full_name, forKey: "name")
        
        if let user = Auth.auth().currentUser {
            let userRef = db.collection("users").document(user.uid)
            
            userRef.updateData([
                "name": full_name
            ]) { error in
                if let error = error {
                    print("Can't update now.")
                } else {
                    print("Updated successfully!")
                    presentationMode.wrappedValue.dismiss()
                }
                isLoading = false
            }
        }
    }
    
    
    @ViewBuilder
    func LoadingScreen() -> some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
                .edgesIgnoringSafeArea(.all)
            
            ProgressView()
                .frame(width: 45, height: 45)
                .background(.background, in: RoundedRectangle(cornerRadius: 5))
        }
    }
    
}

struct ProfileInfoView_Previews: PreviewProvider {
    static var previews: some View {
        EditProfile()
    }
}
