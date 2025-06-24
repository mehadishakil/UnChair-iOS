//
//  on_boarding.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 31/5/25.
//


import SwiftUI
import HealthKit

struct StepsSelectionView: View {
    @Binding var selectedSteps: Int
    @State private var showNextScreen: Bool = false
    @State private var config: WheelPicker.Config = .init(count: 20, steps: 5, spacing: 15, multiplier: 1000)
    @State private var value: CGFloat = 10
    @AppStorage("userTheme") private var userTheme: Theme = .system
    @EnvironmentObject var healthViewModel: HealthDataViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 16) {
                    
                    VStack (spacing: 8){
                        HStack(spacing: 0) {
                            Text("Your daily ")
                                .font(.title2)
                            Text("steps ")
                                .font(.title2.bold())
                                .foregroundColor(Color(red: 0.2, green: 0.8, blue: 0.6))
                            Text("target?")
                                .font(.title2)
                        }
                        Text("We will use this data to give you\na better experience tailored for you")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .padding(.bottom, 20)
                    }
                    
                    // Steps display and picker
                    VStack {
                        Image(systemName: "arrowtriangle.down.fill")
                            .font(.caption)
                            .foregroundColor(Color(red: 0.2, green: 0.8, blue: 0.6))
                            .padding(.bottom, 5)
                        
                        VStack(alignment: .center, spacing: 5) {
                            let steps = Int(CGFloat(config.multiplier) * value)
                            Text("steps")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.gray)
                            
                            Text("\(steps)")
                                .font(.largeTitle.bold())
                                .contentTransition(.numericText(value: Double(steps)))
                                .animation(.snappy, value: value)
                                .onChange(of: value) { newValue in
                                    selectedSteps = Int(CGFloat(config.multiplier) * newValue)
                                }
                        }
                        .padding(.bottom, 30)
                        
                        WheelPicker(config: config, value: $value)
                            .frame(height: 60)
                    }
                    
                    Spacer()
                    
                    
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now()) {                    Task {
                do {
                    try await healthViewModel.healthService.requestHealthDataPermission()
                    healthViewModel.loadAllData()
                } catch {
                    print("Error requesting HealthKit authorization: \(error.localizedDescription)")
                }
            }
            }
        }
    }
}

struct WheelPicker: View {
    var config: Config
    @Binding var value: CGFloat
    @State private var isLoaded: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            let horizontalPadding = size.width / 2
            
            ScrollView(.horizontal) {
                HStack(spacing: config.spacing) {
                    let totalSteps = config.steps * config.count
                    
                    ForEach(0...totalSteps, id: \.self) { index in
                        let remainder = index % config.steps
                        
                        Divider()
                            .background(remainder == 0 ? Color.primary : Color.secondary)
                            .frame(width: 0, height: remainder == 0 ? 20 : 10, alignment: .center)
                            .frame(maxHeight: 20, alignment: .bottom)
                            .overlay(alignment: .bottom) {
                                if remainder == 0 && config.showText {
                                    Text("\((index / config.steps) * config.multiplier)")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.secondary)
                                        .fixedSize()
                                        .offset(y: 20)
                                }
                            }
                    }
                }
                .frame(height: size.height)
                .scrollTargetLayout()
            }
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: .init(get: {
                let position: Int? = isLoaded ? Int(value * CGFloat(config.steps)) : nil
                return position
            }, set: { newValue in
                if let newValue {
                    value = CGFloat(newValue) / CGFloat(config.steps)
                }
            }))
            .overlay(alignment: .center) {
                Rectangle()
                    .frame(width: 1, height: 48)
                    .foregroundColor(Color(red: 0.2, green: 0.8, blue: 0.6))
                    .padding(.bottom, 20)
            }
            .safeAreaPadding(.horizontal, horizontalPadding)
            .onAppear {
                if !isLoaded {
                    isLoaded = true
                }
            }
        }
    }
    
    struct Config: Equatable {
        var count: Int
        var steps: Int = 10
        var spacing: CGFloat = 6
        var multiplier: Int = 10
        var showText: Bool = true
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

#Preview {
    StepsSelectionView(selectedSteps: .constant(5000))
}
