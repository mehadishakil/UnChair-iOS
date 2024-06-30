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
                
                ForEach(breaks) { breakInfo in
                    NavigationLink(destination: breakInfo.destinationView) {
                        HStack {
                            VStack(alignment: .leading, spacing: 5) {
                                Text(breakInfo.title)
                                    .font(.headline)
                                    .fontWeight(.bold)
                                Text(breakInfo.description)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Text(breakInfo.duration)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(15)
        }
    }

    struct BreakInfo: Identifiable {
        let id = UUID()
        let title: String
        let description: String
        let duration: String
        let destinationView: AnyView // Destination view for NavigationLink
    }

    let breaks = [
        BreakInfo(title: "Quick Break", description: "2 min straight basic warm-up exercises", duration: "2 min", destinationView: AnyView(QuickBreakView())),
        BreakInfo(title: "Short Break", description: "3 minutes exercise, 2 min indoor walk", duration: "5 min", destinationView: AnyView(ShortBreakView())),
        BreakInfo(title: "Medium Break", description: "3 min exercise, 2 min indoor walk, 5 min rest", duration: "10 min", destinationView: AnyView(MediumBreakView())),
        BreakInfo(title: "Long Break", description: "10 min exercise, 10 min outdoor walk, 10 min rest", duration: "30 min", destinationView: AnyView(LongBreakView()))
    ]

    struct QuickBreakView: View {
        var body: some View {
            VStack {
                Text("Quick Break")
                    .font(.largeTitle)
                    .padding()
                Text("2 min straight basic warm-up exercises")
                    .padding()
                Spacer()
            }
            .navigationTitle("Quick Break")
        }
    }

    struct ShortBreakView: View {
        var body: some View {
            VStack {
                Text("Short Break")
                    .font(.largeTitle)
                    .padding()
                Text("3 minutes exercise, 2 min indoor walk")
                    .padding()
                Spacer()
            }
            .navigationTitle("Short Break")
        }
    }

    struct MediumBreakView: View {
        var body: some View {
            VStack {
                Text("Medium Break")
                    .font(.largeTitle)
                    .padding()
                Text("3 min exercise, 2 min indoor walk, 5 min rest")
                    .padding()
                Spacer()
            }
            .navigationTitle("Medium Break")
        }
    }

    struct LongBreakView: View {
        var body: some View {
            VStack {
                Text("Long Break")
                    .font(.largeTitle)
                    .padding()
                Text("10 min exercise, 10 min outdoor walk, 10 min rest")
                    .padding()
                Spacer()
            }
            .navigationTitle("Long Break")
        }
    }

#Preview {
    BreakSectionView()
}
