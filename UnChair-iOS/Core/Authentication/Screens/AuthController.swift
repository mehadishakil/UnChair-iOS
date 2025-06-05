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


enum EmailLinkStatus {
  case none
  case pending
}


@MainActor
class AuthController: ObservableObject {
    
    
    var authState: AuthState = .undefined 
    private var db = Firestore.firestore() 
    var currentUser: UserData? = nil
    
    
    @AppStorage("email-link") var emailLink: String?
    @Published var email = ""

    @Published var isValid  = false
    @Published var authenticationState: AuthState = .unauthenticated
    @Published var errorMessage = ""
    @Published var user: User?
    @Published var displayName = ""

    @Published var isGuestUser = false
    @Published var isVerified = false
    
    
    init() {
      registerAuthStateHandler()

      $email
        .map { email in
          !email.isEmpty
        }
        .assign(to: &$isValid)

      $user
        .compactMap { user in
          user?.isAnonymous
        }
        .assign(to: &$isGuestUser)

      $user
        .compactMap { user in
          user?.isEmailVerified
        }
        .assign(to: &$isVerified)
    }
    
    
    func startListeningToAuthState() async { 
        _ = Auth.auth().addStateDidChangeListener { _, user in 
            DispatchQueue.main.async {
                if let user = user { 
                    self.authState = .authenticated 
                    Task {
                        do {
                            try await self.loadUserData(user: user) 
                        } catch {
                            print("Error loading user data: \(error.localizedDescription)") 
                        }
                    }
                } else {
                    self.authState = .unauthenticated 
                    self.currentUser = nil 
                }
            }
        }
    }
    
    
    
    

    

    
      

      

      private var authStateHandler: AuthStateDidChangeListenerHandle?

      func registerAuthStateHandler() {
        if authStateHandler == nil {
          authStateHandler = Auth.auth().addStateDidChangeListener { auth, user in
            self.user = user
            self.authenticationState = user == nil ? .unauthenticated : .authenticated
            self.displayName = user?.email ?? ""
          }
        }
      }

      private func wait() async {
        do {
          print("Wait")
          try await Task.sleep(nanoseconds: 1_000_000_000)
          print("Done")
        }
        catch {
          print(error.localizedDescription)
        }
      }

      func reset() {
        email = ""
        emailLink = nil
        errorMessage = ""
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
            self.currentUser = UserData(uid: user.uid, name: name, email: email, provider: provider) 
            
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


extension AuthController {
  func sendSignInLink() async {
    let actionCodeSettings = ActionCodeSettings()
    actionCodeSettings.handleCodeInApp = true
    actionCodeSettings.url = URL(string: "https://unchair.page.link/email-link-login")

    do {
      try await Auth.auth().sendSignInLink(toEmail: email, actionCodeSettings: actionCodeSettings)
      emailLink = email
    }
    catch {
      print(error.localizedDescription)
      errorMessage = error.localizedDescription
    }
  }

  var emailLinkStatus: EmailLinkStatus {
    emailLink == nil ? .none : .pending
  }

  func handleSignInLink(_ url: URL) async {
    guard let email = emailLink else {
      errorMessage = "Invalid email address. Most likely, the link you used has expired. Try signing in again."
      return
    }
    let link = url.absoluteString
    if Auth.auth().isSignIn(withEmailLink: link) {
      do {
        let result = try await Auth.auth().signIn(withEmail: email, link: link)
        let user = result.user
        print("User \(user.uid) signed in with email \(user.email ?? "(unknown)"). The email is \(user.isEmailVerified ? "" : "NOT") verified")
        emailLink = nil
      }
      catch {
        print(error.localizedDescription)
        self.errorMessage = error.localizedDescription
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
