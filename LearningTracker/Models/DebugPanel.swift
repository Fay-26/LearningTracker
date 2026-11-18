//
//  DebugPanel.swift
//  LearningTracker
//
//  Created by Fay Alabdulqader on 18/11/2026.
//


import SwiftUI
import Combine

// Controls the simulated date during debugging
final class DebugClock: ObservableObject {

    @Published var currentDate = Date()

    func advance(by seconds: TimeInterval) {
        currentDate = currentDate.addingTimeInterval(seconds)
    }

    func reset() {
        currentDate = Date()
    }
}

// Debug panel
struct DebugPanelView: View {

    @ObservedObject var clock: DebugClock
    @ObservedObject var viewModel: ActivityViewModel

    @Environment(\.dismiss) private var dismiss

    var body: some View {

        NavigationStack {

            List {

                Section("Current Goal") {

                    LabeledContent(
                        "Subject",
                        value: viewModel.learningGoal.subject
                    )

                    LabeledContent(
                        "Duration",
                        value: viewModel.learningGoal.duration
                    )

                    LabeledContent(
                        "Learned Days",
                        value: "\(viewModel.learnedDays)"
                    )

                    LabeledContent(
                        "Frozen Days",
                        value: "\(viewModel.frozenDays)"
                    )

                    LabeledContent(
                        "Current Streak",
                        value: "\(viewModel.currentStreak)"
                    )
                }

                Section("Simulated Time") {

                    LabeledContent(
                        "Current Date",
                        value: clock.currentDate.formatted(
                            date: .abbreviated,
                            time: .shortened
                        )
                    )

                    Button("+1 Hour") {
                        clock.advance(by: 60 * 60)
                        viewModel.refresh()
                    }

                    Button("+1 Day") {
                        clock.advance(by: 24 * 60 * 60)
                        viewModel.refresh()
                    }

                    Button("+33 Hours (Test Streak)") {
                        clock.advance(by: 33 * 60 * 60)
                        viewModel.refresh()
                    }

                    Button("Complete Goal Period") {
                        let seconds = viewModel.goalEndDate
                            .timeIntervalSince(clock.currentDate)

                        clock.advance(by: max(0, seconds))
                        viewModel.refresh()
                    }

                    Button("Reset Date") {
                        clock.reset()
                        viewModel.refresh()
                    }
                }

                Section("Activity Testing") {

                    Button("Log as Learned") {
                        viewModel.logAsLearned()
                    }

                    Button("Freeze Day") {
                        viewModel.freezeDay()
                    }

                    Button("Refresh ViewModel") {
                        viewModel.refresh()
                    }
                }

                Section("Goal Information") {

                    LabeledContent(
                        "Goal Start",
                        value: viewModel.goalStartDate.formatted(
                            date: .abbreviated,
                            time: .omitted
                        )
                    )

                    LabeledContent(
                        "Goal End",
                        value: viewModel.goalEndDate.formatted(
                            date: .abbreviated,
                            time: .omitted
                        )
                    )

                    LabeledContent(
                        "Freezes Used",
                        value: "\(viewModel.freezesUsed) / \(viewModel.maximumFreezes)"
                    )

                    LabeledContent(
                        "Goal Finished",
                        value: viewModel.isGoalPeriodFinished ? "Yes" : "No"
                    )

                    LabeledContent(
                        "Goal Completed",
                        value: viewModel.isGoalCompleted ? "Yes" : "No"
                    )

                    LabeledContent(
                        "Previous Goals",
                        value: "\(viewModel.goalHistory.count)"
                    )
                }
            }
            .navigationTitle("Debug Panel")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// Opens the debug panel with a long press
struct DebugPanelTrigger: ViewModifier {

    @ObservedObject var clock: DebugClock
    @ObservedObject var viewModel: ActivityViewModel

    @State private var showingDebugPanel = false

    func body(content: Content) -> some View {

        #if DEBUG
        content
            .onLongPressGesture(minimumDuration: 1) {
                showingDebugPanel = true
            }
            .sheet(isPresented: $showingDebugPanel) {
                DebugPanelView(
                    clock: clock,
                    viewModel: viewModel
                )
            }
        #else
        content
        #endif
    }
}
