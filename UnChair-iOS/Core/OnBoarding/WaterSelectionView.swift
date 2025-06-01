//
//  WaterSelectionView.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 31/5/25.
//

import SwiftUI

struct WaterSelectionView: View {
    @Binding var selectedWater: Int
    @AppStorage("userTheme") private var userTheme: Theme = .system
    private let waterRange: [Int] = Array(stride(from: 1000, through: 6000, by: 100))

    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 16) {
                    VStack(spacing: 8) {
                        HStack(spacing: 0) {
                            Text("Your daily ")
                                .font(.title2)
                                .foregroundColor(.primary)
                            Text("water ")
                                .font(.title2.bold())
                                .foregroundColor(Color(red: 0.2, green: 0.8, blue: 0.6))
                            Text("target?")
                                .font(.title2)
                                .foregroundColor(.primary)
                        }
                        
                        Text("Set how much water you want to\nconsume each day.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .padding(.bottom, 20)
                    }
                    
                    VStack(spacing: 0) {
                        Text("Milliliter")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        
                        Picker("", selection: $selectedWater) {
                            ForEach(waterRange, id: \.self) { value in
                                Text("\(value)")
                                    .font(.title)
                                    .padding(.vertical, 10)
                                    .tag(value)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 250)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    WaterSelectionView(selectedWater: .constant(2500))
}
