//
//  SignupView.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 3/6/25.
//

import SwiftUI
import FirebaseAuth
import AuthenticationServices
import CryptoKit
import Lottie

struct SignupView: View {
    @State private var email: String = ""
    @State private var full_name: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var agreeToTerms: Bool = false
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
        return full_name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty || isLoading
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
                
                
                Text("Create Account")
                    .font(.title.weight(.semibold))
                
                Text("Just a few quick things to get started")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 40)
            
            Spacer().frame(height: 40)
            
            VStack(spacing: 20) {
                TextField("Full Name", text: $full_name)
                    .frame(height: 52)
                    .padding(.leading, 12)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .customTextField("person.fill")
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                    )
                
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
                
                SecureField("Confirm Password", text: $confirmPassword)
                    .frame(height: 52)
                    .padding(.leading, 12)
                    .customTextField("lock.fill")
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                    )
                
                    Text("By signing up you agree to our [Privacy policy](https://your-terms-url.com) & [Terms](https://your-terms-url.com)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        
            }
            
            Spacer()
            
            Button(action: {
                SignUp() // Call the SignIn function
            }) {
                Text("Create Account")
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
                Text("Already have an account?")
                    .foregroundColor(.secondary)
                NavigationLink(destination: SigninView().environment(authController)) {
                    Text("Sign in")
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
            }
            .font(.subheadline)
            
        }
        .padding()
        .navigationBarBackButtonHidden(true)
        .alert(alertMessage, isPresented: $showAlert) { } // Alert for errors
    }
    
    func SignUp(){
        isLoading = true // Start loading
        Task { //
            do {
                if password == confirmPassword { //
                    let result = try await Auth.auth().createUser(withEmail: email, password: password) //
                    
                    // Send email verification
                    try await result.user.sendEmailVerification() //
                    
                    // Save user data to Firestore
                    // Assuming your AuthController handles saving user data on successful creation/sign-in
                    // You might need to call authController.saveUserData(user: result.user, provider: "email") here
                    // if you want to explicitly save user data after email sign-up.
                    // For now, we'll assume AuthController's state listener handles this.
                    
                    await MainActor.run {
                        showEmailVerificationView = true // Show verification view
                        isLoading = false // Stop loading
                    }
                    
                } else {
                    await presentAlert("Passwords do not match.") //
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
    
    @ViewBuilder
    func EmailVerificationView() -> some View {
        VStack(spacing: 6) {
            GeometryReader { _ in
                LottieView(animation: .named("EmailAnimation"))
                    .playing(loopMode: .loop)
                
            }
            Text("Verification")
                .font(.title.bold())
            
            Text("We have sent a verification email to your email address.\nPlease verify to continue.")
                .multilineTextAlignment(.center)
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, 25)
        }
        .overlay(alignment: .topTrailing) {
            Button("Cancel") {
                showEmailVerificationView = false
                // Consider what should happen if the user cancels verification.
                // Maybe sign them out or allow them to retry later.
            }
        }
        .padding(.bottom, 25)
        .onReceive(Timer.publish(every: 2, on: .main, in: .default).autoconnect()) { _ in
            if let user = Auth.auth().currentUser { //
                user.reload { error in // Reload user to get latest verification status
                    if let error = error {
                        print("Error reloading user: \(error.localizedDescription)")
                    } else {
                        if user.isEmailVerified { //
                            showEmailVerificationView = false
                            // If user is verified, AuthController will handle state change to authenticated
                            // and MainView will navigate to ContentView.
                            print("Email verified, proceeding to main content.")
                        }
                    }
                }
            }
        }
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
    SignupView()
        .environmentObject(AuthController())
}
