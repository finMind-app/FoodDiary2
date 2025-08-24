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
                    title: "Daily Calories",
                    leftButton: PlumpyNavigationButton(icon: "xmark", title: "Close", style: .outline) {
                        dismiss()
                    },
                    rightButton: PlumpyNavigationButton(icon: "checkmark", title: "Save", style: .primary) {
                        save()
                    }
                )

                ScrollView {
                    VStack(spacing: PlumpyTheme.Spacing.large) {
                        VStack(spacing: PlumpyTheme.Spacing.medium) {
                            Text("Set your daily calorie target")
                                .font(PlumpyTheme.Typography.subheadline)
                                .foregroundColor(PlumpyTheme.textSecondary)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            PlumpyField(
                                title: "Daily Calories",
                                placeholder: "e.g. 2200",
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


