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
    @State private var showingRegistration = false
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
                        
                        // Registration status
                        if !isUserRegistered {
                            registrationPrompt
                        }
                        
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
        let user = users.first
        return VStack(spacing: PlumpyTheme.Spacing.medium) {
            Button(action: { showingEditProfile = true }) {
                ZStack {
                    if let data = user?.profilePhotoData, let ui = UIImage(data: data) {
                        Image(uiImage: ui)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 96, height: 96)
                            .clipShape(Circle())
                            .shadow(
                                color: PlumpyTheme.shadow.opacity(0.2),
                                radius: PlumpyTheme.Shadow.large.radius,
                                x: PlumpyTheme.Shadow.large.x,
                                y: PlumpyTheme.Shadow.large.y
                            )
                    } else {
                        Circle()
                            .fill(PlumpyTheme.primaryAccent)
                            .frame(width: 96, height: 96)
                            .shadow(
                                color: PlumpyTheme.primaryAccent.opacity(0.3),
                                radius: PlumpyTheme.Shadow.large.radius,
                                x: PlumpyTheme.Shadow.large.x,
                                y: PlumpyTheme.Shadow.large.y
                            )
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: 48))
                                    .foregroundColor(PlumpyTheme.textInverse)
                            )
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            .overlay(
                Circle()
                    .stroke(PlumpyTheme.surface, lineWidth: 3)
                    .frame(width: 102, height: 102)
            )
            
            PlumpyButton(title: LocalizationManager.shared.localizedString(.edit), icon: "pencil", style: .outline, size: .small) {
                showingEditProfile = true
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 180)
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
                            
                            Text(ach.localizedTitle)
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
                toastText = "\(LocalizationManager.shared.localizedString(.unlocked)) : \(first.localizedTitle)"
                withAnimation { showAchievementToast = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation { showAchievementToast = false }
                }
            }
        }
        .sheet(isPresented: $showingAchievementDetail) {
            AchievementDetailSheet(selectedAchievement: $selectedAchievement)
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
                dashboardCard(icon: "bolt.heart", title: LocalizationManager.shared.localizedString(.protein), value: user != nil ? String(format: "%.0f g", user!.dailyProteinGoal) : "-")
                dashboardCard(icon: "leaf", title: LocalizationManager.shared.localizedString(.carbs), value: user != nil ? String(format: "%.0f g", user!.dailyCarbsGoal) : "-")
                dashboardCard(icon: "drop", title: LocalizationManager.shared.localizedString(.fat), value: user != nil ? String(format: "%.0f g", user!.dailyFatGoal) : "-")
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
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [UserProfile]
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var showSourceActionSheet = false
    @State private var imageSource: UIImagePickerController.SourceType = .photoLibrary
    
    var body: some View {
        ZStack {
            PlumpyBackground(style: .primary)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Navigation Bar
                PlumpyNavigationBar(
                    title: LocalizationManager.shared.localizedString(.editProfile),
                    leftButton: PlumpyNavigationButton(
                        icon: "xmark",
                        title: LocalizationManager.shared.localizedString(.cancel),
                        style: .outline
                    ) {
                        dismiss()
                    },
                    rightButton: PlumpyNavigationButton(
                        icon: "checkmark",
                        title: LocalizationManager.shared.localizedString(.save),
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
        .onAppear { preload() }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: $selectedImage, sourceType: imageSource)
        }
    }
    
    private var profilePhotoSection: some View {
        VStack(spacing: PlumpyTheme.Spacing.medium) {
            Text(LocalizationManager.shared.localizedString(.profilePhoto))
                .font(PlumpyTheme.Typography.headline)
                .fontWeight(.semibold)
                .foregroundColor(PlumpyTheme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Button(action: {
                showSourceActionSheet = true
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
                    
                    Text(LocalizationManager.shared.localizedString(.tapToChangePhoto))
                        .font(PlumpyTheme.Typography.caption1)
                        .foregroundColor(PlumpyTheme.primaryAccent)
                }
            }
            .buttonStyle(PlainButtonStyle())
            .actionSheet(isPresented: $showSourceActionSheet) {
                ActionSheet(title: Text(LocalizationManager.shared.localizedString(.profilePhoto)), buttons: [
                    .default(Text(LocalizationManager.shared.localizedString(.pickFromGallery))) {
                        imageSource = .photoLibrary
                        showingImagePicker = true
                    },
                    .default(Text(LocalizationManager.shared.localizedString(.takePhoto))) {
                        imageSource = .camera
                        showingImagePicker = true
                    },
                    .cancel(Text(LocalizationManager.shared.localizedString(.cancel)))
                ])
            }
        }
        .plumpyCard()
    }
    
    private var basicInfoSection: some View {
        VStack(spacing: PlumpyTheme.Spacing.medium) {
            Text(LocalizationManager.shared.localizedString(.basicInformation))
                .font(PlumpyTheme.Typography.headline)
                .fontWeight(.semibold)
                .foregroundColor(PlumpyTheme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            PlumpyField(
                title: LocalizationManager.shared.localizedString(.firstName),
                placeholder: LocalizationManager.shared.localizedString(.enterFirstName),
                text: $firstName,
                icon: "person",
                isRequired: true
            )
            
            PlumpyField(
                title: LocalizationManager.shared.localizedString(.lastName),
                placeholder: LocalizationManager.shared.localizedString(.enterLastName),
                text: $lastName,
                icon: "person",
                isRequired: true
            )
            
            PlumpyField(
                title: LocalizationManager.shared.localizedString(.emailAddress),
                placeholder: LocalizationManager.shared.localizedString(.enterEmail),
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
    
    private func preload() {
        if let u = users.first {
            if let data = u.profilePhotoData, let img = UIImage(data: data) {
                selectedImage = img
            }
            email = u.email
            if let fn = u.firstName, !fn.isEmpty { firstName = fn }
            if let ln = u.lastName, !ln.isEmpty { lastName = ln }
            if (firstName.isEmpty && lastName.isEmpty) {
                let comps = u.name.split(separator: " ")
                if let f = comps.first { firstName = String(f) }
                if comps.count > 1 { lastName = comps.dropFirst().joined(separator: " ") }
            }
        }
    }

    private func saveProfile() {
        if let u = users.first {
            // merge first/last into display name if both present
            if !firstName.trimmingCharacters(in: .whitespaces).isEmpty || !lastName.trimmingCharacters(in: .whitespaces).isEmpty {
                u.firstName = firstName.trimmingCharacters(in: .whitespaces)
                u.lastName = lastName.trimmingCharacters(in: .whitespaces)
                let merged = [u.firstName ?? "", u.lastName ?? ""].joined(separator: " ").trimmingCharacters(in: .whitespaces)
                if !merged.isEmpty { u.name = merged }
            }
            u.email = email
            if let img = selectedImage, let data = img.jpegData(compressionQuality: 0.9) {
                u.profilePhotoData = data
            }
            try? modelContext.save()
        }
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
            
            Text(achievement.localizedTitle)
                .font(PlumpyTheme.Typography.title3)
                .foregroundColor(PlumpyTheme.textPrimary)
            
            Text(achievement.localizedDetail)
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
        .sheet(isPresented: $showingRegistration) {
            RegistrationView(
                onRegistrationComplete: {
                    showingRegistration = false
                },
                onSkip: {
                    UserDefaults.standard.set(true, forKey: "registrationSkipped")
                    showingRegistration = false
                }
            )
        }
    }
    
    // MARK: - Computed Properties
    
    var isUserRegistered: Bool {
        return UserDefaults.standard.bool(forKey: "isRegistered")
    }
    
    var isRegistrationSkipped: Bool {
        return UserDefaults.standard.bool(forKey: "registrationSkipped")
    }
    
    // MARK: - Registration Section
    
    var registrationPrompt: some View {
        VStack(spacing: PlumpyTheme.Spacing.medium) {
            HStack {
                Image(systemName: "person.crop.circle.badge.plus")
                    .font(.title2)
                    .foregroundColor(PlumpyTheme.primary)
                
                VStack(alignment: .leading, spacing: PlumpyTheme.Spacing.small) {
                    Text(LocalizationManager.shared.localizedString(.pleaseRegister))
                        .font(PlumpyTheme.Typography.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(PlumpyTheme.textPrimary)
                    
                    Text(LocalizationManager.shared.localizedString(.registerToSyncData))
                        .font(PlumpyTheme.Typography.caption1)
                        .foregroundColor(PlumpyTheme.textSecondary)
                        .lineLimit(nil)
                }
                
                Spacer()
            }
            
            PlumpyButton(
                title: LocalizationManager.shared.localizedString(.registerNow),
                icon: "arrow.right",
                style: .primary,
                size: .small
            ) {
                showingRegistration = true
            }
        }
        .padding(PlumpyTheme.Spacing.medium)
        .background(
            RoundedRectangle(cornerRadius: PlumpyTheme.Radius.large)
                .fill(PlumpyTheme.primary.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: PlumpyTheme.Radius.large)
                        .stroke(PlumpyTheme.primary.opacity(0.2), lineWidth: 1)
                )
        )
        .shadow(
            color: PlumpyTheme.shadow.opacity(0.05),
            radius: 8,
            x: 0,
            y: 4
        )
    }
}

#Preview {
    ProfileView()
}

// Wrapper to address first-open empty sheet by always providing non-optional content
struct AchievementDetailSheet: View {
    @Binding var selectedAchievement: Achievement?
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        if let ach = selectedAchievement {
            AchievementDetailView(achievement: ach)
        } else {
            VStack { ProgressView().padding(); Button(LocalizationManager.shared.localizedString(.ok)) { dismiss() } }
                .padding()
        }
    }
}
