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
    @State private var isAnonymousUser = false
    @Environment(\.presentationMode) var presentationMode
    private var db = Firestore.firestore()
    
    
    var body: some View {
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
                    Text(isAnonymousUser ? "To update your profile, sign in with your social account" : "Your profile picture is updated from your linked social (Apple/Google) account")
                        .foregroundColor(.gray)
                        .font(.caption2)
                        .multilineTextAlignment(.center)
                    
                    VStack {
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
                    }
                    .disabled(isAnonymousUser)
                    
                    
                    
                    
                    Spacer()
                    
                    if isAnonymousUser {
                        NavigationLink(destination: SigninView()) {
                            Text("Sign in")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                    } else {
                        Button(action: {
                            saveProfileData()
                        }) {
                            Text("Save")
                                .foregroundColor(.white)
                                .font(.title3)
                                .bold()
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
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
    
    
    private func fetchUserData() {
        guard let user = Auth.auth().currentUser else {
            // No user at all—treat as anonymous
            isAnonymousUser = true
            full_name = "anonymous"
            email     = "anonymous"
            return
        }
        
        if user.isAnonymous {
            isAnonymousUser = true
            full_name = "anonymous"
            email     = "anonymous"
        } else {
            isAnonymousUser = false
            Task {
                do {
                    if let userData = try await UserManager.shared.fetchUserData(uid: user.uid) {
                        full_name = userData["name"] as? String ?? ""
                        email     = userData["email"] as? String ?? ""
                    }
                } catch {
                    print("Error loading user data: \(error)")
                }
            }
        }
    }
    
    private func saveProfileData() {
        guard !isAnonymousUser, let user = Auth.auth().currentUser else { return }
        
        isLoading = true
        UserDefaults.standard.set(full_name, forKey: "name")
        
        let userRef = db.collection("users").document(user.uid)
        userRef.updateData([
            "name": full_name
        ]) { error in
            isLoading = false
            if let error = error {
                print("Can't update now:", error)
            } else {
                print("Updated successfully!")
                presentationMode.wrappedValue.dismiss()
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
