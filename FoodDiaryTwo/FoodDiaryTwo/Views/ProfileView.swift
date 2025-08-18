//
//  ProfileView.swift
//  FoodDiaryTwo
//
//  Created by user on 31.07.2025.
//

import SwiftUI

import SwiftData

struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var showingEditProfile = false
    @State private var showingSettings = false
    @State private var showingCalorieEditor = false
    @State private var showingQuestionnaire = false
    
    @Query private var users: [UserProfile] // Using @Query to fetch user profiles
    @Query private var allFoodEntries: [FoodEntry]
    
    var body: some View {
        ZStack {
            PlumpyBackground(style: .gradient)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Navigation Bar
                PlumpyNavigationBar(
                    title: "Profile",
                    rightButton: PlumpyNavigationButton(
                        icon: "gear",
                        title: "Settings",
                        style: .outline
                    ) {
                        showingSettings = true
                    }
                )
                
                ScrollView {
                    VStack(spacing: PlumpyTheme.Spacing.medium) {
                        // Основная информация профиля
                        profileHeader
                        
                        // Статистика (вся за все время, компактная)
                        profileStats
                        
                        // Управление целями
                        goalsControls
                        
                        // Достижения
                        achievementsSection
                        
                        PlumpySpacer(size: .large)
                    }
                    .padding(.horizontal, PlumpyTheme.Spacing.medium)
                    .padding(.top, PlumpyTheme.Spacing.medium)
                }
            }
        }
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView()
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showingCalorieEditor) {
            CalorieGoalEditor()
        }
        .sheet(isPresented: $showingQuestionnaire) {
            OnboardingQuestionnaireView()
        }
    }
    
    private var profileHeader: some View {
        VStack(spacing: PlumpyTheme.Spacing.large) {
            // Аватар и основная информация
            VStack(spacing: PlumpyTheme.Spacing.medium) {
                // Аватар
                Button(action: {
                    showingEditProfile = true
                }) {
                    ZStack {
                        Circle()
                            .fill(PlumpyTheme.primaryAccent)
                            .frame(width: 80, height: 80)
                            .shadow(
                                color: PlumpyTheme.primaryAccent.opacity(0.3),
                                radius: PlumpyTheme.Shadow.large.radius,
                                x: PlumpyTheme.Shadow.large.x,
                                y: PlumpyTheme.Shadow.large.y
                            )
                        
                        Image(systemName: "person.fill")
                            .font(.system(size: 40))
                            .foregroundColor(PlumpyTheme.textInverse)
                    }
                }
                .overlay(
                    Circle()
                        .stroke(PlumpyTheme.surface, lineWidth: 3)
                        .frame(width: 86, height: 86)
                )
                
                // Имя и email
                VStack(spacing: PlumpyTheme.Spacing.tiny) {
                    Text(users.first?.name ?? "Your Name") // Updated to use users.first
                        .font(PlumpyTheme.Typography.title1)
                        .fontWeight(.bold)
                        .foregroundColor(PlumpyTheme.textPrimary)
                    
                    Text(users.first?.email ?? "No Email") // Updated to use users.first?.email
                        .font(PlumpyTheme.Typography.subheadline)
                        .foregroundColor(PlumpyTheme.textSecondary)
                }
                
                // Кнопка редактирования
                PlumpyButton(
                    title: "Edit Profile",
                    icon: "pencil",
                    style: .outline
                ) {
                    showingEditProfile = true
                }
                .frame(maxWidth: 150)
            }
        }
        .plumpyCard()
    }
    
    private var profileStats: some View {
        VStack(spacing: PlumpyTheme.Spacing.small) {
            Text("All-time")
                .font(PlumpyTheme.Typography.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(PlumpyTheme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: PlumpyTheme.Spacing.large) {
                statPill(title: "Meals", value: String(allTimeTotalMeals), icon: "fork.knife", color: PlumpyTheme.primaryAccent)
                statPill(title: "Calories", value: String(allTimeTotalCalories), icon: "flame.fill", color: PlumpyTheme.warning)
                statPill(title: "Avg/Day", value: String(averageDailyCaloriesAllTime), icon: "chart.line.uptrend.xyaxis", color: PlumpyTheme.secondaryAccent)
            }
        }
        .plumpyCard()
    }

    private func statPill(title: String, value: String, icon: String, color: Color) -> some View {
        HStack(spacing: PlumpyTheme.Spacing.small) {
            Image(systemName: icon)
                .font(.footnote)
                .foregroundColor(color)
                .frame(width: 16, height: 16)
            VStack(alignment: .leading, spacing: PlumpyTheme.Spacing.tiny) {
                Text(value)
                    .font(PlumpyTheme.Typography.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(PlumpyTheme.textPrimary)
                Text(title)
                    .font(PlumpyTheme.Typography.caption2)
                    .foregroundColor(PlumpyTheme.textSecondary)
            }
        }
    }

    private var allTimeTotalMeals: Int { allFoodEntries.count }
    private var allTimeTotalCalories: Int { allFoodEntries.reduce(0) { $0 + $1.totalCalories } }
    private var averageDailyCaloriesAllTime: Int {
        let calendar = Calendar.current
        let uniqueDays = Set(allFoodEntries.map { calendar.startOfDay(for: $0.date) })
        let daysCount = max(uniqueDays.count, 1)
        return allTimeTotalCalories / daysCount
    }
    
    private var achievementsSection: some View {
        VStack(spacing: PlumpyTheme.Spacing.medium) {
            HStack {
                Text("Achievements")
                    .font(PlumpyTheme.Typography.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(PlumpyTheme.textPrimary)
                
                Spacer()
                
                PlumpyBadge(
                    text: "8/15",
                    style: .primary,
                    size: .medium
                )
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: PlumpyTheme.Spacing.medium) {
                    ForEach(0..<8, id: \.self) { index in
                        VStack(spacing: PlumpyTheme.Spacing.small) {
                            Circle()
                                .fill(PlumpyTheme.primaryAccent)
                                .frame(width: 56, height: 56)
                                .overlay(
                                    Image(systemName: achievementIcons[index])
                                        .font(.title2)
                                        .foregroundColor(PlumpyTheme.textInverse)
                                )
                                .shadow(
                                    color: PlumpyTheme.primaryAccent.opacity(0.3),
                                    radius: PlumpyTheme.Shadow.medium.radius,
                                    x: PlumpyTheme.Shadow.medium.x,
                                    y: PlumpyTheme.Shadow.medium.y
                                )
                            
                            Text(achievementTitles[index])
                                .font(PlumpyTheme.Typography.caption1)
                                .fontWeight(.medium)
                                .foregroundColor(PlumpyTheme.textPrimary)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                        }
                        .frame(width: 76)
                    }
                }
                .padding(.horizontal, PlumpyTheme.Spacing.medium)
            }
        }
        .plumpyCard()
    }
    
    // quickActionsSection удален по требованию
    
    // profileSettingsSection удален по требованию
    
    // MARK: - Helper Properties
    
    private var achievementIcons: [String] {
        [
            "flame.fill",
            "target",
            "star.fill",
            "trophy.fill",
            "heart.fill",
            "leaf.fill",
            "sun.max.fill",
            "moon.fill"
        ]
    }
    
    private var achievementTitles: [String] {
        [
            "First Meal",
            "Goal Setter",
            "Streak Master",
            "Calorie Counter",
            "Healthy Eater",
            "Photo Pro",
            "Early Bird",
            "Night Owl"
        ]
    }

    private var goalsControls: some View {
        HStack(spacing: PlumpyTheme.Spacing.medium) {
            PlumpyButton(title: "Edit Calories", icon: "flame.fill", style: .outline) { showingCalorieEditor = true }
            PlumpyButton(title: "Re-run Questionnaire", icon: "list.bullet.rectangle", style: .ghost) { showingQuestionnaire = true }
        }
        .plumpyCard()
    }
}

// MARK: - Edit Profile View

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var firstName = "John"
    @State private var lastName = "Doe"
    @State private var email = "john.doe@example.com"
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    
    var body: some View {
        ZStack {
            PlumpyBackground(style: .primary)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Navigation Bar
                PlumpyNavigationBar(
                    title: "Edit Profile",
                    leftButton: PlumpyNavigationButton(
                        icon: "xmark",
                        title: "Cancel",
                        style: .outline
                    ) {
                        dismiss()
                    },
                    rightButton: PlumpyNavigationButton(
                        icon: "checkmark",
                        title: "Save",
                        style: .primary
                    ) {
                        saveProfile()
                    }
                )
                
                ScrollView {
                    VStack(spacing: PlumpyTheme.Spacing.large) {
                        // Фото профиля
                        profilePhotoSection
                        
                        // Основная информация
                        basicInfoSection
                        
                        PlumpySpacer(size: .huge)
                    }
                    .padding(.horizontal, PlumpyTheme.Spacing.large)
                    .padding(.top, PlumpyTheme.Spacing.large)
                }
            }
        }
    }
    
    private var profilePhotoSection: some View {
        VStack(spacing: PlumpyTheme.Spacing.medium) {
            Text("Profile Photo")
                .font(PlumpyTheme.Typography.headline)
                .fontWeight(.semibold)
                .foregroundColor(PlumpyTheme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Button(action: {
                showingImagePicker = true
            }) {
                VStack(spacing: PlumpyTheme.Spacing.medium) {
                    if let selectedImage = selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .shadow(
                                color: PlumpyTheme.shadow.opacity(0.2),
                                radius: PlumpyTheme.Shadow.medium.radius,
                                x: PlumpyTheme.Shadow.medium.x,
                                y: PlumpyTheme.Shadow.medium.y
                            )
                    } else {
                        Circle()
                            .fill(PlumpyTheme.primaryAccent)
                            .frame(width: 120, height: 120)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(PlumpyTheme.textInverse)
                            )
                    }
                    
                    Text("Tap to change photo")
                        .font(PlumpyTheme.Typography.caption1)
                        .foregroundColor(PlumpyTheme.primaryAccent)
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .plumpyCard()
    }
    
    private var basicInfoSection: some View {
        VStack(spacing: PlumpyTheme.Spacing.medium) {
            Text("Basic Information")
                .font(PlumpyTheme.Typography.headline)
                .fontWeight(.semibold)
                .foregroundColor(PlumpyTheme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            PlumpyField(
                title: "First Name",
                placeholder: "Enter first name",
                text: $firstName,
                icon: "person",
                isRequired: true
            )
            
            PlumpyField(
                title: "Last Name",
                placeholder: "Enter last name",
                text: $lastName,
                icon: "person",
                isRequired: true
            )
            
            PlumpyField(
                title: "Email",
                placeholder: "Enter email address",
                text: $email,
                keyboardType: .emailAddress,
                textContentType: .emailAddress,
                icon: "envelope",
                iconColor: PlumpyTheme.secondaryAccent,
                isRequired: true
            )
        }
        .plumpyCard()
    }
    
    private func saveProfile() {
        dismiss()
    }

}

#Preview {
    ProfileView()
}
