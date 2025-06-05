//
//  ForgotPasswordView.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 5/6/25.
//


import SwiftUI

struct ForgotPasswordView: View {
    @AppStorage("userTheme") private var userTheme: Theme = .system
    @Environment(\.colorScheme) private var colorScheme
    @State private var email: String = "" // Pre-fill as in the image
    
    var body: some View {
        NavigationView { // Added for navigation stack and back button
            VStack(spacing: 20) {
                HStack {
                    Button(action: {
                        // action to move back
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.gray.opacity(0.7))
                            .padding()
                            .background(Color.gray.opacity(0.15))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top)
                
                Spacer()
                
                Image(systemName: "lock.shield") // Using a SF Symbol for a lock
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.primary)
                    .padding()
                
                
                VStack(spacing: 12){
                    // Forgot Password? Text
                    Text("Forgot Password?")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                                        
                    Text("Don't worry! Please enter address associated we'll send you reset instructions.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                TextField("Email", text: $email)
                    .padding()
                    .background(.bar, in: .rect(cornerRadius: 16))
                    .foregroundColor(.primary)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                
                Button(action: {
                    print("Send button tapped for email: \(email)")
                }) {
                    Text("Send")
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
                .padding(.horizontal)
                .padding(.top, 30)
                Spacer()
            }
            .edgesIgnoringSafeArea(.all)
            .navigationBarHidden(true)
        }
    }
}

fileprivate extension View {
    @ViewBuilder
    func customTextField(_ icon : String? = nil, _ paddingTop : CGFloat = 0, _ paddingBottom : CGFloat = 0) -> some View {
        HStack {
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

// MARK: - Preview Provider
struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordView()
    }
}
