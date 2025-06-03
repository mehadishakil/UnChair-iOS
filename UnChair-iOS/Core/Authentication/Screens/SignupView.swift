//
//  SignupView.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 3/6/25.
//


import SwiftUI

struct SignupView: View {
    @State private var full_name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var agreeToTerms: Bool = false

    var body: some View {
        VStack {
            VStack(spacing: 8) {
                Text("Create Account")
                    .font(.title.weight(.semibold))

                Text("Fill your information below to create an account")
                    .multilineTextAlignment(.center)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 40)

            Spacer().frame(height: 40)

            VStack(spacing: 20) {
                TextField("Full name", text: $full_name)
                    .padding()
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray6, lineWidth: 1)
                    )
                    .keyboardType(.alphabet)
                    .autocapitalization(.none)
                
                TextField("Email", text: $email)
                    .padding()
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray6, lineWidth: 1)
                    )
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)

                SecureField("Password", text: $password)
                    .padding()
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray6, lineWidth: 1)
                    )

                SecureField("Confirm Password", text: $confirmPassword)
                    .padding()
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray6, lineWidth: 1)
                    )

                Toggle(isOn: $agreeToTerms) {
                    Text("I agree to the [Terms and Conditions](https://your-terms-url.com)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .toggleStyle(CheckboxToggleStyle())

            }

            Spacer()

            Button(action: {
                // Handle sign-up logic
            }) {
                Text("Create Account")
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
            .disabled(!agreeToTerms) // Optional: disable button unless agreed

            Spacer().frame(height: 15)

            HStack {
                Text("Already have an account?")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Button("Sign In") {
                    // Navigate to SigninView
                }
                .fontWeight(.semibold)
            }
            .font(.system(size: 15))
        }
        .padding()
        .navigationBarBackButtonHidden(true)
    }
}

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: { configuration.isOn.toggle() }) {
            HStack {
                Image(systemName: configuration.isOn ? "checkmark.square" : "square")
                    .foregroundColor(configuration.isOn ? .primary : .secondary)
                configuration.label
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    SignupView()
}
