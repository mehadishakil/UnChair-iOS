//
//  DailySleepView.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 7/7/24.
//

import SwiftUI

struct DailySleepView: View {
    var sleep: Float

    var body: some View {
        CardView {
            VStack(spacing: 16) {
                CircleImage(imageName: "moon.stars.fill") // Use your asset if different
                    .frame(width: 40, height: 40)
                VStack(spacing: 4) {
                    Text("Sleep")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                    HStack(alignment: .bottom, spacing: 8) {
                        Text(String(format: "%.1f", sleep))
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.black)
                        Text("Hours")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.black)
                            .padding(.bottom, 2)
                    }
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
            .cornerRadius(12)
            .padding(12)
        }
    }
}

struct CardView<Content: View>: View {
    var content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 4)
            .padding()
    }
}

struct CircleImage: View {
    var imageName: String

    var body: some View {
        Image(systemName: imageName) // Use "moon.stars.fill" for system image or your asset
            .resizable()
            .scaledToFit()
            .padding(8)
            .clipShape(Circle())
    }
}

struct DailySleepView_Previews: PreviewProvider {
    static var previews: some View {
        DailySleepView(sleep: 2.3)
    }
}

#Preview {
    DailySleepView(sleep: 6.5)
}
