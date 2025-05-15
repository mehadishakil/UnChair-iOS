//
//  BreakItem.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 23/4/25.
//


import SwiftUI

struct BreakItem: View {
    var namespace: Namespace.ID
    @Binding var show: Bool
    var breakItem: Break

    var body: some View {
        VStack {
            VStack {
                Spacer()
                VStack(alignment: .leading, spacing: 4) {
                    Text(breakItem.title)
                        .font(.title)
                        .matchedGeometryEffect(id: "title\(breakItem.id)", in: namespace)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text("Approx. \(formatDuration(seconds: breakItem.duration))")
                        .font(.caption)
                        .fontWeight(.medium)
                        .matchedGeometryEffect(id: "subtitle\(breakItem.id)", in: namespace)

                    Text(breakItem.overview)
                        .font(.caption)
                        .matchedGeometryEffect(id: "text\(breakItem.id)", in: namespace)
                }
                .padding(20)
            }
            .foregroundStyle(.white)
            .background(
                Image(breakItem.image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .matchedGeometryEffect(id: "background\(breakItem.id)", in: namespace)
            )
            .mask(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .matchedGeometryEffect(id: "mask\(breakItem.id)", in: namespace)
            )
            .frame(height: 150)
            .padding(.horizontal, 20)
        }
    }

    private func formatDuration(seconds: Int) -> String {
        let minutes = seconds / 60
        switch minutes {
        case 0: return "\(seconds) seconds"
        case 1: return "1 minute"
        default: return "\(minutes) minutes"
        }
    }
}


struct BreakItem_Previews: PreviewProvider {
    @Namespace static var namespace
    static var previews: some View {
        BreakItem(namespace: namespace, show: .constant(true), breakItem: breakList[0])
    }
}
