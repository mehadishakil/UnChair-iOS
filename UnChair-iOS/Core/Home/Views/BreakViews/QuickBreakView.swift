//
//  QuickBreakViews.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 27/7/24.
//

import SwiftUI

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
    QuickBreakView()
}
