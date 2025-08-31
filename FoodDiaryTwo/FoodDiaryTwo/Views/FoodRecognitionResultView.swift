//
//  FoodRecognitionResultView.swift
//  FoodDiaryTwo
//
//  Created by user on 31.07.2025.
//

import SwiftUI

// MARK: - View для отображения результатов распознавания
struct FoodRecognitionResultView: View {
    
    // MARK: - Свойства
    let result: FoodRecognitionResult
    let onApply: () -> Void
    let onRetry: () -> Void
    
    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(spacing: PlumpyTheme.Spacing.large) {
                
                // Заголовок
                headerSection
                
                // Общая информация
                summarySection
                
                // Кнопки действий
                actionButtonsSection
                
                Spacer(minLength: PlumpyTheme.Spacing.large)
            }
            .padding(.horizontal, PlumpyTheme.Spacing.medium)
        }
        .background(PlumpyTheme.surfaceSecondary)
        .navigationTitle(LocalizationManager.shared.localizedString(.analysisResults))
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Заголовок
    private var headerSection: some View {
        VStack(spacing: PlumpyTheme.Spacing.medium) {
            // Иконка результата
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
            
            // Название блюда
            Text(result.name)
                .font(PlumpyTheme.Typography.title2)
                .fontWeight(.semibold)
                .foregroundColor(PlumpyTheme.textPrimary)
                .multilineTextAlignment(.center)
            
            // Время обработки
            Text(String(format: LocalizationManager.shared.localizedString(.processingTimeSec), result.processingTime))
                .font(PlumpyTheme.Typography.caption1)
                .foregroundColor(PlumpyTheme.textSecondary)
        }
        .padding(.vertical, PlumpyTheme.Spacing.large)
        .frame(maxWidth: .infinity)
        .background(PlumpyTheme.surface)
        .cornerRadius(PlumpyTheme.Radius.large)
    }
    
    // MARK: - Общая информация
    private var summarySection: some View {
        VStack(spacing: PlumpyTheme.Spacing.medium) {
            Text(LocalizationManager.shared.localizedString(.generalInfo))
                .font(PlumpyTheme.Typography.title3)
                .fontWeight(.semibold)
                .foregroundColor(PlumpyTheme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: PlumpyTheme.Spacing.medium) {
                
                NutritionCard(
                    title: LocalizationManager.shared.localizedString(.calories),
                    value: "\(Int(result.calories))",
                    unit: LocalizationManager.shared.localizedString(.calUnit),
                    color: .orange,
                    icon: "flame.fill"
                )
                
                NutritionCard(
                    title: LocalizationManager.shared.localizedString(.protein),
                    value: "\(String(format: "%.1f", result.protein))",
                    unit: "g",
                    color: .blue,
                    icon: "circle.hexagongrid.fill"
                )
                
                NutritionCard(
                    title: LocalizationManager.shared.localizedString(.fat),
                    value: "\(String(format: "%.1f", result.fat))",
                    unit: "g",
                    color: .yellow,
                    icon: "drop.fill"
                )
                
                NutritionCard(
                    title: LocalizationManager.shared.localizedString(.carbs),
                    value: "\(String(format: "%.1f", result.carbs))",
                    unit: "g",
                    color: .green,
                    icon: "leaf.fill"
                )
            }
        }
        .padding(PlumpyTheme.Spacing.medium)
        .background(PlumpyTheme.surface)
        .cornerRadius(PlumpyTheme.Radius.large)
    }
    
    // MARK: - Кнопки действий
    private var actionButtonsSection: some View {
        VStack(spacing: PlumpyTheme.Spacing.medium) {
            // Кнопка применения результатов
            Button(action: onApply) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text(LocalizationManager.shared.localizedString(.applyToMeal))
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, PlumpyTheme.Spacing.medium)
                .background(PlumpyTheme.primaryAccent)
                .foregroundColor(.white)
                .cornerRadius(PlumpyTheme.Radius.medium)
            }
            
            // Кнопка повтора
            Button(action: onRetry) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text(LocalizationManager.shared.localizedString(.tryAgain))
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, PlumpyTheme.Spacing.medium)
                .background(PlumpyTheme.surfaceSecondary)
                .foregroundColor(PlumpyTheme.textPrimary)
                .cornerRadius(PlumpyTheme.Radius.medium)
            }
        }
    }
}

// MARK: - Карточка питания
struct NutritionCard: View {
    let title: String
    let value: String
    let unit: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: PlumpyTheme.Spacing.small) {
            // Иконка
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            // Значение
            Text(value)
                .font(PlumpyTheme.Typography.title2)
                .fontWeight(.bold)
                .foregroundColor(PlumpyTheme.textPrimary)
            
            // Единица измерения
            Text(unit)
                .font(PlumpyTheme.Typography.caption1)
                .foregroundColor(PlumpyTheme.textSecondary)
            
            // Название
            Text(title)
                .font(PlumpyTheme.Typography.caption1)
                .foregroundColor(PlumpyTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(PlumpyTheme.Spacing.medium)
        .frame(maxWidth: .infinity)
        .background(PlumpyTheme.surfaceSecondary)
        .cornerRadius(PlumpyTheme.Radius.medium)
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        FoodRecognitionResultView(
            result: FoodRecognitionResult(
                name: "Куриная грудка с рисом",
                calories: 295,
                protein: 33.7,
                fat: 3.9,
                carbs: 28,
                processingTime: 2.3,
                imageSize: CGSize(width: 512, height: 512)
            ),
            onApply: {},
            onRetry: {}
        )
    }
}
