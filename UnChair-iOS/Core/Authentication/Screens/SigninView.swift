//
//  SigninView.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 3/6/25.
//


import SwiftUI

struct SigninView: View {
    @State private var email: String = ""
    @State private var password: String = ""

    var body: some View {
        VStack {
            VStack(spacing: 8) {
                Text("Sign In")
                    .font(.title.weight(.semibold))

                Text("Hi! Welcome back, you've been missed")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 40)

            Spacer().frame(height: 40)

            VStack(spacing: 20) {
                // Use the string-based initializer here:
                TextField("Email", text: $email)
                    .padding()
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray6, lineWidth: 1)
                    )
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)

                // Likewise for SecureField:
                SecureField("Password", text: $password)
                    .padding()
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray6, lineWidth: 1)
                    )

                HStack {
                    Spacer()
                    Button(action: {
                        // Navigate to ForgotPasswordView or handle reset logic
                    }) {
                        Text("Forgot Password?")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                }
            }

            Spacer()

            Button(action: {
                // Handle sign-in action
            }) {
                Text("Sign In")
                    .bold()
                    .foregroundColor(Color.whiteblack)
                    .frame(maxWidth: .infinity, minHeight: 60)
                    .background(Color.BW)
                    .cornerRadius(30)
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(Color.gray6, lineWidth: 1)
                    )
            }

            Spacer().frame(height: 15)

            HStack {
                Text("Don't have an account?")
                    .foregroundColor(.secondary)
                    .font(.subheadline)
                Button("Create account") {
                    // Navigate to SignUpView
                }
                .fontWeight(.semibold)
            }
            .font(.system(size: 15))
        }
        .padding()
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    SigninView()
}
