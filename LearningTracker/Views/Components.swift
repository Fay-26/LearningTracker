
//
//  Components.swift
//  LearningTracker
//
//  Created by Fay Alabdulqader on 14/11/2026.
//

import SwiftUI


func headerDateString(_ date: Date = .now) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_GB")
    formatter.dateFormat = "EEEE, d MMMM"
    return formatter.string(from: date)
}

// MARK: - Round glass icon (45pt)

struct GlassIcon: View {

    let systemName: String

    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: 20))
            .foregroundStyle(.white)
            .frame(width: 45, height: 45)
            .glassEffect(.regular.interactive(), in: Circle())
    }
}

// MARK: - Orange capsule button label (Start Learning / Set a goal)

struct OrangeButtonLabel: View {

    let title: String
    var systemImage: String? = nil
    var height: CGFloat = 45
    var horizontalPadding: CGFloat = 25

    var body: some View {
        HStack(spacing: 6) {
            if let systemImage {
                Image(systemName: systemImage)
            }
            Text(title)
        }
        .font(.system(size: 16, weight: .semibold))
        .foregroundStyle(.white)
        .padding(.horizontal, horizontalPadding)
        .frame(height: height)
        .glassEffect(.regular.tint(Color("apporange")).interactive(), in: Capsule())
    }
}

// MARK: - Day circle

/// learned = translucent orange, frozen = translucent blue,
/// today (not logged) = solid orange, other days = plain white number
struct DayCircle: View {

    let date: Date
    let status: ActivityStatus?
    var size: CGFloat = 43
    var fontSize: CGFloat = 18

    // The app's "today" (follows the Debug Panel clock when passed in)
    var today: Date = Date()

    private var isToday: Bool {
        Calendar.current.isDate(date, inSameDayAs: today)
    }

    private var circleColor: Color {
        switch status {
        case .learned: return Color("apporange").opacity(0.25)
        case .frozen:  return Color("appblue").opacity(0.25)
        case nil:      return isToday ? Color("apporange") : .clear
        }
    }

    private var textColor: Color {
        switch status {
        case .learned: return Color("apporange")
        case .frozen:  return Color("appblue")
        case nil:      return .white
        }
    }

    var body: some View {
        Text(date.formatted(.dateTime.day()))
            .font(.system(size: fontSize))
            .foregroundStyle(textColor)
            .frame(width: size, height: size)
            .background(Circle().fill(circleColor))
    }
}

// MARK: - Week strip (S M T W T F S + dates)

struct WeekStripView: View {

    @ObservedObject var viewModel: ActivityViewModel

    private let weekdays = ["S", "M", "T", "W", "T", "F", "S"]

    private var weekDates: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: viewModel.currentDate)

        guard let week = calendar.dateInterval(of: .weekOfYear, for: today) else {
            return [today]
        }

        return (0..<7).compactMap {
            calendar.date(byAdding: .day, value: $0, to: week.start)
        }
    }

    var body: some View {
        VStack(spacing: 8.5) {
            HStack(spacing: 0) {
                ForEach(0..<7, id: \.self) { index in
                    Text(weekdays[index])
                        .font(.system(size: 12))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                }
            }

            HStack(spacing: 0) {
                ForEach(weekDates, id: \.self) { date in
                    DayCircle(
                        date: date,
                        status: viewModel.status(for: date),
                        today: viewModel.currentDate
                    )
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }
}

// MARK: - Stat cards

struct StatCard: View {

    let icon: String
    let count: Int
    let title: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(color)

            Text("\(count) \(count == 1 ? "day" : "days")")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)

            Text(title)
                .font(.system(size: 12))
                .foregroundStyle(.white.opacity(0.75))
        }
        .frame(maxWidth: .infinity)
        .frame(height: 101)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 32))
    }
}

struct StatCards: View {

    @ObservedObject var viewModel: ActivityViewModel

    var body: some View {
        HStack(spacing: 13) {
            StatCard(
                icon: "flame.fill",
                count: viewModel.learnedDays,
                title: "Learned",
                color: Color("apporange")
            )

            StatCard(
                icon: "snowflake",
                count: viewModel.frozenDays,
                title: "Freezed",
                color: Color("appblue")
            )
        }
    }
}

// MARK: - Header: "Activity" + date (left) and the two icons (right)

struct ActivityHeader<Trailing: View>: View {

    // The date shown under "Activity" (the app's clock when passed in)
    var date: Date = Date()

    @ViewBuilder let trailing: () -> Trailing

    var body: some View {
        HStack(alignment: .top, spacing: 13) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Activity")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(.white)

                Text(headerDateString(date))
                    .font(.system(size: 16))
                    .foregroundStyle(.gray)
            }

            Spacer()

            trailing()
        }
        .padding(.horizontal, 10)
    }
}

// MARK: - Goal form (text field + Week / Month / Year)
// Used by Onboarding and Edit goal

struct GoalForm: View {

    @Binding var learningGoal: String
    @Binding var selectedDuration: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            Text("I want to learn")
                .font(.system(size: 16))
                .foregroundStyle(.white)

            TextField(
                "",
                text: $learningGoal,
                prompt: Text("Enter your learning goal").foregroundColor(.gray)
            )
            .font(.system(size: 16))
            .foregroundStyle(.white)
            .tint(Color("apporange"))
            .padding(.vertical, 11)
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(Color.gray.opacity(0.25))
                    .frame(height: 1)
            }
            .padding(.top, 10)

            Text("I want to learn it in a")
                .font(.system(size: 16))
                .foregroundStyle(.white)
                .padding(.top, 31)

            HStack(spacing: 10) {
                ForEach(["Week", "Month", "Year"], id: \.self) { duration in
                    let isSelected = selectedDuration == duration

                    Button {
                        selectedDuration = duration
                    } label: {
                        Text(duration)
                            .font(.system(size: 16))
                            .foregroundStyle(isSelected ? .white : .gray)
                            .padding(.horizontal, 22)
                            .padding(.vertical, 12)
                            .glassEffect(
                                isSelected
                                ? .regular.tint(Color("apporange")).interactive()
                                : .regular.interactive(),
                                in: Capsule()
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top, 16)
        }
    }
}
