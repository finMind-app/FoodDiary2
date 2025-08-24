//
//  PlumpyHeatmap.swift
//  FoodDiaryTwo
//
//  Created by user on 31.07.2025.
//

import SwiftUI

struct PlumpyHeatmap: View {
    let data: [HeatmapDataPoint]
    @State private var selectedCell: HeatmapDataPoint?
    
    struct HeatmapDataPoint: Identifiable {
        let id = UUID()
        let date: Date
        let count: Int
        let intensity: Double // 0.0 to 1.0
    }
    
    init(data: [HeatmapDataPoint]) {
        self.data = data
    }
    
    var body: some View {
        VStack(spacing: PlumpyTheme.Spacing.small) {
            // Основная сетка
            HStack(spacing: PlumpyTheme.Spacing.small) {
                // Дни недели (слева)
                VStack(spacing: 2) {
                    ForEach(getDayLabels(), id: \.self) { day in
                        Text(day)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(PlumpyTheme.textSecondary)
                            .frame(width: 20, height: 20)
                    }
                }
                
                // Сетка квадратиков с месяцами
                VStack(spacing: 2) {
                    // Месяцы (сверху)
                    HStack(spacing: 2) {
                        ForEach(Array(getMonthLabels().enumerated()), id: \.offset) { index, month in
                            Text(month)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(PlumpyTheme.textSecondary)
                                .frame(width: 20, height: 20)
                        }
                    }
                    
                    // Сетка квадратиков
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 53), spacing: 2) {
                        ForEach(data) { dataPoint in
                            HeatmapCell(dataPoint: dataPoint)
                                .onTapGesture {
                                    selectedCell = dataPoint
                                }
                        }
                    }
                }
            }
            
            // Информация о выбранной ячейке
            if let selected = selectedCell {
                HStack {
                    Text(formatDate(selected.date))
                        .font(PlumpyTheme.Typography.caption1)
                        .foregroundColor(PlumpyTheme.textPrimary)
                    
                    Spacer()
                    
                    Text("\(selected.count) meals")
                        .font(PlumpyTheme.Typography.caption1)
                        .foregroundColor(PlumpyTheme.textSecondary)
                }
                .padding(.horizontal, PlumpyTheme.Spacing.small)
                .padding(.vertical, PlumpyTheme.Spacing.tiny)
                .background(PlumpyTheme.surfaceSecondary)
                .clipShape(RoundedRectangle(cornerRadius: PlumpyTheme.Radius.small))
            }
            
            // Легенда
            HStack(spacing: PlumpyTheme.Spacing.small) {
                Text("Less")
                    .font(PlumpyTheme.Typography.caption2)
                    .foregroundColor(PlumpyTheme.textSecondary)
                
                HStack(spacing: 2) {
                    ForEach(0..<5) { level in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(getColorForIntensity(Double(level) / 4.0))
                            .frame(width: 12, height: 12)
                    }
                }
                
                Text("More")
                    .font(PlumpyTheme.Typography.caption2)
                    .foregroundColor(PlumpyTheme.textSecondary)
                
                Spacer()
            }
            .padding(.top, PlumpyTheme.Spacing.small)
        }
        .onTapGesture {
            // Скрываем информацию при нажатии вне ячеек
            selectedCell = nil
        }
    }
    
    private func getColorForIntensity(_ intensity: Double) -> Color {
        let baseColor = PlumpyTheme.primary
        let alpha = 0.1 + (intensity * 0.9) // От 0.1 до 1.0
        return baseColor.opacity(alpha)
    }
    
    private func getDayLabels() -> [String] {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        return ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    }
    
    private func getMonthLabels() -> [String] {
        let calendar = Calendar.current
        let today = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        
        // Получаем все месяцы за последний год
        var months: [String] = []
        var currentDate = calendar.date(byAdding: .year, value: -1, to: today) ?? today
        
        while currentDate <= today {
            let month = formatter.string(from: currentDate)
            if !months.contains(month) {
                months.append(month)
            }
            currentDate = calendar.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
        }
        
        return months
    }
    
    private func getMonthPositions() -> [Int] {
        let calendar = Calendar.current
        let today = Date()
        let startDate = calendar.date(byAdding: .year, value: -1, to: today) ?? today
        
        var positions: [Int] = []
        var currentDate = startDate
        var dayIndex = 0
        
        while currentDate <= today {
            let month = calendar.component(.month, from: currentDate)
            let dayOfMonth = calendar.component(.day, from: currentDate)
            
            // Если это первый день месяца, добавляем позицию
            if dayOfMonth == 1 {
                positions.append(dayIndex)
            }
            
            dayIndex += 1
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        return positions
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct HeatmapCell: View {
    let dataPoint: PlumpyHeatmap.HeatmapDataPoint?
    
    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(getCellColor())
            .frame(width: 20, height: 20)
            .overlay(
                Group {
                    if let dataPoint = dataPoint, dataPoint.count > 0 {
                        // Показываем число только для очень активных дней
                        if dataPoint.count >= 5 {
                            Text("\(dataPoint.count)")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }
            )
    }
    
    private func getCellColor() -> Color {
        guard let dataPoint = dataPoint, dataPoint.count > 0 else {
            return PlumpyTheme.neutral200
        }
        
        let intensity = dataPoint.intensity
        let baseColor = PlumpyTheme.primary
        let alpha = 0.1 + (intensity * 0.9)
        return baseColor.opacity(alpha)
    }
}

// MARK: - Heatmap Data Generator

extension PlumpyHeatmap {
    static func generateYearlyHeatmapData(from entries: [FoodEntry]) -> [HeatmapDataPoint] {
        let calendar = Calendar.current
        let today = Date()
        let endDate = calendar.startOfDay(for: today)
        
        // Начинаем с 1 января прошлого года
        let startOfYear = calendar.dateInterval(of: .year, for: endDate)?.start ?? endDate
        let startDate = calendar.date(byAdding: .year, value: -1, to: startOfYear) ?? endDate
        
        // Группируем записи по дням
        var dailyCounts: [Date: Int] = [:]
        
        for entry in entries {
            let entryDate = calendar.startOfDay(for: entry.date)
            if entryDate >= startDate && entryDate <= endDate {
                dailyCounts[entryDate, default: 0] += 1
            }
        }
        
        // Находим максимальное количество приемов пищи за день
        let maxCount = dailyCounts.values.max() ?? 1
        
        // Создаем массив данных для heatmap (годовая сетка)
        var heatmapData: [HeatmapDataPoint] = []
        
        // Заполняем сетку по дням недели для всего года
        var currentDate = startDate
        
        while currentDate <= endDate {
            let count = dailyCounts[currentDate] ?? 0
            let intensity = maxCount > 0 ? Double(count) / Double(maxCount) : 0.0
            
            let dataPoint = HeatmapDataPoint(
                date: currentDate,
                count: count,
                intensity: intensity
            )
            heatmapData.append(dataPoint)
            
            // Переходим к следующему дню
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        return heatmapData
    }
}

#Preview {
    VStack(spacing: PlumpyTheme.Spacing.large) {
        // Создаем тестовые данные для года
        let calendar = Calendar.current
        let today = Date()
        let startDate = calendar.date(byAdding: .year, value: -1, to: today) ?? today
        
        var testData: [PlumpyHeatmap.HeatmapDataPoint] = []
        var currentDate = startDate
        
        while currentDate <= today {
            testData.append(PlumpyHeatmap.HeatmapDataPoint(
                date: currentDate,
                count: Int.random(in: 0...8),
                intensity: Double.random(in: 0...1)
            ))
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        PlumpyHeatmap(data: testData)
            .padding()
            .background(PlumpyTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: PlumpyTheme.Radius.medium))
    }
    .padding()
    .background(PlumpyTheme.background)
}
