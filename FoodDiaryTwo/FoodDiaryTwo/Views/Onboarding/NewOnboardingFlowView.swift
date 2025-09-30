//
//  NewOnboardingFlowView.swift
//  FoodDiaryTwo
//
//  Created by AI Assistant
//

import SwiftUI
import SwiftData

struct NewOnboardingFlowView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentStep = 0
    @State private var onboardingData = OnboardingData()
    @State private var calculatedPlan: NutritionPlan?
    
    private let totalSteps = 5
    
    var onComplete: (() -> Void)?
    
    var body: some View {
        ZStack {
            PlumpyBackground(style: .primary).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Progress Bar
                if currentStep > 0 {
                    ProgressBarView(
                        currentStep: currentStep,
                        totalSteps: totalSteps
                    )
                    .padding(.horizontal, PlumpyTheme.Spacing.medium)
                    .padding(.top, PlumpyTheme.Spacing.medium)
                }
                
                // Content
                TabView(selection: $currentStep) {
                    // Step 1: Goal Selection
                    GoalSelectionView(
                        selectedGoal: $onboardingData.goal
                    ) {
                        nextStep()
                    }
                    .tag(0)
                    
                    // Step 2: User Info
                    UserInfoView(
                        gender: $onboardingData.gender,
                        age: $onboardingData.age,
                        height: $onboardingData.height,
                        weight: $onboardingData.weight
                    ) {
                        nextStep()
                    }
                    .tag(1)
                    
                    // Step 3: Activity Level
                    ActivityLevelView(
                        selectedActivityLevel: $onboardingData.activityLevel
                    ) {
                        calculatePlan()
                        nextStep()
                    }
                    .tag(2)
                    
                    // Step 4: Nutrition Plan Result
                    if let plan = calculatedPlan, let goal = onboardingData.goal {
                        NutritionPlanResultView(
                            nutritionPlan: plan,
                            goal: goal
                        ) {
                            nextStep()
                        }
                        .tag(3)
                    }
                    
                    // Step 5: Paywall
                    PaywallView(
                        onUnlock: {
                            saveUserProfile()
                            completeOnboarding()
                        },
                        onContinueFree: {
                            saveUserProfile()
                            completeOnboarding()
                        }
                    )
                    .tag(4)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(PlumpyTheme.Animation.smooth, value: currentStep)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private func nextStep() {
        withAnimation(PlumpyTheme.Animation.smooth) {
            if currentStep < totalSteps - 1 {
                currentStep += 1
            }
        }
    }
    
    private func calculatePlan() {
        guard let goal = onboardingData.goal,
              let gender = onboardingData.gender,
              let age = onboardingData.age,
              let height = onboardingData.height,
              let weight = onboardingData.weight,
              let activityLevel = onboardingData.activityLevel else {
            return
        }
        
        calculatedPlan = OnboardingCalculator.calculateNutritionPlan(
            goal: goal,
            gender: gender,
            age: age,
            height: height,
            weight: weight,
            activityLevel: activityLevel
        )
    }
    
    private func saveUserProfile() {
        guard let goal = onboardingData.goal,
              let gender = onboardingData.gender,
              let age = onboardingData.age,
              let height = onboardingData.height,
              let weight = onboardingData.weight,
              let activityLevel = onboardingData.activityLevel,
              let plan = calculatedPlan else {
            return
        }
        
        // Check if user already exists
        let descriptor = FetchDescriptor<UserProfile>()
        let existingUsers = try? modelContext.fetch(descriptor)
        
        if let existingUser = existingUsers?.first {
            // Update existing user
            existingUser.goal = Goal(rawValue: goal.rawValue) ?? .maintain
            existingUser.gender = gender
            existingUser.age = age
            existingUser.height = height
            existingUser.weight = weight
            existingUser.activityLevel = activityLevel
            existingUser.dailyCalorieGoal = plan.calories
            existingUser.dailyProteinGoal = plan.protein
            existingUser.dailyCarbsGoal = plan.carbs
            existingUser.dailyFatGoal = plan.fat
            existingUser.updatedAt = Date()
        } else {
            // Create new user
            let newUser = UserProfile(
                name: "Пользователь",
                age: age,
                gender: gender,
                height: height,
                weight: weight,
                activityLevel: activityLevel,
                goal: Goal(rawValue: goal.rawValue) ?? .maintain
            )
            newUser.dailyCalorieGoal = plan.calories
            newUser.dailyProteinGoal = plan.protein
            newUser.dailyCarbsGoal = plan.carbs
            newUser.dailyFatGoal = plan.fat
            modelContext.insert(newUser)
        }
        
        try? modelContext.save()
    }
    
    private func completeOnboarding() {
        onComplete?()
    }
}

struct ProgressBarView: View {
    let currentStep: Int
    let totalSteps: Int
    
    var body: some View {
        VStack(spacing: PlumpyTheme.Spacing.small) {
            HStack {
                Text("Шаг \(currentStep + 1) из \(totalSteps)")
                    .font(PlumpyTheme.Typography.caption1)
                    .foregroundColor(PlumpyTheme.textSecondary)
                
                Spacer()
                
                Text("\(Int((Double(currentStep + 1) / Double(totalSteps)) * 100))%")
                    .font(PlumpyTheme.Typography.caption1)
                    .foregroundColor(PlumpyTheme.textSecondary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: PlumpyTheme.Radius.small)
                        .fill(PlumpyTheme.neutral200)
                        .frame(height: 4)
                    
                    // Progress
                    RoundedRectangle(cornerRadius: PlumpyTheme.Radius.small)
                        .fill(PlumpyTheme.primary)
                        .frame(
                            width: geometry.size.width * (Double(currentStep + 1) / Double(totalSteps)),
                            height: 4
                        )
                        .animation(PlumpyTheme.Animation.smooth, value: currentStep)
                }
            }
            .frame(height: 4)
        }
    }
}

#Preview {
    NewOnboardingFlowView()
        .modelContainer(for: [UserProfile.self], inMemory: true)
}
