//
//  CalmCorner.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 11/8/24.
//

import SwiftUI

struct CalmCorner: View {
    @State private var showDialog = false
    @State private var selectedTime = 5
    @State private var navigate = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Meditation")
                .font(.title2.weight(.semibold))
            
            Button {
                showDialog = true
            } label: {
                MeditationCardView()
            }
            .sheet(isPresented: $showDialog) {
                TimeSelectionView(
                    isPresented: $showDialog,
                    selectedTime: $selectedTime
                ) {
                    navigate = true
                }
                .presentationDetents([.height(320)])
                .presentationDragIndicator(.hidden)
            }
            
            NavigationLink(
                destination: Meditation(initialTime: selectedTime)
                    .environmentObject(HealthDataViewModel()),
                isActive: $navigate
            ) { EmptyView() }
                .hidden()
        }
        .padding()
    }
    
    private func MeditationCardView() -> some View {
        ZStack(alignment: .bottomLeading) {
            // Background image
            Image("meditation_image")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 170)
                .clipped()
            
            // Ultra-thin material for frosted glass effect
            Rectangle()
                .fill(.ultraThinMaterial)
                .mask(
                    // Gradient mask to create fade effect
                    LinearGradient(
                        colors: [
                            .black,
                            .black.opacity(0.8),
                            .clear,
                            .clear,
                            .clear
                        ],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
            
            // Additional tint for better contrast
            LinearGradient(
                colors: [
                    .black.opacity(0.5),
                    .black.opacity(0.3),
                    .clear,
                    .clear,
                    .clear
                ],
                startPoint: .bottom,
                endPoint: .top
            )
            
            // Text content
            VStack(alignment: .leading, spacing: 4) {
                Text("Meditate")
                    .font(.title.bold())
                Text("Balance your thoughts with a calming meditation")
                    .font(.footnote)
            }
            .padding()
            .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: 170)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.15), radius: 8, x: 5, y: 10)
    }
    
    
    
}

struct TimeSelectionView: View {
    @Binding var isPresented: Bool
    @Binding var selectedTime: Int
    let onConfirm: () -> Void
    private let presets = [3, 5, 10]
    
    var body: some View {
        VStack(spacing: 20) {
            Capsule()
                .frame(width: 40, height: 5)
                .foregroundColor(.gray.opacity(0.3))
                .padding(.top, 8)
            
            Text("Choose Duration")
                .font(.title2.weight(.bold))
            
            HStack(spacing: 16) {
                ForEach(presets, id: \.self) { mins in
                    Button {
                        selectedTime = mins
                    } label: {
                        Text("\(mins) min")
                            .font(.subheadline.weight(.medium))
                            .padding(.vertical, 8)
                            .padding(.horizontal, 20)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(selectedTime == mins ? .blue : Color(.secondarySystemBackground))
                            )
                            .foregroundColor(selectedTime == mins ? .white : .primary)
                    }
                }
            }
            .padding(.vertical)
            
            HStack(spacing: 30) {
                AdjustmentButton(systemImage: "minus.circle.fill") {
                    selectedTime = max(1, selectedTime - 1)
                }
                
                Text("\(selectedTime) min")
                    .font(.title2.weight(.semibold))
                    .frame(minWidth: 80)
                
                AdjustmentButton(systemImage: "plus.circle.fill") {
                    selectedTime = min(60, selectedTime + 1)
                }
            }
            
            Button {
                isPresented = false
                onConfirm()
            } label: {
                Text("Confirm")
                    .font(.headline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground).ignoresSafeArea())
    }
    
    private func AdjustmentButton(systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .symbolRenderingMode(.hierarchical)
                .font(.system(size: 40))
                .foregroundColor(.blue)
        }
    }
}

#Preview {
    CalmCorner()
        .environmentObject(HealthDataViewModel())
}
