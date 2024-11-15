//
//  CalmCorner.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 11/8/24.
//

import SwiftUI

struct CalmCorner: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Calm Corner")
                .font(.title2)
                .fontWeight(.semibold)
            
            
            NavigationLink(destination: Meditation()){
                VStack(alignment: .leading, spacing: 5) {
                    Text("Meditate")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text("Balance your thoughts and bring peace to your soul with a gentle meditation session.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .minimumScaleFactor(0.9)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(10)
                .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 4)
            }
        }
        .padding()
    }
}

#Preview {
    CalmCorner()
}

