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
    
    @Query private var users: [UserProfile] // Using @Query to fetch user profiles

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
                        
                        // Статистика
                        profileStats
                        
                        // Достижения
                        achievementsSection
                        
                        // Быстрые действия
                        quickActionsSection
                        
                        // Настройки профиля
                        profileSettingsSection
                        
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
        VStack(spacing: PlumpyTheme.Spacing.medium) {
            Text("Your Stats")
                .font(PlumpyTheme.Typography.headline)
                .fontWeight(.semibold)
                .foregroundColor(PlumpyTheme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: PlumpyTheme.Spacing.medium) {
                PlumpyStatsCard(
                    title: "Total Meals",
                    value: "156",
                    subtitle: "This month",
                    icon: "fork.knife",
                    iconColor: PlumpyTheme.primaryAccent,
                    trend: .up
                )
                
                PlumpyStatsCard(
                    title: "Calories",
                    value: "42,350",
                    subtitle: "This month",
                    icon: "flame.fill",
                    iconColor: PlumpyTheme.warning,
                    trend: .up
                )
                
                PlumpyStatsCard(
                    title: "Streak",
                    value: "12",
                    subtitle: "Days in a row",
                    icon: "flame.fill",
                    iconColor: PlumpyTheme.error,
                    trend: .up
                )
                
                PlumpyStatsCard(
                    title: "Goal Met",
                    value: "78%",
                    subtitle: "Of days",
                    icon: "target",
                    iconColor: PlumpyTheme.success,
                    trend: .neutral
                )
            }
        }
        .plumpyCard()
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
                                .frame(width: 60, height: 60)
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
                        .frame(width: 80)
                    }
                }
                .padding(.horizontal, PlumpyTheme.Spacing.medium)
            }
        }
        .plumpyCard()
    }
    
    private var quickActionsSection: some View {
        VStack(spacing: PlumpyTheme.Spacing.medium) {
            Text("Quick Actions")
                .font(PlumpyTheme.Typography.headline)
                .fontWeight(.semibold)
                .foregroundColor(PlumpyTheme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: PlumpyTheme.Spacing.medium) {
                PlumpyActionIconButton(
                    systemImageName: "plus.circle.fill",
                    title: "Add Meal",
                    color: PlumpyTheme.primaryAccent
                ) {
                    // Действие добавления приема пищи
                }
                
                PlumpyActionIconButton(
                    systemImageName: "camera.fill",
                    title: "Take Photo",
                    color: PlumpyTheme.secondaryAccent
                ) {
                    // Действие фото
                }
                
                PlumpyActionIconButton(
                    systemImageName: "chart.bar.fill",
                    title: "View Stats",
                    color: PlumpyTheme.tertiaryAccent
                ) {
                    // Действие просмотра статистики
                }
                
                PlumpyActionIconButton(
                    systemImageName: "trophy.fill",
                    title: "Achievements",
                    color: PlumpyTheme.warning
                ) {
                    // Действие достижений
                }
            }
        }
        .plumpyCard()
    }
    
    private var profileSettingsSection: some View {
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
                    showingEditProfile = true
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
