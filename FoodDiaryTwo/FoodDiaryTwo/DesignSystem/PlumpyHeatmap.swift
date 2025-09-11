//
//  PlumpyHeatmap.swift
//  FoodDiaryTwo
//
//  Created by user on 31.07.2025.
//

import SwiftUI

struct PlumpyHeatmap: View {
    let data: [HeatmapDataPoint]
    let selectedMonth: Date
    let onMonthChanged: (Date) -> Void
    
    @State private var selectedCell: HeatmapDataPoint?
    @StateObject private var localizationManager = LocalizationManager.shared
    
    struct HeatmapDataPoint: Identifiable {
        let id = UUID()
        let date: Date
        let count: Int
        let intensity: Double // 0.0 to 1.0
    }
    
    init(data: [HeatmapDataPoint], selectedMonth: Date, onMonthChanged: @escaping (Date) -> Void) {
        self.data = data
        self.selectedMonth = selectedMonth
        self.onMonthChanged = onMonthChanged
    }
    
    var body: some View {
        VStack(spacing: PlumpyTheme.Spacing.small) {
            // Заголовок с навигацией по месяцам
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(PlumpyTheme.primary)
                }
                
                Spacer()
                
                Text(monthYearString)
                    .font(PlumpyTheme.Typography.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(PlumpyTheme.textPrimary)
                
                Spacer()
                
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(canGoToNextMonth ? PlumpyTheme.primary : PlumpyTheme.textTertiary)
                }
                .disabled(!canGoToNextMonth)
            }
            .padding(.horizontal, PlumpyTheme.Spacing.small)
            
            // Day labels (Sun, Mon, ...) and grid
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
                    // Сетка квадратиков (5-6 недель в месяце)
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 7), spacing: 2) {
                        ForEach(0..<42, id: \.self) { index in // 6 недель * 7 дней = 42
                            let dataPoint = getDataPoint(for: index)
                            HeatmapCell(dataPoint: dataPoint, selectedMonth: selectedMonth)
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
                    
                    Text("\(selected.count) \(localizationManager.localizedString(.meals))")
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
                Text(localizationManager.localizedString(.less))
                    .font(PlumpyTheme.Typography.caption2)
                    .foregroundColor(PlumpyTheme.textSecondary)
                    .overlay(Text(localizationManager.localizedString(.less)).opacity(0))
                
                HStack(spacing: 2) {
                    ForEach(0..<5) { level in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(getColorForIntensity(Double(level) / 4.0))
                            .frame(width: 12, height: 12)
                    }
                }
                
                Text(localizationManager.localizedString(.more))
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
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: localizationManager.currentLanguage.rawValue)
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: selectedMonth)
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
        formatter.locale = Locale(identifier: localizationManager.currentLanguage.rawValue)
        let symbols = formatter.shortWeekdaySymbols ?? ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
        return symbols
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: localizationManager.currentLanguage.rawValue)
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func previousMonth() {
        let calendar = Calendar.current
        if let newMonth = calendar.date(byAdding: .month, value: -1, to: selectedMonth) {
            onMonthChanged(newMonth)
        }
    }
    
    private func nextMonth() {
        let calendar = Calendar.current
        if let newMonth = calendar.date(byAdding: .month, value: 1, to: selectedMonth) {
            onMonthChanged(newMonth)
        }
    }
    
    private var canGoToNextMonth: Bool {
        let calendar = Calendar.current
        let today = Date()
        let currentMonth = calendar.dateInterval(of: .month, for: today)?.start ?? today
        
        // Можно перейти к следующему месяцу, если выбранный месяц не является текущим
        return !calendar.isDate(selectedMonth, equalTo: currentMonth, toGranularity: .month)
    }
}

struct HeatmapCell: View {
    let dataPoint: PlumpyHeatmap.HeatmapDataPoint?
    let selectedMonth: Date
    
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
                                .foregroundColor(PlumpyTheme.textInverse)
                        }
                    }
                }
            )
    }
    
    private func getCellColor() -> Color {
        guard let dataPoint = dataPoint else {
            return Color.clear
        }
        
        let calendar = Calendar.current
        let isInSelectedMonth = calendar.isDate(dataPoint.date, equalTo: selectedMonth, toGranularity: .month)
        
        if !isInSelectedMonth {
            // Дни вне выбранного месяца - очень прозрачные
            return PlumpyTheme.neutral200.opacity(0.3)
        }
        
        if dataPoint.count == 0 {
            // Дни в выбранном месяце без активности
            return PlumpyTheme.neutral200
        }
        
        // Дни с активностью
        let intensity = dataPoint.intensity
        let baseColor = PlumpyTheme.primary
        let alpha = 0.1 + (intensity * 0.9)
        return baseColor.opacity(alpha)
    }
}

// MARK: - Heatmap Data Generator

extension PlumpyHeatmap {
    static func generateHeatmapData(from entries: [FoodEntry], for month: Date) -> [HeatmapDataPoint] {
        let calendar = Calendar.current
        
        // Получаем начало и конец месяца
        let monthInterval = calendar.dateInterval(of: .month, for: month) ?? DateInterval()
        let startOfMonth = monthInterval.start
        let endOfMonth = monthInterval.end
        
        // Получаем начало недели для первого дня месяца
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        let daysFromStartOfWeek = (firstWeekday - calendar.firstWeekday + 7) % 7
        let startDate = calendar.date(byAdding: .day, value: -daysFromStartOfWeek, to: startOfMonth) ?? startOfMonth
        
        // Группируем записи по дням
        var dailyCounts: [Date: Int] = [:]
        
        for entry in entries {
            let entryDate = calendar.startOfDay(for: entry.date)
            if entryDate >= startDate && entryDate < endOfMonth {
                dailyCounts[entryDate, default: 0] += 1
            }
        }
        
        // Находим максимальное количество приемов пищи за день
        let maxCount = dailyCounts.values.max() ?? 1
        
        // Создаем массив данных для heatmap (6 недель * 7 дней = 42 ячейки)
        var heatmapData: [HeatmapDataPoint] = []
        
        // Заполняем сетку по дням недели
        for weekOffset in 0..<6 {
            for dayOffset in 0..<7 {
                // Вычисляем дату для текущей ячейки
                let cellDate = calendar.date(byAdding: .day, value: weekOffset * 7 + dayOffset, to: startDate) ?? startDate
                
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
        let testData = (0..<42).map { index in
            PlumpyHeatmap.HeatmapDataPoint(
                date: Calendar.current.date(byAdding: .day, value: -index, to: Date()) ?? Date(),
                count: Int.random(in: 0...5),
                intensity: Double.random(in: 0...1)
            )
        }
        
        PlumpyHeatmap(
            data: testData,
            selectedMonth: Date(),
            onMonthChanged: { _ in }
        )
        .padding()
        .background(PlumpyTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: PlumpyTheme.Radius.medium))
    }
    .padding()
    .background(PlumpyTheme.background)
}
