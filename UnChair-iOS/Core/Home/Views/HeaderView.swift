//
//  HeaderView.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 30/6/24.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct HeaderView: View {
    
    @State private var full_name: String = ""
    
    var body: some View {
        HStack(spacing : 20) {
            if let user = Auth.auth().currentUser, let profileImageURL = user.photoURL {
                
                AsyncImage(url: URL(string: profileImageURL.absoluteString)) { phase in
                    switch phase {
                    case .failure:
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 45, height: 45)
                            .clipShape(Circle())
                            .foregroundColor(.gray)
                            .padding(.leading, 20)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 45, height: 45)
                            .clipShape(Circle())
                            .foregroundColor(.gray)
                            .padding(.leading, 20)
                    default:
                        ProgressView()
                    }
                }
            } else {
                VStack {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 45, height: 45)
                        .clipShape(Circle())
                        .foregroundColor(.gray)
                        .padding(.leading, 20)
                }
            }
            
            Text("Hi"+", \(full_name)")
                .font(.title3)
                .fontWeight(.medium)
            
            Spacer()
//            ZStack {
//                RoundedRectangle(cornerRadius: 50, style: .continuous)
//                    .fill(Color(.systemBackground))
//                    .frame(width: 40, height: 40)
//                    .shadow(radius: 2)
//                
//                Image(systemName: "bell")
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 16, height: 16)
//                    .foregroundColor(.primary)
//            }
//            .padding(.trailing, 20)
        }
        .padding(.vertical, 20)
        .onAppear {
            fetchUserData()
        }
        
    }
    
    private func fetchUserData() {
        if let currentUser = Auth.auth().currentUser {
            Task {
                do {
                    if let userData = try await UserManager.shared.fetchUserData(uid: currentUser.uid) {
                        full_name = userData["name"] as? String ?? ""
                    }
                } catch {
                    print("Error loading user data: \(error)")
                }
            }
        }
    }
}




#Preview {
    HeaderView()
}
