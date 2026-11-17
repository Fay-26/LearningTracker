//
//  OnboardingView.swift
//  LearningTracker
//
//  Created by Fay Alabdulqader on 10/11/2026.
//

import SwiftUI

struct OnboardingView: View {

    @StateObject private var viewModel: OnboardingViewModel

    @Environment(\.dismiss) private var dismiss

    private let onSave: ((LearningGoal) -> Void)?

    init(
        existingGoal: LearningGoal? = nil,
        onSave: ((LearningGoal) -> Void)? = nil
    ) {
        _viewModel = StateObject(
            wrappedValue: OnboardingViewModel(existingGoal: existingGoal)
        )
        self.onSave = onSave
    }

    private var hasValidGoal: Bool {
        !viewModel.learningGoal.trimmingCharacters(
            in: .whitespacesAndNewlines
        ).isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Logo
            Image(systemName: "flame.fill")
                .font(.system(size: 40))
                .foregroundStyle(Color("apporange"))
                .frame(maxWidth: .infinity, minHeight: 40)
                .padding(.bottom, 86)

            // Greeting
            HStack(spacing: 0) {
                Text("Hello ").fontWeight(.regular)
                Text("Learner").fontWeight(.bold)
            }
            .font(.system(size: 34))
            .foregroundStyle(.white)

            Text("This app will help you learn everyday!")
                .font(.system(size: 17))
                .foregroundStyle(.gray)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(.top, 2)
                .padding(.bottom, 36)

            GoalForm(
                learningGoal: $viewModel.learningGoal,
                selectedDuration: $viewModel.selectedDuration
            )

            Spacer()

            // Save (sheet) or Start (first launch)
            Group {
                if onSave != nil {
                    Button {
                        onSave?(viewModel.createGoal())
                        dismiss()
                    } label: {
                        OrangeButtonLabel(title: "Set a goal")
                    }
                } else {
                    NavigationLink {
                        ActivityView(learningGoal: viewModel.createGoal())
                    } label: {
                        OrangeButtonLabel(title: "Start Learning")
                    }
                }
            }
            .buttonStyle(.plain)
            .disabled(!hasValidGoal)
            .opacity(hasValidGoal ? 1 : 0.5)
            .frame(maxWidth: .infinity)

            Text("You can edit your desire later")
                .font(.system(size: 12))
                .foregroundStyle(.gray)
                .frame(maxWidth: .infinity)
                .padding(.top, 14)
        }
        .padding(.horizontal, 17)
        .padding(.top, 124)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.ignoresSafeArea())
        .ignoresSafeArea(edges: .top)
        .ignoresSafeArea(.keyboard)
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        OnboardingView()
    }
    .preferredColorScheme(.dark)
}
