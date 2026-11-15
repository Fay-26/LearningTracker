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

    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: 0),
        count: 7
    )

    // Months that contain the learning period
    private var months: [Date] {
        let calendar = Calendar.current

        guard
            let first = calendar.dateInterval(of: .month, for: viewModel.goalStartDate)?.start,
            let last = calendar.dateInterval(
                of: .month,
                for: viewModel.goalEndDate.addingTimeInterval(-1)
            )?.start
        else {
            return []
        }

        let count = calendar.dateComponents([.month], from: first, to: last).month ?? 0

        return (0...count).compactMap {
            calendar.date(byAdding: .month, value: $0, to: first)
        }
    }

    var body: some View {
        VStack(spacing: 0) {

            // Header
            ZStack {
                Text("Activities")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)

                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18))
                            .foregroundStyle(.white)
                            .frame(width: 45, height: 45)
                            .glassEffect(.regular.interactive(), in: Circle())
                    }
                    .buttonStyle(.plain)

                    Spacer()
                }
            }
            .padding(.horizontal, 15)
            .padding(.top, 62)
            .padding(.bottom, 28)

            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(months, id: \.self) { month in
                        monthView(for: month)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 20)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.ignoresSafeArea())
        .ignoresSafeArea(edges: .top)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }

    private func monthView(for month: Date) -> some View {
        VStack(alignment: .leading, spacing: 15) {

            Text(month.formatted(.dateTime.month(.wide).year()))
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .padding(.leading, 13)

            VStack(spacing: 9) {
                LazyVGrid(columns: columns, spacing: 0) {
                    ForEach(weekdays, id: \.self) { day in
                        Text(day)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.gray)
                            .frame(maxWidth: .infinity)
                    }
                }

                LazyVGrid(columns: columns, spacing: 14) {
                    ForEach(Array(daysInMonth(for: month).enumerated()), id: \.offset) { _, date in
                        dayView(for: date)
                    }
                }
            }
        }
        .padding(.bottom, 12)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.gray.opacity(0.25))
                .frame(height: 1)
        }
    }

    // Empty spaces before the 1st, then every date of the month
    private func daysInMonth(for month: Date) -> [Date?] {
        let calendar = Calendar.current

        guard
            let firstDay = calendar.dateInterval(of: .month, for: month)?.start,
            let range = calendar.range(of: .day, in: .month, for: month)
        else {
            return []
        }

        let emptyDays = calendar.component(.weekday, from: firstDay) - 1

        return Array(repeating: nil, count: emptyDays) + range.compactMap {
            calendar.date(byAdding: .day, value: $0 - 1, to: firstDay)
        }
    }

    // Only dates inside the learning period are shown
    @ViewBuilder
    private func dayView(for date: Date?) -> some View {
        if let date,
           date >= viewModel.goalStartDate,
           date < viewModel.goalEndDate {

            DayCircle(
                date: date,
                status: viewModel.status(for: date),
                size: 39,
                fontSize: 17
            )
            .frame(maxWidth: .infinity)

        } else {
            Color.clear.frame(height: 39)
        }
    }
}
