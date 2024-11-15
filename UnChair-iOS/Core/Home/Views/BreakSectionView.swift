//
//  BreakSectionView.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 30/6/24.
//

import SwiftUI

struct BreakSectionView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            
            Text("Take a Break")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            ForEach(breakList) { index in
                NavigationLink(destination: DetailsBreakView(breakItem: index)) {
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(index.title)
                                .font(.headline)
                                .fontWeight(.bold)
                            Text(index.overview)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer()
                        Text("\(index.duration/60) min")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(10)
                    .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 4)                    
                }
            }
            
        }
        .padding()
        .cornerRadius(15)
    }
}



#Preview {
    BreakSectionView()
}
