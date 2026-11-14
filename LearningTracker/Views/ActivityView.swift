//
//  ActivityView.swift
//  LearningTracker
//
//  Created by Fay Alabdulqader on 10/11/2026.
//



import SwiftUI
import Combine

struct ActivityView: View {

    @StateObject private var viewModel: ActivityViewModel

    @Environment(\.scenePhase) private var scenePhase

    @State private var showingGoalEditor = false
    @State private var showingNewGoal = false

    private let refreshTimer = Timer.publish(
        every: 60,
        on: .main,
        in: .common
    ).autoconnect()

    private let weekdays = ["S", "M", "T", "W", "T", "F", "S"]

    init(learningGoal: LearningGoal) {
        _viewModel = StateObject(
            wrappedValue: ActivityViewModel(learningGoal: learningGoal)
        )
    }

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
        Group {
            if viewModel.isGoalPeriodFinished {
                GoalResultView(
                    viewModel: viewModel,
                    isCompleted: viewModel.isGoalCompleted
                ) {
                    showingNewGoal = true
                }
            } else {
                activityContent
            }
        }
        .navigationBarBackButtonHidden(true)
        .onReceive(refreshTimer) { _ in
            viewModel.refresh()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                viewModel.refresh()
            }
        }

        // Edit learning goal
        .sheet(isPresented: $showingGoalEditor) {
            NavigationStack {
                EditLearningGoalView(
                    existingGoal: viewModel.learningGoal
                ) { updatedGoal in
                    viewModel.updateLearningGoal(updatedGoal)
                }
            }
            .preferredColorScheme(.dark)
        }

        // Set a new goal
        .sheet(isPresented: $showingNewGoal) {
            NavigationStack {
                OnboardingView { newGoal in
                    viewModel.updateLearningGoal(newGoal)
                }
            }
            .preferredColorScheme(.dark)
        }
    }

    private var activityContent: some View {
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

                // Calendar button
                NavigationLink {
                    CalendarView(viewModel: viewModel)
                } label: {
                    Image(systemName: "calendar")
                        .font(.system(size: 20))
                        .foregroundStyle(.white)
                        .padding(10)
                        .glassEffect(.regular, in: Circle())
                }
                .buttonStyle(.plain)

                // Edit goal button
                Button {
                    showingGoalEditor = true
                } label: {
                    Image(systemName: "pencil")
                        .font(.system(size: 20))
                        .foregroundStyle(.white)
                        .padding(10)
                        .glassEffect(.regular, in: Circle())
                }
                .buttonStyle(.plain)
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
                    title: "Frozen",
                    color: Color("blue")
                )
            }

            Spacer()

            // Log as Learned button
            Button {
                viewModel.logAsLearned()
            } label: {
                Text(
                    viewModel.hasLearnedToday
                    ? "Logged as Learned"
                    : "Log as Learned"
                )
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 260, height: 260)
                .background(
                    viewModel.hasLearnedToday
                    ? Color.gray.opacity(0.25)
                    : Color("orange")
                )
                .clipShape(Circle())
            }
            .disabled(viewModel.hasLearnedToday || viewModel.hasFrozenToday)
            .frame(maxWidth: .infinity)

            Spacer()

            // Freeze button
            Button {
                viewModel.freezeDay()
            } label: {
                Text(
                    viewModel.hasFrozenToday
                    ? "Frozen for a day"
                    : "Freeze for a day"
                )
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 260, height: 44)
                .glassEffect(
                    viewModel.canFreeze
                    ? .regular.tint(Color("blue"))
                    : .regular,
                    in: Capsule()
                )
            }
            .disabled(!viewModel.canFreeze)
            .frame(maxWidth: .infinity)

            // Freeze usage
            Text("\(viewModel.freezesUsed) out of \(viewModel.maximumFreezes) Freezes used")
                .font(.system(size: 12))
                .foregroundStyle(.gray)
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 12)
        .padding(.top, 20)
        .padding(.bottom, 18)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.background)
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
                .foregroundStyle(.gray)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 98)
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

#Preview {
    NavigationStack {
        ActivityView(
            learningGoal: LearningGoal(
                subject: "Swift",
                duration: "Week"
            )
        )
    }
    .preferredColorScheme(.dark)
}
