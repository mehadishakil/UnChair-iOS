//
//  ProfileSettings.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 29/5/24.
//

import SwiftUI

struct ProfileSettings: View {
    
    @State var name : String
    @State var userName : String
    
    var body: some View {
        VStack{
            VStack(alignment: .center){
                Image(.mehadiHasan)
                    .resizable()
                    .frame(width: 100, height: 100)
                    .aspectRatio(contentMode: .fit)
                    .clipShape(Circle())
                    .padding(1)
                Text("Change profile picture")
                    .font(.system(.headline))
            }
            

            
            TextField("Name", text: $name)
                .padding()
                .frame(height: 55)
                .background(Color.black.opacity(0.05))
                .cornerRadius(10)
                .padding()
            
            TextField("UserName", text: $userName)
                .padding()
                .frame(height: 55)
                .background(Color.black.opacity(0.05))
                .cornerRadius(10)
                .padding(.horizontal)
            
            
            
            Spacer()
            
        }
    }
}

#Preview {
    ProfileSettings(name : "Mehadi Hasan", userName: "@mehadishakil1212")
}
