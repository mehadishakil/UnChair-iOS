//
//  on_boarding.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 31/5/25.
//


import SwiftUI

struct StepsSelectionView: View {
    @State private var selectedSteps: Int = 10000
    @State private var showNextScreen: Bool = false
    @State private var config: WheelPicker.Config = .init(count: 30, steps: 5, spacing: 15, multiplier: 1000)
    @State private var value: CGFloat = 10
    @AppStorage("userTheme") private var userTheme: Theme = .system

    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 16) {
                    
                    VStack (spacing: 8){
                        // Title
                        HStack(spacing: 0) {
                            Text("Your daily ")
                                .font(.title2)
                            Text("steps ")
                                .font(.title2.bold())
                                .foregroundColor(Color(red: 0.2, green: 0.8, blue: 0.6))
                            Text("target?")
                                .font(.title2)
                        }

                        // Subtitle
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
    StepsSelectionView()
}


//import SwiftUI
//
//// MARK: - StepsSelectionView
//
//struct StepsSelectionView: View {
//    // State to hold the selected number of steps
//    @State private var selectedSteps: Int = 1000 // Default value for steps
//    @State private var showNextScreen: Bool = false // For navigation
//
//    // Configuration for the WheelPicker, adjusted for steps
//    @State private var wheelPickerConfig: WheelPicker.Config = .init(count: 30, steps: 10, spacing: 6, multiplier: 500, showText: true)
//
//    var body: some View {
//        NavigationView {
//            ZStack {
//                Color(red: 0.98, green: 0.98, blue: 0.99)
//                    .ignoresSafeArea()
//
//                VStack(spacing: 30) {
//                    // MARK: - Top Navigation Bar
//                    HStack {
//                        Button(action: {
//                            print("Back button tapped")
//                            // Add navigation logic to go back
//                        }) {
//                            Image(systemName: "chevron.left")
//                                .font(.title2)
//                                .foregroundColor(.gray.opacity(0.7))
//                                .padding()
//                                .background(Color.gray.opacity(0.15))
//                                .clipShape(Circle())
//                        }
//                        Spacer()
//                        Button("Skip") {
//                            print("Skip button tapped")
//                            // Add navigation logic to skip onboarding
//                        }
//                        .font(.headline)
//                        .foregroundColor(.gray)
//                        .padding(.horizontal, 20)
//                        .padding(.vertical, 10)
//                        .background(Color.gray.opacity(0.15))
//                        .cornerRadius(20)
//                    }
//                    .padding(.horizontal)
//                    .padding(.top)
//
//                    // MARK: - Progress Indicator
//                    Text("5 / 8")
//                        .font(.caption)
//                        .foregroundColor(.gray)
//                        .padding(.top, 20)
//
//                    // MARK: - Title
//                    Text("Your daily ")
//                        .font(.title2) +
//                    Text("steps ")
//                        .foregroundColor(.blue)
//                        .font(.title2.bold()) +
//                    Text("target?")
//                        .font(.title2)
//
//                    // MARK: - Description
//                    Text("We will use this data to give you\na better experience tailored for you.") // Clarified the text
//                        .font(.subheadline)
//                        .foregroundColor(.gray)
//                        .multilineTextAlignment(.center)
//                        .padding(.horizontal, 40)
//                        .padding(.bottom, 20)
//
//                    // Removed the "step" unit button as it's a steps selection view
//                    // and the WheelPicker is now configured for steps directly.
//
//                    // MARK: - Wheel Picker Display
//                    VStack {
//                        Image(systemName: "arrowtriangle.down.fill")
//                            .font(.caption)
//                            .foregroundColor(Color(red: 0.2, green: 0.8, blue: 0.6))
//                            .padding(.bottom, -5)
//
//                        VStack(alignment: .center, spacing: 5) {
//                            Text("steps") // Unit for steps
//                                .font(.title2)
//                                .fontWeight(.semibold)
//                                .textScale(.secondary)
//                                .foregroundStyle(.gray)
//                            
//                            Text(verbatim: "\(selectedSteps)") // Display selected steps
//                                .font(.largeTitle.bold())
//                                .contentTransition(.numericText(value: CGFloat(selectedSteps)))
//                                .animation(.snappy, value: selectedSteps)
//                        }
//                        .padding(.bottom, 30)
//
//                        WheelPicker(config: wheelPickerConfig, value: $selectedSteps)
//                            .frame(height: 60)
//                    }
//
//                    Spacer()
//
//                    // MARK: - Next Button
//                    Button(action: {
//                        print("Selected steps: \(selectedSteps)")
//                        self.showNextScreen = true
//                        // Navigate to the next onboarding screen or main app
//                    }) {
//                        Image(systemName: "chevron.right")
//                            .font(.title)
//                            .foregroundColor(.white)
//                            .padding(25)
//                            .background(Color(red: 0.2, green: 0.25, blue: 0.3))
//                            .clipShape(Circle())
//                            .shadow(radius: 5)
//                    }
//                    .padding(.bottom, 40)
//                    .navigationDestination(isPresented: $showNextScreen) {
//                        // Replace NextOnboardingView with your actual next view
//                        Text("Next Onboarding Screen") // Placeholder for the next screen
//                            .navigationBarHidden(true)
//                    }
//                }
//            }
//            .navigationBarHidden(true)
//        }
//        // Removed .navigationViewStyle as it's deprecated and not needed with current NavigationView usage
//    }
//}
//
//// MARK: - WheelPicker
//
//struct WheelPicker: View {
//    var config: Config
//    @Binding var value: Int // Changed to Int to match steps
//
//    @State private var isLoaded: Bool = false
//
//    var body: some View {
//        GeometryReader { proxy in
//            let size = proxy.size
//            let horizontalPadding = size.width / 2
//
//            ScrollView(.horizontal) {
//                HStack(spacing: config.spacing) {
//                    let totalSteps = config.count * config.steps
//                    
//                    ForEach(0...totalSteps, id: \.self) { index in
//                        let remainder = index % config.steps
//                        let showMajorTick = remainder == 0
//
//                        Divider()
//                            .background(showMajorTick ? Color.primary : .gray)
//                            .frame(width: 0, height: showMajorTick ? 20 : 10, alignment: .center)
//                            .frame(maxHeight: 20, alignment: .bottom) // Ensures consistent height alignment
//                            .overlay(alignment: .bottom) {
//                                if showMajorTick && config.showText { // Changed showTaxt to showText
//                                    Text("\( (index / config.steps) * config.multiplier )")
//                                        .font(.caption)
//                                        .fontWeight(.semibold)
//                                        .textScale(.secondary)
//                                        .fixedSize()
//                                        .offset(y: 20)
//                                }
//                            }
//                    }
//                }
//                .frame(height: size.height)
//                .scrollTargetLayout()
//            }
//            .scrollIndicators(.hidden)
//            .scrollTargetBehavior(.viewAligned)
//            .scrollPosition(id: .init(get: {
//                // Calculate the ID based on the current value.
//                // The ID should correspond to the 'index' in the ForEach.
//                // (value / multiplier) gives us the 'major' tick count.
//                // Multiplying by 'steps' gives us the actual index in the ForEach.
//                let position: Int? = isLoaded ? (value / config.multiplier) * config.steps : nil
//                return position
//            }, set: { newValue in
//                // When scroll position changes, update the bound value.
//                // newValue is the 'index' from the ForEach.
//                // (newValue / steps) gives us the 'major' tick count.
//                // Multiplying by 'multiplier' gives us the actual value.
//                if let newValue {
//                    value = (newValue / config.steps) * config.multiplier
//                }
//            }))
//            .overlay(alignment: .center) {
//                Rectangle()
//                    .frame(width: 1, height: 40)
//                    .padding(.bottom, 20)
//                    .foregroundColor(Color(red: 0.2, green: 0.8, blue: 0.6)) // Emphasize the indicator
//            }
//            .safeAreaPadding(.horizontal, horizontalPadding)
//            .onAppear {
//                // Ensure initial scroll position is set when the view appears
//                if !isLoaded {
//                    isLoaded = true
//                }
//            }
//        }
//    }
//
//    struct Config: Equatable {
//        var count: Int          // Number of major segments
//        var steps: Int = 10     // Minor ticks per major segment
//        var spacing: CGFloat = 6 // Spacing between ticks
//        var multiplier: Int = 100 // Value represented by each major segment (e.g., 10 for 10, 500 for 500 steps)
//        var showText: Bool = true // Corrected from showTaxt
//    }
//}
//
//// MARK: - Custom Corner Radius Extension (simplified)
//
//extension View {
//    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
//        clipShape(RoundedCorner(radius: radius, corners: corners))
//    }
//}
//
//// MARK: - RoundedCorner Shape
//
//struct RoundedCorner: Shape {
//    var radius: CGFloat = .infinity
//    var corners: UIRectCorner = .allCorners
//
//    func path(in rect: CGRect) -> Path {
//        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
//        return Path(path.cgPath)
//    }
//}
//
//// MARK: - Preview
//
//#Preview {
//    StepsSelectionView()
//}




//                        WaterPicker(selection: $selectedHeight, unit: unit, minCM: minHeightCM, maxCM: maxHeightCM)
//                            .frame(height: 120)
//                            .padding(.bottom, 20)

//
//struct WaterPicker: View {
//    @Binding var selection: Int
//    let unit: String
//    let minCM: Int
//    let maxCM: Int
//
//    private var range: ClosedRange<Int> {
//        if unit == "cm" {
//            return minCM...maxCM
//        } else {
//            return 150...210
//        }
//    }
//
//    var body: some View {
//        GeometryReader { geometry in
//            ScrollView(.horizontal, showsIndicators: false) {
//                HStack(spacing: 20) {
//                    ForEach(Array(stride(from: range.lowerBound, to: range.upperBound + 1, by: 1)), id: \.self) { number in
//                        NumberView(number: number, isSelected: number == selection, unit: unit)
//                            .frame(width: geometry.size.width / 5)
//                            .onTapGesture {
//                                withAnimation {
//                                    selection = number
//                                }
//                            }
//                    }
//                }
//                .padding(.horizontal, geometry.size.width / 2 - (geometry.size.width / 5 / 2))
//            }
//        }
//    }
//}
//
//struct NumberView: View {
//    let number: Int
//    let isSelected: Bool
//    let unit: String
//
//    var body: some View {
//        Text("\(number)")
//            .font(isSelected ? .system(size: 50, weight: .bold) : .system(size: 30, weight: .medium))
//            .foregroundColor(isSelected ? Color(red: 0.2, green: 0.8, blue: 0.6) : .gray.opacity(0.7))
//            .padding(.vertical, isSelected ? 25 : 15)
//            .padding(.horizontal, 10)
//            .background(isSelected ? Color.white : Color.gray.opacity(0.1))
//            .cornerRadius(15)
//            .shadow(color: isSelected ? .gray.opacity(0.3) : .clear, radius: 5, x: 0, y: 5)
//            .scaleEffect(isSelected ? 1.0 : 0.8)
//    }
//}
//
//
