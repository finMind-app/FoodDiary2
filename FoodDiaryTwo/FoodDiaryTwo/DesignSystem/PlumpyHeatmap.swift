//
//  PlumpyHeatmap.swift
//  FoodDiaryTwo
//
//  Created by user on 31.07.2025.
//

import SwiftUI

struct PlumpyHeatmap: View {
    let data: [HeatmapDataPoint]
    let columns: Int
    let rows: Int
    @State private var selectedCell: HeatmapDataPoint?
    
    struct HeatmapDataPoint: Identifiable {
        let id = UUID()
        let date: Date
        let count: Int
        let intensity: Double // 0.0 to 1.0
    }
    
    init(data: [HeatmapDataPoint], columns: Int = 7, rows: Int = 7) {
        self.data = data
        self.columns = columns
        self.rows = rows
    }
    
    var body: some View {
        VStack(spacing: PlumpyTheme.Spacing.small) {
            // Дни недели (слева)
            HStack(spacing: PlumpyTheme.Spacing.small) {
                VStack(spacing: 2) {
                    ForEach(getDayLabels(), id: \.self) { day in
                        Text(day)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(PlumpyTheme.textSecondary)
                            .frame(width: 20, height: 20)
                    }
                }
                
                // Сетка квадратиков
                VStack(spacing: 2) {
                    // Месяцы (сверху)
                    HStack(spacing: 2) {
                        ForEach(getMonthLabels(), id: \.self) { month in
                            Text(month)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(PlumpyTheme.textSecondary)
                                .frame(width: 20, height: 20)
                        }
                    }
                    
                    // Сетка квадратиков
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: columns), spacing: 2) {
                        ForEach(0..<(columns * rows), id: \.self) { index in
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
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .weekOfYear, value: -i, to: today) {
                let month = formatter.string(from: date)
                if !months.contains(month) {
                    months.append(month)
                }
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
        RoundedRectangle(cornerRadius: 2)
            .fill(getCellColor())
            .frame(width: 20, height: 20)
            .overlay(
                Group {
                    if let dataPoint = dataPoint, dataPoint.count > 0 {
                        // Показываем число только при наведении или для очень активных дней
                        if dataPoint.count >= 3 {
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
    static func generateHeatmapData(from entries: [FoodEntry], days: Int = 49) -> [HeatmapDataPoint] {
        let calendar = Calendar.current
        let today = Date()
        let endDate = calendar.startOfDay(for: today)
        
        // Начинаем с понедельника 7 недель назад
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: endDate)?.start ?? endDate
        let startDate = calendar.date(byAdding: .weekOfYear, value: -7, to: startOfWeek) ?? endDate
        
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
        
        // Создаем массив данных для heatmap (7x7 сетка)
        var heatmapData: [HeatmapDataPoint] = []
        
        // Заполняем сетку по дням недели (воскресенье - суббота)
        for weekOffset in 0..<7 {
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
        // Создаем тестовые данные
        let testData = (0..<49).map { index in
            PlumpyHeatmap.HeatmapDataPoint(
                date: Calendar.current.date(byAdding: .day, value: -index, to: Date()) ?? Date(),
                count: Int.random(in: 0...5),
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
