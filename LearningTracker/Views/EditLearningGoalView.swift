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

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Header
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18))
                        .foregroundStyle(.white)
                        .padding(10)
                        .glassEffect(.regular, in: Circle())
                }
                .buttonStyle(.plain)

                Spacer()

                Text("Learning Goal")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)

                Spacer()

                Button {
                    showingConfirmation = true
                } label: {
                    Image(systemName: "checkmark")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(10)
                        .glassEffect(
                            .regular.tint(Color("orange")),
                            in: Circle()
                        )
                }
                .buttonStyle(.plain)
                .disabled(learningGoal.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(.bottom, 35)

            // Learning goal
            Text("I want to learn")
                .font(.system(size: 14))
                .foregroundStyle(.white)

            TextField("", text: $learningGoal,
                prompt: Text("Enter your goal").foregroundColor(.gray))
                .font(.system(size: 16))
                .foregroundStyle(.white)
                .tint(Color("orange"))
                .padding(.vertical, 12)
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.25))
                        .frame(height: 1)
                }

            // Duration
            Text("I want to learn it in a")
                .font(.system(size: 14))
                .foregroundStyle(.white)
                .padding(.top, 30)
                .padding(.bottom, 15)

            HStack(spacing: 10) {
                ForEach(["Week", "Month", "Year"], id: \.self) { duration in
                    Button {
                        selectedDuration = duration
                    } label: {
                        Text(duration)
                            .font(.system(size: 14))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .glassEffect(
                                selectedDuration == duration
                                ? .regular.tint(Color("orange"))
                                : .regular,
                                in: Capsule()
                            )
                    }
                    .buttonStyle(.plain)
                }
            }

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 15)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .navigationBarBackButtonHidden(true)
        .alert("Update goal", isPresented: $showingConfirmation) {
            Button("Dismiss", role: .cancel) { }

            Button("Update") {
                let updatedGoal = LearningGoal(
                    subject: learningGoal.trimmingCharacters(in: .whitespaces),
                    duration: selectedDuration
                )

                onSave(updatedGoal)
                dismiss()
            }
        } message: {
            Text("If you update now, your streak will start over.")
        }
    }
}
