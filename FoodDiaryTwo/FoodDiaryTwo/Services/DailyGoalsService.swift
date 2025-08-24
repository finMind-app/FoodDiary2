//
//  DailyGoalsService.swift
//  FoodDiaryTwo
//
//  Created by user on 31.07.2025.
//

import Foundation
import SwiftData

// MARK: - Центральный сервис для работы с суточными нормами
class DailyGoalsService: ObservableObject {
    
    // MARK: - Синглтон
    static let shared = DailyGoalsService()
    
    // MARK: - Публичные методы
    
    /// Получить суточную норму калорий из профиля пользователя
    func getDailyCalorieGoal(from context: ModelContext) -> Int {
        let descriptor = FetchDescriptor<UserProfile>()
        
        do {
            let profiles = try context.fetch(descriptor)
            if let profile = profiles.first {
                return profile.dailyCalorieGoal
            }
        } catch {
            print("Error fetching user profile: \(error)")
        }
        
        // Возвращаем дефолтное значение, если профиль не найден
        return 2000
    }
    
    /// Получить суточную норму белка из профиля пользователя
    func getDailyProteinGoal(from context: ModelContext) -> Double {
        let descriptor = FetchDescriptor<UserProfile>()
        
        do {
            let profiles = try context.fetch(descriptor)
            if let profile = profiles.first {
                return profile.dailyProteinGoal
            }
        } catch {
            print("Error fetching user profile: \(error)")
        }
        
        // Возвращаем дефолтное значение, если профиль не найден
        return 150.0
    }
    
    /// Получить суточную норму углеводов из профиля пользователя
    func getDailyCarbsGoal(from context: ModelContext) -> Double {
        let descriptor = FetchDescriptor<UserProfile>()
        
        do {
            let profiles = try context.fetch(descriptor)
            if let profile = profiles.first {
                return profile.dailyCarbsGoal
            }
        } catch {
            print("Error fetching user profile: \(error)")
        }
        
        // Возвращаем дефолтное значение, если профиль не найден
        return 250.0
    }
    
    /// Получить суточную норму жиров из профиля пользователя
    func getDailyFatGoal(from context: ModelContext) -> Double {
        let descriptor = FetchDescriptor<UserProfile>()
        
        do {
            let profiles = try context.fetch(descriptor)
            if let profile = profiles.first {
                return profile.dailyFatGoal
            }
        } catch {
            print("Error fetching user profile: \(error)")
        }
        
        // Возвращаем дефолтное значение, если профиль не найден
        return 67.0
    }
    
    /// Получить прогресс по калориям для определенной даты
    func getCalorieProgress(for date: Date, context: ModelContext) -> Double {
        let totalCalories = getTotalCaloriesForDate(date, context: context)
        let goal = getDailyCalorieGoal(from: context)
        return goal > 0 ? Double(totalCalories) / Double(goal) : 0.0
    }
    
    /// Получить прогресс по макронутриентам для определенной даты
    func getMacroProgress(for date: Date, context: ModelContext) -> (protein: Double, carbs: Double, fat: Double) {
        let entries = getFoodEntriesForDate(date, context: context)
        let totalProtein = entries.reduce(0.0) { $0 + $1.totalProtein }
        let totalCarbs = entries.reduce(0.0) { $0 + $1.totalCarbs }
        let totalFat = entries.reduce(0.0) { $0 + $1.totalFat }
        
        let proteinGoal = getDailyProteinGoal(from: context)
        let carbsGoal = getDailyCarbsGoal(from: context)
        let fatGoal = getDailyFatGoal(from: context)
        
        return (
            protein: proteinGoal > 0 ? totalProtein / proteinGoal : 0.0,
            carbs: carbsGoal > 0 ? totalCarbs / carbsGoal : 0.0,
            fat: fatGoal > 0 ? totalFat / fatGoal : 0.0
        )
    }
    
    /// Получить общее количество калорий за определенную дату
    func getTotalCaloriesForDate(_ date: Date, context: ModelContext) -> Int {
        let entries = getFoodEntriesForDate(date, context: context)
        return entries.reduce(0) { $0 + $1.totalCalories }
    }
    
    /// Получить общее количество белка за определенную дату
    func getTotalProteinForDate(_ date: Date, context: ModelContext) -> Double {
        let entries = getFoodEntriesForDate(date, context: context)
        return entries.reduce(0.0) { $0 + $1.totalProtein }
    }
    
    /// Получить общее количество углеводов за определенную дату
    func getTotalCarbsForDate(_ date: Date, context: ModelContext) -> Double {
        let entries = getFoodEntriesForDate(date, context: context)
        return entries.reduce(0.0) { $0 + $1.totalCarbs }
    }
    
    /// Получить общее количество жиров за определенную дату
    func getTotalFatForDate(_ date: Date, context: ModelContext) -> Double {
        let entries = getFoodEntriesForDate(date, context: context)
        return entries.reduce(0.0) { $0 + $1.totalFat }
    }
    
    // MARK: - Приватные методы
    
    private func getFoodEntriesForDate(_ date: Date, context: ModelContext) -> [FoodEntry] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let descriptor = FetchDescriptor<FoodEntry>(
            predicate: #Predicate<FoodEntry> { entry in
                entry.date >= startOfDay && entry.date < endOfDay
            }
        )
        
        do {
            return try context.fetch(descriptor)
        } catch {
            print("Error fetching food entries: \(error)")
            return []
        }
    }
}

// MARK: - Расширение для дополнительной функциональности
extension DailyGoalsService {
    
    /// Получить статистику за последние дни
    func getWeeklyStats(context: ModelContext) -> WeeklyStats {
        let calendar = Calendar.current
        let today = Date()
        
        var dailyStats: [DailyStats] = []
        var totalCalories = 0
        var totalProtein = 0.0
        var totalCarbs = 0.0
        var totalFat = 0.0
        
        for dayOffset in 0..<7 {
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: today)!
            let calories = getTotalCaloriesForDate(date, context: context)
            let protein = getTotalProteinForDate(date, context: context)
            let carbs = getTotalCarbsForDate(date, context: context)
            let fat = getTotalFatForDate(date, context: context)
            
            let dailyStat = DailyStats(
                date: date,
                calories: calories,
                protein: protein,
                carbs: carbs,
                fat: fat,
                calorieGoal: getDailyCalorieGoal(from: context),
                proteinGoal: getDailyProteinGoal(from: context),
                carbsGoal: getDailyCarbsGoal(from: context),
                fatGoal: getDailyFatGoal(from: context)
            )
            
            dailyStats.append(dailyStat)
            totalCalories += calories
            totalProtein += protein
            totalCarbs += carbs
            totalFat += fat
        }
        
        let averageCalories = totalCalories / 7
        let averageProtein = totalProtein / 7.0
        let averageCarbs = totalCarbs / 7.0
        let averageFat = totalFat / 7.0
        
        return WeeklyStats(
            dailyStats: dailyStats,
            averageCalories: averageCalories,
            averageProtein: averageProtein,
            averageCarbs: averageCarbs,
            averageFat: averageFat,
            totalCalories: totalCalories,
            totalProtein: totalProtein,
            totalCarbs: totalCarbs,
            totalFat: totalFat
        )
    }
    
    /// Получить рекомендации на основе текущего прогресса
    func getRecommendations(for date: Date, context: ModelContext) -> [String] {
        let currentCalories = getTotalCaloriesForDate(date, context: context)
        let calorieGoal = getDailyCalorieGoal(from: context)
        let remainingCalories = max(calorieGoal - currentCalories, 0)
        
        var recommendations: [String] = []
        
        if currentCalories == 0 {
            recommendations.append("Начните день с завтрака! Рекомендуется 400-600 ккал")
        } else if currentCalories < Int(Double(calorieGoal) * 0.3) {
            recommendations.append("Добавьте больше еды. Осталось \(remainingCalories) ккал")
        } else if currentCalories > Int(Double(calorieGoal) * 1.2) {
            recommendations.append("Попробуйте уменьшить порции. Превышение нормы на \(currentCalories - calorieGoal) ккал")
        } else if currentCalories >= Int(Double(calorieGoal) * 0.8) && currentCalories <= calorieGoal {
            recommendations.append("Отличный прогресс! Осталось \(remainingCalories) ккал до цели")
        }
        
        // Рекомендации по макронутриентам
        let macroProgress = getMacroProgress(for: date, context: context)
        
        if macroProgress.protein < 0.7 {
            recommendations.append("Добавьте больше белка: мясо, рыба, яйца, творог")
        }
        
        if macroProgress.carbs < 0.7 {
            recommendations.append("Добавьте сложные углеводы: крупы, хлеб, овощи")
        }
        
        if macroProgress.fat < 0.7 {
            recommendations.append("Добавьте полезные жиры: орехи, авокадо, оливковое масло")
        }
        
        return recommendations
    }
    
    /// Получить прогноз на основе текущего прогресса
    func getDailyForecast(for date: Date, context: ModelContext) -> DailyForecast {
        let currentCalories = getTotalCaloriesForDate(date, context: context)
        let calorieGoal = getDailyCalorieGoal(from: context)
        let remainingCalories = max(calorieGoal - currentCalories, 0)
        
        let currentTime = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: currentTime)
        
        var forecast: String
        var confidence: Double
        
        if hour < 12 {
            // Утро
            if currentCalories == 0 {
                forecast = "У вас есть \(calorieGoal) ккал на весь день. Начните с питательного завтрака!"
                confidence = 0.9
            } else if currentCalories < Int(Double(calorieGoal) * 0.3) {
                forecast = "Хорошее начало! Осталось \(remainingCalories) ккал. Планируйте обед и ужин"
                confidence = 0.8
            } else {
                forecast = "Отличный прогресс! Продолжайте в том же духе"
                confidence = 0.7
            }
        } else if hour < 18 {
            // День
            if currentCalories < Int(Double(calorieGoal) * 0.6) {
                forecast = "Половина дня прошла. Осталось \(remainingCalories) ккал. Планируйте ужин"
                confidence = 0.8
            } else if currentCalories < calorieGoal {
                forecast = "Хорошо! Осталось \(remainingCalories) ккал до цели"
                confidence = 0.7
            } else {
                forecast = "Цель достигнута! Можете позволить себе легкий перекус"
                confidence = 0.6
            }
        } else {
            // Вечер
            if currentCalories < Int(Double(calorieGoal) * 0.8) {
                forecast = "День подходит к концу. Осталось \(remainingCalories) ккал. Легкий ужин"
                confidence = 0.7
            } else if currentCalories <= calorieGoal {
                forecast = "Отличный день! Вы достигли своей цели"
                confidence = 0.9
            } else {
                forecast = "Превышение нормы. Завтра начните заново"
                confidence = 0.8
            }
        }
        
        return DailyForecast(
            message: forecast,
            confidence: confidence,
            remainingCalories: remainingCalories,
            currentProgress: Double(currentCalories) / Double(calorieGoal)
        )
    }
}

// MARK: - Модели данных для статистики

struct DailyStats {
    let date: Date
    let calories: Int
    let protein: Double
    let carbs: Double
    let fat: Double
    let calorieGoal: Int
    let proteinGoal: Double
    let carbsGoal: Double
    let fatGoal: Double
    
    var calorieProgress: Double {
        return calorieGoal > 0 ? Double(calories) / Double(calorieGoal) : 0.0
    }
    
    var proteinProgress: Double {
        return proteinGoal > 0 ? protein / proteinGoal : 0.0
    }
    
    var carbsProgress: Double {
        return carbsGoal > 0 ? carbs / carbsGoal : 0.0
    }
    
    var fatProgress: Double {
        return fatGoal > 0 ? fat / fatGoal : 0.0
    }
}

struct WeeklyStats {
    let dailyStats: [DailyStats]
    let averageCalories: Int
    let averageProtein: Double
    let averageCarbs: Double
    let averageFat: Double
    let totalCalories: Int
    let totalProtein: Double
    let totalCarbs: Double
    let totalFat: Double
}

struct DailyForecast {
    let message: String
    let confidence: Double
    let remainingCalories: Int
    let currentProgress: Double
}
