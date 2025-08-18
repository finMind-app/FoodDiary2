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
                    leftButton: PlumpyNavigationButton(icon: step == 0 ? "xmark" : "chevron.left", title: step == 0 ? "Close" : "Back", style: .outline) {
                        if step == 0 { dismiss() } else { withAnimation { step -= 1 } }
                    },
                    rightButton: PlumpyNavigationButton(icon: step == maxStep ? "checkmark" : "chevron.right", title: step == maxStep ? "Save" : "Next", style: .primary) {
                        if step < maxStep { withAnimation { step += 1 } } else { saveAndExit() }
                    }
                )

                // step progress
                PlumpyStepProgressBar(currentStep: step, totalSteps: maxStep + 1, style: .primary, showLabels: false)
                    .padding(.horizontal, PlumpyTheme.Spacing.medium)
                    .padding(.top, PlumpyTheme.Spacing.small)

                content
                    .padding(.horizontal, PlumpyTheme.Spacing.medium)
                    .padding(.top, PlumpyTheme.Spacing.medium)
            }
        }
        .onAppear { preloadUser() }
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
            pickerCard(title: "Gender") {
                Picker("Gender", selection: $gender) {
                    ForEach(Gender.allCases, id: \.self) { g in Text(g.displayName).tag(g) }
                }.pickerStyle(.segmented)
            }
        case 2:
            VStack(spacing: PlumpyTheme.Spacing.medium) {
                HStack(spacing: PlumpyTheme.Spacing.medium) {
                    PlumpyField(title: "Height (cm)", placeholder: "175", text: $height, keyboardType: .decimalPad, icon: "ruler", isRequired: true)
                    PlumpyField(title: "Weight (kg)", placeholder: "70", text: $weight, keyboardType: .decimalPad, icon: "scalemass", isRequired: true)
                }
            }.plumpyCard()
        case 3:
            pickerCard(title: "Activity level") {
                Picker("Activity", selection: $activity) {
                    ForEach(ActivityLevel.allCases, id: \.self) { a in Text(a.displayName).tag(a) }
                }
            }
        case 4:
            pickerCard(title: "Goal") {
                Picker("Goal", selection: $goal) {
                    ForEach(Goal.allCases, id: \.self) { g in Text(g.displayName).tag(g) }
                }.pickerStyle(.segmented)
            }
        case 5:
            VStack(spacing: PlumpyTheme.Spacing.medium) {
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
            }.plumpyCard()
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

    private func preloadUser() {
        if let u = users.first {
            name = u.name
            age = String(u.age)
            gender = u.gender
            height = String(format: "%.0f", u.height)
            weight = String(format: "%.1f", u.weight)
            activity = u.activityLevel
            goal = u.goal
            customCalories = String(u.dailyCalorieGoal)
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

    private func saveAndExit() {
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
            u.dailyCalorieGoal = finalCalories
            u.updatedAt = Date()
            try? modelContext.save()
        } else {
            let new = UserProfile(name: name.isEmpty ? "User" : name, age: a, gender: gender, height: h, weight: w, activityLevel: activity, goal: goal)
            new.dailyCalorieGoal = finalCalories
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


