//
//  CalorieGoalEditor.swift
//  FoodDiaryTwo
//

import SwiftUI
import SwiftData

struct CalorieGoalEditor: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [UserProfile]

    @State private var calorieGoalText: String = ""

    var body: some View {
        ZStack {
            PlumpyBackground(style: .primary)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                PlumpyNavigationBar(
                    title: LocalizationManager.shared.localizedString(.dailyCaloriesTitle),
                    leftButton: PlumpyNavigationButton(icon: "xmark", title: LocalizationManager.shared.localizedString(.close), style: .outline) {
                        dismiss()
                    },
                    rightButton: PlumpyNavigationButton(icon: "checkmark", title: LocalizationManager.shared.localizedString(.save), style: .primary) {
                        save()
                    }
                )

                ScrollView {
                    VStack(spacing: PlumpyTheme.Spacing.large) {
                        VStack(spacing: PlumpyTheme.Spacing.medium) {
                            Text(LocalizationManager.shared.localizedString(.setDailyCalorieTarget))
                                .font(PlumpyTheme.Typography.subheadline)
                                .foregroundColor(PlumpyTheme.textSecondary)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            PlumpyField(
                                title: LocalizationManager.shared.localizedString(.dailyCaloriesTitle),
                                placeholder: LocalizationManager.shared.localizedString(.exampleCalories),
                                text: $calorieGoalText,
                                keyboardType: .numberPad,
                                icon: "flame.fill",
                                iconColor: PlumpyTheme.warning,
                                isRequired: true
                            )
                        }
                        .plumpyCard()
                        
                        PlumpySpacer(size: .huge)
                    }
                    .padding(.horizontal, PlumpyTheme.Spacing.medium)
                    .padding(.top, PlumpyTheme.Spacing.medium)
                }
            }
        }
        .onAppear {
            calorieGoalText = String(DailyGoalsService.shared.getDailyCalorieGoal(from: modelContext))
        }
    }

    private func save() {
        guard let goal = Int(calorieGoalText), goal > 800, goal < 10000 else { return }
        if let u = users.first {
            u.updateDailyCalorieGoal(goal)
            try? modelContext.save()
        }
        dismiss()
    }
}

#Preview {
    CalorieGoalEditor()
        .modelContainer(for: [UserProfile.self], inMemory: true)
}


