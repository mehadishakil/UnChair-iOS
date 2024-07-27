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
                    .padding(5)
                
                ForEach(breakList) { index in
//                        ForEach(breaksByType[breakType] ?? []) { breakItem in
                    NavigationLink(destination: DetailsBreakView(breakItem: index)) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text(index.title)
                                            .font(.headline)
                                            .fontWeight(.bold)
                                        Text(index.description)
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                            .multilineTextAlignment(.leading)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                    Spacer()
                                    Text("\(index.duration) sec")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 4)
                            }
                        }
                    
                }
                .padding()
                .background(Color.white)
                .cornerRadius(15)
        }
}

    

#Preview {
    BreakSectionView()
}


//
//struct BreakInfo: Identifiable {
//    let id = UUID()
//    let title: String
//    let description: String
//    let duration: String
//    let destinationView: AnyView
//}
//
//let breaks = [
//    BreakInfo(title: "Quick Break", description: "2 min straight basic warm-up exercises", duration: "2 min", destinationView: AnyView(QuickBreakView())),
//    BreakInfo(title: "Short Break", description: "3 minutes exercise, 2 min indoor walk", duration: "5 min", destinationView: AnyView(ShortBreakView())),
//    BreakInfo(title: "Medium Break", description: "3 min exercise, 2 min indoor walk, 5 min rest", duration: "10 min", destinationView: AnyView(MediumBreakView())),
//    BreakInfo(title: "Long Break", description: "10 min exercise, 10 min outdoor walk, 10 min rest", duration: "30 min", destinationView: AnyView(LongBreakView()))
//]
