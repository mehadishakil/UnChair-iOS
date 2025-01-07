//
//  Authentication.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 1/9/24.
//

import SwiftUI



struct Authentication: View {
    
    @EnvironmentObject var authController: AuthController
    
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
                
                // Continue with Apple Button
                Button(
                    action: {
                        // add action here
                    },
                    label: {
                        HStack{
                            Image("apple_logo")
                                .resizable()
                                .frame(width:20, height: 20)
                                .padding(.horizontal, 6)
                            
                            Text("Continue with Apple")
                                .bold()
                                .foregroundColor(Color.black)
                        }
                        .frame(maxWidth: .infinity, minHeight: 60)
                        .background(Color.gray3) /// make the background gray
                        .cornerRadius(10) /// make the background rounded
                        .overlay( /// apply a rounded border
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray6, lineWidth: 1)
                        )
                    })
                
                Spacer()
                    .frame(height: 15)
                
                // Continue with Google Button
                Button(
                    action: {
                        signIn()
                    },
                    label: {
                        HStack{
                            Image("google_icon")
                                .resizable()
                                .frame(width:20, height: 20)
                                .padding(.horizontal, 6)
                            
                            Text("Continue with Google")
                                .bold()
                                .foregroundColor(Color.black)
                            
                            
                        }
                        .frame(maxWidth: .infinity, minHeight: 60)
                        .background(Color.gray3) /// make the background gray
                        .cornerRadius(10) /// make the background rounded
                        .overlay( /// apply a rounded border
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray6, lineWidth: 1)
                        )
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
    Authentication()
}
