//
//  HCalendarView.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 27/6/24.
//

import SwiftUI

struct HCalendarView: View {
    @State private var selectedDate = Date()
      private let calendar = Calendar.current
      
      var body: some View {
        VStack(alignment: .center, spacing: 20) {
//          monthView
          
          ZStack {
            dayView
            blurView
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
        
        ScrollView(.horizontal, showsIndicators: false) {
          HStack(spacing: 10) {
            let components = (
              0..<calendar.range(of: .day, in: .month, for: startDate)!.count)
              .map {
                calendar.date(byAdding: .day, value: $0, to: startDate)!
              }
            
            ForEach(components, id: \.self) { date in
              VStack {
                Text(day(from: date))
                  .font(.caption)
                Text("\(calendar.component(.day, from: date))")
              }
              .frame(width: 30, height: 30)
              .padding(5)
              .background(calendar.isDate(selectedDate, equalTo: date, toGranularity: .day) ? Color.green : Color.clear)
              .cornerRadius(16)
              .foregroundColor(calendar.isDate(selectedDate, equalTo: date, toGranularity: .day) ? .white : .black)
              .onTapGesture {
                selectedDate = date
              }
            }
          }
        }
      }
      
      // add a blur effect at the edges of the day view
      private var blurView: some View {
        HStack {
          LinearGradient(
            gradient: Gradient(
              colors: [
                Color.white.opacity(1),
                Color.white.opacity(0)
              ]
            ),
            startPoint: .leading,
            endPoint: .trailing
          )
          .frame(width: 20)
          .edgesIgnoringSafeArea(.leading)
          
          Spacer()
          
          LinearGradient(
            gradient: Gradient(
              colors: [
                Color.white.opacity(1),
                Color.white.opacity(0)
              ]
            ),
            startPoint: .trailing,
            endPoint: .leading
          )
          .frame(width: 20)
          .edgesIgnoringSafeArea(.leading)
        }
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
