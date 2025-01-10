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
import FirebaseStorage

@MainActor
@Observable
class AuthController: ObservableObject {
    
    
    var authState: AuthState = .undefined
    private var db = Firestore.firestore()
    private var storage = Storage.storage()
    
    
    func startListeningToAuthState() async {
        Auth.auth().addStateDidChangeListener { _, user in
            self.authState = user != nil ? .authenticated : .unauthenticated
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
        }
    }
    
    
    func signInWithApple(authorization: ASAuthorization, nonce: String?) async throws {
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
        }
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    private func saveUserData(user: User, provider: String) async throws {
        // Check if user already exists in Firestore
        let userRef = db.collection("users").document(user.uid)
        let snapshot = try await userRef.getDocument()
        
        if !snapshot.exists {
            // User doesn't exist, create new document
            var userData: [String: Any] = [
                "name": user.displayName ?? "Unknown",
                "email": user.email ?? "No email",
                "provider": provider,
                "uid": user.uid,
            ]
            try await userRef.setData(userData)
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


