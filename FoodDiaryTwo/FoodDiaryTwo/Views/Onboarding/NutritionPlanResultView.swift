//
//  NutritionPlanResultView.swift
//  FoodDiaryTwo
//
//  Created by AI Assistant
//

import SwiftUI

struct NutritionPlanResultView: View {
    let nutritionPlan: NutritionPlan
    let goal: UserGoal
    let onNext: () -> Void
    
    @State private var animateValues = false
    
    var body: some View {
        VStack(spacing: PlumpyTheme.Spacing.extraLarge) {
            // Header
            VStack(spacing: PlumpyTheme.Spacing.medium) {
                Text(LocalizationManager.shared.localizedString(.onboardingResultTitle))
                    .font(PlumpyTheme.Typography.title1)
                    .fontWeight(.bold)
                    .foregroundColor(PlumpyTheme.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
            .padding(.horizontal, PlumpyTheme.Spacing.medium)
            
            // Main Nutrition Card
            VStack(spacing: PlumpyTheme.Spacing.large) {
                // Calories - Main Focus
                VStack(spacing: PlumpyTheme.Spacing.small) {
                    Text("\(nutritionPlan.calories)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(PlumpyTheme.primary)
                        .scaleEffect(animateValues ? 1.0 : 0.8)
                        .animation(PlumpyTheme.Animation.spring.delay(0.2), value: animateValues)
                    
                    Text(LocalizationManager.shared.localizedString(.onboardingCaloriesPerDay))
                        .font(PlumpyTheme.Typography.headline)
                        .foregroundColor(PlumpyTheme.textSecondary)
                }
                .padding(.vertical, PlumpyTheme.Spacing.medium)
                
                // Macronutrients Grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: PlumpyTheme.Spacing.medium) {
                    MacronutrientCard(
                        title: LocalizationManager.shared.localizedString(.protein),
                        value: "\(Int(nutritionPlan.protein))",
                        unit: "г",
                        percentage: nutritionPlan.proteinPercentage,
                        color: PlumpyTheme.secondary,
                        delay: 0.4
                    )
                    
                    MacronutrientCard(
                        title: LocalizationManager.shared.localizedString(.carbs),
                        value: "\(Int(nutritionPlan.carbs))",
                        unit: "г",
                        percentage: nutritionPlan.carbsPercentage,
                        color: PlumpyTheme.primary,
                        delay: 0.6
                    )
                    
                    MacronutrientCard(
                        title: LocalizationManager.shared.localizedString(.fat),
                        value: "\(Int(nutritionPlan.fat))",
                        unit: "г",
                        percentage: nutritionPlan.fatPercentage,
                        color: PlumpyTheme.tertiary,
                        delay: 0.8
                    )
                }
                
                // Progress Visualization
                MacronutrientProgressView(
                    protein: nutritionPlan.proteinPercentage,
                    carbs: nutritionPlan.carbsPercentage,
                    fat: nutritionPlan.fatPercentage
                )
                .padding(.top, PlumpyTheme.Spacing.medium)
                
                // Weight Loss Prediction
                if let weightLoss = nutritionPlan.estimatedWeightLoss, goal == .lose {
                    VStack(spacing: PlumpyTheme.Spacing.small) {
                        Text(LocalizationManager.shared.localizedString(.onboardingWeightLossPrediction))
                            .font(PlumpyTheme.Typography.caption1)
                            .foregroundColor(PlumpyTheme.textSecondary)
                            .multilineTextAlignment(.center)
                        
                        Text("\(String(format: "%.1f", weightLoss)) кг")
                            .font(PlumpyTheme.Typography.title2)
                            .fontWeight(.bold)
                            .foregroundColor(PlumpyTheme.success)
                    }
                    .padding(.top, PlumpyTheme.Spacing.medium)
                }
            }
            .padding(PlumpyTheme.Spacing.large)
            .background(
                RoundedRectangle(cornerRadius: PlumpyTheme.Radius.extraLarge)
                    .fill(PlumpyTheme.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: PlumpyTheme.Radius.extraLarge)
                            .stroke(PlumpyTheme.primary.opacity(0.2), lineWidth: 2)
                    )
                    .shadow(
                        color: PlumpyTheme.primary.opacity(0.1),
                        radius: 20,
                        x: 0,
                        y: 10
                    )
            )
            .padding(.horizontal, PlumpyTheme.Spacing.medium)
            
            Spacer()
            
            // Next Button
            PlumpyButton(
                title: LocalizationManager.shared.localizedString(.onboardingContinue),
                icon: "arrow.right",
                style: .primary,
                action: onNext
            )
            .padding(.horizontal, PlumpyTheme.Spacing.medium)
            .padding(.bottom, PlumpyTheme.Spacing.large)
        }
        .background(PlumpyTheme.background)
        .onAppear {
            withAnimation {
                animateValues = true
            }
        }
    }
}

struct MacronutrientCard: View {
    let title: String
    let value: String
    let unit: String
    let percentage: Double
    let color: Color
    let delay: Double
    
    @State private var animate = false
    
    var body: some View {
        VStack(spacing: PlumpyTheme.Spacing.small) {
            Text(title)
                .font(PlumpyTheme.Typography.caption1)
                .foregroundColor(PlumpyTheme.textSecondary)
                .multilineTextAlignment(.center)
            
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(color)
                    .scaleEffect(animate ? 1.0 : 0.8)
                    .animation(PlumpyTheme.Animation.spring.delay(delay), value: animate)
                
                Text(unit)
                    .font(PlumpyTheme.Typography.caption1)
                    .foregroundColor(PlumpyTheme.textSecondary)
            }
            
            Text("\(Int(percentage))%")
                .font(PlumpyTheme.Typography.caption2)
                .foregroundColor(PlumpyTheme.textTertiary)
        }
        .padding(PlumpyTheme.Spacing.medium)
        .background(
            RoundedRectangle(cornerRadius: PlumpyTheme.Radius.medium)
                .fill(color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: PlumpyTheme.Radius.medium)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
        .onAppear {
            withAnimation {
                animate = true
            }
        }
    }
}

struct MacronutrientProgressView: View {
    let protein: Double
    let carbs: Double
    let fat: Double
    
    var body: some View {
        VStack(spacing: PlumpyTheme.Spacing.small) {
            HStack {
                Text(LocalizationManager.shared.localizedString(.onboardingMacroDistribution))
                    .font(PlumpyTheme.Typography.caption1)
                    .foregroundColor(PlumpyTheme.textSecondary)
                Spacer()
            }
            
            HStack(spacing: 0) {
                // Protein
                Rectangle()
                    .fill(PlumpyTheme.secondary)
                    .frame(width: protein * 2) // Scale for visual representation
                
                // Carbs
                Rectangle()
                    .fill(PlumpyTheme.primary)
                    .frame(width: carbs * 2)
                
                // Fat
                Rectangle()
                    .fill(PlumpyTheme.tertiary)
                    .frame(width: fat * 2)
            }
            .frame(height: 8)
            .clipShape(Capsule())
            
            HStack {
                HStack(spacing: PlumpyTheme.Spacing.tiny) {
                    Circle()
                        .fill(PlumpyTheme.secondary)
                        .frame(width: 8, height: 8)
                    Text(LocalizationManager.shared.localizedString(.protein))
                        .font(PlumpyTheme.Typography.caption2)
                        .foregroundColor(PlumpyTheme.textSecondary)
                }
                
                Spacer()
                
                HStack(spacing: PlumpyTheme.Spacing.tiny) {
                    Circle()
                        .fill(PlumpyTheme.primary)
                        .frame(width: 8, height: 8)
                    Text(LocalizationManager.shared.localizedString(.carbs))
                        .font(PlumpyTheme.Typography.caption2)
                        .foregroundColor(PlumpyTheme.textSecondary)
                }
                
                Spacer()
                
                HStack(spacing: PlumpyTheme.Spacing.tiny) {
                    Circle()
                        .fill(PlumpyTheme.tertiary)
                        .frame(width: 8, height: 8)
                    Text(LocalizationManager.shared.localizedString(.fat))
                        .font(PlumpyTheme.Typography.caption2)
                        .foregroundColor(PlumpyTheme.textSecondary)
                }
            }
        }
    }
}

#Preview {
    let samplePlan = NutritionPlan(
        calories: 2050,
        protein: 110,
        carbs: 250,
        fat: 70,
        estimatedWeightLoss: 4.2,
        estimatedTimeframe: "6 недель"
    )
    
    NutritionPlanResultView(
        nutritionPlan: samplePlan,
        goal: .lose
    ) {
        print("Next tapped")
    }
}
