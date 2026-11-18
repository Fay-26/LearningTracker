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

    @State private var selectedRecord: ActivityRecord?

    private let weekdays = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]

    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: 0),
        count: 7
    )

    // Current goal period
    private var selectedStartDate: Date {
        viewModel.goalStartDate
    }

    private var selectedEndDate: Date {
        viewModel.goalEndDate
    }

    // Combine current and previous goal activities
    private var selectedRecords: [ActivityRecord] {

        let previousRecords = viewModel.goalHistory.flatMap {
            $0.records
        }

        return (previousRecords + viewModel.records)
            .sorted { $0.date < $1.date }
    }

    // All months from the first activity through December
    // of the current year, with at least one full calendar year
    private var months: [Date] {

        let calendar = Calendar.current

        let currentYear = calendar.component(.year, from: viewModel.currentDate)

        guard
            let january = calendar.date(
                from: DateComponents(
                    year: currentYear,
                    month: 1,
                    day: 1
                )
            ),
            let december = calendar.date(
                from: DateComponents(
                    year: currentYear,
                    month: 12,
                    day: 1
                )
            )
        else {
            return []
        }

        let firstActivity = selectedRecords
            .map { $0.date }
            .min()

        let firstMonth = firstActivity.flatMap {
            calendar.dateInterval(of: .month, for: $0)?.start
        } ?? january

        let startMonth = min(firstMonth, january)

        let monthCount = calendar.dateComponents(
            [.month],
            from: startMonth,
            to: december
        ).month ?? 0

        return (0...max(0, monthCount)).compactMap {
            calendar.date(
                byAdding: .month,
                value: $0,
                to: startMonth
            )
        }
    }

    // Get historical subject if an older record has no subject saved
    private func subject(for record: ActivityRecord) -> String {

        if let subject = record.subject {
            return subject
        }

        let historicalGoal = viewModel.goalHistory.first {
            $0.records.contains { $0.id == record.id }
        }

        return historicalGoal?.learningGoal.subject
            ?? viewModel.learningGoal.subject
    }

    // Get historical duration if an older record has no duration saved
    private func duration(for record: ActivityRecord) -> String {

        if let duration = record.duration {
            return duration
        }

        let historicalGoal = viewModel.goalHistory.first {
            $0.records.contains { $0.id == record.id }
        }

        return historicalGoal?.learningGoal.duration
            ?? viewModel.learningGoal.duration
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
            .padding(.bottom, 20)

            // Calendar
            ScrollViewReader { proxy in

                ScrollView {

                    LazyVStack(spacing: 16) {

                        ForEach(months, id: \.self) { month in

                            monthView(for: month)
                                .id(month)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.bottom, 20)
                }
                .onAppear {

                    let calendar = Calendar.current

                    let currentMonth = calendar.dateInterval(
                        of: .month,
                        for: viewModel.currentDate
                    )?.start ?? viewModel.currentDate

                    proxy.scrollTo(currentMonth, anchor: .top)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.ignoresSafeArea())
        .ignoresSafeArea(edges: .top)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)

        // Activity details popup
        .sheet(item: $selectedRecord) { record in

            let activityColor = record.status == .learned
                ? Color("apporange")
                : Color("appblue")

            VStack(spacing: 22) {

                // Activity icon
                Image(
                    systemName: record.status == .learned
                        ? "checkmark"
                        : "snowflake"
                )
                .font(.system(size: 25, weight: .semibold))
                .foregroundStyle(activityColor)
                .frame(width: 62, height: 62)
                .glassEffect(
                    .regular.tint(activityColor),
                    in: Circle()
                )
                .padding(.top, 12)

                // Activity title and date
                VStack(spacing: 7) {

                    Text(
                        record.status == .learned
                            ? "Learned"
                            : "Frozen Day"
                    )
                    .font(.system(size: 23, weight: .bold))
                    .foregroundStyle(.white)

                    Text(
                        record.date.formatted(
                            date: .complete,
                            time: .omitted
                        )
                    )
                    .font(.system(size: 14))
                    .foregroundStyle(.gray)
                }

                // Activity details card
                VStack(spacing: 16) {

                    detailRow(
                        title: record.status == .learned
                            ? "What you learned"
                            : "Learning goal",
                        value: subject(for: record)
                    )

                    Rectangle()
                        .fill(Color.gray.opacity(0.25))
                        .frame(height: 1)

                    detailRow(
                        title: "Goal duration",
                        value: duration(for: record)
                    )
                }
                .padding(20)
                .glassEffect(
                    .regular,
                    in: RoundedRectangle(cornerRadius: 25)
                )

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 25)
            .padding(.top, 15)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .presentationDetents([.height(350)])
            .presentationDragIndicator(.visible)
            .presentationBackground(Color.black)
            .presentationCornerRadius(30)
            .preferredColorScheme(.dark)
        }
    }

    // Month layout
    private func monthView(for month: Date) -> some View {

        VStack(alignment: .leading, spacing: 15) {

            Text(month.formatted(.dateTime.month(.wide).year()))
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .padding(.leading, 13)

            VStack(spacing: 9) {

                // Weekday names
                LazyVGrid(columns: columns, spacing: 0) {

                    ForEach(weekdays, id: \.self) { day in

                        Text(day)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.gray)
                            .frame(maxWidth: .infinity)
                    }
                }

                // Days of the month
                LazyVGrid(columns: columns, spacing: 14) {

                    ForEach(
                        Array(daysInMonth(for: month).enumerated()),
                        id: \.offset
                    ) { _, date in

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
            let firstDay = calendar.dateInterval(
                of: .month,
                for: month
            )?.start,
            let range = calendar.range(
                of: .day,
                in: .month,
                for: month
            )
        else {
            return []
        }

        let emptyDays = calendar.component(
            .weekday,
            from: firstDay
        ) - 1

        return Array(repeating: nil, count: emptyDays) + range.compactMap {

            calendar.date(
                byAdding: .day,
                value: $0 - 1,
                to: firstDay
            )
        }
    }

    // Show dates and activities
    @ViewBuilder
    private func dayView(for date: Date?) -> some View {

        if let date {

            let calendar = Calendar.current

            // Records are sorted oldest → newest, so `last` picks the
            // newest one if a day has two (e.g. logged, changed goal, logged again)
            let activity = selectedRecords.last {
                calendar.isDate($0.date, inSameDayAs: date)
            }

            let isSelectedGoalPeriod =
                date >= calendar.startOfDay(for: selectedStartDate) &&
                date < selectedEndDate

            DayCircle(
                date: date,
                status: activity?.status,
                size: 39,
                fontSize: 17,
                today: viewModel.currentDate
            )
            .frame(width: 43, height: 43)
            .overlay {

                if isSelectedGoalPeriod {

                    RoundedRectangle(cornerRadius: 11)
                        .stroke(
                            Color.orange.opacity(0.85),
                            lineWidth: 1
                        )
                        .padding(1)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {

                selectedRecord = activity
            }
            .frame(maxWidth: .infinity)

        } else {

            Color.clear.frame(height: 43)
        }
    }

    // Popup detail row
    private func detailRow(title: String, value: String) -> some View {

        HStack {

            Text(title)
                .font(.system(size: 14))
                .foregroundStyle(.gray)

            Spacer()

            Text(value)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
        }
    }
}
