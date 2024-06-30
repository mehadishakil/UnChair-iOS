//
//  HeaderView.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 30/6/24.
//

import SwiftUI

struct HeaderView: View {
    var body: some View {
        HStack(spacing : 20) {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(.gray)
                .padding(.leading, 20)
            
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text("Welcome")
                        .fontWeight(.light)
                        .foregroundColor(.gray)
                    Image(systemName: "hand.wave.fill")
                        .foregroundColor(.yellow)
                }
                Text("Mehadi Hasan")
                    .font(.title3)
                    .fontWeight(.medium)
                
            }
            Spacer()
            
        
            Image(systemName: "crown.fill")
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundColor(.yellow)
                .padding(.trailing, 20)
        }
        .padding(.vertical, 20)
    
    }
}




#Preview {
    HeaderView()
}
