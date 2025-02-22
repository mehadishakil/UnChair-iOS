//
//  Authentication.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 1/9/24.
//

import SwiftUI
import AuthenticationServices
import CryptoKit

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
            
            Image(systemName: "figure.walk")
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
            
            Spacer()
                .frame(height: 15)
            
            Button(
                action: {
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
                },
                label: {
                    HStack {
                        Image("google_icon")
                            .resizable()
                            .frame(width: 16, height: 16)
                        
                        Text("Continue with Google")
                            .foregroundColor(.BG)
                            .font(.title2)
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity, minHeight: 56)
                    .background(Color.BW)
                    .cornerRadius(10)
                    .shadow(radius: 1)
                })
            
            Text("By continuing, you agree to Basic's [Terms of Service](https://basics.com/terms-of-service) and [Privacy Policy](https://basics.com/privacypolicy) ")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .tint(.primary)
                .padding(.top, 20)
                .font(.caption)
                .frame(width: 250)
        }
        .padding()
        .alert(errorMessage, isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        }
        .overlay {
            if isLoading {
                LoadingScreen()
            }
        }
    }
    
    @ViewBuilder
    func LoadingScreen() -> some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
                .edgesIgnoringSafeArea(.all)
            
            ProgressView()
                .frame(width: 45, height: 45)
                .background(.background, in: RoundedRectangle(cornerRadius: 5))
        }
    }
    
    func showError(_ message: String) {
        errorMessage = message
        showAlert.toggle()
        isLoading = false
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

#Preview {
    Authentication()
}
