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
        VStack(spacing: PlumpyTheme.Spacing.medium) {
            // Основной контент
            HStack(spacing: PlumpyTheme.Spacing.medium) {
                // Дни недели (слева)
                VStack(spacing: 3) {
                    ForEach(getDayLabels(), id: \.self) { day in
                        Text(day)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(PlumpyTheme.textSecondary)
                            .frame(width: 25, height: 25)
                    }
                }
                
                // Сетка квадратиков
                VStack(spacing: 3) {
                    // Месяцы (сверху)
                    HStack(spacing: 3) {
                        ForEach(getMonthLabels(), id: \.self) { month in
                            Text(month)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(PlumpyTheme.textSecondary)
                                .frame(width: 25, height: 25)
                        }
                    }
                    
                    // Сетка квадратиков (53 недели x 7 дней)
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 3), count: 53), spacing: 3) {
                        ForEach(0..<(53 * 7), id: \.self) { index in
                            let dataPoint = getDataPoint(for: index)
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
                
                HStack(spacing: 3) {
                    ForEach(0..<5) { level in
                        RoundedRectangle(cornerRadius: 3)
                            .fill(getColorForIntensity(Double(level) / 4.0))
                            .frame(width: 15, height: 15)
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
    
    private func getDataPoint(for index: Int) -> HeatmapDataPoint? {
        guard index < data.count else { return nil }
        return data[index]
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
        
        var months: [String] = []
        var currentMonth = ""
        var monthCount = 0
        
        // Проходим по всем 53 неделям и группируем месяцы
        for i in 0..<53 {
            if let date = calendar.date(byAdding: .weekOfYear, value: -i, to: today) {
                let month = formatter.string(from: date)
                
                if month != currentMonth {
                    if !currentMonth.isEmpty {
                        // Добавляем предыдущий месяц с правильным количеством недель
                        for _ in 0..<monthCount {
                            months.append(currentMonth)
                        }
                    }
                    currentMonth = month
                    monthCount = 1
                } else {
                    monthCount += 1
                }
            }
        }
        
        // Добавляем последний месяц
        if !currentMonth.isEmpty {
            for _ in 0..<monthCount {
                months.append(currentMonth)
            }
        }
        
        return months.reversed()
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
        RoundedRectangle(cornerRadius: 3)
            .fill(getCellColor())
            .frame(width: 25, height: 25)
            .overlay(
                Group {
                    if let dataPoint = dataPoint, dataPoint.count > 0 {
                        // Показываем число только для очень активных дней
                        if dataPoint.count >= 4 {
                            Text("\(dataPoint.count)")
                                .font(.system(size: 9, weight: .bold))
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
    static func generateHeatmapData(from entries: [FoodEntry]) -> [HeatmapDataPoint] {
        let calendar = Calendar.current
        let today = Date()
        let endDate = calendar.startOfDay(for: today)
        
        // Начинаем с понедельника 53 недели назад (год)
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: endDate)?.start ?? endDate
        let startDate = calendar.date(byAdding: .weekOfYear, value: -53, to: startOfWeek) ?? endDate
        
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
        
        // Создаем массив данных для heatmap (53 недели x 7 дней)
        var heatmapData: [HeatmapDataPoint] = []
        
        // Заполняем сетку по дням недели (воскресенье - суббота)
        for weekOffset in 0..<53 {
            for dayOffset in 0..<7 {
                // Вычисляем дату для текущей ячейки
                let weekStart = calendar.date(byAdding: .weekOfYear, value: -weekOffset, to: startOfWeek) ?? startDate
                let cellDate = calendar.date(byAdding: .day, value: dayOffset, to: weekStart) ?? startDate
                
                let count = dailyCounts[cellDate] ?? 0
                let intensity = maxCount > 0 ? Double(count) / Double(maxCount) : 0.0
                
                let dataPoint = HeatmapDataPoint(
                    date: cellDate,
                    count: count,
                    intensity: intensity
                )
                heatmapData.append(dataPoint)
            }
        }
        
        return heatmapData
    }
}

#Preview {
    VStack(spacing: PlumpyTheme.Spacing.large) {
        // Создаем тестовые данные для года (53 недели * 7 дней = 371 день)
        let testData = (0..<371).map { index in
            PlumpyHeatmap.HeatmapDataPoint(
                date: Calendar.current.date(byAdding: .day, value: -index, to: Date()) ?? Date(),
                count: Int.random(in: 0...6),
                intensity: Double.random(in: 0...1)
            )
        }
        
        PlumpyHeatmap(data: testData)
            .padding()
            .background(PlumpyTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: PlumpyTheme.Radius.medium))
    }
    .padding()
    .background(PlumpyTheme.background)
}
