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
                
                // Детали по продуктам
                foodDetailsSection
                
                // Кнопки действий
                actionButtonsSection
                
                Spacer(minLength: PlumpyTheme.Spacing.large)
            }
            .padding(.horizontal, PlumpyTheme.Spacing.medium)
        }
        .background(PlumpyTheme.surfaceSecondary)
        .navigationTitle("Результаты анализа")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Заголовок
    private var headerSection: some View {
        VStack(spacing: PlumpyTheme.Spacing.medium) {
            // Иконка результата
            Image(systemName: result.isHighConfidence ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(result.isHighConfidence ? .green : .orange)
            
            // Текст уверенности
            Text(result.confidenceText)
                .font(PlumpyTheme.Typography.title2)
                .fontWeight(.semibold)
                .foregroundColor(PlumpyTheme.textPrimary)
            
            // Время обработки
            Text("Время анализа: \(String(format: "%.1f", result.processingTime)) сек")
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
            Text("Общая информация")
                .font(PlumpyTheme.Typography.title3)
                .fontWeight(.semibold)
                .foregroundColor(PlumpyTheme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: PlumpyTheme.Spacing.medium) {
                
                NutritionCard(
                    title: "Калории",
                    value: "\(Int(result.totalCalories))",
                    unit: "ккал",
                    color: .orange,
                    icon: "flame.fill"
                )
                
                NutritionCard(
                    title: "Белки",
                    value: "\(String(format: "%.1f", result.totalProtein))",
                    unit: "г",
                    color: .blue,
                    icon: "circle.hexagongrid.fill"
                )
                
                NutritionCard(
                    title: "Жиры",
                    value: "\(String(format: "%.1f", result.totalFat))",
                    unit: "г",
                    color: .yellow,
                    icon: "drop.fill"
                )
                
                NutritionCard(
                    title: "Углеводы",
                    value: "\(String(format: "%.1f", result.totalCarbs))",
                    unit: "г",
                    color: .green,
                    icon: "leaf.fill"
                )
            }
        }
        .padding(PlumpyTheme.Spacing.medium)
        .background(PlumpyTheme.surface)
        .cornerRadius(PlumpyTheme.Radius.large)
    }
    
    // MARK: - Детали по продуктам
    private var foodDetailsSection: some View {
        VStack(spacing: PlumpyTheme.Spacing.medium) {
            Text("Распознанные продукты")
                .font(PlumpyTheme.Typography.title3)
                .fontWeight(.semibold)
                .foregroundColor(PlumpyTheme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ForEach(result.recognizedFoods) { food in
                RecognizedFoodRow(food: food)
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
                    Text("Применить к приему пищи")
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
                    Text("Попробовать снова")
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

// MARK: - Строка распознанного продукта
struct RecognizedFoodRow: View {
    let food: RecognizedFood
    
    var body: some View {
        VStack(spacing: PlumpyTheme.Spacing.small) {
            HStack {
                // Иконка категории
                Text(food.category.icon)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 2) {
                    // Название продукта
                    Text(food.name)
                        .font(PlumpyTheme.Typography.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(PlumpyTheme.textPrimary)
                    
                    // Размер порции
                    Text(food.estimatedServingSize)
                        .font(PlumpyTheme.Typography.caption1)
                        .foregroundColor(PlumpyTheme.textSecondary)
                }
                
                Spacer()
                
                // Уверенность
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(Int(food.confidence * 100))%")
                        .font(PlumpyTheme.Typography.caption1)
                        .fontWeight(.semibold)
                        .foregroundColor(food.confidenceColor)
                    
                    Text("уверенность")
                        .font(PlumpyTheme.Typography.caption2)
                        .foregroundColor(PlumpyTheme.textTertiary)
                }
            }
            
            // Детали питания
            HStack(spacing: PlumpyTheme.Spacing.medium) {
                NutritionBadge(label: "Кал", value: "\(Int(food.calories))")
                NutritionBadge(label: "Б", value: "\(String(format: "%.1f", food.protein))")
                NutritionBadge(label: "Ж", value: "\(String(format: "%.1f", food.fat))")
                NutritionBadge(label: "У", value: "\(String(format: "%.1f", food.carbs))")
                
                Spacer()
                
                // Способ приготовления
                if let cookingMethod = food.cookingMethod {
                    HStack(spacing: 4) {
                        Text(cookingMethod.icon)
                        Text(cookingMethod.rawValue)
                            .font(PlumpyTheme.Typography.caption2)
                            .foregroundColor(PlumpyTheme.textSecondary)
                    }
                }
            }
        }
        .padding(PlumpyTheme.Spacing.medium)
        .background(PlumpyTheme.surfaceSecondary)
        .cornerRadius(PlumpyTheme.Radius.medium)
    }
}

// MARK: - Бейдж питания
struct NutritionBadge: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(PlumpyTheme.Typography.caption1)
                .fontWeight(.semibold)
                .foregroundColor(PlumpyTheme.textPrimary)
            
            Text(label)
                .font(PlumpyTheme.Typography.caption2)
                .foregroundColor(PlumpyTheme.textSecondary)
        }
        .padding(.horizontal, PlumpyTheme.Spacing.small)
        .padding(.vertical, 4)
        .background(PlumpyTheme.surface)
        .cornerRadius(PlumpyTheme.Radius.small)
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        FoodRecognitionResultView(
            result: FoodRecognitionResult(
                confidence: 0.85,
                recognizedFoods: [
                    RecognizedFood(
                        name: "Куриная грудка",
                        confidence: 0.9,
                        estimatedWeight: 174,
                        calories: 165,
                        protein: 31,
                        fat: 3.6,
                        carbs: 0,
                        category: .protein,
                        boundingBox: nil,
                        isProcessed: true,
                        cookingMethod: .grilled,
                        estimatedServingSize: "1 грудка (174г)"
                    ),
                    RecognizedFood(
                        name: "Рис отварной",
                        confidence: 0.8,
                        estimatedWeight: 158,
                        calories: 130,
                        protein: 2.7,
                        fat: 0.3,
                        carbs: 28,
                        category: .grains,
                        boundingBox: nil,
                        isProcessed: true,
                        cookingMethod: .boiled,
                        estimatedServingSize: "1 чашка (158г)"
                    )
                ],
                totalCalories: 295,
                totalProtein: 33.7,
                totalFat: 3.9,
                totalCarbs: 28,
                processingTime: 2.3,
                imageSize: CGSize(width: 512, height: 512)
            ),
            onApply: {},
            onRetry: {}
        )
    }
}
