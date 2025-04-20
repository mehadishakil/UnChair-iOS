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
      Text("Calm Corner")
        .font(.title2).fontWeight(.semibold)

      Button {
        showDialog = true
      } label: {
        VStack(alignment: .leading, spacing: 5) {
          Text("Meditate")
            .font(.headline).fontWeight(.bold)
          Text("Balance your thoughts and bring peace to your soul with a gentle meditation session.")
            .font(.subheadline)
            .foregroundColor(.gray)
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 4)
      }
      .sheet(isPresented: $showDialog) {
        TimeSelectionView(
          isPresented: $showDialog,
          selectedTime: $selectedTime
        ) {
          // after confirm
          navigate = true
        }
        .presentationDetents([.height(300)])
      }

      // Hidden NavigationLink triggered after confirm
      NavigationLink(
        destination: Meditation(initialTime: selectedTime)
                       .environmentObject(HealthDataViewModel()),
        isActive: $navigate
      ) {
        EmptyView()
      }
    }
    .padding()
  }
}

#Preview {
  CalmCorner()
    .environmentObject(HealthDataViewModel())
}






// TimeSelectionView.swift
import SwiftUI

struct TimeSelectionView: View {
  @Binding var isPresented: Bool
  @Binding var selectedTime: Int
  let onConfirm: () -> Void

  var body: some View {
    VStack(spacing: 24) {
      Text("Choose Duration")
        .font(.title2).bold()

      // Presets
      HStack(spacing: 20) {
        ForEach([3,5,10], id: \.self) { mins in
          Button {
            selectedTime = mins
          } label: {
            Text("\(mins) min")
                  .fontWeight(.medium)
              .padding(.horizontal, 24)
              .padding(.vertical, 12)
              .background(selectedTime == mins ? Color.purple.opacity(0.8) : Color.gray.opacity(0.3))
              .foregroundColor(.white)
              .cornerRadius(8)
          }
        }
      }

      // Nudge buttons
      HStack(spacing: 40) {
        Button {
          selectedTime = max(1, selectedTime - 1)
        } label: {
          Image(systemName: "minus.circle.fill")
            .font(.largeTitle)
        }

        Text("\(selectedTime) min")
          .font(.title2)
          .fontWeight(.medium)

        Button {
          selectedTime = min(60, selectedTime + 1)
        } label: {
          Image(systemName: "plus.circle.fill")
            .font(.largeTitle)
        }
      }

      // Confirm
      Button("Confirm") {
        isPresented = false
        onConfirm()
      }
      .font(.headline)
      .padding(.horizontal, 40)
      .padding(.vertical, 12)
      .background(Color.purple)
      .foregroundColor(.white)
      .cornerRadius(10)

      Spacer()
    }
    .padding()
  }
}
