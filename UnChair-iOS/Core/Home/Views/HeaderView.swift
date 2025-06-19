//
//  HeaderView.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 30/6/24.
//

import SwiftUI
import FirebaseAuth

struct HeaderView: View {
    @State private var fullName: String = ""
    @State private var isAnonymousUser = false

    var body: some View {
        HStack {
            // Greeting + optional login CTA
            
                Text(isAnonymousUser
                     ? "Let’s begin!"
                     : "Good \(timeOfDay), \(fullName)")
                .font(.title2.weight(.semibold))

                
            

            Spacer()

            // Avatar / Sign-in button
            ProfileAvatarView(size: 36, isAnonymous: isAnonymousUser)
        }
        .padding(.horizontal)
        .padding(.vertical, 20)
        .onAppear(perform: fetchUserData)
    }

    // MARK: - Helpers

    /// “Morning”, “Afternoon”, “Evening”, or “Night”
    private var timeOfDay: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Morning"
        case 12..<17: return "Afternoon"
        case 17..<22: return "Evening"
        default:     return "Night"
        }
    }

    private func fetchUserData() {
        guard let user = Auth.auth().currentUser else {
            isAnonymousUser = true
            fullName = "anonymous"
            return
        }

        if user.isAnonymous {
            isAnonymousUser = true
            fullName = "anonymous"
        } else {
            isAnonymousUser = false
            Task {
                do {
                    if let data = try await UserManager.shared.fetchUserData(uid: user.uid) {
                        fullName = data["name"] as? String ?? "Unknown"
                    }
                } catch {
                    print("Error loading user data:", error)
                }
            }
        }
    }
}

struct ProfileAvatarView: View {
    let size: CGFloat
    let isAnonymous: Bool

    var body: some View {
        if isAnonymous {
            NavigationLink(destination: SigninView()) {
                Image(systemName: "person.crop.circle.fill.badge.plus")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size, height: size)
                    .clipShape(Circle())
                    .foregroundColor(.primary.opacity(0.7))
            }
        } else if let url = Auth.auth().currentUser?.photoURL {
            AsyncImage(url: url) { phase in
                NavigationLink(destination: EditProfile()) {
                    switch phase {
                    case .success(let img):
                        img.resizable()
                           .aspectRatio(contentMode: .fill)
                           .frame(width: size, height: size)
                           .clipShape(Circle())
                    default:
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: size, height: size)
                            .clipShape(Circle())
                            .foregroundColor(.primary.opacity(0.7))
                    }
                }
            }
            .frame(width: size, height: size)
            .clipShape(Circle())
        } else {
            NavigationLink(destination: EditProfile()) {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size, height: size)
                    .clipShape(Circle())
                    .foregroundColor(.gray)
            }
        }
    }
}

#Preview {
    HeaderView()
}



//        HStack(spacing : 20) {
//            if let user = Auth.auth().currentUser, let profileImageURL = user.photoURL {
//
//                AsyncImage(url: URL(string: profileImageURL.absoluteString)) { phase in
//                    switch phase {
//                    case .failure:
//                        Image(systemName: "person.circle.fill")
//                            .resizable()
//                            .aspectRatio(contentMode: .fill)
//                            .frame(width: 45, height: 45)
//                            .clipShape(Circle())
//                            .foregroundColor(.gray)
//                            .padding(.leading, 20)
//                    case .success(let image):
//                        image
//                            .resizable()
//                            .aspectRatio(contentMode: .fill)
//                            .frame(width: 45, height: 45)
//                            .clipShape(Circle())
//                            .foregroundColor(.gray)
//                            .padding(.leading, 20)
//                    default:
//                        ProgressView()
//                    }
//                }
//            } else {
//                VStack {
//                    Image(systemName: "person.circle.fill")
//                        .resizable()
//                        .aspectRatio(contentMode: .fill)
//                        .frame(width: 45, height: 45)
//                        .clipShape(Circle())
//                        .foregroundColor(.gray)
//                        .padding(.leading, 20)
//                }
//            }
//
//            Text("Hi"+", \(full_name)")
//                .font(.title3)
//                .fontWeight(.medium)
//
//            Spacer()
////            ZStack {
////                RoundedRectangle(cornerRadius: 50, style: .continuous)
////                    .fill(Color(.systemBackground))
////                    .frame(width: 40, height: 40)
////                    .shadow(radius: 2)
////
////                Image(systemName: "bell")
////                    .resizable()
////                    .scaledToFit()
////                    .frame(width: 16, height: 16)
////                    .foregroundColor(.primary)
////            }
////            .padding(.trailing, 20)
//        }
//        .padding(.vertical, 20)
//        .onAppear {
//            fetchUserData()
//        }
