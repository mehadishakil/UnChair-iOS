//
//  CalmCorner.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 11/8/24.
//

import SwiftUI

struct CalmCorner: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Calm Corner")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(5)
            
            NavigationLink(destination: Meditation()) {
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Meditate")
                            .font(.headline)
                            .fontWeight(.bold)
                        Text("Center your mind with calming meditation sessions")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding()
                .background(Color.white)
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
