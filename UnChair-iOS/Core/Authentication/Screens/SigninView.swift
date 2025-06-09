////
////  SigninView.swift
////  UnChair-iOS
////
////  Created by Mehadi Hasan on 3/6/25.
////
//
//import SwiftUI
//import FirebaseAuth
//import AuthenticationServices
//import CryptoKit
//
//struct SigninView: View {
//    @State private var email: String = ""
//    @State private var alertMessage : String = ""
//    @State private var showAlert : Bool = false
//    @State private var isLoading : Bool = false
//    @State private var showEmailVerificationView : Bool = false
//    @AppStorage("userTheme") private var userTheme: Theme = .system
//    @Environment(\.colorScheme) private var colorScheme
//    @EnvironmentObject var authController: AuthController
//    @State private var errorMessage: String = ""
//    @State private var nonce: String?
//    @AppStorage("log_status") private var logStatus: Bool = false
//    @State private var showSignInView: Bool = false
//    
//    var buttonStatus : Bool {
//        return email.isEmpty || isLoading
//    }
//    
//    var body: some View {
//        VStack {
//            VStack(spacing: 8) {
//                Image(
//                    (userTheme == .light || (userTheme == .system && colorScheme == .light))
//                    ? "UnChair_black"
//                    : "UnChair_white"
//                )
//                .resizable()
//                .aspectRatio(contentMode: .fit)
//                .frame(width: 40)
//                
//                
//                Text("Sign in")
//                    .font(.title.weight(.semibold))
//                
//                Text("Welcome Back you've been missed")
//                    .font(.subheadline)
//                    .foregroundColor(.secondary)
//            }
//            .padding(.top, 40)
//            
//            Spacer().frame(height: 40)
//            
//            VStack(spacing: 20) {
//                TextField("Email", text: $authController.email)
//                    .frame(height: 52)
//                    .padding(.leading, 12)
//                    .keyboardType(.emailAddress)
//                    .autocapitalization(.none)
//                    .customTextField("envelope.fill")
//                    .cornerRadius(16)
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 16)
//                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
//                    )
//            }
//            
//            Spacer()
//            
//            Button(action: {
//                signInWithEmailLink()
//            }) {
//                Text("Sign In")
//                    .font(.title3.weight(.semibold))
//                    .foregroundColor(Color.whiteblack)
//                    .frame(maxWidth: .infinity, minHeight: 52)
//                    .background(Color.BW)
//                    .cornerRadius(30)
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 30)
//                            .stroke(Color.gray6, lineWidth: 1)
//                    )
//            }
//            .showLoadingIndicator(isLoading)
//            .disabled(buttonStatus || isLoading)
//            .padding(.vertical)
//            .overlay {
//                if isLoading {
//                    ProgressView()
//                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
//                }
//            }
//            
//            HStack {
//                RoundedRectangle(cornerRadius: 2)
//                    .fill(.secondary)
//                    .frame(height: 1)
//                
//                Text("OR")
//                    .foregroundColor(.secondary)
//                    .font(.caption)
//                
//                RoundedRectangle(cornerRadius: 2)
//                    .fill(.secondary)
//                    .frame(height: 1)
//            }
//            
//            
//            VStack(spacing: 16) {
//                SignInWithAppleButton { request in
//                    let nonce = randomNonceString()
//                    self.nonce = nonce
//                    request.requestedScopes = [.email, .fullName]
//                    request.nonce = sha256(nonce)
//                } onCompletion: { result in
//                    isLoading = true
//                    switch result {
//                    case .success(let authorization):
//                        Task {
//                            do {
//                                try await authController.signInWithApple(authorization: authorization, nonce: nonce)
//                                logStatus = true
//                            } catch {
//                                showError(error.localizedDescription)
//                            }
//                            isLoading = false
//                        }
//                    case .failure(let error):
//                        showError(error.localizedDescription)
//                        isLoading = false
//                    }
//                }
//                .signInWithAppleButtonStyle((userTheme == .light || (userTheme == .system && colorScheme == .light)) ? .white : .black)
//                .frame(height: 52)
//                .clipShape(.capsule)
//                .shadow(color: (userTheme == .light || (userTheme == .system && colorScheme == .light)) ? .black : .white, radius: 1)
//                .id("\(userTheme)-\(colorScheme)")
//                
//                Button(action: {
//                    isLoading = true
//                    Task {
//                        do {
//                            try await authController.signInWithGoogle()
//                            logStatus = true
//                        } catch {
//                            showError(error.localizedDescription)
//                        }
//                        isLoading = false
//                    }
//                }) {
//                    HStack {
//                        Image("google_icon")
//                            .resizable()
//                            .frame(width: 16, height: 16)
//                        
//                        Text("Sign in with Google")
//                            .font(.title3.weight(.medium))
//                            .foregroundColor(.primary)
//                    }
//                    .frame(maxWidth: .infinity)
//                    .frame(height: 52)
//                    .background((userTheme == .light || (userTheme == .system && colorScheme == .light))
//                                ? .white
//                                : .black)
//                    .clipShape(Capsule())
//                    .shadow(color: (userTheme == .light || (userTheme == .system && colorScheme == .light)) ? .black : .white, radius: 1)
//                }
//                
//                HStack {
//                    Text("Don't have an account?")
//                        .foregroundColor(.secondary)
//                    NavigationLink(destination: SignupView()) {
//                        Text("Create account")
//                            .fontWeight(.semibold)
//                            .foregroundColor(.blue)
//                    }
//                }
//                .font(.subheadline)
//            }
//            .padding(.vertical)
//            
//            Spacer()
//        }
//        .padding()
//        .navigationBarBackButtonHidden(true)
//        .alert(alertMessage, isPresented: $showAlert) {
//            Button("OK", role: .cancel) { }
//        }
//        .onAppear {
//            // Listen for email link notifications
//            NotificationCenter.default.addObserver(
//                forName: .emailLinkReceived,
//                object: nil,
//                queue: .main
//            ) { notification in
//                if let emailLink = notification.object as? String {
//                    handleEmailLink(emailLink)
//                }
//            }
//        }
//        .onDisappear {
//            NotificationCenter.default.removeObserver(self, name: .emailLinkReceived, object: nil)
//        }
//    }
//    
//    private func signInWithEmailLink() {
//        Task {
//          await authController.sendSignInLink()
//        }
//      }
//    
//    func EmailSignIn() {
//        // Validate email format
//        guard isValidEmail(email) else {
//            showError("Please enter a valid email address")
//            return
//        }
//        
//        isLoading = true
//        
//        let actionCodeSettings = ActionCodeSettings()
//        
//        // FIXED: Use a proper deep link URL that matches your app's URL scheme
//        // Replace "unchair" with your actual app's URL scheme from Info.plist
//        actionCodeSettings.url = URL(string: "https://unchair.page.link/email-signin")
//        
//        // FIXED: This should be true for email link sign-in
//        actionCodeSettings.handleCodeInApp = true
//        
//        // FIXED: Use the correct bundle identifier
//        if let bundleID = Bundle.main.bundleIdentifier {
//            actionCodeSettings.setIOSBundleID(bundleID)
//        }
//        
//        // Optional: Android package name (remove if not needed)
//        // actionCodeSettings.setAndroidPackageName("com.yourcompany.unchair", installIfNotAvailable: false, minimumVersion: "12")
//        
//        Auth.auth().sendSignInLink(toEmail: email, actionCodeSettings: actionCodeSettings) { error in
//            DispatchQueue.main.async {
//                self.isLoading = false
//                
//                if let error = error {
//                    print("Email link send error: \(error.localizedDescription)")
//                    self.showError("Failed to send email: \(error.localizedDescription)")
//                    return
//                }
//                
//                // Success: Save email and show success message
//                UserDefaults.standard.set(self.email, forKey: "Email")
//                self.showError("Check your email for the sign-in link!")
//                print("Email link sent successfully to: \(self.email ?? "")")
//            }
//        }
//    }
//    
//    private func handleEmailLink(_ emailLink: String) {
//        guard let savedEmail = UserDefaults.standard.string(forKey: "Email") else {
//            showError("No email found. Please try signing in again.")
//            return
//        }
//        
//        // Verify that the link is valid
//        guard Auth.auth().isSignIn(withEmailLink: emailLink) else {
//            showError("Invalid email link")
//            return
//        }
//        
//        isLoading = true
//        
//        Auth.auth().signIn(withEmail: savedEmail, link: emailLink) { result, error in
//            DispatchQueue.main.async {
//                self.isLoading = false
//                
//                if let error = error {
//                    print("Email link sign-in error: \(error.localizedDescription)")
//                    self.showError("Sign-in failed: \(error.localizedDescription)")
//                    return
//                }
//                
//                guard let user = result?.user else {
//                    self.showError("Sign-in failed: No user returned")
//                    return
//                }
//                
//                print("Email link sign-in successful for user: \(user.uid)")
//                
//                // Save user data and update auth state
//                Task {
//                    do {
//                        try await self.authController.saveUserData(user: user, provider: "email")
//                        try await self.authController.loadUserData(user: user)
//                        
//                        // Clear saved email
//                        UserDefaults.standard.removeObject(forKey: "Email")
//                        
//                        // Update login status
//                        await MainActor.run {
//                            self.logStatus = true
//                        }
//                    } catch {
//                        print("Error saving user data: \(error.localizedDescription)")
//                    }
//                }
//            }
//        }
//    }
//    
//    private func isValidEmail(_ email: String) -> Bool {
//        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
//        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
//        return emailPred.evaluate(with: email)
//    }
//    
//    func showError(_ message: String) {
//        alertMessage = message
//        showAlert = true
//        isLoading = false
//    }
//    
//    func presentAlert(_ message : String) async {
//        await MainActor.run {
//            alertMessage = message
//            showAlert = true
//            isLoading = false
//        }
//    }
//    
//    
//    private func randomNonceString(length: Int = 32) -> String {
//        precondition(length > 0)
//        var randomBytes = [UInt8](repeating: 0, count: length)
//        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
//        if errorCode != errSecSuccess {
//            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
//        }
//        
//        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
//        let nonce = randomBytes.map { byte in
//            charset[Int(byte) % charset.count]
//        }
//        return String(nonce)
//    }
//    
//    private func sha256(_ input: String) -> String {
//        let inputData = Data(input.utf8)
//        let hashedData = SHA256.hash(data: inputData)
//        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
//    }
//}
//
//fileprivate extension View {
//    
//    @ViewBuilder
//    func showLoadingIndicator(_ status: Bool) -> some View {
//        self
//            .animation(.snappy) { content in
//                content.opacity(status ? 0 : 1)
//            }
//            .overlay {
//                if status {
//                    ZStack {
//                        Capsule()
//                            .fill(.bar)
//                        
//                        ProgressView()
//                    }
//                }
//            }
//    }
//    
//    @ViewBuilder
//    func customTextField(_ icon : String? = nil, _ paddingTop : CGFloat = 0, _ paddingBottom : CGFloat = 0) -> some View {
//        HStack {
//            if let icon = icon {
//                Image(systemName: icon)
//                    .font(.title3)
//                    .foregroundColor(.gray)
//                    .frame(width: 20)
//            }
//            self
//        }
//        .padding(.horizontal, 16)
//        .background(.bar, in: .rect(cornerRadius: 10))
//        .padding(.top, paddingTop)
//        .padding(.bottom, paddingBottom)
//        .listRowInsets(.init(top: 10, leading: 0, bottom: 0, trailing: 0))
//        .listRowSeparator(.hidden)
//    }
//}
//
//#Preview {
//    SigninView()
//        .environmentObject(AuthController())
//}



//
//  SigninView.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 3/6/25.
//

import SwiftUI
import FirebaseAuth
import AuthenticationServices
import CryptoKit

struct SigninView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var alertMessage : String = ""
    @State private var showAlert : Bool = false
    @State private var isLoading : Bool = false
    @State private var showEmailVerificationView : Bool = false
    @AppStorage("userTheme") private var userTheme: Theme = .system
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var authController: AuthController
    @State private var errorMessage: String = ""
    @State private var nonce: String?
    @AppStorage("log_status") private var logStatus: Bool = false
    @State private var showSignInView: Bool = false

    var buttonStatus : Bool {
        return email.isEmpty || password.isEmpty || isLoading
    }

    var body: some View {
        VStack {
            VStack(spacing: 8) {
                Image(
                    (userTheme == .light || (userTheme == .system && colorScheme == .light))
                    ? "UnChair_black"
                    : "UnChair_white"
                )
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40)


                Text("Sign in")
                    .font(.title.weight(.semibold))

                Text("Welcome Back you've been missed")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 40)

            Spacer().frame(height: 40)

            VStack(spacing: 20) {
                // Use the string-based initializer here:
                TextField("Email", text: $email)
                    .frame(height: 52)
                    .padding(.leading, 12)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .customTextField("envelope.fill")
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                    )

                // Likewise for SecureField:
                SecureField("Password", text: $password)
                    .frame(height: 52)
                    .padding(.leading, 12)
                    .customTextField("lock.fill")
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                    )

                HStack {
                    Spacer()
                    Button(action: {
                        // Navigate to ForgotPasswordView or handle reset logic
                        print("Forgot password tapped")
                    }) {
                        Text("Forgot Password?")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                }
            }

            Spacer()

            Button(action: {
                SignIn() // Call the SignIn function
            }) {
                Text("Sign In")
                    .font(.title3.weight(.semibold))
                    .foregroundColor(Color.whiteblack)
                    .frame(maxWidth: .infinity, minHeight: 52)
                    .background(Color.BW)
                    .cornerRadius(30)
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(Color.gray6, lineWidth: 1)
                    )
            }
            .disabled(buttonStatus)
            .padding(.vertical)
            .overlay {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white)) // Make the progress view white
                }
            }

            HStack {
                RoundedRectangle(cornerRadius: 2)
                    .fill(.secondary)
                    .frame(height: 1)

                Text("OR")
                    .foregroundColor(.secondary)
                    .font(.caption)

                RoundedRectangle(cornerRadius: 2)
                    .fill(.secondary)
                    .frame(height: 1)
            }


            VStack(spacing: 16) {
                SignInWithAppleButton { request in
                    let nonce = randomNonceString()
                    self.nonce = nonce
                    request.requestedScopes = [.email, .fullName]
                    request.nonce = sha256(nonce)
                } onCompletion: { result in
                    isLoading = true
                    switch result {
                    case .success(let authorization):
                        Task {
                            do {
                                try await authController.signInWithApple(authorization: authorization, nonce: nonce)
                                logStatus = true
                            } catch {
                                showError(error.localizedDescription)
                            }
                            isLoading = false
                        }
                    case .failure(let error):
                        showError(error.localizedDescription)
                        isLoading = false
                    }
                }
                .signInWithAppleButtonStyle((userTheme == .light || (userTheme == .system && colorScheme == .light)) ? .white : .black)
                .frame(height: 52)
                .clipShape(.capsule)
                // Adjust shadow based on your desired outlier effect
                .shadow(color: (userTheme == .light || (userTheme == .system && colorScheme == .light)) ? .black : .white, radius: 1)
                .id("\(userTheme)-\(colorScheme)")

                Button(action: {
                    isLoading = true
                    Task {
                        do {
                            try await authController.signInWithGoogle()
                            logStatus = true
                        } catch {
                            showError(error.localizedDescription)
                        }
                        isLoading = false
                    }
                }) {
                    HStack {
                        Image("google_icon") // Ensure this image is correctly imported into your asset catalog
                            .resizable()
                            .frame(width: 16, height: 16) // Slightly larger icon for better visibility

                        Text("Sign in with Google")
                            .font(.title3.weight(.medium))
                            .foregroundColor(.primary) // Adjust text color based on theme
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 52) // Consistent height with Apple button
                    .background((userTheme == .light || (userTheme == .system && colorScheme == .light))
                                ? .white
                                : .black) // White background for both themes
                    .clipShape(Capsule()) // Capsule shape
                    .shadow(color: (userTheme == .light || (userTheme == .system && colorScheme == .light)) ? .black : .white, radius: 1)
                }

                HStack {
                    Text("Don't have an account?")
                        .foregroundColor(.secondary)
                    NavigationLink(destination: SignupView()) {
                        Text("Create account")
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }
                }
                .font(.subheadline)
            }
            .padding(.vertical)



            Spacer()
        }
        .padding()
        .navigationBarBackButtonHidden(true)
        .alert(alertMessage, isPresented: $showAlert) { } // Alert for errors
    }

    func SignIn() {
        isLoading = true // Start loading
        Task { //
            do {
                let result = try await Auth.auth().signIn(withEmail: email, password: password) //

                if result.user.isEmailVerified { //
                    // User is verified, AuthController will handle state change to authenticated
                    // No need to explicitly navigate here, MainView observes authController.authState
                    print("User signed in and email is verified.")
                } else {
                    // Send verification email and present verification view
                    try await result.user.sendEmailVerification() //
                    // You'll need to define EmailVerificationView in SigninView if you want to show it here.
                    // For now, let's just print a message.
                    print("User signed in but email not verified. Verification email sent.")
                    await presentAlert("Please verify your email address to continue.")
                }
            } catch let error as NSError { // Catch specific Firebase errors
                await presentAlert(error.localizedDescription) //
            } catch {
                await presentAlert("An unexpected error occurred.") // Catch any other errors
            }
            isLoading = false // Stop loading
        }
    }

    func showError(_ message: String) {
        errorMessage = message
        showAlert.toggle()
        isLoading = false
    }

    func presentAlert(_ message : String) async {
        await MainActor.run {
            alertMessage = message
            showAlert = true
            isLoading = false
        }
    }

    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }

        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        let nonce = randomBytes.map { byte in
            charset[Int(byte) % charset.count]
        }
        return String(nonce)
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
    }
}

fileprivate extension View {
    @ViewBuilder
    func customTextField(_ icon : String? = nil, _ paddingTop : CGFloat = 0, _ paddingBottom : CGFloat = 0) -> some View {
        HStack {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.gray)
                    .frame(width: 20)
            }
            self
        }
        .padding(.horizontal, 16)
        .background(.bar, in: .rect(cornerRadius: 10))
        .padding(.top, paddingTop)
        .padding(.bottom, paddingBottom)
        .listRowInsets(.init(top: 10, leading: 0, bottom: 0, trailing: 0))
        .listRowSeparator(.hidden)
    }
}

#Preview {
    SigninView()
        .environmentObject(AuthController()) // Provide a dummy AuthController for preview
}
