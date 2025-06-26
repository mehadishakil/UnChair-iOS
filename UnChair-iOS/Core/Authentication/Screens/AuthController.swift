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





// 111111111111

//
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
//        case undefined, authenticated, unauthenticated, error(Error)
//    }
//
//    var authState: AuthState = .undefined {
//        didSet { log("authState changed to: \(authState)") }
//    }
//
//    private var db = Firestore.firestore()
//    var currentUser: User? { Auth.auth().currentUser }
//    var displayName: String = "anonymous" {
//        didSet { log("displayName updated to: \(displayName)") }
//    }
//    var isAnonymousUser: Bool = true {
//        didSet { log("isAnonymousUser updated to: \(isAnonymousUser)") }
//    }
//
//    func log(_ message: String) {
//        print("[AuthController] \(message)")
//    }
//
//    @MainActor
//    func startListeningToAuthState() async {
//        if Auth.auth().currentUser == nil {
//            do {
//                let result = try await Auth.auth().signInAnonymously()
//                log("✅ Signed in anon as \(result.user.uid)")
//                authState = .authenticated
//                identifyUserWithRevenueCat(uid: result.user.uid)
//            } catch {
//                log("❌ Anonymous sign‑in failed: \(error.localizedDescription)")
//                authState = .error(error)
//            }
//        } else {
//            authState = .authenticated
//        }
//
//        Auth.auth().addStateDidChangeListener { [weak self] _, user in
//            guard let self = self else { return }
//            if let user = user {
//                self.log("🧠 Firebase state listener: user signed in \(user.uid)")
//                self.authState = .authenticated
//            } else {
//                self.log("🧠 Firebase state listener: user signed out")
//                self.authState = .unauthenticated
//            }
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
//        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
//
//        if let anonUser = Auth.auth().currentUser, anonUser.isAnonymous {
//            let authResult = try await anonUser.link(with: credential)
//            log("🔗 Linked anon user to Google: \(authResult.user.uid)")
//        } else {
//            let authResult = try await Auth.auth().signIn(with: credential)
//            log("🔑 Signed in existing user: \(authResult.user.uid)")
//        }
//
//        if let user = Auth.auth().currentUser {
//            try await saveUserData(user: user, provider: "google")
//            try await loadUserData(user: user)
//            identifyUserWithRevenueCat(uid: user.uid)
//            self.displayName = user.displayName ?? "User"
//            self.isAnonymousUser = user.isAnonymous
//            self.authState = .authenticated
//        }
//    }
//
//    @MainActor
//    func signInWithApple(authorization: ASAuthorization, nonce: String?) async throws {
//        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
//            throw NSError(domain: "AuthController", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid Apple ID Credential"])
//        }
//        guard let rawNonce = nonce else {
//            throw NSError(domain: "AuthController", code: -1, userInfo: [NSLocalizedDescriptionKey: "Missing nonce"])
//        }
//        guard let appleIDToken = appleIDCredential.identityToken,
//              let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
//            throw NSError(domain: "AuthController", code: -1, userInfo: [NSLocalizedDescriptionKey: "Token conversion failed"])
//        }
//
//        let credential = OAuthProvider.appleCredential(
//            withIDToken: idTokenString,
//            rawNonce: rawNonce,
//            fullName: appleIDCredential.fullName
//        )
//
//        if let anonUser = Auth.auth().currentUser, anonUser.isAnonymous {
//            let authResult = try await anonUser.link(with: credential)
//            log("🔗 Linked anonymous user to Apple account: \(authResult.user.uid)")
//        } else {
//            let authResult = try await Auth.auth().signIn(with: credential)
//            log("🔑 Signed in via Apple: \(authResult.user.uid)")
//        }
//
//        if let user = Auth.auth().currentUser {
//            try await saveUserData(user: user, provider: "apple")
//            try await loadUserData(user: user)
//            identifyUserWithRevenueCat(uid: user.uid)
//            self.displayName = user.displayName ?? "User"
//            self.isAnonymousUser = user.isAnonymous
//            self.authState = .authenticated
//        }
//    }
//
//    @MainActor
//    func signUpWithEmail(email: String, password: String, confirmPassword: String, fullName: String) async throws {
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
//            self.displayName = authResult.user.displayName ?? "User"
//            self.isAnonymousUser = authResult.user.isAnonymous
//            self.authState = .authenticated
//        } else {
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
//            self.displayName = result.user.displayName ?? "User"
//            self.isAnonymousUser = result.user.isAnonymous
//            self.authState = .authenticated
//        }
//    }
//
//    @MainActor
//    func signInWithEmail(email: String, password: String) async throws -> Bool {
//        let result = try await Auth.auth().signIn(withEmail: email, password: password)
//
//        if result.user.isEmailVerified {
//            try await loadUserData(user: result.user)
//            identifyUserWithRevenueCat(uid: result.user.uid)
//            self.displayName = result.user.displayName ?? "User"
//            self.isAnonymousUser = result.user.isAnonymous
//            self.authState = .authenticated
//            return true
//        } else {
//            try await result.user.sendEmailVerification()
//            return false
//        }
//    }
//
//    func signOut() throws {
//        do {
//            try Auth.auth().signOut()
//            GIDSignIn.sharedInstance.signOut()
//            Purchases.shared.logOut { customerInfo, error in
//                if let error = error {
//                    self.log("❌ RevenueCat logOut error: \(error.localizedDescription)")
//                } else {
//                    self.log("✅ Signed out from RevenueCat")
//                }
//            }
//            self.authState = .unauthenticated
//        } catch {
//            throw NSError(domain: "AuthController", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to sign out"])
//        }
//    }
//
//    func saveUserData(user: User, provider: String) async throws {
//        let userRef = db.collection("users").document(user.uid)
//        let snapshot = try await userRef.getDocument()
//
//        if !snapshot.exists {
//            var userData: [String: Any] = [
//                "name": user.displayName ?? "Unknown",
//                "provider": provider,
//                "uid": user.uid
//            ]
//            if let email = user.email {
//                userData["email"] = email
//            }
//            try await userRef.setData(userData)
//        }
//    }
//
//    func loadUserData(user: User) async throws {
//        let userRef = db.collection("users").document(user.uid)
//        let snapshot = try await userRef.getDocument()
//
//        if let data = snapshot.data() {
//            let name = data["name"] as? String ?? "Unknown"
//            log("📄 Loaded user data for: \(name)")
//        } else {
//            try await saveUserData(user: user, provider: "unknown")
//        }
//    }
//
//    private func identifyUserWithRevenueCat(uid: String) {
//        Purchases.shared.logIn(uid) { customerInfo, created, error in
//            if let error = error {
//                self.log("RevenueCat identify failed: \(error.localizedDescription)")
//            } else {
//                self.log("RevenueCat identified as \(uid)")
//            }
//        }
//    }
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


// 2222222222222222
//
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
//        case undefined, authenticated, unauthenticated, error(Error)
//    }
//
//    var authState: AuthState = .undefined {
//        didSet { log("authState changed to: \(authState)") }
//    }
//
//    private var db = Firestore.firestore()
//    var currentUser: User? { Auth.auth().currentUser }
//    var displayName: String = "anonymous" {
//        didSet { log("displayName updated to: \(displayName)") }
//    }
//    var isAnonymousUser: Bool = true {
//        didSet { log("isAnonymousUser updated to: \(isAnonymousUser)") }
//    }
//
//    private var anonUidBeforeLink: String?
//
//    func log(_ message: String) {
//        print("[AuthController] \(message)")
//    }
//
//    // UIApplication extension for firstKeyWindow
//    private var rootViewController: UIViewController? {
//        UIApplication.shared.connectedScenes
//            .compactMap { $0 as? UIWindowScene }
//            .flatMap { $0.windows }
//            .first { $0.isKeyWindow }?
//            .rootViewController
//    }
//
//    @MainActor
//    func startListeningToAuthState() async {
//        // Listen for Firebase auth state changes
//        Auth.auth().addStateDidChangeListener { [weak self] _, user in
//            guard let self = self else { return }
//            if let user = user {
//                self.log("Firebase state listener: user signed in \(user.uid), isAnonymous: \(user.isAnonymous)")
//                self.authState = .authenticated
//                self.displayName = user.displayName ?? "User"
//                self.isAnonymousUser = user.isAnonymous
//            } else {
//                self.log("Firebase state listener: user signed out")
//                self.authState = .unauthenticated
//            }
//        }
//
//        // Perform anonymous sign-in if needed
//        if Auth.auth().currentUser == nil {
//            do {
//                let result = try await Auth.auth().signInAnonymously()
//                log("Signed in anon as \(result.user.uid)")
//                authState = .authenticated
//                identifyUserWithRevenueCat(uid: result.user.uid)
//            } catch {
//                log("Anonymous sign‑in failed: \(error.localizedDescription)")
//                authState = .error(error)
//            }
//        } else if let user = Auth.auth().currentUser {
//            // Store anon UID before potential link
//            anonUidBeforeLink = user.isAnonymous ? user.uid : nil
//            authState = .authenticated
//            identifyUserWithRevenueCat(uid: user.uid)
//        }
//    }
//
//    // MARK: - Google Sign-In
//    @MainActor
//    func signInWithGoogle() async throws {
//        guard let rootVC = rootViewController,
//              let clientID = FirebaseApp.app()?.options.clientID else { return }
//        let config = GIDConfiguration(clientID: clientID)
//        GIDSignIn.sharedInstance.configuration = config
//
//        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootVC)
//        guard let idToken = result.user.idToken?.tokenString else { return }
//        let accessToken = result.user.accessToken.tokenString
//        let credential = GoogleAuthProvider.credential(
//            withIDToken: idToken,
//            accessToken: accessToken
//        )
//        try await linkOrSignIn(with: credential)
//    }
//
//    // MARK: - Apple Sign-In
//    @MainActor
//    func signInWithApple(authorization: ASAuthorization, nonce: String?) async throws {
//        guard let appleCred = authorization.credential as? ASAuthorizationAppleIDCredential,
//              let rawNonce = nonce,
//              let tokenData = appleCred.identityToken,
//              let idToken = String(data: tokenData, encoding: .utf8) else {
//            throw NSError(domain: "AuthController", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid Apple credentials"])
//        }
//        let credential = OAuthProvider.appleCredential(
//            withIDToken: idToken,
//            rawNonce: rawNonce,
//            fullName: appleCred.fullName
//        )
//        try await linkOrSignIn(with: credential)
//    }
//
//    // MARK: - Email Sign-Up
//    @MainActor
//    func signUpWithEmail(email: String, password: String, confirm: String, fullName: String) async throws {
//        guard password == confirm else {
//            throw NSError(domain: "AuthController", code: 400, userInfo: [NSLocalizedDescriptionKey: "Passwords do not match"])
//        }
//        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
//        try await linkOrCreateEmail(credential: credential, email: email, password: password, fullName: fullName)
//    }
//
//    // MARK: - Email Sign-In
//    @MainActor
//    func signInWithEmail(email: String, password: String) async throws -> Bool {
//        let result = try await Auth.auth().signIn(withEmail: email, password: password)
//        guard result.user.isEmailVerified else {
//            try await result.user.sendEmailVerification()
//            return false
//        }
//        handlePostAuth(user: result.user)
//        return true
//    }
//
//    // MARK: - Sign Out
//    func signOut() throws {
//        try Auth.auth().signOut()
//        GIDSignIn.sharedInstance.signOut()
//        Purchases.shared.logOut { _, error in
//            if let e = error { self.log("RevenueCat logout error: \(e.localizedDescription)") }
//        }
//        authState = .unauthenticated
//    }
//
//    // MARK: - Link or Sign-In
//    private func linkOrSignIn(with credential: AuthCredential) async throws {
//        guard let user = Auth.auth().currentUser else { return }
//        let preLinkAnon = user.uid // Capture BEFORE linking
//        
//        do {
//            let authResult = try await user.link(with: credential)
//            log("Linked anonymous user to \(credential.provider) with UID: \(authResult.user.uid)")
//            handlePostAuth(user: authResult.user)
//        } catch let err as NSError where AuthErrorCode(rawValue: err.code) == .credentialAlreadyInUse {
//            let authResult = try await Auth.auth().signIn(with: credential)
//            try await mergeAnonymousData(into: authResult.user.uid, from: preLinkAnon) // Use captured UID
//            handlePostAuth(user: authResult.user)
//        }
//    }
//
//    // MARK: - Link or Create Email
//    private func linkOrCreateEmail(credential: AuthCredential, email: String, password: String, fullName: String) async throws {
//        if let user = Auth.auth().currentUser, user.isAnonymous {
//            do {
//                let authResult = try await user.link(with: credential)
//                try await authResult.user.sendEmailVerification()
//                let changeReq = authResult.user.createProfileChangeRequest()
//                changeReq.displayName = fullName
//                try await changeReq.commitChanges()
//                log("Linked anonymous to email user UID: \(authResult.user.uid)")
//                handlePostAuth(user: authResult.user)
//            } catch let err as NSError where AuthErrorCode(rawValue: err.code) == .credentialAlreadyInUse {
//                // Already used, sign in normally
//                _ = try await signInWithEmail(email: email, password: password)
//            }
//        } else {
//            let result = try await Auth.auth().createUser(withEmail: email, password: password)
//            try await result.user.sendEmailVerification()
//            let changeReq = result.user.createProfileChangeRequest()
//            changeReq.displayName = fullName
//            try await changeReq.commitChanges()
//            log("Created new email user UID: \(result.user.uid)")
//            handlePostAuth(user: result.user)
//        }
//    }
//
//    // MARK: - Post Auth Handling
//    private func handlePostAuth(user: User) {
//        Task {
//            try await saveUserData(user: user, provider: user.providerData.first?.providerID ?? "email")
//            await loadUserData(user: user)
//            identifyUserWithRevenueCat(uid: user.uid)
//        }
//    }
//
//    // MARK: - Merge Anonymous Data
//    private func mergeAnonymousData(into realUid: String, from anonUid: String) async throws {
//        log("Starting data merge from anonymous user \(anonUid) to \(realUid)")
//        
//        // Set custom claims before merging
//        try await setMergeClaims(realUid: realUid, anonUid: anonUid)
//        
//        let db = Firestore.firestore()
//        let batch = db.batch()
//        
//        // 1. Copy all health data records
//        let healthDataRef = db.collection("users").document(anonUid).collection("health_data")
//        let snapshot = try await healthDataRef.getDocuments(source: .server) // Force server fetch
//        
//        log("Found \(snapshot.documents.count) health records to migrate")
//        
//        for document in snapshot.documents {
//            let targetRef = db.collection("users")
//                .document(realUid)
//                .collection("health_data")
//                .document(document.documentID)
//            
//            log("Migrating document: \(document.documentID)")
//            batch.setData(document.data(), forDocument: targetRef, merge: true)
//        }
//        
//        // 2. Commit changes
//        try await batch.commit()
//        log("Successfully migrated \(snapshot.documents.count) health records")
//        
//        // 3. Cleanup - delete anonymous data
//        try await deleteAnonymousData(anonUid: anonUid)
//        
//        // Clear custom claims
//        try await clearMergeClaims(realUid: realUid)
//    }
//
//    private func setMergeClaims(realUid: String, anonUid: String) async throws {
//        guard let user = Auth.auth().currentUser else { return }
//        
//        // Use UserDefaults as a temporary workaround since we can't set custom claims client-side
//        UserDefaults.standard.set(anonUid, forKey: "anonSourceForMerge")
//        log("Set merge state in UserDefaults for \(realUid)")
//    }
//
//    private func clearMergeClaims(realUid: String) async throws {
//        UserDefaults.standard.removeObject(forKey: "anonSourceForMerge")
//        log("Cleared merge state from UserDefaults for \(realUid)")
//    }
//
//    private func deleteAnonymousData(anonUid: String) async throws {
//        let db = Firestore.firestore()
//        let healthDataRef = db.collection("users").document(anonUid).collection("health_data")
//        let snapshot = try await healthDataRef.getDocuments()
//        
//        let batch = db.batch()
//        for document in snapshot.documents {
//            batch.deleteDocument(document.reference)
//        }
//        batch.deleteDocument(db.collection("users").document(anonUid))
//        
//        try await batch.commit()
//        log("Deleted anonymous user data for \(anonUid)")
//    }
//
//
//    // MARK: - Firestore User Doc
//    func saveUserData(user: User, provider: String) async throws {
//        let ref = db.collection("users").document(user.uid)
//        let doc = try await ref.getDocument()
//        if !doc.exists {
//            var data: [String: Any] = ["uid": user.uid, "provider": provider]
//            if let name = user.displayName { data["name"] = name }
//            if let email = user.email { data["email"] = email }
//            try await ref.setData(data)
//        }
//    }
//
//    func loadUserData(user: User) async {
//        let ref = db.collection("users").document(user.uid)
//        if let data = try? await ref.getDocument().data(), let name = data["name"] as? String {
//            log("Loaded profile for \(name)")
//        }
//    }
//
//    // MARK: - RevenueCat
//    private func identifyUserWithRevenueCat(uid: String) {
//        Purchases.shared.logIn(uid) { _, _, error in
//            if let error = error {
//                self.log("RevenueCat identify failed: \(error.localizedDescription)")
//            } else {
//                self.log("RevenueCat identified as \(uid)")
//            }
//        }
//    }
//}



// 33333333333
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

        try await handleCredentialSignIn(credential: credential, provider: "google")
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

        try await handleCredentialSignIn(credential: credential, provider: "apple")
    }

    @MainActor
    private func handleCredentialSignIn(credential: AuthCredential, provider: String) async throws {
        let anonUID = Auth.auth().currentUser?.uid

        var anonData: [QueryDocumentSnapshot] = []
        if let anonUID = anonUID {
            let snapshot = try await db.collection("users").document(anonUID).collection("health_data").getDocuments()
            anonData = snapshot.documents
        }

        let user: User
        if let anonUser = Auth.auth().currentUser, anonUser.isAnonymous {
            do {
                let result = try await Auth.auth().signIn(with: credential)
                user = result.user
            } catch {
                throw error
            }
        } else {
            let result = try await Auth.auth().signIn(with: credential)
            user = result.user
        }

        if let anonUID = anonUID, anonUID != user.uid {
            for doc in anonData {
                let data = doc.data()
                try await db.collection("users").document(user.uid)
                    .collection("health_data").document(doc.documentID)
                    .setData(data)
            }
            try? await db.collection("users").document(anonUID).delete()
        }

        try await saveUserData(user: user, provider: provider)
        try await loadUserData(user: user)
        identifyUserWithRevenueCat(uid: user.uid)
        self.displayName = user.displayName ?? "User"
        self.isAnonymousUser = user.isAnonymous
        self.authState = .authenticated
    }
    
    @MainActor
    func signUpWithEmail(
        email: String,
        password: String,
        confirmPassword: String,
        fullName: String
    ) async throws {
        guard password == confirmPassword else {
            throw NSError(domain: "AuthController", code: 400, userInfo: [NSLocalizedDescriptionKey: "Passwords do not match"])
        }

        let credential = EmailAuthProvider.credential(withEmail: email, password: password)

        if let anonUser = Auth.auth().currentUser, anonUser.isAnonymous {
            
            // collecting anonymous user data
            let anonUID = Auth.auth().currentUser?.uid

            var anonData: [QueryDocumentSnapshot] = []
            if let anonUID = anonUID {
                let snapshot = try await db.collection("users").document(anonUID).collection("health_data").getDocuments()
                anonData = snapshot.documents
            }
            
            
            // linking new account
            let authResult = try await anonUser.link(with: credential)
            
            
            
            try await authResult.user.sendEmailVerification()

            let changeRequest = authResult.user.createProfileChangeRequest()
            changeRequest.displayName = fullName
            try await changeRequest.commitChanges()
            
            
            // transfering data to new account
            if let anonUID = anonUID, anonUID != authResult.user.uid {
                for doc in anonData {
                    let data = doc.data()
                    try await db.collection("users").document(authResult.user.uid)
                        .collection("health_data").document(doc.documentID)
                        .setData(data)
                }
                try? await db.collection("users").document(anonUID).delete()
            }
            

            try await saveUserData(user: authResult.user, provider: "email")
            try await loadUserData(user: authResult.user)
            identifyUserWithRevenueCat(uid: authResult.user.uid)
            
            
            self.displayName = authResult.user.displayName ?? "User"
            self.isAnonymousUser = authResult.user.isAnonymous
            self.authState = .authenticated
        } else {
            // fallback: create user normally
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

//    @MainActor
//    func signUpWithEmail(email: String, password: String, confirmPassword: String, fullName: String) async throws {
//        guard password == confirmPassword else {
//            throw NSError(domain: "AuthController", code: 400, userInfo: [NSLocalizedDescriptionKey: "Passwords do not match"])
//        }
//
//        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
//        try await handleCredentialSignIn(credential: credential, provider: "email")
//
//        if let user = Auth.auth().currentUser {
//            try await user.sendEmailVerification()
//            let changeRequest = user.createProfileChangeRequest()
//            changeRequest.displayName = fullName
//            try await changeRequest.commitChanges()
//        }
//    }

    @MainActor
        func signInWithEmail(email: String, password: String) async throws -> Bool {
            let anonUID = Auth.auth().currentUser?.uid

            var anonData: [QueryDocumentSnapshot] = []
            if let anonUID = anonUID {
                let snapshot = try await db.collection("users").document(anonUID).collection("health_data").getDocuments()
                anonData = snapshot.documents
            }

            let result = try await Auth.auth().signIn(withEmail: email, password: password)

            if let anonUID = anonUID, anonUID != result.user.uid {
                for doc in anonData {
                    let data = doc.data()
                    try await db.collection("users").document(result.user.uid)
                        .collection("health_data").document(doc.documentID)
                        .setData(data)
                }
                try? await db.collection("users").document(anonUID).delete()
            }

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
