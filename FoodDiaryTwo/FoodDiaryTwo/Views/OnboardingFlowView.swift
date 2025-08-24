//
//  OnboardingFlowView.swift
//  FoodDiaryTwo
//

import SwiftUI
import SwiftData

struct OnboardingFlowView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [UserProfile]

    @Environment(\.dismiss) private var dismiss

    @State private var step: Int = 0
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
            PlumpyBackground(style: .primary).ignoresSafeArea()
            VStack(spacing: 0) {
                PlumpyNavigationBar(
                    title: flowTitle,
                    leftButton: PlumpyNavigationButton(icon: "xmark", title: "Close", style: .outline) { dismiss() },
                    rightButton: PlumpyNavigationButton(icon: "forward.end", title: "Skip", style: .ghost) { saveAndExit(skip: true) }
                )

                // step progress
                PlumpyStepProgressBar(currentStep: step, totalSteps: maxStep + 1, style: .primary, showLabels: false)
                    .padding(.horizontal, PlumpyTheme.Spacing.medium)
                    .padding(.top, PlumpyTheme.Spacing.small)

                content
                    .padding(.horizontal, PlumpyTheme.Spacing.medium)
                    .padding(.top, PlumpyTheme.Spacing.medium)

                Spacer()

                // Bottom next/save button
                VStack(spacing: PlumpyTheme.Spacing.small) {
                    PlumpyButton(
                        title: step == maxStep ? "Save" : "Next",
                        icon: step == maxStep ? "checkmark" : "chevron.right",
                        style: .primary
                    ) {
                        if step < maxStep { withAnimation { step += 1 } } else { saveAndExit() }
                    }
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)
                }
                .padding(.horizontal, PlumpyTheme.Spacing.medium)
                .padding(.top, PlumpyTheme.Spacing.medium)
                .padding(.bottom, PlumpyTheme.Spacing.large)
            }
        }
        .onAppear { preloadUser() }
        .navigationBarBackButtonHidden(true)
    }

    private var maxStep: Int { 6 }

    @ViewBuilder
    private var content: some View {
        switch step {
        case 0:
            VStack(spacing: PlumpyTheme.Spacing.medium) {
                Text("Tell us about you")
                    .font(PlumpyTheme.Typography.subheadline)
                    .foregroundColor(PlumpyTheme.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                PlumpyField(title: "Name", placeholder: "Your name", text: $name, icon: "person", isRequired: true)
                PlumpyField(title: "Age", placeholder: "Years", text: $age, keyboardType: .numberPad, icon: "number", isRequired: true)
            }.plumpyCard()
        case 1:
            VStack(spacing: PlumpyTheme.Spacing.small) {
                Text("Gender")
                    .font(PlumpyTheme.Typography.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(PlumpyTheme.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
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
                                .frame(height: 55)
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
            .plumpyCard()
        case 2:
            VStack(spacing: PlumpyTheme.Spacing.large) {
                HStack(spacing: PlumpyTheme.Spacing.medium) {
                    PlumpyField(title: "Height (cm)", placeholder: "175", text: $height, keyboardType: .decimalPad, icon: "ruler", isRequired: true)
                    PlumpyField(title: "Weight (kg)", placeholder: "70", text: $weight, keyboardType: .decimalPad, icon: "scalemass", isRequired: true)
                }
            }
            .padding(.top, PlumpyTheme.Spacing.large)
            .plumpyCard()
        case 3:
            VStack(spacing: PlumpyTheme.Spacing.small) {
                Text("Activity")
                    .font(PlumpyTheme.Typography.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(PlumpyTheme.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: PlumpyTheme.Spacing.small), count: 3), spacing: PlumpyTheme.Spacing.small) {
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
                                .frame(height: 55)
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
            .plumpyCard()
        case 4:
            VStack(spacing: PlumpyTheme.Spacing.small) {
                Text("Goal")
                    .font(PlumpyTheme.Typography.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(PlumpyTheme.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
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
                                .frame(height: 55)
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
            .plumpyCard()
        case 5:
            VStack(spacing: PlumpyTheme.Spacing.large) {
                let recommended = recommendedCalories
                Text("Recommended daily calories based on your data")
                    .font(PlumpyTheme.Typography.subheadline)
                    .foregroundColor(PlumpyTheme.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                HStack {
                    Text("Recommended:")
                        .font(PlumpyTheme.Typography.caption1)
                        .foregroundColor(PlumpyTheme.textSecondary)
                    Text("\(recommended) cal")
                        .font(PlumpyTheme.Typography.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(PlumpyTheme.textPrimary)
                    Spacer()
                }
                PlumpyField(title: "Custom (optional)", placeholder: String(recommended), text: $customCalories, keyboardType: .numberPad, icon: "flame.fill", iconColor: PlumpyTheme.warning, isRequired: false)
            }
            .padding(.top, PlumpyTheme.Spacing.large)
            .plumpyCard()
        case 6:
            summaryCard
        default:
            EmptyView()
        }
    }

    private var summaryCard: some View {
        VStack(spacing: PlumpyTheme.Spacing.medium) {
            Text("Summary")
                .font(PlumpyTheme.Typography.subheadline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            VStack(spacing: PlumpyTheme.Spacing.small) {
                row("Name", name)
                row("Age", age)
                row("Gender", gender.displayName)
                row("Height", "\(height) cm")
                row("Weight", "\(weight) kg")
                row("Activity", activity.displayName)
                row("Goal", goal.displayName)
                row("Calories", "\(finalCalories) cal")
            }
        }.plumpyCard()
    }

    private func row(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title).font(PlumpyTheme.Typography.caption2).foregroundColor(PlumpyTheme.textSecondary)
            Spacer()
            Text(value).font(PlumpyTheme.Typography.caption1).foregroundColor(PlumpyTheme.textPrimary)
        }
    }

    private var flowTitle: String {
        switch step {
        case 0: return "About You"
        case 1: return "Gender"
        case 2: return "Body"
        case 3: return "Activity"
        case 4: return "Goal"
        case 5: return "Calories"
        case 6: return "Summary"
        default: return "Questionnaire"
        }
    }

    private func pickerCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: PlumpyTheme.Spacing.small) {
            Text(title)
                .font(PlumpyTheme.Typography.subheadline)
                .fontWeight(.medium)
                .foregroundColor(PlumpyTheme.textPrimary)
            content()
        }.plumpyCard()
    }

    private func chipsCard(title: String, items: [String], selectionIndex: Binding<Int>) -> some View {
        VStack(alignment: .leading, spacing: PlumpyTheme.Spacing.small) {
            Text(title)
                .font(PlumpyTheme.Typography.subheadline)
                .fontWeight(.medium)
                .foregroundColor(PlumpyTheme.textPrimary)
            HStack(spacing: PlumpyTheme.Spacing.small) {
                ForEach(items.indices, id: \.self) { idx in
                    PlumpyChip(
                        title: items[idx],
                        style: selectionIndex.wrappedValue == idx ? .primary : .outline,
                        isSelected: selectionIndex.wrappedValue == idx
                    ) {
                        selectionIndex.wrappedValue = idx
                    }
                }
            }
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

    private var recommendedCalories: Int {
        let a = Int(age) ?? 28
        let h = Double(height) ?? 175
        let w = Double(weight) ?? 70
        let bmr = UserProfile.calculateBMR(weight: w, height: h, age: a, gender: gender)
        let tdee = UserProfile.calculateTDEE(bmr: bmr, activityLevel: activity)
        return UserProfile.calculateCalorieGoal(tdee: tdee, goal: goal)
    }

    private var finalCalories: Int { Int(customCalories) ?? recommendedCalories }

    private func saveAndExit(skip: Bool = false) {
        let a = Int(age) ?? 28
        let h = Double(height) ?? 175
        let w = Double(weight) ?? 70
        if let u = users.first {
            u.name = name.isEmpty ? u.name : name
            u.age = a
            u.gender = gender
            u.height = h
            u.weight = w
            u.activityLevel = activity
            u.goal = goal
            if !skip {
                u.updateDailyCalorieGoal(finalCalories)
            }
            try? modelContext.save()
        } else {
            let new = UserProfile(name: name.isEmpty ? "User" : name, age: a, gender: gender, height: h, weight: w, activityLevel: activity, goal: goal)
            if !skip {
                new.updateDailyCalorieGoal(finalCalories)
            }
            modelContext.insert(new)
            try? modelContext.save()
        }
        dismiss()
    }
}

#Preview {
    OnboardingFlowView()
        .modelContainer(for: [UserProfile.self], inMemory: true)
}


