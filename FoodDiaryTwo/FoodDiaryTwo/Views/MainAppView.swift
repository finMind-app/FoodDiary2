//
//  MainAppView.swift
//  FoodDiaryTwo
//
//  Created by user on 31.07.2025.
//

import SwiftUI
import SwiftData

struct MainAppView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var showingSplash = true
    @State private var splashOpacity = 1.0
    @State private var appSettingsManager: AppSettingsManager?
    @State private var showingOnboarding = false
    @State private var hasCheckedOnboarding = false
    
    // Переключение между версиями сплеш скрина (true = основная, false = простая)
    private let useAdvancedSplash = true
    
    var body: some View {
        ZStack {
            // Основное приложение
            ContentView()
                .opacity(showingSplash || showingOnboarding ? 0 : 1)
                .animation(.easeInOut(duration: 0.5), value: showingSplash)
                .animation(.easeInOut(duration: 0.5), value: showingOnboarding)
            
            // Онбординг
            if showingOnboarding {
                NewOnboardingFlowView(onComplete: {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showingOnboarding = false
                    }
                })
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.5), value: showingOnboarding)
            }
            
            // Сплеш скрин
            if showingSplash {
                Group {
                    if useAdvancedSplash {
                        SplashScreenView()
                    } else {
                        SimpleSplashScreenView()
                    }
                }
                .opacity(splashOpacity)
                .animation(.easeInOut(duration: 0.5), value: splashOpacity)
                .onAppear {
                    // Ensure theme is applied at app launch
                    if appSettingsManager == nil {
                        appSettingsManager = AppSettingsManager(modelContext: modelContext)
                    }

                    // Evaluate achievements on launch to seed and refresh
                    _ = AchievementsService.shared.evaluateAndSync(in: modelContext)
                    
                    // Initialize RemoteConfigService to preload API key
                    initializeRemoteConfig()

                    // Показываем сплеш скрин на 2.5 секунды
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            splashOpacity = 0
                        }
                        
                        // Скрываем сплеш скрин после анимации исчезновения
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            showingSplash = false
                            checkForOnboarding()
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Onboarding Check
    private func checkForOnboarding() {
        guard !hasCheckedOnboarding else { return }
        hasCheckedOnboarding = true
        
        // Check if this is the first launch or if user profile doesn't exist
        let userDescriptor = FetchDescriptor<UserProfile>()
        let settingsDescriptor = FetchDescriptor<AppSettings>()
        
        do {
            let users = try modelContext.fetch(userDescriptor)
            let settings = try modelContext.fetch(settingsDescriptor)
            
            let shouldShowOnboarding = users.isEmpty || (settings.first?.isFirstLaunch ?? true)
            
            if shouldShowOnboarding {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showingOnboarding = true
                    }
                }
            }
        } catch {
            print("Error checking onboarding status: \(error)")
            // Show onboarding as fallback
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showingOnboarding = true
                }
            }
        }
    }
    
    // MARK: - RemoteConfig Initialization
    private func initializeRemoteConfig() {
        let remoteConfigService = RemoteConfigService()
        
        // Preload API key during splash screen
        remoteConfigService.getAPIKey { apiKey in
            if let apiKey = apiKey {
                print("✅ MainAppView: API ключ успешно загружен при запуске")
                print("🔑 Ключ: \(String(apiKey.prefix(20)))...")
            } else {
                print("⚠️ MainAppView: Не удалось загрузить API ключ при запуске")
            }
        }
    }
}

#Preview {
    MainAppView()
        .modelContainer(for: [FoodEntry.self, FoodProduct.self, UserProfile.self], inMemory: true)
}
