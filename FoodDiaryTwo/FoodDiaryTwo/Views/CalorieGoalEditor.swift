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
    @State private var proteinGoalText: String = ""
    @State private var carbsGoalText: String = ""
    @State private var fatGoalText: String = ""

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

                            // Macros (BJU) goals
                            HStack(spacing: PlumpyTheme.Spacing.medium) {
                                PlumpyField(
                                    title: LocalizationManager.shared.localizedString(.protein),
                                    placeholder: LocalizationManager.shared.localizedString(.protein),
                                    text: $proteinGoalText,
                                    keyboardType: .decimalPad,
                                    icon: "bolt.heart",
                                    iconColor: PlumpyTheme.secondaryAccent,
                                    isRequired: false
                                )
                                PlumpyField(
                                    title: LocalizationManager.shared.localizedString(.carbs),
                                    placeholder: LocalizationManager.shared.localizedString(.carbs),
                                    text: $carbsGoalText,
                                    keyboardType: .decimalPad,
                                    icon: "leaf",
                                    iconColor: PlumpyTheme.primaryAccent,
                                    isRequired: false
                                )
                                PlumpyField(
                                    title: LocalizationManager.shared.localizedString(.fat),
                                    placeholder: LocalizationManager.shared.localizedString(.fat),
                                    text: $fatGoalText,
                                    keyboardType: .decimalPad,
                                    icon: "drop",
                                    iconColor: PlumpyTheme.tertiaryAccent,
                                    isRequired: false
                                )
                            }
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
            proteinGoalText = String(format: "%.0f", DailyGoalsService.shared.getDailyProteinGoal(from: modelContext))
            carbsGoalText = String(format: "%.0f", DailyGoalsService.shared.getDailyCarbsGoal(from: modelContext))
            fatGoalText = String(format: "%.0f", DailyGoalsService.shared.getDailyFatGoal(from: modelContext))
        }
    }

    private func save() {
        guard let goal = Int(calorieGoalText), goal > 800, goal < 10000 else { return }
        if let u = users.first {
            u.updateDailyCalorieGoal(goal)
            if let p = Double(proteinGoalText), p > 0 { u.dailyProteinGoal = p }
            if let c = Double(carbsGoalText), c > 0 { u.dailyCarbsGoal = c }
            if let f = Double(fatGoalText), f > 0 { u.dailyFatGoal = f }
            try? modelContext.save()
        }
        dismiss()
    }
}

#Preview {
    CalorieGoalEditor()
        .modelContainer(for: [UserProfile.self], inMemory: true)
}


