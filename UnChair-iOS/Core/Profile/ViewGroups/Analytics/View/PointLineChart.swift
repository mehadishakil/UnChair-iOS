//
//  PointLineChart.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 7/4/25.
//


import SwiftUI
import Charts

struct PointLineChart : View {

    @State private var rawSelectedDate: Date?
    var selectedViewMonth: ViewMonth? {
        guard let rawSelectedDate else { return nil }
        return viewMonths.first {
            Calendar.current.isDate(rawSelectedDate, equalTo: $0.date, toGranularity: .month)
        }
    }

    let viewMonths: [ViewMonth] = [
        .init(date: Date.from(year: 2023, month: 1, day: 1), viewCount: 55000),
        .init(date: Date.from(year: 2023, month: 2, day: 1), viewCount: 89000),
        .init(date: Date.from(year: 2023, month: 3, day: 1), viewCount: 64000),
        .init(date: Date.from(year: 2023, month: 4, day: 1), viewCount: 79000),
        .init(date: Date.from(year: 2023, month: 5, day: 1), viewCount: 13000),
        .init(date: Date.from(year: 2023, month: 6, day: 1), viewCount: 90000),
        .init(date: Date.from(year: 2023, month: 7, day: 1), viewCount: 88000),
        .init(date: Date.from(year: 2023, month: 8, day: 1), viewCount: 64000),
        .init(date: Date.from(year: 2023, month: 9, day: 1), viewCount: 74000),
        .init(date: Date.from(year: 2023, month: 10, day: 1), viewCount: 99000),
        .init(date: Date.from(year: 2023, month: 11, day: 1), viewCount: 110000),
        .init(date: Date.from(year: 2023, month: 12, day: 1), viewCount: 94000)
    ]

    var body: some View {
        VStack {
            Chart {
                if let selectedViewMonth {
                    RuleMark(x: .value("Selected Month", selectedViewMonth.date, unit: .month))
                        .foregroundStyle(.secondary.opacity(0.3))
                        .annotation(position: .top, overflowResolution: .init(x: .fit(to: .chart), y: .disabled)) {
                            VStack{
                                Text(selectedViewMonth.date, format: .dateTime.month(.wide))
                                    .bold()

                                Text("\(selectedViewMonth.viewCount)")
                                    .font(.title3.bold())
                            }
                            .foregroundStyle(.white)
                            .padding(12)
                            .frame(width: 120)
                            .background(RoundedRectangle(cornerRadius: 10).fill(.pink.gradient))
                        }
                }

                RuleMark(y: .value("Goal", 80000))
                    .foregroundStyle(Color.mint)
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                    .annotation(alignment: .leading){
                        Text("Goal")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                ForEach(viewMonths) { viewMonth in
                    // Line part of lollipop
                    LineMark(
                        x: .value("Month", viewMonth.date, unit: .month),
                        y: .value("Views", viewMonth.viewCount)
                    )
                    .foregroundStyle(Color.pink)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    .opacity(rawSelectedDate == nil || viewMonth.date == selectedViewMonth?.date ? 1.0 : 0.3)

                    // Circle part of lollipop
                    PointMark(
                        x: .value("Month", viewMonth.date, unit: .month),
                        y: .value("Views", viewMonth.viewCount)
                    )
                    .foregroundStyle(Color.pink.gradient)
                    .symbolSize(rawSelectedDate == nil || viewMonth.date == selectedViewMonth?.date ? 100 : 80)
                    .opacity(rawSelectedDate == nil || viewMonth.date == selectedViewMonth?.date ? 1.0 : 0.3)
                }
            }
            .frame(height: 180)
            .chartXSelection(value: $rawSelectedDate.animation(.easeInOut))
            .onChange(of: selectedViewMonth?.viewCount, { oldValue, newValue in
                print(newValue)
            })
            .chartXAxis{
                AxisMarks(values: .stride(by: .month)) { value in
                    AxisValueLabel(format: .dateTime.month(.narrow), centered: true)
                    AxisGridLine()
                }
            }
            .chartYAxis{
                AxisMarks { value in
                    AxisValueLabel()
                    AxisGridLine()
                }
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
            // Create a mock AuthController instance (or use a real one if necessary)
            let authController = AuthController()

            // Provide the AuthController to the environment
            return PointLineChart()
            .environmentObject(authController)  // Inject the AuthController environment object
        }
}

//struct ViewMonth: Identifiable {
//    let id = UUID()
//    let date: Date
//    let viewCount: Int
//}
//
//extension Date {
//    static func from(year: Int, month: Int, day: Int) -> Date {
//        let components = DateComponents(year: year, month: month, day: day)
//        return Calendar.current.date(from: components)!
//    }
//}
//
