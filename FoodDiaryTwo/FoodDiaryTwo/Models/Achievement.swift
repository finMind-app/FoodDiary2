//
//  Achievement.swift
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
        case "streak_3": return LocalizationManager.shared.localizedString(.achStreak3Title)
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
