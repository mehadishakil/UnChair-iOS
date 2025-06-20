//
//  AuthController.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 2/12/24.
//


//    @MainActor
//    func startListeningToAuthState() async {
//        if Auth.auth().currentUser == nil {
//            Auth.auth().signInAnonymously { [weak self] result, error in
//                if let error = error {
//                    print("❌ Anonymous sign‑in failed:", error)
//                    self?.authState = .unauthenticated
//                } else if let user = result?.user {
//                    print("✅ Signed in anon as", user.uid)
//                    self?.authState = .authenticated
//                    self?.identifyUserWithRevenueCat(uid: user.uid)
//                }
//            }
//        } else {
//            authState = .authenticated
//        }
//
//        Auth.auth().addStateDidChangeListener { [weak self] _, user in
//            self?.authState = (user != nil) ? .authenticated : .unauthenticated
//        }
//    }



//import SwiftUI
//import FirebaseAuth 
//import FirebaseCore 
//import GoogleSignIn 
//import AuthenticationServices 
//import FirebaseFirestore 
//import RevenueCat 
//
//@MainActor
//@Observable
//class AuthController: ObservableObject {
//   
//    enum AuthState {
//        case undefined, authenticated, unauthenticated
//    }
//    
//    var authState: AuthState = .undefined
//    private var db = Firestore.firestore()
//    var currentUser: User? { Auth.auth().currentUser }
//    var displayName: String = "anonymous"
//    var isAnonymousUser: Bool = true
//        
//
//    
//    
//    @MainActor
//    func startListeningToAuthState() async {
//        if Auth.auth().currentUser == nil {
//            do {
//                let result = try await Auth.auth().signInAnonymously()
//                print("✅ Signed in anon as", result.user.uid)
//                authState = .authenticated
//                identifyUserWithRevenueCat(uid: result.user.uid)
//            } catch {
//                print("❌ Anonymous sign‑in failed:", error)
//                authState = .unauthenticated
//            }
//        } else {
//            authState = .authenticated
//        }
//
//        Auth.auth().addStateDidChangeListener { [weak self] _, user in
//            self?.authState = (user != nil) ? .authenticated : .unauthenticated
//        }
//    }
//
//    @MainActor
//    func signInWithGoogle() async throws { 
//        guard let rootViewController = UIApplication.shared.firstKeyWindow?.rootViewController else { return } 
//        guard let clientID = FirebaseApp.app()?.options.clientID else { return } 
//        let configuration = GIDConfiguration(clientID: clientID) 
//        GIDSignIn.sharedInstance.configuration = configuration 
//        
//        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) 
//        guard let idToken = result.user.idToken?.tokenString else { return } 
//        let accessToken = result.user.accessToken.tokenString 
//        
//        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
//        
//        if let anonUser = Auth.auth().currentUser, anonUser.isAnonymous {
//                let authResult = try await anonUser.link(with: credential)
//                print("🔗 Linked anon user to Google:", authResult.user.uid)
//            } else {
//                let authResult = try await Auth.auth().signIn(with: credential)
//                print("Signed in existing user:", authResult.user.uid)
//            }
//
//            if let user = Auth.auth().currentUser {
//                try await saveUserData(user: user, provider: "google")
//                try await loadUserData(user: user)
//                identifyUserWithRevenueCat(uid: user.uid)
//                
//                self.displayName = user.displayName ?? "User"
//                self.isAnonymousUser = user.isAnonymous
//                self.authState = .authenticated
//            }
//    }
//    
//    @MainActor
//    func signInWithApple(authorization: ASAuthorization, nonce: String?) async throws {
//        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
//            throw NSError(domain: "AuthController", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid Apple ID Credential"])
//        }
//        guard let rawNonce = nonce else {
//            throw NSError(domain: "AuthController", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid state: A login callback was received, but no login request was sent."])
//        }
//        guard let appleIDToken = appleIDCredential.identityToken,
//              let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
//            throw NSError(domain: "AuthController", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to fetch or serialize identity token"])
//        }
//
//        let credential = OAuthProvider.appleCredential(
//            withIDToken: idTokenString,
//            rawNonce: rawNonce,
//            fullName: appleIDCredential.fullName
//        )
//
//        // 1️⃣ If we already have an anonymous user, link to it
//        if let anonUser = Auth.auth().currentUser, anonUser.isAnonymous {
//            let authResult = try await anonUser.link(with: credential)
//            print("🔗 Linked anonymous user to Apple account:", authResult.user.uid)
//        } else {
//            // 2️⃣ Otherwise do a normal sign‑in (existing or new non‑anon user)
//            let authResult = try await Auth.auth().signIn(with: credential)
//            print("🔑 Signed in via Apple:", authResult.user.uid)
//        }
//
//        // 3️⃣ After link/sign‑in, load/save your user data as before
//        if let user = Auth.auth().currentUser {
//            try await saveUserData(user: user, provider: "apple")
//            try await loadUserData(user: user)
//            identifyUserWithRevenueCat(uid: user.uid)
//            
//            self.displayName = user.displayName ?? "User"
//            self.isAnonymousUser = user.isAnonymous
//            self.authState = .authenticated
//        }
//    }
//
//    
//    @MainActor
//    func signUpWithEmail(
//        email: String,
//        password: String,
//        confirmPassword: String,
//        fullName: String
//    ) async throws {
//        guard password == confirmPassword else {
//            throw NSError(domain: "AuthController", code: 400, userInfo: [NSLocalizedDescriptionKey: "Passwords do not match"])
//        }
//
//        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
//
//        if let anonUser = Auth.auth().currentUser, anonUser.isAnonymous {
//            let authResult = try await anonUser.link(with: credential)
//            try await authResult.user.sendEmailVerification()
//
//            let changeRequest = authResult.user.createProfileChangeRequest()
//            changeRequest.displayName = fullName
//            try await changeRequest.commitChanges()
//
//            try await saveUserData(user: authResult.user, provider: "email")
//            try await loadUserData(user: authResult.user)
//            identifyUserWithRevenueCat(uid: authResult.user.uid)
//            
//            
//            self.displayName = authResult.user.displayName ?? "User"
//            self.isAnonymousUser = authResult.user.isAnonymous
//            self.authState = .authenticated
//        } else {
//            // fallback: create user normally
//            let result = try await Auth.auth().createUser(withEmail: email, password: password)
//            try await result.user.sendEmailVerification()
//
//            let changeRequest = result.user.createProfileChangeRequest()
//            changeRequest.displayName = fullName
//            try await changeRequest.commitChanges()
//
//            try await saveUserData(user: result.user, provider: "email")
//            try await loadUserData(user: result.user)
//            identifyUserWithRevenueCat(uid: result.user.uid)
//            
//            self.displayName = result.user.displayName ?? "User"
//            self.isAnonymousUser = result.user.isAnonymous
//            self.authState = .authenticated
//        }
//    }
//    
//    
//    @MainActor
//    func signInWithEmail(email: String, password: String) async throws -> Bool {
//        let result = try await Auth.auth().signIn(withEmail: email, password: password)
//        
//        if result.user.isEmailVerified {
//            try await loadUserData(user: result.user)
//            identifyUserWithRevenueCat(uid: result.user.uid)
//            return true // User is verified
//        } else {
//            try await result.user.sendEmailVerification()
//            return false // User not verified yet
//        }
//    }
//    
//    
//    func signOut() throws { 
//        do {
//            try Auth.auth().signOut() 
//            GIDSignIn.sharedInstance.signOut() // Sign out Google user
//            Purchases.shared.logOut { customerInfo, error in 
//                if let error = error {
//                    print("Error signing out from RevenueCat: \(error.localizedDescription)") 
//                } else {
//                    print("Successfully signed out from RevenueCat") 
//                }
//            }
//            self.authState = .unauthenticated // Update state
//        } catch {
//            throw NSError(domain: "AuthController", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to sign out"]) 
//        }
//    }
//    
//    
//    func saveUserData(user: User, provider: String) async throws { 
//        // Check if user already exists in Firestore
//        let userRef = db.collection("users").document(user.uid) 
//        let snapshot = try await userRef.getDocument() 
//        
//        if !snapshot.exists { 
//            // User doesn't exist, create new document
//            var userData: [String: Any] = [
//                "name": user.displayName ?? "Unknown", 
//                "provider": provider, 
//                "uid": user.uid, 
//            ]
//            
//            if let email = user.email { 
//                userData["email"] = email 
//            }
//            
//            try await userRef.setData(userData) 
//        }
//    }
//    
//    
//    func loadUserData(user: User) async throws { 
//        let userRef = db.collection("users").document(user.uid) 
//        let snapshot = try await userRef.getDocument() 
//        
//        if let data = snapshot.data() { 
//            // If the user document exists, map Firestore fields to your UserData model
//            let name = data["name"] as? String ?? "Unknown" 
//            let email = data["email"] as? String ?? "" 
//            let provider = data["provider"] as? String ?? "" 
//            
//            // Update the AuthController’s currentUser property
//            // self.currentUser = UserData(uid: user.uid, name: name, email: email, provider: provider)
//            
//            print("Fetched existing user data for \(name)") 
//        } else {
//            // If no document exists, create one (already handled by saveUserData)
//            // But you could also explicitly call saveUserData here if you want:
//            try await saveUserData(user: user, provider: "unknown") 
//        }
//    }
//    
//    private func identifyUserWithRevenueCat(uid: String) { 
//        Purchases.shared.logIn(uid) { (customerInfo, created, error) in 
//            if let error = error {
//                print("RevenueCat identify failed: \(error.localizedDescription)") 
//            } else {
//                print("RevenueCat identified as \(uid)") 
//            }
//        }
//    }
//    
//    
//}
//
//extension UIApplication {
//    var firstKeyWindow: UIWindow? {
//        return UIApplication.shared.connectedScenes
//            .compactMap { $0 as? UIWindowScene}
//            .filter { $0.activationState == .foregroundActive }
//            .first?.windows
//            .first(where: \.isKeyWindow)
//    }
//}


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
        case undefined, authenticated, unauthenticated, error(Error)
    }

    var authState: AuthState = .undefined {
        didSet { log("authState changed to: \(authState)") }
    }

    private var db = Firestore.firestore()
    var currentUser: User? { Auth.auth().currentUser }
    var displayName: String = "anonymous" {
        didSet { log("displayName updated to: \(displayName)") }
    }
    var isAnonymousUser: Bool = true {
        didSet { log("isAnonymousUser updated to: \(isAnonymousUser)") }
    }

    func log(_ message: String) {
        print("[AuthController] \(message)")
    }

    @MainActor
    func startListeningToAuthState() async {
        if Auth.auth().currentUser == nil {
            do {
                let result = try await Auth.auth().signInAnonymously()
                log("✅ Signed in anon as \(result.user.uid)")
                authState = .authenticated
                identifyUserWithRevenueCat(uid: result.user.uid)
            } catch {
                log("❌ Anonymous sign‑in failed: \(error.localizedDescription)")
                authState = .error(error)
            }
        } else {
            authState = .authenticated
        }

        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }
            if let user = user {
                self.log("🧠 Firebase state listener: user signed in \(user.uid)")
                self.authState = .authenticated
            } else {
                self.log("🧠 Firebase state listener: user signed out")
                self.authState = .unauthenticated
            }
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

        if let anonUser = Auth.auth().currentUser, anonUser.isAnonymous {
            let authResult = try await anonUser.link(with: credential)
            log("🔗 Linked anon user to Google: \(authResult.user.uid)")
        } else {
            let authResult = try await Auth.auth().signIn(with: credential)
            log("🔑 Signed in existing user: \(authResult.user.uid)")
        }

        if let user = Auth.auth().currentUser {
            try await saveUserData(user: user, provider: "google")
            try await loadUserData(user: user)
            identifyUserWithRevenueCat(uid: user.uid)
            self.displayName = user.displayName ?? "User"
            self.isAnonymousUser = user.isAnonymous
            self.authState = .authenticated
        }
    }

    @MainActor
    func signInWithApple(authorization: ASAuthorization, nonce: String?) async throws {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            throw NSError(domain: "AuthController", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid Apple ID Credential"])
        }
        guard let rawNonce = nonce else {
            throw NSError(domain: "AuthController", code: -1, userInfo: [NSLocalizedDescriptionKey: "Missing nonce"])
        }
        guard let appleIDToken = appleIDCredential.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            throw NSError(domain: "AuthController", code: -1, userInfo: [NSLocalizedDescriptionKey: "Token conversion failed"])
        }

        let credential = OAuthProvider.appleCredential(
            withIDToken: idTokenString,
            rawNonce: rawNonce,
            fullName: appleIDCredential.fullName
        )

        if let anonUser = Auth.auth().currentUser, anonUser.isAnonymous {
            let authResult = try await anonUser.link(with: credential)
            log("🔗 Linked anonymous user to Apple account: \(authResult.user.uid)")
        } else {
            let authResult = try await Auth.auth().signIn(with: credential)
            log("🔑 Signed in via Apple: \(authResult.user.uid)")
        }

        if let user = Auth.auth().currentUser {
            try await saveUserData(user: user, provider: "apple")
            try await loadUserData(user: user)
            identifyUserWithRevenueCat(uid: user.uid)
            self.displayName = user.displayName ?? "User"
            self.isAnonymousUser = user.isAnonymous
            self.authState = .authenticated
        }
    }

    @MainActor
    func signUpWithEmail(email: String, password: String, confirmPassword: String, fullName: String) async throws {
        guard password == confirmPassword else {
            throw NSError(domain: "AuthController", code: 400, userInfo: [NSLocalizedDescriptionKey: "Passwords do not match"])
        }

        let credential = EmailAuthProvider.credential(withEmail: email, password: password)

        if let anonUser = Auth.auth().currentUser, anonUser.isAnonymous {
            let authResult = try await anonUser.link(with: credential)
            try await authResult.user.sendEmailVerification()

            let changeRequest = authResult.user.createProfileChangeRequest()
            changeRequest.displayName = fullName
            try await changeRequest.commitChanges()

            try await saveUserData(user: authResult.user, provider: "email")
            try await loadUserData(user: authResult.user)
            identifyUserWithRevenueCat(uid: authResult.user.uid)
            self.displayName = authResult.user.displayName ?? "User"
            self.isAnonymousUser = authResult.user.isAnonymous
            self.authState = .authenticated
        } else {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            try await result.user.sendEmailVerification()

            let changeRequest = result.user.createProfileChangeRequest()
            changeRequest.displayName = fullName
            try await changeRequest.commitChanges()

            try await saveUserData(user: result.user, provider: "email")
            try await loadUserData(user: result.user)
            identifyUserWithRevenueCat(uid: result.user.uid)
            self.displayName = result.user.displayName ?? "User"
            self.isAnonymousUser = result.user.isAnonymous
            self.authState = .authenticated
        }
    }

    @MainActor
    func signInWithEmail(email: String, password: String) async throws -> Bool {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)

        if result.user.isEmailVerified {
            try await loadUserData(user: result.user)
            identifyUserWithRevenueCat(uid: result.user.uid)
            self.displayName = result.user.displayName ?? "User"
            self.isAnonymousUser = result.user.isAnonymous
            self.authState = .authenticated
            return true
        } else {
            try await result.user.sendEmailVerification()
            return false
        }
    }

    func signOut() throws {
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut()
            Purchases.shared.logOut { customerInfo, error in
                if let error = error {
                    self.log("❌ RevenueCat logOut error: \(error.localizedDescription)")
                } else {
                    self.log("✅ Signed out from RevenueCat")
                }
            }
            self.authState = .unauthenticated
        } catch {
            throw NSError(domain: "AuthController", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to sign out"])
        }
    }

    func saveUserData(user: User, provider: String) async throws {
        let userRef = db.collection("users").document(user.uid)
        let snapshot = try await userRef.getDocument()

        if !snapshot.exists {
            var userData: [String: Any] = [
                "name": user.displayName ?? "Unknown",
                "provider": provider,
                "uid": user.uid
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
            let name = data["name"] as? String ?? "Unknown"
            log("📄 Loaded user data for: \(name)")
        } else {
            try await saveUserData(user: user, provider: "unknown")
        }
    }

    private func identifyUserWithRevenueCat(uid: String) {
        Purchases.shared.logIn(uid) { customerInfo, created, error in
            if let error = error {
                self.log("RevenueCat identify failed: \(error.localizedDescription)")
            } else {
                self.log("RevenueCat identified as \(uid)")
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
