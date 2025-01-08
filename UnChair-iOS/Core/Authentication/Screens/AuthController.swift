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

@Observable
class AuthController: ObservableObject {
    
    var authState: AuthState = .undefined
    @Published var errorMessage: String = ""
    @Published var isLoading: Bool = false
    
    func startListeningToAuthState() async {
        Auth.auth().addStateDidChangeListener { _, user in
            self.authState = user != nil ? .authenticated : .unauthenticated
        }
    }
    
    func signInWithApple(request: ASAuthorizationAppleIDRequest) {
        let nonce = randomNonceString()
        request.requestedScopes = [.email, .fullName]
        request.nonce = sha256(nonce)
    }
    
    func handleSignInWithAppleCompletion(result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                showError("Cannot process your request.")
                return
            }
            signInWithApple(credential: appleIDCredential)
        case .failure(let error):
            showError(error.localizedDescription)
        }
    }
    
    private func signInWithApple(credential: ASAuthorizationAppleIDCredential) {
        isLoading = true
        guard let nonce = nonce else {
            showError("Cannot process your request.")
            return
        }
        guard let appleIDToken = credential.identityToken else {
            showError("Cannot process your request.")
            return
        }
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            showError("Cannot process your request.")
            return
        }
        
        let firebaseCredential = OAuthProvider.appleCredential(withIDToken: idTokenString, rawNonce: nonce, fullName: credential.fullName)
        Auth.auth().signIn(with: firebaseCredential) { authResult, error in
            if let error = error {
                self.showError(error.localizedDescription)
                return
            }
            self.logStatus = true
            self.isLoading = false
        }
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        // ... (same implementation)
    }
    
    private func sha256(_ input: String) -> String {
        // ... (same implementation)
    }
    
    private func showError(_ message: String) {
        errorMessage = message
        isLoading = false
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
        
    }
    
    func signInWithApple() async throws {
        
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
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
