//
//  ContactUsView.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 30/7/24.
//

import SwiftUI

struct ContactUsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack {
                Text("Contact Us")
                    .font(.headline)
            }
            .padding(.bottom)
            
            // Description
            Text("You can get in touch with us through below platforms. Our Team will reach out to you as soon as it would be possible")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.bottom)
            
            // Customer Support Section
            VStack(alignment: .leading, spacing: 15) {
                Text("Customer Support")
                    .font(.headline)
                
                HStack {
                    Image(systemName: "phone")
                    Text("Mobile")
                    Spacer()
                    Text("+880 1796581711")
                        .foregroundColor(.blue)
                        .font(.subheadline)
                }
                
                HStack {
                    Image(systemName: "envelope")
                    Text("Email")
                    Spacer()
                    Text("mehadihasan469@gmail.com")
                        .foregroundColor(.blue)
                        .font(.subheadline)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            
            // Social Media Section
            VStack(alignment: .leading, spacing: 15) {
                Text("Social Media")
                    .font(.headline)
                
                HStack {
                    Image("instagram") // You'll need to add this image to your assets
                        .resizable()
                        .frame(width: 20, height: 20)
                    Text("Instagram")
                    Spacer()
                    Text("@mehadi__shakil")
                        .foregroundColor(.blue)
                        .font(.subheadline)
                }
                
                HStack {
                    Image("x") // You'll need to add this image to your assets
                        .resizable()
                        .frame(width: 20, height: 20)
                    Text("Twitter")
                    Spacer()
                    Text("@mehadi__shakil")
                        .foregroundColor(.blue)
                        .font(.subheadline)
                }
                
                HStack {
                    Image("facebook") // You'll need to add this image to your assets
                        .resizable()
                        .frame(width: 20, height: 20)
                    Text("Facebook")
                    Spacer()
                    Text("@mehadishakil469")
                        .foregroundColor(.blue)
                        .font(.subheadline)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    ContactUsView()
}
