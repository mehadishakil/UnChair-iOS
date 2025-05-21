//
//  HCalendarView.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 27/6/24.
//

import SwiftUI

struct HCalendarView: View {

    @State private var scrollPosition: CGFloat = 0
    @State private var selectedDate = Date()
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            
            ZStack {
                dayView
                    .padding(.vertical, 5)
            }
            .frame(height: 30)
            .padding(.horizontal, 20)
        }
    }
    
    // display the current month and navigation buttons
    private var monthView: some View {
        HStack(spacing: 30) {
            Button(
                action: {
                    changeMonth(-1)
                },
                label: {
                    Image(systemName: "chevron.left")
                        .padding()
                }
            )
            
            Text(monthTitle(from: selectedDate))
                .font(.title)
            
            Button(
                action: {
                    changeMonth(1)
                },
                label: {
                    Image(systemName: "chevron.right")
                        .padding()
                }
            )
        }
    }
    
    // display the days of the current month
    @ViewBuilder
    private var dayView: some View {
        let startDate = calendar.date(from: Calendar.current.dateComponents([.year, .month], from: selectedDate))!
        
        ScrollViewReader { scrollProxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    let components = (
                        0..<calendar.range(of: .day, in: .month, for: startDate)!.count)
                        .map {
                            calendar.date(byAdding: .day, value: $0, to: startDate)!
                        }
                    
                    ForEach(Array(components.enumerated()), id: \.element) { index, date in
                        let isSelected = calendar.isDate(selectedDate, equalTo: date, toGranularity: .day)

                        VStack(spacing: 12) {
                            Text(day(from: date).prefix(1)) // "M", "T", etc.
                                .font(.caption)
                                .fontWeight(.medium)

                            ZStack {
                                if isSelected {
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 36, height: 36)
                                }

                                Text("\(calendar.component(.day, from: date))")
                                    .fontWeight(.semibold)
                                    .foregroundColor(isSelected ? .darkGray : .primary)
                            }
                        }
                        .frame(width: 48, height: 80)
                        .background(
                            ZStack {
                                if isSelected {
                                    RoundedRectangle(cornerRadius: 36)
                                        .fill(Color.blue)
                                        .matchedGeometryEffect(id: "selectedBackground", in: Namespace().wrappedValue)
                                }
                            }
                        )
                        .animation(.easeInOut(duration: 0.3), value: selectedDate)
                        .foregroundColor(isSelected ? .white : .primary)
                        .onTapGesture {
                            withAnimation {
                                selectedDate = date
                            }
                        }
                        .id(index)

                    }
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation {
                        scrollProxy.scrollTo(todayIndex, anchor: .center)
                    }
                }
            }
        }
    }
    
    private var todayIndex: Int {
        let startDate = calendar.date(from: Calendar.current.dateComponents([.year, .month], from: selectedDate))!
        let today = Date()
        return calendar.dateComponents([.day], from: startDate, to: today).day ?? 0
    }
}

// Extension for logic to handle date operations
private extension HCalendarView {

    func monthTitle(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("MMMM yyyy")
        return dateFormatter.string(from: date)
    }
    
    /// Changes the current month by a given value
    func changeMonth(_ value: Int) {
        guard let date = calendar.date(
            byAdding: .month,
            value: value,
            to: selectedDate
        ) else {
            return
        }
        
        selectedDate = date
    }
    
    /// Returns the abbreviated day of the week for a given date
    func day(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("E")
        return dateFormatter.string(from: date)
    }
}

#Preview {
    HCalendarView()
}
