//
//  WorkHourSelectionView.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 31/5/25.
//

import SwiftUI

struct WorkHourSelectionView: View {
    @Binding var selectedStartHour: Int
    @Binding var selectedStartMinute: Int
    @Binding var selectedEndHour: Int
    @Binding var selectedEndMinute: Int
    
    @AppStorage("userTheme") private var userTheme: Theme = .system
    
    // State for the custom picker
    @State private var startTime: Date = {
        var components = DateComponents()
        components.hour = 9 // 9 AM
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }()
    
    @State private var endTime: Date = {
        var components = DateComponents()
        components.hour = 17 // 5 PM
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }()
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 16) {
                    VStack(spacing: 8) {
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
            .onAppear {
                // Load from binding values
                loadFromBindings()
            }
            .onChange(of: startTime) { newValue in
                updateBindingsFromStartTime(newValue)
            }
            .onChange(of: endTime) { newValue in
                updateBindingsFromEndTime(newValue)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // MARK: - Helper Methods
    
    private func loadFromBindings() {
        // Create start time from binding values
        var startComponents = DateComponents()
        startComponents.hour = selectedStartHour
        startComponents.minute = selectedStartMinute
        if let date = Calendar.current.date(from: startComponents) {
            startTime = date
        }
        
        // Create end time from binding values
        var endComponents = DateComponents()
        endComponents.hour = selectedEndHour
        endComponents.minute = selectedEndMinute
        if let date = Calendar.current.date(from: endComponents) {
            endTime = date
        }
    }
    
    private func updateBindingsFromStartTime(_ time: Date) {
        let calendar = Calendar.current
        selectedStartHour = calendar.component(.hour, from: time)
        selectedStartMinute = calendar.component(.minute, from: time)
    }
    
    private func updateBindingsFromEndTime(_ time: Date) {
        let calendar = Calendar.current
        selectedEndHour = calendar.component(.hour, from: time)
        selectedEndMinute = calendar.component(.minute, from: time)
    }
}

// MARK: - CircularTimePicker (Same as before, no changes needed)
struct CircularTimePicker: View {
    @Binding var startTime: Date
    @Binding var endTime: Date
    
    @State private var startAngle: Angle = .degrees(0)
    @State private var endAngle: Angle = .degrees(0)
    @State private var isDraggingStart: Bool = false
    @State private var isDraggingEnd: Bool = false
    
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
            
            // Duration Display
            Text("Duration: \(calculateDuration())")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            // Circular Timer
            ZStack {
                // Outer Dark Background Circle
                Circle()
                    .fill(.gray)
                    .frame(width: (radius + outerRingWidth) * 2, height: (radius + outerRingWidth) * 2)
                    .overlay(
                        Circle()
                            .stroke(Color.orange.opacity(0.4), lineWidth: 1)
                    )
                
                // Inner Circle Background
                Circle()
                    .fill(.background)
                    .frame(width: radius * 2, height: radius * 2)
                    .overlay(
                        Circle()
                            .stroke(Color.orange.opacity(0.4), lineWidth: 1)
                    )
                
                // MARK: - Major Tick Marks (Every Hour)
                ForEach(0..<24) { hour in
                    Rectangle()
                        .fill(Color.gray)
                        .frame(width: 1, height: 4)
                        .offset(y: -radius + 6)
                        .rotationEffect(.degrees(Double(hour) * 15))
                }
                
                // Time Hour Numbers
                ForEach(Array(stride(from: 0, to: 24, by: 2)), id: \.self) { hour in
                    let displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour)
                    let angle = Double(hour) * 15 - 90
                    
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
                    .stroke(Color.gray.opacity(0.3), lineWidth: outerRingWidth)
                    .frame(width: (radius + outerRingWidth/2) * 2, height: (radius + outerRingWidth/2) * 2)
                
                // Active Arc - showing selected time range
                Path { path in
                    let size = (radius + outerRingWidth) * 2
                    let center = CGPoint(x: size / 2, y: size / 2)
                    let arcRadius = radius + outerRingWidth/2
                    
                    // Convert our angles to the correct coordinate system
                    let startAngleRadians = (startAngle.degrees - 90) * .pi / 180
                    let endAngleRadians = (endAngle.degrees - 90) * .pi / 180
                    
                    path.addArc(
                        center: center,
                        radius: arcRadius,
                        startAngle: Angle(radians: startAngleRadians),
                        endAngle: Angle(radians: endAngleRadians),
                        clockwise: false
                    )
                }
                .stroke(
                    .white.opacity(0.5),
                    style: StrokeStyle(lineWidth: outerRingWidth * 0.6, lineCap: .round)
                )
                
                // Start Time Handle (Teal)
                Circle()
                    .fill(highLightColor)
                    .frame(width: handleRadius * 2, height: handleRadius * 2)
                    .overlay(
                        Circle()
                            .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                    )
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                    .offset(
                        x: (radius + outerRingWidth/2) * cos((startAngle - .degrees(90)).radians),
                        y: (radius + outerRingWidth/2) * sin((startAngle - .degrees(90)).radians)
                    )
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                isDraggingStart = true
                                let center = CGPoint(x: 0, y: 0)
                                let vector = CGVector(
                                    dx: gesture.location.x - center.x,
                                    dy: gesture.location.y - center.y
                                )
                                let angle = atan2(vector.dy, vector.dx)
                                let newAngle = Angle(radians: Double(angle)) + .degrees(90)
                                
                                // Smooth angle transition to avoid jumps
                                let smoothedAngle = smoothAngleTransition(
                                    from: startAngle,
                                    to: newAngle
                                )
                                
                                startAngle = smoothedAngle
                                updateTimeFromAngle(angle: startAngle, isStartTime: true)
                            }
                            .onEnded { _ in
                                isDraggingStart = false
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
                        x: (radius + outerRingWidth/2) * cos((endAngle - .degrees(90)).radians),
                        y: (radius + outerRingWidth/2) * sin((endAngle - .degrees(90)).radians)
                    )
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                isDraggingEnd = true
                                let center = CGPoint(x: 0, y: 0)
                                let vector = CGVector(
                                    dx: gesture.location.x - center.x,
                                    dy: gesture.location.y - center.y
                                )
                                let angle = atan2(vector.dy, vector.dx)
                                let newAngle = Angle(radians: Double(angle)) + .degrees(90)
                                
                                // Smooth angle transition to avoid jumps
                                let smoothedAngle = smoothAngleTransition(
                                    from: endAngle,
                                    to: newAngle
                                )
                                
                                endAngle = smoothedAngle
                                updateTimeFromAngle(angle: endAngle, isStartTime: false)
                            }
                            .onEnded { _ in
                                isDraggingEnd = false
                            }
                    )
            }
            .frame(width: (radius + outerRingWidth) * 2, height: (radius + outerRingWidth) * 2)
            .onAppear {
                startAngle = Self.angle(for: startTime)
                endAngle = Self.angle(for: endTime)
            }
            .onChange(of: startTime) { newValue in
                if !isDraggingStart {
                    startAngle = Self.angle(for: newValue)
                }
            }
            .onChange(of: endTime) { newValue in
                if !isDraggingEnd {
                    endAngle = Self.angle(for: newValue)
                }
            }
        }
        .padding()
    }
    
    // MARK: - Helper Functions
    
    static func angle(for date: Date) -> Angle {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let totalMinutes = Double(hour * 60 + minute)
        // Convert to degrees (0° = 12am at top)
        let angle = (totalMinutes / (24.0 * 60.0)) * 360.0
        return Angle.degrees(angle)
    }
    
    // Smooth angle transition to prevent jumps when crossing 0°/360° boundary
    private func smoothAngleTransition(from currentAngle: Angle, to newAngle: Angle) -> Angle {
        let current = currentAngle.degrees.truncatingRemainder(dividingBy: 360)
        let new = newAngle.degrees.truncatingRemainder(dividingBy: 360)
        
        let diff = new - current
        
        // If the difference is greater than 180°, we're crossing the boundary
        if diff > 180 {
            return Angle.degrees(current + (diff - 360))
        } else if diff < -180 {
            return Angle.degrees(current + (diff + 360))
        } else {
            return Angle.degrees(current + diff)
        }
    }
    
    private func updateTimeFromAngle(angle: Angle, isStartTime: Bool) {
        // Normalize angle to 0-360 range
        var normalizedAngle = angle.degrees.truncatingRemainder(dividingBy: 360)
        if normalizedAngle < 0 {
            normalizedAngle += 360
        }
        
        // Convert angle to time (24-hour format)
        let totalMinutes = (normalizedAngle / 360.0) * (24.0 * 60.0)
        let hour = Int(totalMinutes / 60.0) % 24
        let minute = Int(totalMinutes.truncatingRemainder(dividingBy: 60.0))
        
        // Round to nearest 15 minutes for better UX
        let roundedMinute = (minute / 15) * 15
        
        let calendar = Calendar.current
        var components = DateComponents()
        components.hour = hour
        components.minute = roundedMinute
        components.second = 0
        
        if let newDate = calendar.date(from: components) {
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
    
    private func calculateDuration() -> String {
        let calendar = Calendar.current
        
        // Handle case where end time is the next day
        let actualEndTime = endTime < startTime ?
            calendar.date(byAdding: .day, value: 1, to: endTime)! : endTime
        
        let components = calendar.dateComponents([.hour, .minute], from: startTime, to: actualEndTime)
        let hours = components.hour ?? 0
        let minutes = components.minute ?? 0
        
        if minutes == 0 {
            return "\(hours) hours"
        } else {
            return "\(hours)h \(minutes)m"
        }
    }
}

#Preview {
    WorkHourSelectionView(
        selectedStartHour: .constant(9),
        selectedStartMinute: .constant(0),
        selectedEndHour: .constant(17),
        selectedEndMinute: .constant(0)
    )
}
