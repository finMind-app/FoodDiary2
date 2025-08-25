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
        Achievement(id: "first_meal", title: "First Meal", detail: "Log your very first meal.", icon: "fork.knife", colorHex: "#10B981"),
        Achievement(id: "five_meals", title: "Getting Started", detail: "Log 5 meals in total.", icon: "fork.knife.circle", colorHex: "#3B82F6", target: 5),
        Achievement(id: "twenty_meals", title: "Meal Enthusiast", detail: "Log 20 meals in total.", icon: "takeoutbag.and.cup.and.straw.fill", colorHex: "#6366F1", target: 20),
        Achievement(id: "hundred_meals", title: "Meal Master", detail: "Log 100 meals in total.", icon: "fork.knife.circle.fill", colorHex: "#8B5CF6", target: 100),
        Achievement(id: "photo_entry", title: "Photo Pro", detail: "Attach a photo to a meal.", icon: "camera.fill", colorHex: "#EC4899"),
        Achievement(id: "healthy_snacks", title: "Snack Smart", detail: "Log 10 snacks.", icon: "leaf.fill", colorHex: "#22C55E", target: 10),
        Achievement(id: "breakfast_early", title: "Early Bird", detail: "Log a breakfast before 8 AM.", icon: "sunrise.fill", colorHex: "#F59E0B"),
        Achievement(id: "dinner_late", title: "Night Owl", detail: "Log a dinner after 9 PM.", icon: "moon.stars.fill", colorHex: "#0EA5E9"),
        Achievement(id: "streak_3", title: "3-Day Streak", detail: "Log meals 3 days in a row.", icon: "flame.fill", colorHex: "#F97316", target: 3),
        Achievement(id: "streak_7", title: "7-Day Streak", detail: "Log meals 7 days in a row.", icon: "flame.circle.fill", colorHex: "#FB923C", target: 7),
        Achievement(id: "goal_day", title: "On Target", detail: "Hit your daily calorie goal.", icon: "target", colorHex: "#16A34A"),
        Achievement(id: "goal_week_4", title: "Consistency", detail: "Hit your goal on 4 days in a week.", icon: "target.circle", colorHex: "#22C55E", target: 4),
        Achievement(id: "protein_100", title: "Protein Punch", detail: "Reach 100g protein in a day.", icon: "bolt.fill", colorHex: "#F59E0B"),
        Achievement(id: "veggie_day", title: "Veggie Day", detail: "Log 5 different products in a day.", icon: "leaf.circle.fill", colorHex: "#84CC16", target: 5),
        Achievement(id: "week_30_meals", title: "Busy Week", detail: "Log 30 meals in a week.", icon: "calendar", colorHex: "#06B6D4", target: 30),
        Achievement(id: "month_100_meals", title: "Power Logger", detail: "Log 100 meals in a month.", icon: "calendar.circle.fill", colorHex: "#0EA5E9", target: 100)
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

extension Color {
    static func fromHexOrDefault(_ hex: String, defaultColor: Color = PlumpyTheme.primaryAccent) -> Color {
        return Color(hex: hex)
    }
}

