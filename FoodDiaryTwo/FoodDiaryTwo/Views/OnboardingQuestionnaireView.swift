//
//  OnboardingQuestionnaireView.swift
//  FoodDiaryTwo
//

import SwiftUI
import SwiftData

struct OnboardingQuestionnaireView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [UserProfile]

    @State private var name: String = ""
    @State private var age: String = "28"
    @State private var gender: Gender = .male
    @State private var height: String = "175"
    @State private var weight: String = "70"
    @State private var activity: ActivityLevel = .moderate
    @State private var goal: Goal = .maintain
    @State private var customCalories: String = ""

    var body: some View {
        ZStack {
            PlumpyBackground(style: .primary)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                PlumpyNavigationBar(
                    title: LocalizationManager.shared.localizedString(.questionnaireTitle),
                    leftButton: PlumpyNavigationButton(icon: "xmark", title: LocalizationManager.shared.localizedString(.skip), style: .outline) {
                        dismiss()
                    },
                    rightButton: PlumpyNavigationButton(icon: "checkmark", title: LocalizationManager.shared.localizedString(.save), style: .primary) {
                        save()
                    }
                )

                ScrollView {
                    VStack(spacing: PlumpyTheme.Spacing.medium) {
                        PlumpyField(title: LocalizationManager.shared.localizedString(.userName), placeholder: LocalizationManager.shared.localizedString(.userName), text: $name, icon: "person", isRequired: true)
                        PlumpyField(title: LocalizationManager.shared.localizedString(.ageLabel), placeholder: LocalizationManager.shared.localizedString(.years), text: $age, keyboardType: .numberPad, icon: "number", isRequired: true)
                        .overlay(
                            EmptyView()
                        )

                        pickerCard(title: LocalizationManager.shared.localizedString(.gender)) {
                            HStack(spacing: PlumpyTheme.Spacing.small) {
                                ForEach(Gender.allCases, id: \.self) { g in
                                    Button(action: {
                                        gender = g
                                    }) {
                                        Text(g.displayName)
                                            .font(PlumpyTheme.Typography.caption1)
                                            .fontWeight(.medium)
                                            .foregroundColor(gender == g ? PlumpyTheme.textInverse : PlumpyTheme.textPrimary)
                                            .multilineTextAlignment(.center)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.8)
                                            .padding(.horizontal, PlumpyTheme.Spacing.small)
                                            .padding(.vertical, PlumpyTheme.Spacing.small)
                                            .frame(height: 55) // Увеличил высоту для лучшей видимости
                                            .frame(maxWidth: .infinity)
                                            .background(
                                                RoundedRectangle(cornerRadius: PlumpyTheme.Radius.small)
                                                    .fill(gender == g ? PlumpyTheme.primaryAccent : PlumpyTheme.surfaceSecondary)
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: PlumpyTheme.Radius.small)
                                                    .stroke(gender == g ? PlumpyTheme.primaryAccent : PlumpyTheme.neutral200, lineWidth: 1)
                                            )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .animation(.easeInOut(duration: 0.2), value: gender)
                                }
                            }
                        }

                        HStack(spacing: PlumpyTheme.Spacing.medium) {
                            PlumpyField(title: LocalizationManager.shared.localizedString(.heightCm), placeholder: LocalizationManager.shared.localizedString(.heightCm), text: $height, keyboardType: .decimalPad, icon: "ruler", isRequired: true)
                            PlumpyField(title: LocalizationManager.shared.localizedString(.weightKg), placeholder: LocalizationManager.shared.localizedString(.weightKg), text: $weight, keyboardType: .decimalPad, icon: "scalemass", isRequired: true)
                        }

                        pickerCard(title: LocalizationManager.shared.localizedString(.activityLevel)) {
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: PlumpyTheme.Spacing.small), count: 2), spacing: PlumpyTheme.Spacing.small) {
                                ForEach(ActivityLevel.allCases, id: \.self) { level in
                                    Button(action: {
                                        activity = level
                                    }) {
                                        Text(level.shortName)
                                            .font(PlumpyTheme.Typography.caption1)
                                            .fontWeight(.medium)
                                            .foregroundColor(activity == level ? PlumpyTheme.textInverse : PlumpyTheme.textPrimary)
                                            .multilineTextAlignment(.center)
                                            .lineLimit(2)
                                            .minimumScaleFactor(0.8)
                                            .padding(.horizontal, PlumpyTheme.Spacing.tiny)
                                            .padding(.vertical, PlumpyTheme.Spacing.small)
                                            .frame(height: 55) // Увеличил высоту для лучшей видимости
                                            .frame(maxWidth: .infinity)
                                            .background(
                                                RoundedRectangle(cornerRadius: PlumpyTheme.Radius.small)
                                                    .fill(activity == level ? PlumpyTheme.primaryAccent : PlumpyTheme.surfaceSecondary)
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: PlumpyTheme.Radius.small)
                                                    .stroke(activity == level ? PlumpyTheme.primaryAccent : PlumpyTheme.neutral200, lineWidth: 1)
                                            )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .animation(.easeInOut(duration: 0.2), value: activity)
                                }
                            }
                            
                            // Показываем полное описание выбранного уровня активности
                            Text(activity.displayName)
                                .font(PlumpyTheme.Typography.caption1)
                                .foregroundColor(PlumpyTheme.textSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.top, PlumpyTheme.Spacing.small)
                                .animation(.easeInOut(duration: 0.3), value: activity)
                        }

                        pickerCard(title: LocalizationManager.shared.localizedString(.goal)) {
                            HStack(spacing: PlumpyTheme.Spacing.small) {
                                ForEach(Goal.allCases, id: \.self) { goalType in
                                    Button(action: {
                                        goal = goalType
                                    }) {
                                        Text(goalType.displayName)
                                            .font(PlumpyTheme.Typography.caption1)
                                            .fontWeight(.medium)
                                            .foregroundColor(goal == goalType ? PlumpyTheme.textInverse : PlumpyTheme.textPrimary)
                                            .multilineTextAlignment(.center)
                                            .lineLimit(2)
                                            .minimumScaleFactor(0.8)
                                            .padding(.horizontal, PlumpyTheme.Spacing.small)
                                            .padding(.vertical, PlumpyTheme.Spacing.small)
                                            .frame(height: 55) // Увеличил высоту для лучшей видимости
                                            .frame(maxWidth: .infinity)
                                            .background(
                                                RoundedRectangle(cornerRadius: PlumpyTheme.Radius.small)
                                                    .fill(goal == goalType ? PlumpyTheme.primaryAccent : PlumpyTheme.surfaceSecondary)
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: PlumpyTheme.Radius.small)
                                                    .stroke(goal == goalType ? PlumpyTheme.primaryAccent : PlumpyTheme.neutral200, lineWidth: 1)
                                            )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .animation(.easeInOut(duration: 0.2), value: goal)
                                }
                            }
                        }

                        PlumpyField(
                            title: LocalizationManager.shared.localizedString(.customOptional),
                            placeholder: LocalizationManager.shared.localizedString(.customOptional),
                            text: $customCalories,
                            keyboardType: .numberPad,
                            icon: "flame.fill",
                            iconColor: PlumpyTheme.warning,
                            isRequired: false
                        )

                        PlumpySpacer(size: .huge)
                    }
                    .padding(.horizontal, PlumpyTheme.Spacing.medium)
                    .padding(.top, PlumpyTheme.Spacing.medium)
                }
            }
        }
        .onAppear { preloadUser() }
    }

    private func pickerCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: PlumpyTheme.Spacing.small) {
            Text(title)
                .font(PlumpyTheme.Typography.subheadline)
                .fontWeight(.medium)
                .foregroundColor(PlumpyTheme.textPrimary)
            content()
        }
        .plumpyCard()
    }

    private func preloadUser() {
        if let u = users.first {
            name = u.name
            age = String(u.age)
            gender = u.gender
            height = String(format: "%.0f", u.height)
            weight = String(format: "%.1f", u.weight)
            activity = u.activityLevel
            goal = u.goal
            customCalories = String(DailyGoalsService.shared.getDailyCalorieGoal(from: modelContext))
        }
    }

    private func save() {
        print("DEBUG: Save function called - CODE UPDATED!") // ОТЛАДОЧНАЯ ИНФОРМАЦИЯ
        guard let ageInt = Int(age), let h = Double(height), let w = Double(weight) else { dismiss(); return }
        if let u = users.first {
            u.name = name.isEmpty ? u.name : name
            u.age = ageInt
            u.gender = gender
            u.height = h
            u.weight = w
            u.activityLevel = activity
            u.goal = goal
            let bmr = UserProfile.calculateBMR(weight: w, height: h, age: ageInt, gender: gender)
            let tdee = UserProfile.calculateTDEE(bmr: bmr, activityLevel: activity)
            let auto = UserProfile.calculateCalorieGoal(tdee: tdee, goal: goal)
            let final = Int(customCalories) ?? auto
            u.updateDailyCalorieGoal(final)
            try? modelContext.save()
        } else {
            let g = gender
            let a = ageInt
            let new = UserProfile(name: name.isEmpty ? "User" : name, age: a, gender: g, height: h, weight: w, activityLevel: activity, goal: goal)
            if let override = Int(customCalories) { 
                new.updateDailyCalorieGoal(override)
            }
            modelContext.insert(new)
            try? modelContext.save()
        }
        dismiss()
    }
}

#Preview {
    OnboardingQuestionnaireView()
        .modelContainer(for: [UserProfile.self], inMemory: true)
}


