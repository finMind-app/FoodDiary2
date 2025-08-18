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
}

enum Gender: String, CaseIterable, Codable {
    case male = "male"
    case female = "female"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .male:
            return "Male"
        case .female:
            return "Female"
        case .other:
            return "Other"
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
            return "Sedentary (little or no exercise)"
        case .light:
            return "Light (light exercise 1-3 days/week)"
        case .moderate:
            return "Moderate (moderate exercise 3-5 days/week)"
        case .active:
            return "Active (hard exercise 6-7 days/week)"
        case .veryActive:
            return "Very Active (very hard exercise, physical job)"
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
            return "Lose Weight"
        case .maintain:
            return "Maintain Weight"
        case .gain:
            return "Gain Weight"
        }
    }
}
