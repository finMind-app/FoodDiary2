//
//  AppSettings.swift
//  FoodDiaryTwo
//
//  Created by user on 31.07.2025.
//

import Foundation
import SwiftData

@Model
final class AppSettings {
    var id: UUID
    var notificationsEnabled: Bool
    var reminderTime: Date
    var calorieRemindersEnabled: Bool
    var darkModeEnabled: Bool
    var selectedLanguage: String
    var region: String
    var dataExportEnabled: Bool
    var appVersion: String
    var createdAt: Date
    var updatedAt: Date
    
    init() {
        self.id = UUID()
        self.notificationsEnabled = true
        self.reminderTime = Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date()
        self.calorieRemindersEnabled = true
        self.darkModeEnabled = false
        self.selectedLanguage = "English"
        self.region = "United States"
        self.dataExportEnabled = false
        self.appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    // MARK: - Notification Settings
    
    func updateNotificationSettings(enabled: Bool, time: Date, calorieReminders: Bool) {
        self.notificationsEnabled = enabled
        self.reminderTime = time
        self.calorieRemindersEnabled = calorieReminders
        self.updatedAt = Date()
    }
    
    // MARK: - Appearance Settings
    
    func updateAppearanceSettings(darkMode: Bool) {
        self.darkModeEnabled = darkMode
        self.updatedAt = Date()
    }
    
    // MARK: - Language & Region Settings
    
    func updateLanguageSettings(language: String, region: String) {
        self.selectedLanguage = language
        self.region = region
        self.updatedAt = Date()
    }
    
    // MARK: - Data Management Settings
    
    func updateDataExportSettings(enabled: Bool) {
        self.dataExportEnabled = enabled
        self.updatedAt = Date()
    }
    
    // MARK: - Helper Methods
    
    var reminderTimeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: reminderTime)
    }
    
    var isFirstLaunch: Bool {
        return createdAt == updatedAt
    }
}

// MARK: - App Settings Manager

class AppSettingsManager: ObservableObject {
    @Published var settings: AppSettings?
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadSettings()
    }
    
    private func loadSettings() {
        let descriptor = FetchDescriptor<AppSettings>()
        do {
            let settings = try modelContext.fetch(descriptor)
            if let firstSettings = settings.first {
                self.settings = firstSettings
            } else {
                // Создаем настройки по умолчанию
                let newSettings = AppSettings()
                modelContext.insert(newSettings)
                try modelContext.save()
                self.settings = newSettings
            }
        } catch {
            print("Error loading app settings: \(error)")
            // Создаем настройки по умолчанию в случае ошибки
            let newSettings = AppSettings()
            modelContext.insert(newSettings)
            do {
                try modelContext.save()
                self.settings = newSettings
            } catch {
                print("Error saving default settings: \(error)")
            }
        }
    }
    
    func saveSettings() {
        do {
            try modelContext.save()
        } catch {
            print("Error saving app settings: \(error)")
        }
    }
    
    // MARK: - Notification Settings
    
    func updateNotificationSettings(enabled: Bool, time: Date, calorieReminders: Bool) {
        settings?.updateNotificationSettings(enabled: enabled, time: time, calorieReminders: calorieReminders)
        saveSettings()
    }
    
    // MARK: - Appearance Settings
    
    func updateAppearanceSettings(darkMode: Bool) {
        settings?.updateAppearanceSettings(darkMode: darkMode)
        saveSettings()
    }
    
    // MARK: - Language & Region Settings
    
    func updateLanguageSettings(language: String, region: String) {
        settings?.updateLanguageSettings(language: language, region: region)
        saveSettings()
    }
    
    // MARK: - Data Management Settings
    
    func updateDataExportSettings(enabled: Bool) {
        settings?.updateDataExportSettings(enabled: enabled)
        saveSettings()
    }
    
    // MARK: - Data Export
    
    func exportData() -> String? {
        let descriptor = FetchDescriptor<FoodEntry>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        
        do {
            let entries = try modelContext.fetch(descriptor)
            let userDescriptor = FetchDescriptor<UserProfile>()
            let users = try modelContext.fetch(userDescriptor)
            let user = users.first
            
            var exportString = "Food Diary Export\n"
            exportString += "Date: \(Date())\n"
            exportString += "Version: \(settings?.appVersion ?? "1.0.0")\n"
            exportString += "User: \(user?.name ?? "Unknown")\n"
            exportString += "Daily Calorie Goal: \(user?.dailyCalorieGoal ?? 0) cal\n\n"
            
            exportString += "Food Entries (\(entries.count) total):\n"
            exportString += String(repeating: "=", count: 50) + "\n\n"
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            
            for entry in entries {
                exportString += "Date: \(dateFormatter.string(from: entry.date))\n"
                exportString += "Meal Type: \(entry.mealType.displayName)\n"
                exportString += "Food: \(entry.name)\n"
                exportString += "Calories: \(entry.totalCalories) cal\n"
                exportString += "Protein: \(String(format: "%.1f", entry.totalProtein))g\n"
                exportString += "Carbs: \(String(format: "%.1f", entry.totalCarbs))g\n"
                exportString += "Fat: \(String(format: "%.1f", entry.totalFat))g\n"
                if let notes = entry.notes, !notes.isEmpty {
                    exportString += "Notes: \(notes)\n"
                }
                exportString += String(repeating: "-", count: 30) + "\n"
            }
            
            return exportString
        } catch {
            print("Error exporting data: \(error)")
            return "Error exporting data: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Clear All Data
    
    func clearAllData() {
        // Удаляем все записи о еде
        let foodDescriptor = FetchDescriptor<FoodEntry>()
        let productDescriptor = FetchDescriptor<FoodProduct>()
        
        do {
            let foodEntries = try modelContext.fetch(foodDescriptor)
            let foodProducts = try modelContext.fetch(productDescriptor)
            
            for entry in foodEntries {
                modelContext.delete(entry)
            }
            
            for product in foodProducts {
                modelContext.delete(product)
            }
            
            try modelContext.save()
        } catch {
            print("Error clearing data: \(error)")
        }
    }
}
