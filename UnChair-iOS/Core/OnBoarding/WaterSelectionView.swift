//
//  WaterSelectionView.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 31/5/25.
//

import SwiftUI

struct WaterSelectionView: View {
    @State private var selectedSteps: Int = 10000
    @State private var showNextScreen: Bool = false
    @State private var value: CGFloat = 10
    @AppStorage("userTheme") private var userTheme: Theme = .system
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 16) {
                    // Title
                    VStack(spacing : 8) {
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
                        // Subtitle
                        Text("Set how much water you want to\nconsume each day.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .padding(.bottom, 20)
                        
                    }
                    
                    
                    WaterPicker()
                    
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct WaterPicker: View {
    @State var water: Int = 3000
    private let waterRange: [Int] = Array(stride(from: 1000, through: 6000, by: 100))
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Milliliter")
                .font(.footnote)
                .foregroundColor(.secondary)
            
            Picker("", selection: $water) {
                ForEach(waterRange, id: \.self) { value in
                    Text("\(value)")
                        .font(.title)
                        .padding(.vertical, 10)
                        .tag(value)
                }
            }
            .pickerStyle(
                .wheel
            )
            .frame(width: 250)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }
}

#Preview {
    WaterSelectionView()
}
