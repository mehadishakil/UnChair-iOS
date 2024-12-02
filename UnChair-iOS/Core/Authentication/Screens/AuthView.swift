//
//  AuthView.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 2/12/24.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift


struct AuthView: View {
    
    @Environment(AuthController.self) private var authController
    
    var body: some View {
        VStack{
            Spacer()
            
            GoogleSignInButton(scheme: .dark, style: .standard, state: .normal) {
                signIn()
            }
        }
        .padding()
    }
    
    @MainActor
    func signIn(){
        Task {
            do {
                try await authController.signIn()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}


#Preview {
    AuthView()
}
