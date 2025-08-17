//
//  SettingsView.swift
//  FoodDiaryTwo
//
//  Created by user on 31.07.2025.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @State private var notificationsEnabled = true
    @State private var darkModeEnabled = false
    @State private var selectedLanguage = "English"
    @State private var dailyGoal = 2000
    
    let languages = ["English", "Русский", "Español", "Français"]
    
    var body: some View {
        ZStack {
            PlumpyBackground(style: .primary)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Navigation Bar
                PlumpyNavigationBar(
                    title: "Settings",
                    subtitle: "App preferences"
                )
                
                ScrollView {
                    VStack(spacing: PlumpyTheme.Spacing.large) {
                        // Профиль
                        profileSection
                        
                        // Настройки приложения
                        appSettingsSection
                        
                        // Цели
                        goalsSection
                        
                        // О приложении
                        aboutSection
                        
                        PlumpySpacer(size: .huge)
                    }
                    .padding(.horizontal, PlumpyTheme.Spacing.medium)
                    .padding(.top, PlumpyTheme.Spacing.medium)
                }
            }
        }
    }
    
    private var profileSection: some View {
        VStack(spacing: PlumpyTheme.Spacing.medium) {
            Text("Profile Settings")
                .font(PlumpyTheme.Typography.headline)
                .fontWeight(.semibold)
                .foregroundColor(PlumpyTheme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: PlumpyTheme.Spacing.small) {
                PlumpyInfoCard(
                    title: "Personal Information",
                    subtitle: "Edit your name, email, and photo",
                    icon: "person.circle",
                    iconColor: PlumpyTheme.primaryAccent
                ) {
                    // Открытие редактирования профиля
                }
                
                PlumpyInfoCard(
                    title: "Goals & Targets",
                    subtitle: "Set your daily calorie goals",
                    icon: "target",
                    iconColor: PlumpyTheme.success
                ) {
                    // Открытие настроек целей
                }
                
                PlumpyInfoCard(
                    title: "Notifications",
                    subtitle: "Manage your notification preferences",
                    icon: "bell.fill",
                    iconColor: PlumpyTheme.warning
                ) {
                    // Открытие настроек уведомлений
                }
                
                PlumpyInfoCard(
                    title: "Privacy & Security",
                    subtitle: "Control your privacy settings",
                    icon: "lock.fill",
                    iconColor: PlumpyTheme.info
                ) {
                    // Открытие настроек приватности
                }
            }
        }
        .plumpyCard()
    }
    
    private var appSettingsSection: some View {
        VStack(spacing: PlumpyTheme.Spacing.medium) {
            Text("App Settings")
                .font(PlumpyTheme.Typography.headline)
                .fontWeight(.semibold)
                .foregroundColor(PlumpyTheme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: PlumpyTheme.Spacing.small) {
                PlumpyInfoCard(
                    title: "Notifications",
                    subtitle: notificationsEnabled ? "Enabled" : "Disabled",
                    icon: "bell.fill",
                    iconColor: notificationsEnabled ? PlumpyTheme.success : PlumpyTheme.textTertiary
                ) {
                    notificationsEnabled.toggle()
                }
                
                PlumpyInfoCard(
                    title: "Dark Mode",
                    subtitle: darkModeEnabled ? "Enabled" : "Disabled",
                    icon: "moon.fill",
                    iconColor: darkModeEnabled ? PlumpyTheme.tertiaryAccent : PlumpyTheme.textTertiary
                ) {
                    darkModeEnabled.toggle()
                }
                
                PlumpyInfoCard(
                    title: "Language",
                    subtitle: selectedLanguage,
                    icon: "globe",
                    iconColor: PlumpyTheme.info
                ) {
                    // Выбор языка
                }
            }
        }
        .plumpyCard()
    }
    
    private var goalsSection: some View {
        VStack(spacing: PlumpyTheme.Spacing.medium) {
            Text("Goals")
                .font(PlumpyTheme.Typography.headline)
                .fontWeight(.semibold)
                .foregroundColor(PlumpyTheme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: PlumpyTheme.Spacing.medium) {
                VStack(alignment: .leading, spacing: PlumpyTheme.Spacing.small) {
                    Text("Daily Calorie Goal")
                        .font(PlumpyTheme.Typography.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(PlumpyTheme.textSecondary)
                    
                    HStack {
                        Text("\(dailyGoal)")
                            .font(PlumpyTheme.Typography.title2)
                            .fontWeight(.bold)
                            .foregroundColor(PlumpyTheme.primaryAccent)
                        
                        Text("calories")
                            .font(PlumpyTheme.Typography.caption1)
                            .foregroundColor(PlumpyTheme.textSecondary)
                        
                        Spacer()
                        
                        PlumpyButton(
                            title: "Change",
                            icon: "pencil",
                            style: .outline
                        ) {
                            // Изменение цели
                        }
                        .frame(maxWidth: 100)
                    }
                }
                
                PlumpyProgressBar(
                    value: 1250,
                    maxValue: Double(dailyGoal),
                    title: "Today's Progress",
                    showPercentage: true,
                    style: .primary
                )
            }
        }
        .plumpyCard()
    }
    
    private var aboutSection: some View {
        VStack(spacing: PlumpyTheme.Spacing.medium) {
            Text("About")
                .font(PlumpyTheme.Typography.headline)
                .fontWeight(.semibold)
                .foregroundColor(PlumpyTheme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: PlumpyTheme.Spacing.small) {
                PlumpyInfoCard(
                    title: "Version",
                    subtitle: "1.0.0",
                    icon: "info.circle",
                    iconColor: PlumpyTheme.info,
                    action: {}
                )
                
                PlumpyInfoCard(
                    title: "Developer",
                    subtitle: "Food Diary Team",
                    icon: "person.2.fill",
                    iconColor: PlumpyTheme.primaryAccent,
                    action: {}
                )
                
                PlumpyInfoCard(
                    title: "Privacy Policy",
                    subtitle: "Read our privacy policy",
                    icon: "hand.raised.fill",
                    iconColor: PlumpyTheme.secondaryAccent,
                    action: {
                        // Открытие политики конфиденциальности
                    }
                )
                
                PlumpyInfoCard(
                    title: "Terms of Service",
                    subtitle: "Read our terms of service",
                    icon: "doc.text.fill",
                    iconColor: PlumpyTheme.tertiaryAccent,
                    action: {
                        // Открытие условий использования
                    }
                )
            }
        }
        .plumpyCard()
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [FoodEntry.self, FoodProduct.self, UserProfile.self], inMemory: true)
}
