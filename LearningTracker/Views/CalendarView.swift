//
//  CalendarView.swift
//  LearningTracker
//
//  Created by Fay Alabdulqader on 12/11/2026.
//

import SwiftUI

struct CalendarView: View {

    @ObservedObject var viewModel: ActivityViewModel

    @Environment(\.dismiss) private var dismiss

    private let weekdays = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]

    // Start of the learning period
    private var periodStart: Date {
        Calendar.current.startOfDay(for: viewModel.goalStartDate)
    }

    // End of the learning period
    private var periodEnd: Date {

        let calendar = Calendar.current

        switch viewModel.learningGoal.duration {

        case "Week":
            return calendar.date(
                byAdding: .day,
                value: 7,
                to: periodStart
            ) ?? periodStart

        case "Month":
            return calendar.date(
                byAdding: .month,
                value: 1,
                to: periodStart
            ) ?? periodStart

        case "Year":
            return calendar.date(
                byAdding: .year,
                value: 1,
                to: periodStart
            ) ?? periodStart

        default:
            return periodStart
        }
    }

    // Display only the months included in the learning period
    private var months: [Date] {

        let calendar = Calendar.current

        guard
            let firstMonth = calendar.date(
                from: calendar.dateComponents(
                    [.year, .month],
                    from: periodStart
                )
            ),
            let lastIncludedDate = calendar.date(
                byAdding: .second,
                value: -1,
                to: periodEnd
            ),
            let lastMonth = calendar.date(
                from: calendar.dateComponents(
                    [.year, .month],
                    from: lastIncludedDate
                )
            )
        else {
            return []
        }

        let monthCount = calendar.dateComponents(
            [.month],
            from: firstMonth,
            to: lastMonth
        ).month ?? 0

        return (0...monthCount).compactMap {
            calendar.date(
                byAdding: .month,
                value: $0,
                to: firstMonth
            )
        }
    }

    var body: some View {

        VStack(spacing: 0) {

            // Header
            HStack {

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20))
                        .foregroundStyle(.white)
                        .padding(12)
                        .glassEffect(.regular, in: Circle())
                }
                .buttonStyle(.plain)

                Spacer()

                Text("Activities")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)

                Spacer()

                // Keeps the title centered
                Image(systemName: "chevron.left")
                    .font(.system(size: 20))
                    .foregroundStyle(.clear)
                    .padding(12)
            }
            .padding(.horizontal, 12)
            .padding(.top, 12)
            .padding(.bottom, 22)

            // Learning period months
            ScrollView {
                LazyVStack(spacing: 22) {
                    ForEach(months, id: \.self) { month in
                        monthView(for: month)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 20)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .navigationBarBackButtonHidden(true)
    }

    // One month
    private func monthView(for month: Date) -> some View {

        let days = daysInMonth(for: month)

        return VStack(alignment: .leading, spacing: 14) {

            Text(month.formatted(.dateTime.month(.wide).year()))
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)

            LazyVGrid(
                columns: Array(
                    repeating: GridItem(.flexible(), spacing: 0),
                    count: 7
                ),
                spacing: 14
            ) {

                // Weekday labels
                ForEach(weekdays, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.gray)
                        .frame(maxWidth: .infinity)
                }

                // Calendar dates
                ForEach(Array(days.enumerated()), id: \.offset) { _, date in

                    if let date {
                        dayView(for: date)
                    } else {
                        Color.clear
                            .frame(height: 34)
                    }
                }
            }
        }
        .padding(.bottom, 14)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.gray.opacity(0.25))
                .frame(height: 1)
        }
    }

    // Dates in a month, including empty spaces before the first day
    private func daysInMonth(for month: Date) -> [Date?] {

        let calendar = Calendar.current

        guard
            let range = calendar.range(
                of: .day,
                in: .month,
                for: month
            ),
            let firstDay = calendar.date(
                from: calendar.dateComponents(
                    [.year, .month],
                    from: month
                )
            )
        else {
            return []
        }

        let weekday = calendar.component(
            .weekday,
            from: firstDay
        )

        var days: [Date?] = Array(
            repeating: nil,
            count: weekday - 1
        )

        for day in range {

            if let date = calendar.date(
                byAdding: .day,
                value: day - 1,
                to: firstDay
            ) {
                days.append(date)
            }
        }

        return days
    }

    // One calendar date
    @ViewBuilder
    private func dayView(for date: Date) -> some View {

        let calendar = Calendar.current
        let day = calendar.startOfDay(for: date)

        // Hide dates outside the learning period
        if day >= periodStart && day < periodEnd {

            let status = viewModel.status(for: date)

            let dayColor: Color = {
                switch status {
                case .learned:
                    return Color("orange")
                case .frozen:
                    return Color("blue")
                case nil:
                    return .clear
                }
            }()

            Text(date.formatted(.dateTime.day()))
                .font(.system(size: 16))
                .foregroundStyle(.white)
                .frame(width: 34, height: 34)
                .background {
                    Circle().fill(dayColor)
                }
                .frame(maxWidth: .infinity)

        } else {

            Color.clear
                .frame(height: 34)
                .frame(maxWidth: .infinity)
        }
    }
}

#Preview {

    NavigationStack {
        CalendarView(
            viewModel: ActivityViewModel(
                learningGoal: LearningGoal(
                    subject: "Swift",
                    duration: "Week"
                )
            )
        )
    }
    .preferredColorScheme(.dark)
}
