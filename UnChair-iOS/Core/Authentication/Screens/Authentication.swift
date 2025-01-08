//
//  Authentication.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 1/9/24.
//

import SwiftUI
import AuthenticationServices
import CryptoKit
import FirebaseAuth



struct Authentication: View {
    
    @EnvironmentObject var authController: AuthController
    @State private var errorMessage: String = ""
    @State private var showAlert: Bool = false
    @State private var isLoading: Bool = false
    @State private var nonce: String?
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("log_status") private var logStatus: Bool = false
    var body: some View {
        VStack {
            Spacer()
            
            // Your Logo
            Image(systemName: "figure.walk")/// replace with your logo
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 40)
                .foregroundColor(.primary)
            
            Text("UnChair")
                .font(.title)
                .bold()
                .foregroundColor(.primary)
            
            
            
            Spacer()
            
            
            SignInWithAppleButton { request in
                let nonce = randomNonceString()
                self.nonce = nonce
                request.requestedScopes = [.email, .fullName]
                request.nonce = sha256(nonce)
            } onCompletion: { result in
                switch result {
                case .success(let authorization):
                    appleSignIn(authorization)
                case .failure(let error):
                    showError(error.localizedDescription)
                }
            }
            .overlay {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                    
                    HStack {
                        Image(systemName: "applelogo")
                            .foregroundColor(Color.BG)
                        
                        Text("Continue with Apple")
                            .foregroundColor(Color.BG)
                            .font(.title2)
                            .fontWeight(.medium)
                    }
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                    
                }
                .allowsHitTesting(false)
            }
            .frame(maxWidth: .infinity, maxHeight: 56)
            .cornerRadius(10)
            .shadow(radius: 1)
            
            
            
            // Continue with Apple Button
            //                Button(
            //                    action: {
            //                        // add action here
            //                    },
            //                    label: {
            //                        HStack{
            //                            Image("apple_logo")
            //                                .resizable()
            //                                .frame(width:20, height: 20)
            //                                .padding(.horizontal, 6)
            //
            //                            Text("Continue with Apple")
            //                                .bold()
            //                                .foregroundColor(Color.black)
            //                        }
            //                        .frame(maxWidth: .infinity, minHeight: 60)
            //                        .background(Color.gray3) /// make the background gray
            //                        .cornerRadius(10) /// make the background rounded
            //                        .overlay( /// apply a rounded border
            //                            RoundedRectangle(cornerRadius: 10)
            //                                .stroke(Color.gray6, lineWidth: 1)
            //                        )
            //                    })
            
            Spacer()
                .frame(height: 15)
            
            // Continue with Google Button
            Button(
                action: {
                    googleSignIn()
                },
                label: {
                    HStack{
                        Image("google_icon")
                            .resizable()
                            .frame(width: 16, height: 16)
                        
                        
                        Text("Continue with Google")
                            .foregroundColor(.BG)
                            .font(.title2)
                            .fontWeight(.medium)
                        
                        
                    }
                    .frame(maxWidth: .infinity, minHeight: 56)
                    .background(Color.BW) /// make the background gray
                    .cornerRadius(10) /// make the background rounded
                    .shadow(radius: 1)
                    
                })
            
            // Legal Disclaimer
            Text("By continuing, you agree to Basic's [Terms of Service](https://basics.com/terms-of-service) and [Privacy Policy](https://basics.com/privacypolicy) ")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .tint(.primary)
                .padding(.top, 20)
                .font(.caption)
                .frame(width: 250)
        }
        .padding()
        .alert(errorMessage, isPresented: $showAlert) { }
        .overlay {
            if isLoading {
                LoadingScreen()
            }
        }
        
    }
    @ViewBuilder
    func LoadingScreen() -> some View {
        ZStack{
            Rectangle()
                .fill(.ultraThinMaterial)
            
            ProgressView()
                .frame(width: 45, height: 45)
                .background(.background, in: .rect(cornerRadius: 5))
        }
    }
    
    func showError(_ message: String) {
        errorMessage = message
        showAlert.toggle()
        isLoading = false
    }
    
    func appleSignIn(_ authorization: ASAuthorization){
//        Task {
//            do {
//                // try await authController.signInWithApple()
//            } catch {
//                print(error.localizedDescription)
//            }
//        }
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            // showing loading screen until login completes with firebase
            isLoading = true
            
              guard let nonce else {
                // fatalError("Invalid state: A login callback was received, but no login request was sent.")
                  showError("Cannot process your request.")
                  return
              }
              guard let appleIDToken = appleIDCredential.identityToken else {
                // print("Unable to fetch identity token")
                  showError("Cannot process your request.")
                  return
              }
              guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                // print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                  showError("Cannot process your request.")
                  return
              }
              // Initialize a Firebase credential, including the user's full name.
              let credential = OAuthProvider.appleCredential(withIDToken: idTokenString,
                                                                rawNonce: nonce,
                                                                fullName: appleIDCredential.fullName)
              // Sign in with Firebase.
              Auth.auth().signIn(with: credential) { (authResult, error) in
                  if let error {
                  // Error. If error.code == .MissingOrInvalidNonce, make sure
                  // you're sending the SHA256-hashed nonce as a hex string with
                  // your request to Apple.
                     showError(error.localizedDescription)
                }
                // User is signed in to Firebase with Apple.
                  
                // Pushing user to home-screen
                  logStatus = true
                  isLoading = false
              }
            }
    }
    
    
    @MainActor
    func googleSignIn(){
        Task {
            do {
                try await authController.signInWithGoogle()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func appleSignIn(){
        Task {
            do {
                try await authController.signInWithGoogle()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError(
                "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
        }
        
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        
        let nonce = randomBytes.map { byte in
            // Pick a random character from the set, wrapping around if needed.
            charset[Int(byte) % charset.count]
        }
        
        return String(nonce)
    }
    

    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        String(format: "%02x", $0)
      }.joined()

      return hashString
    }

    
    
        
    
    
}

#Preview {
    Authentication()
}
