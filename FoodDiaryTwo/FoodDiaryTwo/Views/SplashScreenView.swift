//
//  SplashScreenView.swift
//  FoodDiaryTwo
//
//  Created by user on 31.07.2025.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0.0
    @State private var textOpacity: Double = 0.0
    @State private var backgroundOpacity: Double = 0.0
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Градиентный фон
            LinearGradient(
                gradient: Gradient(colors: [
                    PlumpyTheme.primaryAccent,
                    PlumpyTheme.secondaryAccent,
                    PlumpyTheme.tertiaryAccent
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .opacity(backgroundOpacity)
            
            VStack(spacing: PlumpyTheme.Spacing.huge) {
                Spacer()
                
                // Логотип приложения
                ZStack {
                    // Круглый фон для логотипа
                    Circle()
                        .fill(PlumpyTheme.surface)
                        .frame(width: 120, height: 120)
                        .shadow(
                            color: PlumpyTheme.shadow.opacity(0.3),
                            radius: 20,
                            x: 0,
                            y: 10
                        )
                    
                    // Иконка приложения
                    Image(systemName: "fork.knife.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(PlumpyTheme.primaryAccent)
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)
                
                // Название приложения
                VStack(spacing: PlumpyTheme.Spacing.small) {
                    Text("Food Diary")
                        .font(PlumpyTheme.Typography.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(PlumpyTheme.textInverse)
                    
                    Text("Track your nutrition journey")
                        .font(PlumpyTheme.Typography.body)
                        .fontWeight(.medium)
                        .foregroundColor(PlumpyTheme.textInverse.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .opacity(textOpacity)
                
                Spacer()
                
                // Индикатор загрузки
                HStack(spacing: PlumpyTheme.Spacing.small) {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .fill(PlumpyTheme.surface)
                            .frame(width: 8, height: 8)
                            .scaleEffect(isAnimating ? 1.2 : 0.8)
                            .animation(
                                .easeInOut(duration: 0.6)
                                .repeatForever()
                                .delay(Double(index) * 0.2),
                                value: isAnimating
                            )
                    }
                }
                .opacity(textOpacity)
                
                Spacer()
            }
            .padding(.horizontal, PlumpyTheme.Spacing.large)
        }
        .onAppear {
            startAnimation()
        }
    }
    
    private func startAnimation() {
        // Анимация появления фона
        withAnimation(.easeInOut(duration: 0.8)) {
            backgroundOpacity = 1.0
        }
        
        // Анимация логотипа
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6, blendDuration: 0)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }
        
        // Анимация текста
        withAnimation(.easeInOut(duration: 0.6).delay(0.4)) {
            textOpacity = 1.0
        }
        
        // Запуск анимации индикатора
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            isAnimating = true
        }
    }
}

#Preview {
    SplashScreenView()
}
