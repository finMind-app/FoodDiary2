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
    let period: HeatmapPeriod
    @State private var selectedCell: HeatmapDataPoint?
    
    struct HeatmapDataPoint: Identifiable {
        let id = UUID()
        let date: Date
        let count: Int
        let intensity: Double // 0.0 to 1.0
    }
    
    enum HeatmapPeriod {
        case week
        case month
        case year
        
        var columns: Int {
            switch self {
            case .week: return 7
            case .month: return 7
            case .year: return 53 // 53 недели в году
            }
        }
        
        var rows: Int {
            switch self {
            case .week: return 7
            case .month: return 4
            case .year: return 7
            }
        }
        
        var displayName: String {
            switch self {
            case .week: return "Last 7 days"
            case .month: return "Last 4 weeks"
            case .year: return "Last year"
            }
        }
    }
    
    init(data: [HeatmapDataPoint], period: HeatmapPeriod = .year) {
        self.data = data
        self.period = period
        self.columns = period.columns
        self.rows = period.rows
    }
    
    var body: some View {
        VStack(spacing: PlumpyTheme.Spacing.medium) {
            // Заголовок с периодом
            HStack {
                Text("Activity Heatmap")
                    .font(PlumpyTheme.Typography.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(PlumpyTheme.textPrimary)
                
                Spacer()
                
                Text(period.displayName)
                    .font(PlumpyTheme.Typography.caption1)
                    .foregroundColor(PlumpyTheme.textSecondary)
            }
            
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
                    
                    // Сетка квадратиков
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 3), count: columns), spacing: 3) {
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
        let weekCount = period == .year ? 53 : 7
        
        for i in 0..<weekCount {
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
    static func generateHeatmapData(from entries: [FoodEntry], period: HeatmapPeriod = .year) -> [HeatmapDataPoint] {
        let calendar = Calendar.current
        let today = Date()
        let endDate = calendar.startOfDay(for: today)
        
        // Определяем период в зависимости от типа
        let startDate: Date
        let weekCount: Int
        
        switch period {
        case .week:
            weekCount = 1
            startDate = calendar.date(byAdding: .weekOfYear, value: -1, to: endDate) ?? endDate
        case .month:
            weekCount = 4
            startDate = calendar.date(byAdding: .weekOfYear, value: -4, to: endDate) ?? endDate
        case .year:
            weekCount = 53
            startDate = calendar.date(byAdding: .weekOfYear, value: -53, to: endDate) ?? endDate
        }
        
        // Начинаем с понедельника
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: startDate)?.start ?? startDate
        
        // Группируем записи по дням
        var dailyCounts: [Date: Int] = [:]
        
        for entry in entries {
            let entryDate = calendar.startOfDay(for: entry.date)
            if entryDate >= startOfWeek && entryDate <= endDate {
                dailyCounts[entryDate, default: 0] += 1
            }
        }
        
        // Находим максимальное количество приемов пищи за день
        let maxCount = dailyCounts.values.max() ?? 1
        
        // Создаем массив данных для heatmap
        var heatmapData: [HeatmapDataPoint] = []
        
        // Заполняем сетку по дням недели (воскресенье - суббота)
        for weekOffset in 0..<weekCount {
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
        
        PlumpyHeatmap(data: testData, period: .year)
            .padding()
            .background(PlumpyTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: PlumpyTheme.Radius.medium))
    }
    .padding()
    .background(PlumpyTheme.background)
}
