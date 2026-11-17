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
    var onOpenCalendar: () -> Void = {}
    var onEditGoal: () -> Void = {}

    var body: some View {
        VStack(spacing: 0) {

            // Header
            ActivityHeader {

                Button {
                    onOpenCalendar()
                } label: {
                    GlassIcon(systemName: "calendar")
                }

                Button {
                    onEditGoal()
                } label: {
                    GlassIcon(systemName: "pencil.and.outline")
                }
            }

            WeekStripView(viewModel: viewModel)
                .padding(.top, 19)

            StatCards(viewModel: viewModel)
                .padding(.horizontal, 7)
                .padding(.top, 15)

            // Result message
            Image(systemName: isCompleted ? "hands.clap.fill" : "xmark.seal.fill")
                .font(.system(size: 46))
                .foregroundStyle(Color("apporange"))
                .padding(.top, 69)

            Text(isCompleted ? "Well done!" : "You didn't reach your goal this time.")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .padding(.top, 22)

            Text(isCompleted ? "Ready for your next goal?" : "Want to set another goal?")
                .font(.system(size: 12))
                .foregroundStyle(.gray)
                .padding(.top, 8)

            // Set a goal
            Button {
                onSetNewGoal()
            } label: {
                OrangeButtonLabel(
                    title: "Set a goal",
                    systemImage: "pencil.and.outline",
                    height: 50,
                    horizontalPadding: 22
                )
            }
            .buttonStyle(.plain)
            .padding(.top, 76)

            Spacer()
        }
        .padding(.horizontal, 7)
        .padding(.top, 65)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(edges: .top)
    }
}

#Preview("Goal Completed") {
    let viewModel = ActivityViewModel(
        learningGoal: LearningGoal(
            subject: "SwiftUI",
            duration: "Week"
        )
    )

    GoalResultView(
        viewModel: viewModel,
        isCompleted: true,
        onSetNewGoal: {}
    )
}

#Preview("Goal Not Completed") {
    let viewModel = ActivityViewModel(
        learningGoal: LearningGoal(
            subject: "SwiftUI",
            duration: "Week"
        )
    )

    GoalResultView(
        viewModel: viewModel,
        isCompleted: false,
        onSetNewGoal: {}
    )
}

private enum GoalResultDebugSheet: String, Identifiable {
    case calendar
    case editGoal
    case onboarding

    var id: String { rawValue }
}

private struct GoalResultDebugPreview: View {

    @StateObject private var viewModel = ActivityViewModel(
        learningGoal: LearningGoal(
            subject: "SwiftUI",
            duration: "Week"
        )
    )

    @State private var activeSheet: GoalResultDebugSheet?

    var body: some View {

        GoalResultView(
            viewModel: viewModel,
            isCompleted: true,
            onSetNewGoal: {
                activeSheet = .onboarding
            },
            onOpenCalendar: {
                activeSheet = .calendar
            },
            onEditGoal: {
                activeSheet = .editGoal
            }
        )
        .sheet(item: $activeSheet) { sheet in

            switch sheet {

            case .calendar:
                CalendarView(viewModel: viewModel)

            case .editGoal:
                EditLearningGoalView(
                    existingGoal: viewModel.learningGoal,
                    onSave: { _ in }
                )

            case .onboarding:
                OnboardingView()
            }
        }
    }
}

#Preview("Test Goal Result Buttons") {
    GoalResultDebugPreview()
}
