//
//  EditLearningGoalView.swift
//  LearningTracker
//
//  Created by Fay Alabdulqader on 12/11/2026.
//


import SwiftUI

struct EditLearningGoalView: View {

    @Environment(\.dismiss) private var dismiss

    @State private var learningGoal: String
    @State private var selectedDuration: String
    @State private var showingConfirmation = false

    let onSave: (LearningGoal) -> Void

    init(
        existingGoal: LearningGoal,
        onSave: @escaping (LearningGoal) -> Void
    ) {
        _learningGoal = State(initialValue: existingGoal.subject)
        _selectedDuration = State(initialValue: existingGoal.duration)
        self.onSave = onSave
    }

    private var trimmedGoal: String {
        learningGoal.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Header
            ZStack {
                Text("Learning Goal")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)

                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18))
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .glassEffect(.regular.interactive(), in: Circle())
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    Button {
                        showingConfirmation = true
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .glassEffect(
                                .regular.tint(Color("orange")).interactive(),
                                in: Circle()
                            )
                    }
                    .buttonStyle(.plain)
                    .disabled(trimmedGoal.isEmpty)
                }
            }

            GoalForm(learningGoal: $learningGoal, selectedDuration: $selectedDuration)
                .padding(.top, 46)

            Spacer()
        }
        .padding(.horizontal, 17)
        .padding(.top, 54)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.ignoresSafeArea())
        .ignoresSafeArea(edges: .top)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .alert("Update goal", isPresented: $showingConfirmation) {
            Button("Dismiss", role: .cancel) { }

            Button("Update") {
                onSave(LearningGoal(subject: trimmedGoal, duration: selectedDuration))
                dismiss()
            }
        } message: {
            Text("If you update now, your streak will start over.")
        }
    }
}
