//
//  BreakDurationSelector.swift
//  UnChair-iOS
//
//  Break duration selection popup
//

import SwiftUI

enum BreakType: String, CaseIterable {
    case quick = "Quick Break"
    case short = "Short Break"
    case medium = "Medium Break"
    case tea = "Tea Break"

    var duration: Int {
        switch self {
        case .quick: return 5
        case .short: return 10
        case .medium: return 20
        case .tea: return 15
        }
    }

    var icon: String {
        switch self {
        case .quick: return "bolt.fill"
        case .short: return "figure.walk"
        case .medium: return "figure.mind.and.body"
        case .tea: return "cup.and.saucer.fill"
        }
    }

    var color: Color {
        switch self {
        case .quick: return .orange
        case .short: return .blue
        case .medium: return .purple
        case .tea: return .brown
        }
    }

    var description: String {
        switch self {
        case .quick: return "Quick stretch"
        case .short: return "Walk around"
        case .medium: return "Exercise or meditate"
        case .tea: return "Relax & refresh"
        }
    }
}

struct BreakDurationSelector: View {
    @Environment(\.dismiss) var dismiss
    let onSelect: (BreakType) -> Void

    @AppStorage("userTheme") private var userTheme: Theme = .system
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "figure.stand")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)

                    Text("Take a Break")
                        .font(.title2.bold())

                    Text("How long would you like to break?")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)

                // Break Options
                VStack(spacing: 16) {
                    ForEach(BreakType.allCases, id: \.self) { breakType in
                        BreakOptionCard(
                            breakType: breakType,
                            onSelect: {
                                onSelect(breakType)
                                dismiss()
                            }
                        )
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
            .background(
                userTheme == .system
                ? (colorScheme == .light ? Color(.systemBackground) : Color(.systemBackground))
                : (userTheme == .dark ? Color(.systemBackground) : Color(.systemBackground))
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct BreakOptionCard: View {
    let breakType: BreakType
    let onSelect: () -> Void

    @AppStorage("userTheme") private var userTheme: Theme = .system
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(breakType.color.opacity(0.15))
                        .frame(width: 60, height: 60)

                    Image(systemName: breakType.icon)
                        .font(.system(size: 26))
                        .foregroundColor(breakType.color)
                }

                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(breakType.rawValue)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(breakType.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Duration
                VStack(spacing: 2) {
                    Text("\(breakType.duration)")
                        .font(.title.bold())
                        .foregroundColor(breakType.color)

                    Text("min")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        userTheme == .system
                        ? (colorScheme == .light ? Color.white : Color(.secondarySystemBackground))
                        : (userTheme == .dark ? Color(.secondarySystemBackground) : Color(.systemBackground))
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(breakType.color.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    BreakDurationSelector { breakType in
        print("Selected: \(breakType.rawValue)")
    }
}
