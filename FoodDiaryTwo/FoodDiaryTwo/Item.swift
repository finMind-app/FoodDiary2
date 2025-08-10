//
//  Item.swift
//  FoodDiaryTwo
//
//  Created by Emil Svetlichnyy on 10.08.2025.
//

import Foundation
import SwiftData

@Model
final class Meal {
    var date: Date
    var typeRaw: String
    var calories: Double
    var protein: Double
    var fat: Double
    var carbs: Double
    var note: String
    var photoData: Data?

    init(
        date: Date = Date(),
        type: MealType,
        calories: Double,
        protein: Double,
        fat: Double,
        carbs: Double,
        note: String = "",
        photoData: Data? = nil
    ) {
        self.date = date
        self.typeRaw = type.rawValue
        self.calories = calories
        self.protein = protein
        self.fat = fat
        self.carbs = carbs
        self.note = note
        self.photoData = photoData
    }

    var type: MealType { MealType(rawValue: typeRaw) ?? .other }
}

enum MealType: String, CaseIterable, Identifiable, Codable {
    case breakfast
    case lunch
    case dinner
    case snack
    case afternoonSnack
    case other

    var id: String { rawValue }

    var title: String {
        switch self {
        case .breakfast: return "Завтрак"
        case .lunch: return "Обед"
        case .dinner: return "Ужин"
        case .snack: return "Перекус"
        case .afternoonSnack: return "Полдник"
        case .other: return "Другое"
        }
    }

    var systemImage: String {
        switch self {
        case .breakfast: return "sunrise"
        case .lunch: return "fork.knife"
        case .dinner: return "moon"
        case .snack: return "takeoutbag.and.cup.and.straw"
        case .afternoonSnack: return "cup.and.saucer"
        case .other: return "plus"
        }
    }
}

enum Sex: String, CaseIterable, Identifiable, Codable { case male, female; var id: String { rawValue } }

enum ActivityLevel: String, CaseIterable, Identifiable, Codable {
    case low, medium, high
    var id: String { rawValue }
    var factor: Double {
        switch self { case .low: 1.2; case .medium: 1.5; case .high: 1.75 }
    }
    var title: String {
        switch self { case .low: "Низкая"; case .medium: "Средняя"; case .high: "Высокая" }
    }
}

enum Goal: String, CaseIterable, Identifiable, Codable {
    case lose, maintain, gain
    var id: String { rawValue }
    var title: String { switch self { case .lose: "Сбросить"; case .maintain: "Удержать"; case .gain: "Набрать" } }
    var calorieMultiplier: Double {
        switch self { case .lose: 0.8; case .maintain: 1.0; case .gain: 1.15 }
    }
}

@Model
final class UserProfile {
    var name: String
    var sexRaw: String
    var weightKg: Double
    var heightCm: Double
    var activityRaw: String
    var goalRaw: String
    var dailyCalories: Double
    var proteinTarget: Double
    var fatTarget: Double
    var carbTarget: Double

    init(
        name: String = "",
        sex: Sex = .male,
        weightKg: Double = 70,
        heightCm: Double = 175,
        activity: ActivityLevel = .medium,
        goal: Goal = .maintain,
        dailyCalories: Double = 2000,
        proteinTarget: Double = 120,
        fatTarget: Double = 70,
        carbTarget: Double = 220
    ) {
        self.name = name
        self.sexRaw = sex.rawValue
        self.weightKg = weightKg
        self.heightCm = heightCm
        self.activityRaw = activity.rawValue
        self.goalRaw = goal.rawValue
        self.dailyCalories = dailyCalories
        self.proteinTarget = proteinTarget
        self.fatTarget = fatTarget
        self.carbTarget = carbTarget
    }

    var sex: Sex { Sex(rawValue: sexRaw) ?? .male }
    var activity: ActivityLevel { ActivityLevel(rawValue: activityRaw) ?? .medium }
    var goal: Goal { Goal(rawValue: goalRaw) ?? .maintain }

    func recalculateTargets(ageYears: Int = 30) {
        // Mifflin-St Jeor (approx, age default 30)
        let s: Double = (sex == .male) ? 5 : -161
        let bmr = 10 * weightKg + 6.25 * heightCm - 5 * Double(ageYears) + s
        let tdee = bmr * activity.factor
        let targetCalories = tdee * goal.calorieMultiplier

        // Macros: protein 1.6 g/kg, fat 0.9 g/kg, carbs fill rest
        let protein = max(60, weightKg * 1.6)
        let fat = max(40, weightKg * 0.9)
        let proteinKcal = protein * 4
        let fatKcal = fat * 9
        let carbKcal = max(0, targetCalories - proteinKcal - fatKcal)
        let carbs = carbKcal / 4

        dailyCalories = round(targetCalories)
        proteinTarget = round(protein)
        fatTarget = round(fat)
        carbTarget = round(carbs)
    }
}

