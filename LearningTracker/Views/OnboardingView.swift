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

        ZStack {

            // Background
            Color(.systemBackground)
                .ignoresSafeArea()

            // Main content
            VStack(alignment: .leading, spacing: 0) {

                // App logo
                HStack {
                    Spacer()

                    Image(systemName: "flame.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(Color("orange"))

                    Spacer()
                }
                .padding(.bottom, 40)

                // Greeting
                HStack(spacing: 0) {
                    Text("Hello ")
                        .fontWeight(.regular)

                    Text("Learner")
                        .fontWeight(.bold)
                }
                .font(.system(size: 35))
                .foregroundStyle(.white)

                // Subtitle
                Text("This app will help you learn everyday!")
                    .foregroundStyle(.gray)
                    .font(.system(size: 20))
                    .padding(.bottom, 30)

                // Learning goal label
                Text("I want to learn")
                    .font(.system(size: 18))
                    .foregroundStyle(.white)

                // Learning goal input
                TextField(
                    "",
                    text: $viewModel.learningGoal,
                    prompt: Text("Enter your goal")
                        .foregroundColor(.gray)
                )
                .font(.system(size: 18))
                .foregroundStyle(.white)
                .tint(Color("orange"))
                .padding(.vertical, 10)
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.25))
                        .frame(height: 1)
                }

                // Duration label
                Text("I want to learn it in a")
                    .font(.system(size: 18))
                    .foregroundStyle(.white)
                    .padding(.top, 25)
                    .padding(.bottom, 12)

                // Duration buttons
                HStack(spacing: 10) {
                    ForEach(["Week", "Month", "Year"], id: \.self) { duration in

                        Button {
                            viewModel.selectedDuration = duration
                        } label: {
                            Text(duration)
                                .font(.system(size: 18))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .glassEffect(
                                    viewModel.selectedDuration == duration
                                    ? .regular.tint(Color("orange"))
                                    : .regular,
                                    in: Capsule()
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }

                Spacer()

                // Save or Start button
                if onSave != nil {

                    Button {
                        onSave?(viewModel.createGoal())
                        dismiss()
                    } label: {
                        Text("Set a goal")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 18)
                    }
                    .buttonStyle(.glassProminent)
                    .tint(Color("orange"))
                    .frame(maxWidth: .infinity)
                    .disabled(!hasValidGoal)

                } else {

                    NavigationLink {
                        ActivityView(
                            learningGoal: viewModel.createGoal()
                        )
                    } label: {
                        Text("Start Learning")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 18)
                    }
                    .buttonStyle(.glassProminent)
                    .tint(Color("orange"))
                    .frame(maxWidth: .infinity)
                    .disabled(!hasValidGoal)
                }

                // Bottom subtitle
                Text("You can edit your desire later")
                    .font(.system(size: 16))
                    .foregroundStyle(.gray)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 12)
            }
            .padding(.horizontal, 30)
            .padding(.top, 50)
            .padding(.bottom, 40)
        }
    }
}

#Preview {
    NavigationStack {
        OnboardingView()
    }
    .preferredColorScheme(.dark)
}
