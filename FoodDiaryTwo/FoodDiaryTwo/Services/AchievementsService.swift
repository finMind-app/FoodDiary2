//
//  AchievementsService.swift
//  FoodDiaryTwo
//
//  Created by assistant on 25.08.2025.
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class Achievement {
    var id: String
    var title: String
    var detail: String
    var icon: String
    var colorHex: String
    var isUnlocked: Bool
    var progress: Double
    var target: Double
    var unlockedAt: Date?
    
    init(id: String, title: String, detail: String, icon: String, colorHex: String, isUnlocked: Bool = false, progress: Double = 0, target: Double = 1, unlockedAt: Date? = nil) {
        self.id = id
        self.title = title
        self.detail = detail
        self.icon = icon
        self.colorHex = colorHex
        self.isUnlocked = isUnlocked
        self.progress = progress
        self.target = target
        self.unlockedAt = unlockedAt
    }
}

final class AchievementsService {
    static let shared = AchievementsService()
    private init() {}
    
    // Seed a rich set of achievements
    private let catalogue: [Achievement] = [
        Achievement(id: "first_meal", title: LocalizationManager.shared.localizedString(.achFirstMealTitle), detail: LocalizationManager.shared.localizedString(.achFirstMealDetail), icon: "fork.knife", colorHex: "#10B981"),
        Achievement(id: "five_meals", title: LocalizationManager.shared.localizedString(.achFiveMealsTitle), detail: LocalizationManager.shared.localizedString(.achFiveMealsDetail), icon: "fork.knife.circle", colorHex: "#3B82F6", target: 5),
        Achievement(id: "twenty_meals", title: LocalizationManager.shared.localizedString(.achTwentyMealsTitle), detail: LocalizationManager.shared.localizedString(.achTwentyMealsDetail), icon: "takeoutbag.and.cup.and.straw.fill", colorHex: "#6366F1", target: 20),
        Achievement(id: "hundred_meals", title: LocalizationManager.shared.localizedString(.achHundredMealsTitle), detail: LocalizationManager.shared.localizedString(.achHundredMealsDetail), icon: "fork.knife.circle.fill", colorHex: "#8B5CF6", target: 100),
        Achievement(id: "photo_entry", title: LocalizationManager.shared.localizedString(.achPhotoEntryTitle), detail: LocalizationManager.shared.localizedString(.achPhotoEntryDetail), icon: "camera.fill", colorHex: "#EC4899"),
        Achievement(id: "healthy_snacks", title: LocalizationManager.shared.localizedString(.achHealthySnacksTitle), detail: LocalizationManager.shared.localizedString(.achHealthySnacksDetail), icon: "leaf.fill", colorHex: "#22C55E", target: 10),
        Achievement(id: "breakfast_early", title: LocalizationManager.shared.localizedString(.achBreakfastEarlyTitle), detail: LocalizationManager.shared.localizedString(.achBreakfastEarlyDetail), icon: "sunrise.fill", colorHex: "#F59E0B"),
        Achievement(id: "dinner_late", title: LocalizationManager.shared.localizedString(.achDinnerLateTitle), detail: LocalizationManager.shared.localizedString(.achDinnerLateDetail), icon: "moon.stars.fill", colorHex: "#0EA5E9"),
        Achievement(id: "streak_3", title: LocalizationManager.shared.localizedString(.achStreak3Title), detail: LocalizationManager.shared.localizedString(.achStreak3Detail), icon: "flame.fill", colorHex: "#F97316", target: 3),
        Achievement(id: "streak_7", title: LocalizationManager.shared.localizedString(.achStreak7Title), detail: LocalizationManager.shared.localizedString(.achStreak7Detail), icon: "flame.circle.fill", colorHex: "#FB923C", target: 7),
        Achievement(id: "goal_day", title: LocalizationManager.shared.localizedString(.achGoalDayTitle), detail: LocalizationManager.shared.localizedString(.achGoalDayDetail), icon: "target", colorHex: "#16A34A"),
        Achievement(id: "goal_week_4", title: LocalizationManager.shared.localizedString(.achGoalWeek4Title), detail: LocalizationManager.shared.localizedString(.achGoalWeek4Detail), icon: "target.circle", colorHex: "#22C55E", target: 4),
        Achievement(id: "protein_100", title: LocalizationManager.shared.localizedString(.achProtein100Title), detail: LocalizationManager.shared.localizedString(.achProtein100Detail), icon: "bolt.fill", colorHex: "#F59E0B"),
        Achievement(id: "veggie_day", title: LocalizationManager.shared.localizedString(.achVeggieDayTitle), detail: LocalizationManager.shared.localizedString(.achVeggieDayDetail), icon: "leaf.circle.fill", colorHex: "#84CC16", target: 5),
        Achievement(id: "week_30_meals", title: LocalizationManager.shared.localizedString(.achWeek30MealsTitle), detail: LocalizationManager.shared.localizedString(.achWeek30MealsDetail), icon: "calendar", colorHex: "#06B6D4", target: 30),
        Achievement(id: "month_100_meals", title: LocalizationManager.shared.localizedString(.achMonth100MealsTitle), detail: LocalizationManager.shared.localizedString(.achMonth100MealsDetail), icon: "calendar.circle.fill", colorHex: "#0EA5E9", target: 100)
    ]
    
    // Returns newly unlocked achievements from this evaluation
    @discardableResult
    func evaluateAndSync(in context: ModelContext) -> [Achievement] {
        // Fetch entries
        let descriptor = FetchDescriptor<FoodEntry>(sortBy: [SortDescriptor(\.date, order: .forward)])
        let entries = (try? context.fetch(descriptor)) ?? []
        
        // Load or seed achievements
        var existing = (try? context.fetch(FetchDescriptor<Achievement>())) ?? []
        if existing.isEmpty {
            for ach in catalogue {
                context.insert(ach)
            }
            try? context.save()
            existing = (try? context.fetch(FetchDescriptor<Achievement>())) ?? []
        }
        
        // Helpers
        let totalMeals = entries.count
        let daysWithEntries: [Date: [FoodEntry]] = Dictionary(grouping: entries) { Calendar.current.startOfDay(for: $0.date) }
        let longestStreak = computeCurrentStreak(days: Set(daysWithEntries.keys))
        let today = Calendar.current.startOfDay(for: Date())
        let todayEntries = daysWithEntries[today] ?? []
        let todayProtein = todayEntries.reduce(0.0) { $0 + $1.totalProtein }
        let todayProductCount = todayEntries.reduce(0) { $0 + $1.products.count }
        let hasPhoto = entries.contains { $0.photoData != nil }
        let hadEarlyBreakfast = entries.contains { $0.mealType == .breakfast && Calendar.current.component(.hour, from: $0.date) < 8 }
        let hadLateDinner = entries.contains { $0.mealType == .dinner && Calendar.current.component(.hour, from: $0.date) >= 21 }
        let snacksCount = entries.filter { $0.mealType == .snack }.count
        
        // Goal logic
        let calorieGoal = DailyGoalsService.shared.getDailyCalorieGoal(from: context)
        let goalDays = daysWithEntries.keys.filter { day in
            let end = Calendar.current.date(byAdding: .day, value: 1, to: day) ?? day
            let dayCals = (daysWithEntries[day] ?? []).filter { $0.date >= day && $0.date < end }.reduce(0) { $0 + $1.totalCalories }
            return dayCals >= calorieGoal
        }
        let goalDaysThisWeek: Int = {
            let weekInterval = Calendar.current.dateInterval(of: .weekOfYear, for: Date())
            guard let start = weekInterval?.start, let end = weekInterval?.end else { return 0 }
            return goalDays.filter { $0 >= start && $0 < end }.count
        }()
        
        // Weekly and monthly meal counts
        let weekInterval = Calendar.current.dateInterval(of: .weekOfYear, for: Date())
        let mealsThisWeek = entries.filter { if let i = weekInterval { return $0.date >= i.start && $0.date < i.end } else { return false }}.count
        let monthInterval = Calendar.current.dateInterval(of: .month, for: Date())
        let mealsThisMonth = entries.filter { if let i = monthInterval { return $0.date >= i.start && $0.date < i.end } else { return false }}.count
        
        // Update achievements and track newly unlocked
        var newlyUnlocked: [Achievement] = []
        func update(_ key: String, progress: Double, target: Double = 1, unlocked: Bool) {
            if let ach = existing.first(where: { $0.id == key }) {
                ach.progress = progress
                ach.target = target
                if unlocked && !ach.isUnlocked {
                    ach.isUnlocked = true
                    ach.unlockedAt = Date()
                    newlyUnlocked.append(ach)
                }
            }
        }
        
        update("first_meal", progress: totalMeals > 0 ? 1 : 0, unlocked: totalMeals > 0)
        update("five_meals", progress: Double(totalMeals), target: 5, unlocked: totalMeals >= 5)
        update("twenty_meals", progress: Double(totalMeals), target: 20, unlocked: totalMeals >= 20)
        update("hundred_meals", progress: Double(totalMeals), target: 100, unlocked: totalMeals >= 100)
        update("photo_entry", progress: hasPhoto ? 1 : 0, unlocked: hasPhoto)
        update("healthy_snacks", progress: Double(snacksCount), target: 10, unlocked: snacksCount >= 10)
        update("breakfast_early", progress: hadEarlyBreakfast ? 1 : 0, unlocked: hadEarlyBreakfast)
        update("dinner_late", progress: hadLateDinner ? 1 : 0, unlocked: hadLateDinner)
        update("streak_3", progress: Double(longestStreak), target: 3, unlocked: longestStreak >= 3)
        update("streak_7", progress: Double(longestStreak), target: 7, unlocked: longestStreak >= 7)
        update("goal_day", progress: goalDays.contains(today) ? 1 : 0, unlocked: goalDays.contains(today))
        update("goal_week_4", progress: Double(goalDaysThisWeek), target: 4, unlocked: goalDaysThisWeek >= 4)
        update("protein_100", progress: todayProtein, target: 100, unlocked: todayProtein >= 100)
        update("veggie_day", progress: Double(todayProductCount), target: 5, unlocked: todayProductCount >= 5)
        update("week_30_meals", progress: Double(mealsThisWeek), target: 30, unlocked: mealsThisWeek >= 30)
        update("month_100_meals", progress: Double(mealsThisMonth), target: 100, unlocked: mealsThisMonth >= 100)
        
        try? context.save()
        return newlyUnlocked
    }
    
    private func computeCurrentStreak(days: Set<Date>) -> Int {
        var streak = 0
        var date = Calendar.current.startOfDay(for: Date())
        while days.contains(date) {
            streak += 1
            date = Calendar.current.date(byAdding: .day, value: -1, to: date) ?? date
        }
        return streak
    }
}

struct AchievementViewModel: Identifiable {
    let id: String
    let title: String
    let detail: String
    let icon: String
    let color: Color
    let isUnlocked: Bool
}

extension Achievement {
    var localizedTitle: String {
        switch id {
        case "first_meal": return LocalizationManager.shared.localizedString(.achFirstMealTitle)
        case "five_meals": return LocalizationManager.shared.localizedString(.achFiveMealsTitle)
        case "twenty_meals": return LocalizationManager.shared.localizedString(.achTwentyMealsTitle)
        case "hundred_meals": return LocalizationManager.shared.localizedString(.achHundredMealsTitle)
        case "photo_entry": return LocalizationManager.shared.localizedString(.achPhotoEntryTitle)
        case "healthy_snacks": return LocalizationManager.shared.localizedString(.achHealthySnacksTitle)
        case "breakfast_early": return LocalizationManager.shared.localizedString(.achBreakfastEarlyTitle)
        case "dinner_late": return LocalizationManager.shared.localizedString(.achDinnerLateTitle)
        case "streak_3": return LocalizationManager.shared.localizedString(.achStreak3Title)
        case "streak_7": return LocalizationManager.shared.localizedString(.achStreak7Title)
        case "goal_day": return LocalizationManager.shared.localizedString(.achGoalDayTitle)
        case "goal_week_4": return LocalizationManager.shared.localizedString(.achGoalWeek4Title)
        case "protein_100": return LocalizationManager.shared.localizedString(.achProtein100Title)
        case "veggie_day": return LocalizationManager.shared.localizedString(.achVeggieDayTitle)
        case "week_30_meals": return LocalizationManager.shared.localizedString(.achWeek30MealsTitle)
        case "month_100_meals": return LocalizationManager.shared.localizedString(.achMonth100MealsTitle)
        default: return title
        }
    }

    var localizedDetail: String {
        switch id {
        case "first_meal": return LocalizationManager.shared.localizedString(.achFirstMealDetail)
        case "five_meals": return LocalizationManager.shared.localizedString(.achFiveMealsDetail)
        case "twenty_meals": return LocalizationManager.shared.localizedString(.achTwentyMealsDetail)
        case "hundred_meals": return LocalizationManager.shared.localizedString(.achHundredMealsDetail)
        case "photo_entry": return LocalizationManager.shared.localizedString(.achPhotoEntryDetail)
        case "healthy_snacks": return LocalizationManager.shared.localizedString(.achHealthySnacksDetail)
        case "breakfast_early": return LocalizationManager.shared.localizedString(.achBreakfastEarlyDetail)
        case "dinner_late": return LocalizationManager.shared.localizedString(.achDinnerLateDetail)
        case "streak_3": return LocalizationManager.shared.localizedString(.achStreak3Detail)
        case "streak_7": return LocalizationManager.shared.localizedString(.achStreak7Detail)
        case "goal_day": return LocalizationManager.shared.localizedString(.achGoalDayDetail)
        case "goal_week_4": return LocalizationManager.shared.localizedString(.achGoalWeek4Detail)
        case "protein_100": return LocalizationManager.shared.localizedString(.achProtein100Detail)
        case "veggie_day": return LocalizationManager.shared.localizedString(.achVeggieDayDetail)
        case "week_30_meals": return LocalizationManager.shared.localizedString(.achWeek30MealsDetail)
        case "month_100_meals": return LocalizationManager.shared.localizedString(.achMonth100MealsDetail)
        default: return detail
        }
    }
}

extension Color {
    static func fromHexOrDefault(_ hex: String, defaultColor: Color = PlumpyTheme.primaryAccent) -> Color {
        return Color(hex: hex)
    }
}

