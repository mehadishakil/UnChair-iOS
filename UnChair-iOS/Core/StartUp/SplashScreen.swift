//
//  SplashScreen.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 2/9/24.
//

import SwiftUI

struct SplashScreen: View {
    
    var body: some View {
        ZStack{
            Color.black
                .ignoresSafeArea(.all)
            
            Spacer()
            
            Image("UnChair")
                .resizable()
                .renderingMode(.template)
                .foregroundColor(.white)
                .aspectRatio(contentMode: .fit)
                .frame(width: 100)
                
            Spacer()
        }
    }
}

#Preview {
    SplashScreen()
}
