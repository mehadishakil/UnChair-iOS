//
//  WorkHourSelectionView.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 31/5/25.
//
import SwiftUI

struct WorkHourSelectionView: View {
    @State private var selectedSteps: Int = 10000
    @State private var showNextScreen: Bool = false
    @State private var value: CGFloat = 10
    @AppStorage("userTheme") private var userTheme: Theme = .system // Assuming 'Theme' enum is defined elsewhere
    
    // State for the custom picker
    @State private var startTime: Date = {
        var components = DateComponents()
        components.hour = 22 // 10 PM
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }()
    
    @State private var endTime: Date = {
        var components = DateComponents()
        components.hour = 8 // 8 AM
        components.minute = 30
        return Calendar.current.date(from: components) ?? Date()
    }()
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 16) {
                    VStack(spacing : 8) {
                        HStack(spacing: 0) {
                            Text("Your ")
                                .font(.title2)
                                .foregroundColor(.primary)
                            Text("Work Hour ")
                                .font(.title2.bold())
                                .foregroundColor(Color(red: 0.2, green: 0.8, blue: 0.6))
                            Text("schedule?")
                                .font(.title2)
                                .foregroundColor(.primary)
                        }
                        
                        
                        // Subtitle
                        Text("We will remind you to take breaks\nonly during this period.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .padding(.bottom, 20)
                        
                    }
                    // MARK: - Hour Schedule picker
                    CircularTimePicker(startTime: $startTime, endTime: $endTime)
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

// MARK: - CircularTimePicker
struct CircularTimePicker: View {
    @Binding var startTime: Date
    @Binding var endTime: Date
    
    @State private var startAngle: Angle = .degrees(0)
    @State private var endAngle: Angle = .degrees(0)
    
    private let radius: CGFloat = 100
    private let handleRadius: CGFloat = 8
    private let lineWidth: CGFloat = 8
    private let outerRingWidth: CGFloat = 30
    private let highLightColor: Color = Color(red: 0.2, green: 0.8, blue: 0.6)
    @AppStorage("userTheme") private var userTheme: Theme = .system

    var body: some View {
        VStack(spacing: 12) {
            // Time Display at Top
            HStack(spacing: 12) {
                Text(formattedTime(startTime))
                    .font(.headline)
                    .foregroundColor(highLightColor)
                
                Text("to")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(formattedTime(endTime))
                    .font(.headline)
                    .foregroundColor(.orange.opacity(0.9))
            }
            
            // Circular Timer
            ZStack {
                // Outer Dark Background Circle - Changed to purple
                Circle()
                    .fill(.gray) // Changed from black.opacity(0.8)
                    .frame(width: (radius + outerRingWidth) * 2, height: (radius + outerRingWidth) * 2)
                    .overlay(
                        Circle()
                            .stroke(Color.orange.opacity(0.4), lineWidth: 1)
                    )
                
                // Inner Circle Background - Changed to a darker purple
                Circle()
                    .fill(.background) // Changed from black.opacity(0.6)
                    .frame(width: radius * 2, height: radius * 2)
                    .overlay(
                        Circle()
                            .stroke(Color.orange.opacity(0.4), lineWidth: 1)
                    )
                
                // MARK: - Major Tick Marks (Every Hour)
                ForEach(0..<24) { hour in
                    Rectangle()
                        .fill(Color.gray)
                        .frame(width: 1, height: 4) // Length of major tick
                        .offset(y: -radius + 6) // Position outside inner circle
                        .rotationEffect(.degrees(Double(hour) * 15)) // 360 degrees / 24 hours = 15 degrees per hour
                }
                
                // Time Hour Numbers
                ForEach(Array(stride(from: 0, to: 24, by: 2)), id: \.self) { hour in
                    let displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour)
                    let angle = Double(hour) * 15 - 90 // Start from top (12am)
                    
                    if displayHour != 12 && displayHour != 6{
                        Text("\(displayHour)")
                            .font(.footnote.weight(.medium))
                            .foregroundColor(.primary.opacity(0.8))
                            .offset(
                                x: (radius - 25) * cos(Angle.degrees(angle).radians),
                                y: (radius - 25) * sin(Angle.degrees(angle).radians)
                            )
                    }
                    
                }
                
                // Special Time Labels (12am, 6am, 12pm, 6pm)
                Group {
                    // 12am (top)
                    VStack(spacing: 4) {
                        Image(systemName: "moon")
                            .font(.system(size: 14))
                            .foregroundColor(.yellow.opacity(0.8))
                            .padding(.top, 36)
                        Text("12am")
                            .font(.footnote.weight(.medium))
                            .foregroundColor(.primary.opacity(0.9))
                    }
                    .offset(y: -(radius - 15))
                    
                    // 6am (right)
                    HStack(spacing: 4) {
                        Text("6am")
                            .font(.footnote.weight(.medium))
                            .foregroundColor(.primary.opacity(0.9))
                        Image(systemName: "sunrise")
                            .font(.system(size: 14))
                            .foregroundColor(.orange.opacity(0.7))
                            .padding(.trailing, 36)
                    }
                    .offset(x: radius - 15)
                    
                    // 12pm (bottom)
                    VStack(spacing: 4) {
                        Text("12pm")
                            .font(.footnote.weight(.medium))
                            .foregroundColor(.primary.opacity(0.9))
                        Image(systemName: "sun.max")
                            .font(.system(size: 14))
                            .foregroundColor(.yellow.opacity(0.8))
                            .padding(.bottom, 36)
                    }
                    .offset(y: radius - 15)
                    
                    // 6pm (left)
                    HStack(spacing: 4) {
                        Image(systemName: "sunset")
                            .font(.system(size: 14))
                            .foregroundColor(.orange.opacity(0.7))
                            .padding(.leading, 36)
                        Text("6pm")
                            .font(.footnote.weight(.medium))
                            .foregroundColor(.primary.opacity(0.9))
                    }
                    .offset(x: -(radius - 15))
                }
                
                // Outer Ring Progress Track
                Circle()
                    .stroke(Color.darkGray.opacity(0.3), lineWidth: outerRingWidth)
                    .frame(width: (radius + outerRingWidth/2) * 2, height: (radius + outerRingWidth/2) * 2)
                
                // Active Arc - showing selected time range
                Path { path in
                    let size = (radius + outerRingWidth) * 2
                    let center = CGPoint(x: size / 2, y: size / 2)
                    let arcRadius = radius + outerRingWidth/2
                    
                    path.addArc(
                        center: center,
                        radius: arcRadius,
                        startAngle: startAngle,
                        endAngle: endAngle,
                        clockwise: false
                    )
                }
                .stroke(
                    Color.white.opacity(0.45),
                    style: StrokeStyle(lineWidth: outerRingWidth * 0.8, lineCap: .round)
                )
                
                // Start Time Handle (Gray)
                Circle()
                    .fill(highLightColor)
                    .frame(width: handleRadius * 2, height: handleRadius * 2)
                    .overlay(
                        Circle()
                            .stroke(Color.gray.opacity(0.3), lineWidth: 2) // Changed to .gray from .darkGray
                    )
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                    .offset(
                        x: (radius + outerRingWidth/2) * cos(startAngle.radians),
                        y: (radius + outerRingWidth/2) * sin(startAngle.radians)
                    )
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                let center = CGPoint(x: 0, y: 0)
                                let vector = CGVector(dx: gesture.location.x - center.x, dy: gesture.location.y - center.y)
                                let angle = atan2(vector.dy, vector.dx) + .pi / 2
                                let normalizedAngle = angle < 0 ? angle + 2 * .pi : angle
                                self.startAngle = Angle(radians: normalizedAngle)
                                updateTimeFromAngle(angle: startAngle, isStartTime: true)
                            }
                    )
                
                // End Time Handle (Orange)
                Circle()
                    .fill(Color.orange.opacity(0.9))
                    .frame(width: handleRadius * 2, height: handleRadius * 2)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 2)
                    )
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                    .offset(
                        x: (radius + outerRingWidth/2) * cos(endAngle.radians),
                        y: (radius + outerRingWidth/2) * sin(endAngle.radians)
                    )
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                let center = CGPoint(x: 0, y: 0)
                                let vector = CGVector(dx: gesture.location.x - center.x, dy: gesture.location.y - center.y)
                                let angle = atan2(vector.dy, vector.dx) + .pi / 2
                                let normalizedAngle = angle < 0 ? angle + 2 * .pi : angle
                                self.endAngle = Angle(radians: normalizedAngle)
                                updateTimeFromAngle(angle: endAngle, isStartTime: false)
                            }
                    )
            }
            .frame(width: (radius + outerRingWidth) * 2, height: (radius + outerRingWidth) * 2)
            .onAppear {
                startAngle = Self.angle(for: startTime)
                endAngle = Self.angle(for: endTime)
            }
            .onChange(of: startTime) { newValue in
                startAngle = Self.angle(for: newValue)
            }
            .onChange(of: endTime) { newValue in
                endAngle = Self.angle(for: newValue)
            }
        }
        .padding()
        
        //.fill(userTheme == .light ? Color(.systemBackground) : Color(.secondarySystemBackground))
    }
    
    // MARK: - Helper Functions
    
    static func angle(for date: Date) -> Angle {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let totalMinutes = Double(hour * 60 + minute)
        let angle = (totalMinutes / (24.0 * 60.0)) * 360.0
        return Angle.degrees(angle)
    }
    
    private func updateTimeFromAngle(angle: Angle, isStartTime: Bool) {
        let normalizedAngle = angle.degrees.truncatingRemainder(dividingBy: 360)
        let positiveAngle = normalizedAngle < 0 ? normalizedAngle + 360 : normalizedAngle
        
        let totalMinutes = (positiveAngle / 360.0) * (24.0 * 60.0)
        let hour = Int(totalMinutes / 60.0) % 24
        let minute = Int(totalMinutes.truncatingRemainder(dividingBy: 60.0))
        
        let calendar = Calendar.current
        let baseDate = isStartTime ? startTime : endTime
        
        if let newDate = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: baseDate) {
            if isStartTime {
                startTime = newDate
            } else {
                endTime = newDate
            }
        }
    }
    
    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        return formatter.string(from: date)
    }
}





#Preview {
    WorkHourSelectionView()
}
