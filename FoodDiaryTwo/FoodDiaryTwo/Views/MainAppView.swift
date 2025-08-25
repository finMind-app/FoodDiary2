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
    
    // Переключение между версиями сплеш скрина (true = основная, false = простая)
    private let useAdvancedSplash = true
    
    var body: some View {
        ZStack {
            // Основное приложение
            ContentView()
                .opacity(showingSplash ? 0 : 1)
                .animation(.easeInOut(duration: 0.5), value: showingSplash)
            
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

                    // Показываем сплеш скрин на 2.5 секунды
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            splashOpacity = 0
                        }
                        
                        // Скрываем сплеш скрин после анимации исчезновения
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            showingSplash = false
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    MainAppView()
        .modelContainer(for: [FoodEntry.self, FoodProduct.self, UserProfile.self], inMemory: true)
}
