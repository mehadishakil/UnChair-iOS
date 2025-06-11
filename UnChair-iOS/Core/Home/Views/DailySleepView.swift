//
//  DailySleepView.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 7/7/24.
//

import SwiftUI

//struct DailySleepView: View {
//    @EnvironmentObject private var healthVM: HealthDataViewModel
//    @State private var showPicker = false
//    @AppStorage("userTheme") private var userTheme: Theme = .system
//    private var hours: Int { Int(healthVM.sleepHours) }
//    private var minutes: Int { Int((healthVM.sleepHours - Float(hours)) * 60) }
//    
//    var body: some View {
//        Button(action: { showPicker.toggle() }) {
//            ZStack {
//                // background & border
//                RoundedRectangle(cornerRadius: 20, style: .continuous)
////                    .fill(Color(.systemBackground))
//                    .fill(userTheme == .dark ? Color(.secondarySystemBackground) : Color(.systemBackground))
//                
//                
//                VStack(alignment: .leading) {
//                    Text("Sleep")
//                        .font(.subheadline.weight(.medium))
//                        .foregroundColor(.primary)
//                    
//                    Spacer()
//                    
//                    HStack{
//                        Text("\(hours)h \(String(format: "%02dm", minutes))")
//                            .font(.system(size: 36, weight: .bold))
//                            .foregroundColor(.primary)
//                        
//                        Spacer()
//                        
//                        Image("sleep")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(height: 88)
//                            .offset(y: -28)
//                    }
//                    
//                    Spacer()
//                    
//                    
//                    // custom progress bar
//                    GeometryReader { geo in
//                        let total = 12.0
//                        let percent = CGFloat(healthVM.sleepHours) / CGFloat(total)
//                        ZStack(alignment: .leading) {
//                            Capsule()
//                                .fill(Color.gray.opacity(0.2))
//                                .frame(height: 6)
//                            Capsule()
//                                .fill(Color.blue)
//                                .frame(width: geo.size.width * percent, height: 6)
//                        }
//                    }
//                    .frame(height: 6)
//                }
//                .padding(20)
//            }
//        }
//        .buttonStyle(PlainButtonStyle())
//        .frame(height: 170)
//        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
//        // .shadow(color: userTheme == .dark ? Color.gray.opacity(0.5) : Color.black.opacity(0.15), radius: 8)
//        .sheet(isPresented: $showPicker) {
//            SleepPickerView(initialSleep: healthVM.sleepHours) { newVal in
//                healthVM.updateSleepHours(newVal)
//            }
//            .presentationDetents([.medium])
//            .presentationDragIndicator(.hidden)
//        }
//    }
//}
//
//
//struct SleepPickerView: View {
//    @State private var hours: Int
//    @State private var minutes: Int
//    let onSave: (Float) -> Void
//    @Environment(\.dismiss) private var dismiss
//
//    init(initialSleep: Float, onSave: @escaping (Float) -> Void) {
//        // decompose initialSleep into whole hours + minutes
//        let totalMinutes = Int((initialSleep * 60).rounded())
//        self._hours = State(initialValue: totalMinutes / 60)
//        self._minutes = State(initialValue: totalMinutes % 60)
//        self.onSave = onSave
//    }
//
//    var body: some View {
//        VStack(spacing: 24) {
//            // custom handle
//            Capsule()
//                .frame(width: 40, height: 5)
//                .foregroundColor(.gray.opacity(0.3))
//                .padding(.top, 8)
//
//            Text("Today's Sleep")
//                .font(.title3.weight(.semibold))
//                .multilineTextAlignment(.center)
//                .padding(.horizontal)
//
//            // wheel pickers
//            HStack(spacing: 32) {
//                wheelPicker(selection: $hours, range: 0...12, label: "hr")
//                wheelPicker(selection: $minutes, range: 0...59, label: "min")
//            }
//
//            // live preview
//            Text("\(hours) hr \(minutes) min")
//                .font(.headline.weight(.bold))
//                .padding()
//                .background(Color.secondary.opacity(0.1))
//                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
//
//            Spacer()
//
//            // save button
//            Button {
//                let totalHours = Float(hours) + Float(minutes) / 60
//                onSave(totalHours)
//                dismiss()
//            } label: {
//                Text("Done")
//                    .font(.headline)
//                    .frame(maxWidth: .infinity)
//                    .padding()
//                    .background(Color.blue)
//                    .foregroundColor(.white)
//                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
//            }
//        }
//        .padding()
//    }
//
//    @ViewBuilder
//    private func wheelPicker(selection: Binding<Int>, range: ClosedRange<Int>, label: String) -> some View {
//        VStack(spacing: 8) {
//            Text(label)
//                .font(.caption)
//                .foregroundColor(.secondary)
//
//            Picker("", selection: selection) {
//                ForEach(range, id: \.self) { val in
//                    Text("\(val)").tag(val)
//                }
//            }
//            .pickerStyle(.wheel)
//            .frame(width: 80, height: 100)
//            .clipped()
//            .background(.ultraThinMaterial)
//            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
//        }
//    }
//}

struct DailySleepView: View {
    @EnvironmentObject private var healthVM: HealthDataViewModel
    @State private var showPicker = false
    @AppStorage("userTheme") private var userTheme: Theme = .system
    @AppStorage("sleepGoalMins") private var sleepGoalMins: Int = 8 * 60
    
    @Environment(\.colorScheme) private var colorScheme
    private var hours: Int { healthVM.sleepMinutes / 60 }
    private var minutes: Int { healthVM.sleepMinutes % 60 }
    
    var body: some View {
        Button(action: { showPicker.toggle() }) {
            ZStack {
                VStack(alignment: .leading) {
                    Text("Sleep")
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    HStack{
                        Text("\(hours)h \(String(format: "%02dm", minutes))")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Image("sleep")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 88)
                            .offset(y: -28)
                    }
                    
                    Spacer()
                    
                    // custom progress bar - convert minutes to hours for percentage calculation
                    GeometryReader { geo in
                        let percent = CGFloat(healthVM.sleepMinutes) / CGFloat(sleepGoalMins)
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 6)
                            Capsule()
                                .fill(Color.blue)
                                .frame(width: geo.size.width * percent, height: 6)
                        }
                    }
                    .frame(height: 6)
                }
                .padding(20)
            }
            .background(
                userTheme == .system
                ? (colorScheme == .light ? .white : .darkGray)
                    : (userTheme == .dark ? Color(.secondarySystemBackground) : Color(.systemBackground))
            )
            .cornerRadius(20, corners: .allCorners)
        }
        .buttonStyle(PlainButtonStyle())
        .frame(height: 170)
        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
        .sheet(isPresented: $showPicker) {
            SleepPickerView(initialSleepMinutes: healthVM.sleepMinutes) { newMinutes in
                healthVM.updateSleepMinutes(newMinutes)
            }
            .presentationDetents([.medium])
            .presentationDragIndicator(.hidden)
        }
    }
}

struct SleepPickerView: View {
    @State private var hours: Int
    @State private var minutes: Int
    let onSave: (Int) -> Void
    @Environment(\.dismiss) private var dismiss

    init(initialSleepMinutes: Int, onSave: @escaping (Int) -> Void) {
        // Convert total minutes to hours and minutes for picker
        self._hours = State(initialValue: initialSleepMinutes / 60)
        self._minutes = State(initialValue: initialSleepMinutes % 60)
        self.onSave = onSave
    }

    var body: some View {
        VStack(spacing: 24) {
            // custom handle
            Capsule()
                .frame(width: 40, height: 5)
                .foregroundColor(.gray.opacity(0.3))
                .padding(.top, 8)

            Text("Today's Sleep")
                .font(.title3.weight(.semibold))
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            // wheel pickers
            HStack(spacing: 32) {
                wheelPicker(selection: $hours, range: 0...12, label: "hr")
                wheelPicker(selection: $minutes, range: 0...59, label: "min")
            }

            // live preview
            Text("\(hours) hr \(minutes) min")
                .font(.headline.weight(.bold))
                .padding()
                .background(Color.secondary.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            Spacer()

            // save button
            Button {
                let totalMinutes = (hours * 60) + minutes
                onSave(totalMinutes)
                dismiss()
            } label: {
                Text("Done")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
        }
        .padding()
    }

    @ViewBuilder
    private func wheelPicker(selection: Binding<Int>, range: ClosedRange<Int>, label: String) -> some View {
        VStack(spacing: 8) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)

            Picker("", selection: selection) {
                ForEach(range, id: \.self) { val in
                    Text("\(val)").tag(val)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 80, height: 100)
            .clipped()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }
}


// MARK: - Preview
struct DailySleepView_Previews: PreviewProvider {
    static var previews: some View {
        DailySleepView()
            .environmentObject(HealthDataViewModel())
            .padding()
            .previewLayout(.sizeThatFits)
        
        SleepPickerView(initialSleepMinutes: 150) { _ in } // 2.5 hours = 150 minutes
            .previewLayout(.sizeThatFits)
    }
}
