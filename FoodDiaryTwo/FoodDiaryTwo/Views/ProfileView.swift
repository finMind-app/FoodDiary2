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
    @State private var navigateQuestionnaire = false
    @State private var showingAchievementDetail = false
    @State private var selectedAchievement: Achievement?
    @State private var showAchievementToast = false
    @State private var toastText = ""
    @Query private var achievementsQuery: [Achievement]
    
    @Query private var users: [UserProfile] // Using @Query to fetch user profiles
    @Query private var allFoodEntries: [FoodEntry]
    
    var body: some View {
        NavigationStack {
        ZStack {
            PlumpyBackground(style: .gradient)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Navigation Bar
                PlumpyNavigationBar(
                    title: LocalizationManager.shared.localizedString(.profile),
                    rightButton: PlumpyNavigationButton(
                        icon: "gear",
                        title: LocalizationManager.shared.localizedString(.settings),
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
                        
                        // Мини-дэшборд с данными анкеты
                        profileInfoDashboard
                        
                        // Достижения
                        achievementsSection
                        
                        PlumpySpacer(size: .large)
                    }
                    .padding(.horizontal, PlumpyTheme.Spacing.medium)
                    .padding(.top, PlumpyTheme.Spacing.medium)
                }
                // Hidden navigation link for questionnaire
                NavigationLink(isActive: $navigateQuestionnaire) {
                    OnboardingFlowView()
                } label: { EmptyView() }
            }
        }
        .achievementToast(isPresented: showAchievementToast, text: toastText)
        }
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView()
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(modelContext: modelContext)
        }
        .sheet(isPresented: $showingCalorieEditor) {
            CalorieGoalEditor()
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
                    Text(users.first?.name ?? LocalizationManager.shared.localizedString(.userName)) // Updated to use users.first
                        .font(PlumpyTheme.Typography.title1)
                        .fontWeight(.bold)
                        .foregroundColor(PlumpyTheme.textPrimary)
                    
                    Text(users.first?.email ?? LocalizationManager.shared.localizedString(.emailAddress)) // Updated to use users.first?.email
                        .font(PlumpyTheme.Typography.subheadline)
                        .foregroundColor(PlumpyTheme.textSecondary)
                }
                
                // Кнопка редактирования
                PlumpyButton(
                    title: LocalizationManager.shared.localizedString(.editProfile),
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
            Text(LocalizationManager.shared.localizedString(.allTime))
                .font(PlumpyTheme.Typography.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(PlumpyTheme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: PlumpyTheme.Spacing.large) {
                statPill(title: LocalizationManager.shared.localizedString(.mealsLabel), value: String(allTimeTotalMeals), icon: "fork.knife", color: PlumpyTheme.primaryAccent)
                statPill(title: LocalizationManager.shared.localizedString(.calories), value: String(allTimeTotalCalories), icon: "flame.fill", color: PlumpyTheme.warning)
                statPill(title: LocalizationManager.shared.localizedString(.avgPerDay), value: String(averageDailyCaloriesAllTime), icon: "chart.line.uptrend.xyaxis", color: PlumpyTheme.secondaryAccent)
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
                Text(LocalizationManager.shared.localizedString(.achievements))
                    .font(PlumpyTheme.Typography.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(PlumpyTheme.textPrimary)
                
                Spacer()
                
                let unlockedCount = achievementsQuery.filter { $0.isUnlocked }.count
                let totalCount = achievementsQuery.count
                PlumpyBadge(text: "\(unlockedCount)/\(max(totalCount, 1))", style: .primary, size: .medium)
            }
            
            let achievements = achievementsQuery.sorted { a, b in
                if a.isUnlocked != b.isUnlocked { return a.isUnlocked && !b.isUnlocked }
                return a.title < b.title
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: PlumpyTheme.Spacing.medium) {
                    ForEach(achievements, id: \.id) { ach in
                        VStack(spacing: PlumpyTheme.Spacing.small) {
                            Button(action: {
                                selectedAchievement = ach
                                showingAchievementDetail = true
                            }) {
                                Circle()
                                    .fill(ach.isUnlocked ? Color(hex: ach.colorHex) : PlumpyTheme.neutral700)
                                    .frame(width: 56, height: 56)
                                    .overlay(
                                        Image(systemName: ach.icon)
                                            .font(.title2)
                                            .foregroundColor(ach.isUnlocked ? PlumpyTheme.textInverse : PlumpyTheme.textTertiary)
                                    )
                                    .shadow(
                                        color: (ach.isUnlocked ? Color(hex: ach.colorHex) : PlumpyTheme.neutral700).opacity(0.3),
                                        radius: PlumpyTheme.Shadow.medium.radius,
                                        x: PlumpyTheme.Shadow.medium.x,
                                        y: PlumpyTheme.Shadow.medium.y
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Text(ach.title)
                                .font(PlumpyTheme.Typography.caption1)
                                .fontWeight(.medium)
                                .foregroundColor(PlumpyTheme.textPrimary)
                                .multilineTextAlignment(.center)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(width: 76)
                    }
                }
                .padding(.horizontal, PlumpyTheme.Spacing.medium)
            }
        }
        .plumpyCard()
        .onAppear {
            let newly = AchievementsService.shared.evaluateAndSync(in: modelContext)
            if let first = newly.first {
                toastText = "\(LocalizationManager.shared.localizedString(.unlocked)) : \(first.title)"
                withAnimation { showAchievementToast = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation { showAchievementToast = false }
                }
            }
        }
        .sheet(isPresented: $showingAchievementDetail) {
            if let ach = selectedAchievement {
                AchievementDetailView(achievement: ach)
            }
        }
    }
    
    // MARK: - Helper Properties
    
    // legacy arrays removed

    private var goalsControls: some View {
        VStack(spacing: PlumpyTheme.Spacing.small) {
            HStack(spacing: PlumpyTheme.Spacing.medium) {
                PlumpyButton(title: LocalizationManager.shared.localizedString(.editDailyCalories), icon: "flame.fill", style: .outline, size: .small) { showingCalorieEditor = true }
                PlumpyButton(title: LocalizationManager.shared.localizedString(.runQuestionnaire), icon: "list.bullet.rectangle", style: .outline, size: .small) { navigateQuestionnaire = true }
            }
        }
        .plumpyCard()
    }

    private var profileInfoDashboard: some View {
        let user = users.first
        return VStack(spacing: PlumpyTheme.Spacing.small) {
            Text(LocalizationManager.shared.localizedString(.profileSummary))
                .font(PlumpyTheme.Typography.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(PlumpyTheme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: PlumpyTheme.Spacing.medium), count: 2), spacing: PlumpyTheme.Spacing.medium) {
                dashboardCard(icon: "target", title: LocalizationManager.shared.localizedString(.goal), value: user?.goal.displayName ?? "-")
                dashboardCard(icon: "flame.fill", title: LocalizationManager.shared.localizedString(.calories), value: user != nil ? "\(DailyGoalsService.shared.getDailyCalorieGoal(from: modelContext)) \(LocalizationManager.shared.localizedString(.calUnit))" : "-")
                dashboardCard(icon: "ruler", title: LocalizationManager.shared.localizedString(.heightLabel), value: user != nil ? "\(Int(user!.height)) \(LocalizationManager.shared.localizedString(.cmUnit))" : "-")
                dashboardCard(icon: "scalemass", title: LocalizationManager.shared.localizedString(.weightLabel), value: user != nil ? String(format: "%.1f \(LocalizationManager.shared.localizedString(.kgUnit))", user!.weight) : "-")
                dashboardCard(icon: "heart.text.square", title: LocalizationManager.shared.localizedString(.bmiLabel), value: user != nil ? String(format: "%.1f", user!.bmi) : "-")
                dashboardCard(icon: "calendar", title: LocalizationManager.shared.localizedString(.ageLabel), value: user != nil ? "\(user!.age) \(LocalizationManager.shared.localizedString(.yearsSuffix))" : "-")
            }
            .frame(maxWidth: .infinity)
            .animation(.easeInOut(duration: 0.3), value: user?.goal)
            .animation(.easeInOut(duration: 0.3), value: DailyGoalsService.shared.getDailyCalorieGoal(from: modelContext))
        }
        .plumpyCard()
    }
 
    private func dashboardCard(icon: String, title: String, value: String) -> some View {
        HStack(spacing: PlumpyTheme.Spacing.medium) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(PlumpyTheme.primaryAccent)
                .frame(width: 24, height: 24)
            VStack(alignment: .leading, spacing: PlumpyTheme.Spacing.tiny) {
                Text(value)
                    .font(PlumpyTheme.Typography.caption1)
                    .fontWeight(.semibold)
                    .foregroundColor(PlumpyTheme.textPrimary)
                    .lineLimit(3)
                    .minimumScaleFactor(0.6)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
                Text(title)
                    .font(PlumpyTheme.Typography.caption2)
                    .foregroundColor(PlumpyTheme.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            Spacer()
        }
        .padding(.horizontal, PlumpyTheme.Spacing.medium)
        .padding(.vertical, PlumpyTheme.Spacing.small)
        .frame(height: 80) // Только фиксированная высота
        .background(PlumpyTheme.surfaceSecondary)
        .clipShape(RoundedRectangle(cornerRadius: PlumpyTheme.Radius.medium))
        .overlay(
            RoundedRectangle(cornerRadius: PlumpyTheme.Radius.medium)
                .stroke(PlumpyTheme.neutral200, lineWidth: 1)
        )
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

// MARK: - Achievement Detail View

struct AchievementDetailView: View {
    let achievement: Achievement
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: PlumpyTheme.Spacing.medium) {
            HStack {
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .foregroundColor(PlumpyTheme.textSecondary)
                }
            }
            
            Circle()
                .fill(achievement.isUnlocked ? Color(hex: achievement.colorHex) : PlumpyTheme.neutral700)
                .frame(width: 64, height: 64)
                .overlay(
                    Image(systemName: achievement.icon)
                        .font(.title2)
                        .foregroundColor(achievement.isUnlocked ? PlumpyTheme.textInverse : PlumpyTheme.textTertiary)
                )
            
            Text(achievement.title)
                .font(PlumpyTheme.Typography.title3)
                .foregroundColor(PlumpyTheme.textPrimary)
            
            Text(achievement.detail)
                .font(PlumpyTheme.Typography.body)
                .foregroundColor(PlumpyTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, PlumpyTheme.Spacing.large)
            
            if !achievement.isUnlocked {
                ProgressView(value: min(1, achievement.target == 0 ? 0 : achievement.progress / achievement.target))
                    .tint(PlumpyTheme.primaryAccent)
            }
            
            Spacer()
        }
        .padding()
        .background(PlumpyTheme.surface)
        .presentationDetents([.fraction(0.35)])
    }
}

// MARK: - Toast Overlay Modifier
extension View {
    func achievementToast(isPresented: Bool, text: String) -> some View {
        ZStack(alignment: .top) {
            self
            if isPresented {
                HStack {
                    Image(systemName: "trophy.fill")
                        .foregroundColor(PlumpyTheme.textInverse)
                    Text(text)
                        .font(PlumpyTheme.Typography.caption1)
                        .foregroundColor(PlumpyTheme.textInverse)
                }
                .padding(.horizontal, PlumpyTheme.Spacing.medium)
                .padding(.vertical, PlumpyTheme.Spacing.small)
                .background(PlumpyTheme.primaryAccent)
                .clipShape(RoundedRectangle(cornerRadius: PlumpyTheme.Radius.medium))
                .padding(.top, 16)
            }
        }
    }
}

#Preview {
    ProfileView()
}
