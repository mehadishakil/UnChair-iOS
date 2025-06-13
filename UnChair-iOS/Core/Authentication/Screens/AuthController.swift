//
//  AuthController.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 2/12/24.
//

import SwiftUI
import FirebaseAuth 
import FirebaseCore 
import GoogleSignIn 
import AuthenticationServices 
import FirebaseFirestore 
import RevenueCat 

@MainActor
@Observable
class AuthController: ObservableObject {
   
    enum AuthState {
        case undefined, authenticated, unauthenticated
    }
    
    var authState: AuthState = .undefined
    private var db = Firestore.firestore()
    var currentUser: User? { Auth.auth().currentUser }
    
//    func startListeningToAuthState() async { 
//        _ = Auth.auth().addStateDidChangeListener { _, user in 
//            DispatchQueue.main.async {
//                if let user = user { 
//                    self.authState = .authenticated 
//                    Task {
//                        do {
//                            try await self.loadUserData(user: user) 
//                        } catch {
//                            print("Error loading user data: \(error.localizedDescription)") 
//                        }
//                    }
//                } else {
//                    self.authState = .unauthenticated 
//                    self.currentUser = nil 
//                }
//            }
//        }
//    }
    
    func startListeningToAuthState() async {
        // Immediately reflect any already-signed‑in user:
        if Auth.auth().currentUser != nil {
          authState = .authenticated
        } else {
          authState = .unauthenticated
        }

        // Then hook up Firebase’s listener for real‑time changes:
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
          guard let self = self else { return }
          self.authState = (user != nil) ? .authenticated : .unauthenticated
        }
      }

    
    
    @MainActor
    func signInWithGoogle() async throws { 
        guard let rootViewController = UIApplication.shared.firstKeyWindow?.rootViewController else { return } 
        guard let clientID = FirebaseApp.app()?.options.clientID else { return } 
        let configuration = GIDConfiguration(clientID: clientID) 
        GIDSignIn.sharedInstance.configuration = configuration 
        
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) 
        guard let idToken = result.user.idToken?.tokenString else { return } 
        let accessToken = result.user.accessToken.tokenString 
        
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken) 
        try await Auth.auth().signIn(with: credential) 
        
        if let user = Auth.auth().currentUser { 
            try await saveUserData(user: user, provider: "google") 
            try await loadUserData(user: user) 
            identifyUserWithRevenueCat(uid: user.uid) 
        }
    }
    
    @MainActor
    func signInWithApple(authorization: ASAuthorization, nonce: String?) async throws { 
        do {
            guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else { 
                throw NSError(domain: "AuthController", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid Apple ID Credential"]) 
            }
            
            guard let nonce = nonce else { 
                throw NSError(domain: "AuthController", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid state: A login callback was received, but no login request was sent."]) 
            }
            
            guard let appleIDToken = appleIDCredential.identityToken else { 
                throw NSError(domain: "AuthController", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to fetch identity token"]) 
            }
            
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else { 
                throw NSError(domain: "AuthController", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to serialize token string from data: \(appleIDToken.debugDescription)"]) 
            }
            
            let credential = OAuthProvider.appleCredential(withIDToken: idTokenString, rawNonce: nonce, fullName: appleIDCredential.fullName) 
            try await Auth.auth().signIn(with: credential) 
            
            if let user = Auth.auth().currentUser { 
                try await saveUserData(user: user, provider: "apple") 
                try await loadUserData(user: user) 
                identifyUserWithRevenueCat(uid: user.uid) 
            }
        } catch {
            print("Apple Sign-In Error: \(error.localizedDescription)") 
            throw error 
        }
    }
    
    
    func signOut() throws { 
        do {
            try Auth.auth().signOut() 
            GIDSignIn.sharedInstance.signOut() // Sign out Google user
            Purchases.shared.logOut { customerInfo, error in 
                if let error = error {
                    print("Error signing out from RevenueCat: \(error.localizedDescription)") 
                } else {
                    print("Successfully signed out from RevenueCat") 
                }
            }
            self.authState = .unauthenticated // Update state
        } catch {
            throw NSError(domain: "AuthController", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to sign out"]) 
        }
    }
    
    
    func saveUserData(user: User, provider: String) async throws { 
        // Check if user already exists in Firestore
        let userRef = db.collection("users").document(user.uid) 
        let snapshot = try await userRef.getDocument() 
        
        if !snapshot.exists { 
            // User doesn't exist, create new document
            var userData: [String: Any] = [
                "name": user.displayName ?? "Unknown", 
                "provider": provider, 
                "uid": user.uid, 
            ]
            
            if let email = user.email { 
                userData["email"] = email 
            }
            
            try await userRef.setData(userData) 
        }
    }
    
    
    func loadUserData(user: User) async throws { 
        let userRef = db.collection("users").document(user.uid) 
        let snapshot = try await userRef.getDocument() 
        
        if let data = snapshot.data() { 
            // If the user document exists, map Firestore fields to your UserData model
            let name = data["name"] as? String ?? "Unknown" 
            let email = data["email"] as? String ?? "" 
            let provider = data["provider"] as? String ?? "" 
            
            // Update the AuthController’s currentUser property
            // self.currentUser = UserData(uid: user.uid, name: name, email: email, provider: provider)
            
            print("Fetched existing user data for \(name)") 
        } else {
            // If no document exists, create one (already handled by saveUserData)
            // But you could also explicitly call saveUserData here if you want:
            try await saveUserData(user: user, provider: "unknown") 
        }
    }
    
    private func identifyUserWithRevenueCat(uid: String) { 
        Purchases.shared.logIn(uid) { (customerInfo, created, error) in 
            if let error = error {
                print("RevenueCat identify failed: \(error.localizedDescription)") 
            } else {
                print("RevenueCat identified as \(uid)") 
            }
        }
    }
    
    
}

extension UIApplication {
    var firstKeyWindow: UIWindow? {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene}
            .filter { $0.activationState == .foregroundActive }
            .first?.windows
            .first(where: \.isKeyWindow)
    }
}
