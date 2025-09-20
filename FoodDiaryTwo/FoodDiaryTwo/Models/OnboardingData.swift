//
//  OnboardingData.swift
//  FoodDiaryTwo
//
//  Created by AI Assistant
//

import Foundation

// MARK: - Onboarding Data Model

struct OnboardingData {
    var goal: UserGoal?
    var gender: Gender?
    var age: Int?
    var height: Double? // в см
    var weight: Double? // в кг
    var activityLevel: ActivityLevel?
    var calculatedPlan: NutritionPlan?
    
    var isComplete: Bool {
        return goal != nil && 
               gender != nil && 
               age != nil && 
               height != nil && 
               weight != nil && 
               activityLevel != nil
    }
}

// MARK: - User Goal Enum

enum UserGoal: String, CaseIterable, Codable {
    case lose = "lose"
    case maintain = "maintain"
    case gain = "gain"
    
    var displayName: String {
        switch self {
        case .lose:
            return LocalizationManager.shared.localizedString(.loseWeight)
        case .maintain:
            return LocalizationManager.shared.localizedString(.maintainWeight)
        case .gain:
            return LocalizationManager.shared.localizedString(.gainWeight)
        }
    }
    
    var icon: String {
        switch self {
        case .lose:
            return "arrow.down.circle.fill"
        case .maintain:
            return "equal.circle.fill"
        case .gain:
            return "arrow.up.circle.fill"
        }
    }
    
    var emoji: String {
        switch self {
        case .lose:
            return "🔻"
        case .maintain:
            return "⚖️"
        case .gain:
            return "💪"
        }
    }
    
    var description: String {
        switch self {
        case .lose:
            return LocalizationManager.shared.localizedString(.goalLoseDescription)
        case .maintain:
            return LocalizationManager.shared.localizedString(.goalMaintainDescription)
        case .gain:
            return LocalizationManager.shared.localizedString(.goalGainDescription)
        }
    }
}

// MARK: - Activity Level with New Descriptions

extension ActivityLevel {
    var onboardingIcon: String {
        switch self {
        case .sedentary:
            return "chair.fill"
        case .light:
            return "figure.walk"
        case .moderate:
            return "dumbbell.fill"
        case .active:
            return "figure.run"
        case .veryActive:
            return "figure.run.circle.fill"
        }
    }
    
    var onboardingEmoji: String {
        switch self {
        case .sedentary:
            return "🪑"
        case .light:
            return "🚶"
        case .moderate:
            return "🏋️"
        case .active:
            return "🏃"
        case .veryActive:
            return "🏃‍♂️"
        }
    }
    
    var onboardingDescription: String {
        switch self {
        case .sedentary:
            return LocalizationManager.shared.localizedString(.activitySedentaryDescription)
        case .light:
            return LocalizationManager.shared.localizedString(.activityLightDescription)
        case .moderate:
            return LocalizationManager.shared.localizedString(.activityModerateDescription)
        case .active:
            return LocalizationManager.shared.localizedString(.activityActiveDescription)
        case .veryActive:
            return LocalizationManager.shared.localizedString(.activityVeryActiveDescription)
        }
    }
}

// MARK: - Nutrition Plan

struct NutritionPlan: Codable {
    let calories: Int
    let protein: Double // в граммах
    let carbs: Double // в граммах
    let fat: Double // в граммах
    let estimatedWeightLoss: Double? // в кг за 6 недель
    let estimatedTimeframe: String
    
    var proteinPercentage: Double {
        return (protein * 4) / Double(calories) * 100
    }
    
    var carbsPercentage: Double {
        return (carbs * 4) / Double(calories) * 100
    }
    
    var fatPercentage: Double {
        return (fat * 9) / Double(calories) * 100
    }
}

// MARK: - Onboarding Calculator

class OnboardingCalculator {
    
    static func calculateNutritionPlan(
        goal: UserGoal,
        gender: Gender,
        age: Int,
        height: Double,
        weight: Double,
        activityLevel: ActivityLevel
    ) -> NutritionPlan {
        
        // Рассчитываем BMR по формуле Миффлина-Сан Жеора
        let bmr = calculateBMR(weight: weight, height: height, age: age, gender: gender)
        
        // Рассчитываем TDEE
        let tdee = calculateTDEE(bmr: bmr, activityLevel: activityLevel)
        
        // Рассчитываем целевые калории в зависимости от цели
        let targetCalories = calculateTargetCalories(tdee: tdee, goal: goal)
        
        // Рассчитываем макронутриенты
        let protein = calculateProtein(calories: targetCalories, goal: goal)
        let carbs = calculateCarbs(calories: targetCalories, goal: goal)
        let fat = calculateFat(calories: targetCalories, protein: protein, carbs: carbs)
        
        // Рассчитываем прогноз потери веса
        let estimatedWeightLoss = calculateWeightLoss(goal: goal, tdee: tdee, targetCalories: targetCalories)
        
        return NutritionPlan(
            calories: targetCalories,
            protein: protein,
            carbs: carbs,
            fat: fat,
            estimatedWeightLoss: estimatedWeightLoss,
            estimatedTimeframe: "6 недель"
        )
    }
    
    private static func calculateBMR(weight: Double, height: Double, age: Int, gender: Gender) -> Double {
        if gender == .male {
            return 10 * weight + 6.25 * height - 5 * Double(age) + 5
        } else {
            return 10 * weight + 6.25 * height - 5 * Double(age) - 161
        }
    }
    
    private static func calculateTDEE(bmr: Double, activityLevel: ActivityLevel) -> Double {
        let multiplier: Double
        switch activityLevel {
        case .sedentary:
            multiplier = 1.2
        case .light:
            multiplier = 1.375
        case .moderate:
            multiplier = 1.55
        case .active:
            multiplier = 1.725
        case .veryActive:
            multiplier = 1.9
        }
        return bmr * multiplier
    }
    
    private static func calculateTargetCalories(tdee: Double, goal: UserGoal) -> Int {
        let multiplier: Double
        switch goal {
        case .lose:
            multiplier = 0.85 // 15% дефицит
        case .maintain:
            multiplier = 1.0
        case .gain:
            multiplier = 1.15 // 15% профицит
        }
        return Int(tdee * multiplier)
    }
    
    private static func calculateProtein(calories: Int, goal: UserGoal) -> Double {
        let proteinPercentage: Double
        switch goal {
        case .lose:
            proteinPercentage = 0.30 // 30% для похудения
        case .maintain:
            proteinPercentage = 0.25 // 25% для поддержания
        case .gain:
            proteinPercentage = 0.30 // 30% для набора массы
        }
        return Double(calories) * proteinPercentage / 4.0 // 4 калории на грамм белка
    }
    
    private static func calculateCarbs(calories: Int, goal: UserGoal) -> Double {
        let carbsPercentage: Double
        switch goal {
        case .lose:
            carbsPercentage = 0.35 // 35% для похудения
        case .maintain:
            carbsPercentage = 0.45 // 45% для поддержания
        case .gain:
            carbsPercentage = 0.45 // 45% для набора массы
        }
        return Double(calories) * carbsPercentage / 4.0 // 4 калории на грамм углеводов
    }
    
    private static func calculateFat(calories: Int, protein: Double, carbs: Double) -> Double {
        let proteinCalories = protein * 4
        let carbsCalories = carbs * 4
        let fatCalories = Double(calories) - proteinCalories - carbsCalories
        return fatCalories / 9.0 // 9 калорий на грамм жира
    }
    
    private static func calculateWeightLoss(goal: UserGoal, tdee: Double, targetCalories: Int) -> Double? {
        guard goal == .lose else { return nil }
        
        let weeklyDeficit = (tdee - Double(targetCalories)) * 7 // недельный дефицит в калориях
        let weeklyWeightLoss = weeklyDeficit / 7700 // 7700 калорий = 1 кг жира
        let sixWeekWeightLoss = weeklyWeightLoss * 6
        
        return max(0, min(6, sixWeekWeightLoss)) // ограничиваем от 0 до 6 кг
    }
}
