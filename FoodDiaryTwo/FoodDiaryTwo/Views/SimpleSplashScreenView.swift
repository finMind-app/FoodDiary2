//
//  SimpleSplashScreenView.swift
//  FoodDiaryTwo
//
//  Created by user on 31.07.2025.
//

import SwiftUI

struct SimpleSplashScreenView: View {
    @State private var logoScale: CGFloat = 0.8
    @State private var logoOpacity: Double = 0.0
    
    var body: some View {
        ZStack {
            // Простой фон
            PlumpyTheme.primaryAccent
                .ignoresSafeArea()
            
            VStack(spacing: PlumpyTheme.Spacing.large) {
                Spacer()
                
                // Простой логотип
                Image(systemName: "fork.knife.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(PlumpyTheme.surface)
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
                
                // Название приложения
                Text(LocalizationManager.shared.localizedString(.foodDiary))
                    .font(PlumpyTheme.Typography.title1)
                    .fontWeight(.bold)
                    .foregroundColor(PlumpyTheme.surface)
                
                Spacer()
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
        }
    }
}

#Preview {
    SimpleSplashScreenView()
}
