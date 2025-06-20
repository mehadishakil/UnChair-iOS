
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
import Lottie

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
    @State private var showResetAlert : Bool = false
    @State private var resetEmailAddress : String = ""
    @Environment(\.dismiss) private var dismiss
    @Binding var showAuthSheet: Bool


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
                        showResetAlert = true
                     }) {
                        Text("Forgot Password?")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                }
            }

            Spacer()

            Button(action: {
                SignIn()
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
            .opacity(isLoading ? 0.2 : 1)
            .overlay {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
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
                                await MainActor.run { showAuthSheet = false }
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
                .shadow(color: (userTheme == .light || (userTheme == .system && colorScheme == .light)) ? .black : .white, radius: 1)
                .id("\(userTheme)-\(colorScheme)")

                Button(action: {
                    isLoading = true
                    Task {
                        do {
                            try await authController.signInWithGoogle()
                            logStatus = true
                            await MainActor.run { showAuthSheet = false }
                        } catch {
                            showError(error.localizedDescription)
                        }
                        isLoading = false
                    }
                }) {
                    HStack {
                        Image("google_icon")
                            .resizable()
                            .frame(width: 16, height: 16)

                        Text("Sign in with Google")
                            .font(.title3.weight(.medium))
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background((userTheme == .light || (userTheme == .system && colorScheme == .light))
                                ? .white
                                : .black)
                    .clipShape(Capsule())
                    .shadow(color: (userTheme == .light || (userTheme == .system && colorScheme == .light)) ? .black : .white, radius: 1)
                }

                HStack {
                    Text("Don't have an account?")
                        .foregroundColor(.secondary)
                    NavigationLink(destination: SignupView(showAuthSheet: $showAuthSheet).environment(authController)) {
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
        .alert(alertMessage, isPresented: $showAlert) { }
        .sheet(isPresented: $showEmailVerificationView) {
            EmailVerificationView()
                .presentationDetents([.height(350)])
                .presentationCornerRadius(24)
                .interactiveDismissDisabled()
        }
        .alert("Reset Password", isPresented: $showResetAlert, actions: {
            TextField("Email Address", text: $resetEmailAddress)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
            
            Button("Send Reset Link", role: .destructive, action: sendResetLink)
            
            Button("Cancel", role: .cancel){
                resetEmailAddress = ""
            }
        }, message: {
            Text("Enter the email address")
        })

    }

    func SignIn() {
        isLoading = true
        Task {
            do {
                let isVerified = try await authController.signInWithEmail(email: email, password: password)
                if isVerified {
                    logStatus = true
                    await MainActor.run { showAuthSheet = false }
                } else {
                    showEmailVerificationView = true
                }
            } catch {
                await presentAlert(error.localizedDescription)
            }
            isLoading = false
        }
    }
    
    func sendResetLink(){
        Task {
            do {
                if resetEmailAddress.isEmpty {
                    await presentAlert("Please enter an email address")
                    return
                }
                
                isLoading = true
                try await Auth.auth().sendPasswordReset(withEmail: resetEmailAddress)
                await presentAlert("Please check your email inbox and follow the steps to reset your password!")
                
                resetEmailAddress = ""
                isLoading = false
            } catch {
                await presentAlert(error.localizedDescription)
            }
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
            resetEmailAddress = ""
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
        }
        .padding(.bottom, 25)
        .onReceive(Timer.publish(every: 2, on: .main, in: .default).autoconnect()) { _ in
            if let user = Auth.auth().currentUser { //
                user.reload()
                if user.isEmailVerified {
                    showEmailVerificationView = false
                    logStatus = true
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
    SigninView(showAuthSheet: .constant(true))
        .environmentObject(AuthController()) // Provide a dummy AuthController for preview
}
