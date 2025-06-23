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
    @Environment(\.dismiss) private var dismiss
    @Binding var showAuthSheet: Bool

    
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
                
                    Text("By signing up you agree to our [Privacy policy](https://un-chair-landing-page.vercel.app/privacy-policy) & [Terms of Use](https://www.apple.com/legal/internet-services/itunes/dev/stdeula/)")
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
            .opacity(isLoading ? 0.2 : 1)
            .overlay {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
            }
            
            HStack {
                Text("Already have an account?")
                    .foregroundColor(.secondary)
                NavigationLink(destination: SigninView(showAuthSheet: $showAuthSheet)) {
                    Text("Sign in")
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
            }
            .font(.subheadline)
            
        }
        .padding()
        .alert(alertMessage, isPresented: $showAlert) { } // Alert for errors
        .sheet(isPresented: $showEmailVerificationView) {
            EmailVerificationView()
                .presentationDetents([.height(350)])
                .presentationCornerRadius(24)
                .interactiveDismissDisabled()
        }
    }
    
    func SignUp() {
        isLoading = true
        Task {
            do {
                try await authController.signUpWithEmail(
                    email: email,
                    password: password,
                    confirm: confirmPassword,
                    fullName: full_name
                )
                showEmailVerificationView = true
            } catch {
                await presentAlert(error.localizedDescription)
            }
            isLoading = false
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
                if let bundle = Bundle.main.path(forResource: "EmailAnimation", ofType: "json"){
                    LottieView {
                        await LottieAnimation.loadedFrom(url: URL(filePath: bundle))
                    }
                    .playing(loopMode: .loop )
                }   
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
                
                if let user = Auth.auth().currentUser {
                    user.delete { _ in
                        showError("Canceled")
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            
        }
        .padding(.bottom, 25)
        .onReceive(Timer.publish(every: 2, on: .main, in: .default).autoconnect()) { _ in
            if let user = Auth.auth().currentUser { //
                user.reload { error in
                  if user.isEmailVerified {
                    // now really verified!
                    showEmailVerificationView = false
                    authController.authState = .authenticated
                    showAuthSheet = false
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
    SignupView(showAuthSheet: .constant(true))
        .environmentObject(AuthController())
}


