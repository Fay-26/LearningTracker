//
//  GoalResultView.swift
//  LearningTracker
//
//  Created by Fay Alabdulqader on 12/11/2026.
//


import SwiftUI

struct GoalResultView: View {

    @ObservedObject var viewModel: ActivityViewModel

    let isCompleted: Bool
    let onSetNewGoal: () -> Void

    private let weekdays = ["S", "M", "T", "W", "T", "F", "S"]

    private var weekDates: [Date] {
        var calendar = Calendar.current
        calendar.firstWeekday = 1

        let today = calendar.startOfDay(for: Date())

        guard let weekInterval = calendar.dateInterval(
            of: .weekOfYear,
            for: today
        ) else {
            return [today]
        }

        return (0..<7).compactMap {
            calendar.date(
                byAdding: .day,
                value: $0,
                to: weekInterval.start
            )
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Activity")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.white)

                    Text(
                        Date.now,
                        format: .dateTime.weekday(.wide).day().month(.wide)
                    )
                    .font(.system(size: 12))
                    .foregroundStyle(.gray)
                }

                Spacer()

                Image(systemName: "calendar")
                    .font(.system(size: 20))
                    .foregroundStyle(.white)
                    .padding(10)
                    .glassEffect(.regular, in: Circle())

                Image(systemName: "pencil")
                    .font(.system(size: 20))
                    .foregroundStyle(.white)
                    .padding(10)
                    .glassEffect(.regular, in: Circle())
            }

            // Weekday labels
            HStack {
                ForEach(Array(weekdays.enumerated()), id: \.offset) { _, day in
                    Text(day)
                        .font(.system(size: 11))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                }
            }

            // Calendar dates
            HStack {
                ForEach(weekDates, id: \.self) { date in
                    let activityStatus = viewModel.status(for: date)

                    let dayColor: Color = {
                        switch activityStatus {
                        case .learned:
                            return Color("orange")
                        case .frozen:
                            return Color("blue")
                        case nil:
                            return .clear
                        }
                    }()

                    Text(date.formatted(.dateTime.day()))
                        .font(.system(size: 14))
                        .foregroundStyle(
                            dayColor == .clear ? Color("orange") : .white
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background {
                            Circle().fill(dayColor)
                        }
                }
            }

            // Statistics cards
            HStack(spacing: 10) {
                statCard(
                    icon: "flame.fill",
                    count: viewModel.learnedDays,
                    title: "Learned",
                    color: Color("orange")
                )

                statCard(
                    icon: "snowflake",
                    count: viewModel.frozenDays,
                    title: "Freezed",
                    color: Color("blue")
                )
            }

            Spacer()

            // Goal result message
            VStack(spacing: 12) {
                Image(systemName: isCompleted ? "hands.clap.fill" : "xmark.seal.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(
                        isCompleted ? Color.yellow : Color("orange")
                    )

                if isCompleted {
                    Text("Well done!")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)

                    Text("Ready for your next goal?")
                        .font(.system(size: 16))
                        .foregroundStyle(.gray)

                } else {
                    Text("You didn't reach your goal this time.")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)

                    Text("Want to set another goal?")
                        .font(.system(size: 16))
                        .foregroundStyle(.gray)
                }
            }
            .frame(maxWidth: .infinity)

            Spacer()

            // Set a goal button
            Button {
                onSetNewGoal()
            } label: {
                Label("Set a goal", systemImage: "pencil.circle")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 25)
                    .padding(.vertical, 18)
            }
            .buttonStyle(.glassProminent)
            .tint(Color("orange"))
            .frame(maxWidth: .infinity)

            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.top, 20)
        .padding(.bottom, 18)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black)
        .navigationBarBackButtonHidden(true)
    }

    // Statistics card
    private func statCard(
        icon: String,
        count: Int,
        title: String,
        color: Color
    ) -> some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(color)

            Text("\(count) \(count == 1 ? "Day" : "Days")")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)

            Text(title)
                .font(.system(size: 10))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 128)
        .glassEffect(
            .regular,
            in: RoundedRectangle(cornerRadius: 34)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 34)
                .stroke(Color.gray.opacity(0.35), lineWidth: 1)
        }
    }
}
