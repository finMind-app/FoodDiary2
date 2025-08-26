//
//  UserProfile.swift
//  FoodDiaryTwo
//
//  Created by Emil Svetlichnyy on 10.08.2025.
//

import Foundation
import SwiftData

@Model
final class UserProfile {
    var id: UUID
    var name: String
    var age: Int
    var gender: Gender
    var height: Double // в см
    var weight: Double // в кг
    var activityLevel: ActivityLevel
    var goal: Goal
    var email: String // Added for profile view
    var dailyCalorieGoal: Int
    var dailyProteinGoal: Double
    var dailyCarbsGoal: Double
    var dailyFatGoal: Double
    var createdAt: Date
    var updatedAt: Date
    
    init(
        name: String,
        age: Int,
        gender: Gender,
        height: Double,
        weight: Double,
        activityLevel: ActivityLevel = .moderate,
        goal: Goal = .maintain,
        email: String = ""
    ) {
        self.id = UUID()
        self.name = name
        self.age = age
        self.gender = gender
        self.height = height
        self.weight = weight
        self.activityLevel = activityLevel
        self.goal = goal
        self.email = email
        
        // Calculate goals based on BMR and activity level
        let bmr = Self.calculateBMR(weight: weight, height: height, age: age, gender: gender)
        let tdee = Self.calculateTDEE(bmr: bmr, activityLevel: activityLevel)
        let calorieGoal = Self.calculateCalorieGoal(tdee: tdee, goal: goal)
        
        self.dailyCalorieGoal = calorieGoal
        
        // Calculate macronutrients (25% protein, 45% carbs, 30% fat)
        self.dailyProteinGoal = Double(calorieGoal) * 0.25 / 4.0 // 4 calories per gram of protein
        self.dailyCarbsGoal = Double(calorieGoal) * 0.45 / 4.0 // 4 calories per gram of carbs
        self.dailyFatGoal = Double(calorieGoal) * 0.30 / 9.0 // 9 calories per gram of fat
        
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    static func calculateBMR(weight: Double, height: Double, age: Int, gender: Gender) -> Double {
        // Mifflin-St Jeor Formula
        let bmr: Double
        if gender == .male {
            bmr = 10 * weight + 6.25 * height - 5 * Double(age) + 5
        } else {
            bmr = 10 * weight + 6.25 * height - 5 * Double(age) - 161
        }
        return bmr
    }
    
    static func calculateTDEE(bmr: Double, activityLevel: ActivityLevel) -> Double {
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
    
    static func calculateCalorieGoal(tdee: Double, goal: Goal) -> Int {
        let adjustment: Double
        switch goal {
        case .lose:
            adjustment = 0.85 // 15% deficit
        case .maintain:
            adjustment = 1.0 // Weight maintenance
        case .gain:
            adjustment = 1.15 // 15% surplus
        }
        return Int(tdee * adjustment)
    }
    
    var bmi: Double {
        let heightInMeters = height / 100.0
        return weight / (heightInMeters * heightInMeters)
    }
    
    var bmiCategory: String {
        switch bmi {
        case ..<18.5:
            return "Underweight"
        case 18.5..<25:
            return "Normal"
        case 25..<30:
            return "Overweight"
        default:
            return "Obese"
        }
    }
    
    // MARK: - Методы для работы с суточными нормами
    
    /// Обновить суточную норму калорий и пересчитать макронутриенты
    func updateDailyCalorieGoal(_ newGoal: Int) {
        self.dailyCalorieGoal = newGoal
        
        // Пересчитываем макронутриенты (25% protein, 45% carbs, 30% fat)
        self.dailyProteinGoal = Double(newGoal) * 0.25 / 4.0 // 4 calories per gram of protein
        self.dailyCarbsGoal = Double(newGoal) * 0.45 / 4.0 // 4 calories per gram of carbs
        self.dailyFatGoal = Double(newGoal) * 0.30 / 9.0 // 9 calories per gram of fat
        
        self.updatedAt = Date()
    }
    
    /// Пересчитать суточные нормы на основе текущих параметров
    func recalculateDailyGoals() {
        let bmr = Self.calculateBMR(weight: weight, height: height, age: age, gender: gender)
        let tdee = Self.calculateTDEE(bmr: bmr, activityLevel: activityLevel)
        let calorieGoal = Self.calculateCalorieGoal(tdee: tdee, goal: goal)
        
        updateDailyCalorieGoal(calorieGoal)
    }
    
    /// Получить процент выполнения суточной нормы калорий
    func getCalorieCompletionPercentage(currentCalories: Int) -> Double {
        guard dailyCalorieGoal > 0 else { return 0.0 }
        return min(Double(currentCalories) / Double(dailyCalorieGoal), 1.0)
    }
    
    /// Получить оставшиеся калории на день
    func getRemainingCalories(currentCalories: Int) -> Int {
        return max(dailyCalorieGoal - currentCalories, 0)
    }
    
    /// Получить статус выполнения суточной нормы
    func getCalorieStatus(currentCalories: Int) -> CalorieStatus {
        let percentage = getCalorieCompletionPercentage(currentCalories: currentCalories)
        
        switch percentage {
        case 0.0..<0.5:
            return .low
        case 0.5..<0.8:
            return .moderate
        case 0.8..<1.0:
            return .good
        case 1.0..<1.2:
            return .excellent
        default:
            return .exceeded
        }
    }
}

// MARK: - Enums

enum Gender: String, CaseIterable, Codable {
    case male = "male"
    case female = "female"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .male:
            return LocalizationManager.shared.localizedString(.maleLabel)
        case .female:
            return LocalizationManager.shared.localizedString(.femaleLabel)
        case .other:
            return LocalizationManager.shared.localizedString(.otherLabel)
        }
    }
}

enum ActivityLevel: String, CaseIterable, Codable {
    case sedentary = "sedentary"
    case light = "light"
    case moderate = "moderate"
    case active = "active"
    case veryActive = "veryActive"
    
    var displayName: String {
        switch self {
        case .sedentary:
            return LocalizationManager.shared.localizedString(.sedentary)
        case .light:
            return LocalizationManager.shared.localizedString(.light)
        case .moderate:
            return LocalizationManager.shared.localizedString(.moderate)
        case .active:
            return LocalizationManager.shared.localizedString(.active)
        case .veryActive:
            return LocalizationManager.shared.localizedString(.veryActive)
        }
    }
    
    var shortName: String {
        switch self {
        case .sedentary:
            return LocalizationManager.shared.localizedString(.sedentary)
        case .light:
            return LocalizationManager.shared.localizedString(.light)
        case .moderate:
            return LocalizationManager.shared.localizedString(.moderate)
        case .active:
            return LocalizationManager.shared.localizedString(.active)
        case .veryActive:
            return LocalizationManager.shared.localizedString(.veryActive)
        }
    }
}

enum Goal: String, CaseIterable, Codable {
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
}

enum CalorieStatus: String, CaseIterable {
    case low = "low"
    case moderate = "moderate"
    case good = "good"
    case excellent = "excellent"
    case exceeded = "exceeded"
    
    var displayName: String {
        switch self {
        case .low:
            return "Низкое потребление"
        case .moderate:
            return "Умеренное потребление"
        case .good:
            return "Хорошее потребление"
        case .excellent:
            return "Отличное потребление"
        case .exceeded:
            return "Превышение нормы"
        }
    }
    
    var color: String {
        switch self {
        case .low:
            return "warning"
        case .moderate:
            return "info"
        case .good:
            return "success"
        case .excellent:
            return "primary"
        case .exceeded:
            return "error"
        }
    }
}
