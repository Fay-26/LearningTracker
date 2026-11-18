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
    @StateObject private var clock: DebugClock

    @Environment(\.scenePhase) private var scenePhase

    @State private var showingGoalEditor = false
    @State private var showingNewGoal = false
    @State private var showingCalendar = false

    private let refreshTimer = Timer.publish(
        every: 60,
        on: .main,
        in: .common
    ).autoconnect()

    init(learningGoal: LearningGoal) {

        let debugClock = DebugClock()

        _clock = StateObject(
            wrappedValue: debugClock
        )

        _viewModel = StateObject(
            wrappedValue: ActivityViewModel(
                learningGoal: learningGoal,
                now: { debugClock.currentDate }
            )
        )
    }

    var body: some View {

        Group {

            if viewModel.isGoalPeriodFinished {

                GoalResultView(
                    viewModel: viewModel,
                    isCompleted: viewModel.isGoalCompleted,
                    onSetNewGoal: {
                        showingNewGoal = true
                    },
                    onOpenCalendar: {
                        showingCalendar = true
                    },
                    onEditGoal: {
                        showingGoalEditor = true
                    }
                )

            } else {

                activityContent
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)

        .onReceive(refreshTimer) { _ in
            viewModel.refresh()
        }

        .onChange(of: scenePhase) { _, newPhase in

            if newPhase == .active {
                viewModel.refresh()
            }
        }

        // Edit learning goal
        .navigationDestination(isPresented: $showingGoalEditor) {

            EditLearningGoalView(
                existingGoal: viewModel.learningGoal
            ) { updatedGoal in

                viewModel.updateLearningGoal(updatedGoal)
            }
        }

        .navigationDestination(isPresented: $showingCalendar) {
            CalendarView(viewModel: viewModel)
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

    private var freezeTitle: String {

        let noFreezesLeft = viewModel.freezesUsed >= viewModel.maximumFreezes

        return (viewModel.hasFrozenToday || noFreezesLeft)
            ? "Freezed for a day"
            : "Freeze for a day"
    }

    private var activityContent: some View {

        VStack(spacing: 0) {

            // Header
            ActivityHeader {

                NavigationLink {
                    CalendarView(viewModel: viewModel)
                } label: {
                    GlassIcon(systemName: "calendar")
                }
                .buttonStyle(.plain)

                Button {
                    showingGoalEditor = true
                } label: {
                    GlassIcon(systemName: "pencil.and.outline")
                }
                .buttonStyle(.plain)
            }

            WeekStripView(viewModel: viewModel)
                .padding(.top, 19)

            StatCards(viewModel: viewModel)
                .padding(.horizontal, 7)
                .padding(.top, 15)

            Spacer()

            // Log as Learned
            Button {

                viewModel.logAsLearned()

            } label: {

                Text(
                    viewModel.hasLearnedToday
                        ? "Logged as Learned"
                        : "Log as Learned"
                )
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(
                    viewModel.hasLearnedToday ? .gray : .white
                )
                .frame(width: 277, height: 277)
                .glassEffect(
                    viewModel.hasLearnedToday
                        ? .regular
                        : .regular.tint(Color("apporange")).interactive(),
                    in: Circle()
                )
            }
            .buttonStyle(.plain)
            .disabled(viewModel.hasLearnedToday || viewModel.hasFrozenToday)

            Spacer()

            // Freeze
            Button {

                viewModel.freezeDay()

            } label: {

                Text(freezeTitle)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(viewModel.canFreeze ? .white : .gray)
                    .frame(width: 277, height: 46)
                    .glassEffect(
                        viewModel.canFreeze
                            ? .regular.tint(Color("appblue")).interactive()
                            : .regular,
                        in: Capsule()
                    )
            }
            .buttonStyle(.plain)
            .disabled(!viewModel.canFreeze)

            Text(
                "\(viewModel.freezesUsed) out of \(viewModel.maximumFreezes) Freezes used"
            )
            .font(.system(size: 14))
            .foregroundStyle(.gray)
            .padding(.top, 18)
        }
        .padding(.horizontal, 7)
        .padding(.top, 65)
        .padding(.bottom, 49)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(edges: .top)

        // Long press to open Debug Panel
        .modifier(
            DebugPanelTrigger(
                clock: clock,
                viewModel: viewModel
            )
        )
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
