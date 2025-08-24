//
//  StatisticsView.swift
//  FoodDiaryTwo
//
//  Created by user on 31.07.2025.
//

import SwiftUI
import SwiftData

struct StatisticsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedPeriod: StatisticsPeriod = .week
    @State private var selectedDate = Date()
    @State private var showingCalendar = false
    @State private var isLoading = false
    @State private var isDataLoading = false
    
    // Кэшированные данные для оптимизации
    @State private var cachedPeriodEntries: [FoodEntry] = []
    @State private var cachedChartData: [ChartDataPoint] = []
    
    struct ChartDataPoint: Equatable {
        let date: Date
        let calories: Int
        let dateLabel: String
    }
    
    enum StatisticsPeriod: String, CaseIterable {
        case week = "week"
        case month = "month"
        case year = "year"
        case custom = "custom"
        
        var displayName: String {
            switch self {
            case .week: return "Week"
            case .month: return "Month"
            case .year: return "Year"
            case .custom: return "Custom"
            }
        }
    }
    
    var body: some View {
        ZStack {
            PlumpyBackground(style: .primary)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Navigation Bar
                PlumpyNavigationBar(
                    title: "Statistics",
                    subtitle: "Your nutrition insights"
                )
                
                ScrollView {
                    VStack(spacing: PlumpyTheme.Spacing.large) {
                        // Период
                        periodSelector
                        
                        // Основная статистика
                        mainStatistics
                        
                        // График калорий
                        caloriesChart
                        
                        // Дополнительная статистика
                        additionalStats
                        
                        PlumpySpacer(size: .huge)
                            .frame(height: PlumpyTheme.Spacing.huge)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, PlumpyTheme.Spacing.medium)
                    .padding(.top, PlumpyTheme.Spacing.medium)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
        .sheet(isPresented: $showingCalendar) {
            CalendarView(selectedDate: $selectedDate)
        }
        .onAppear {
            loadData()
        }
        .onChange(of: selectedPeriod) { _, newPeriod in
            if newPeriod != .custom {
                selectedDate = Date()
            }
            loadData()
        }
        .onChange(of: selectedDate) { _, _ in
            if selectedPeriod == .custom {
                loadData()
            }
        }
    }
    
    private var periodSelector: some View {
        VStack(alignment: .leading, spacing: PlumpyTheme.Spacing.medium) {
            HStack {
                Text("Period")
                    .font(PlumpyTheme.Typography.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(PlumpyTheme.textPrimary)
                
                Spacer()
                
                if selectedPeriod == .custom {
                    Button(action: {
                        showingCalendar = true
                    }) {
                        HStack(spacing: PlumpyTheme.Spacing.tiny) {
                            Image(systemName: "calendar")
                                .font(.system(size: 14))
                            Text(formatDate(selectedDate))
                                .font(PlumpyTheme.Typography.caption1)
                        }
                        .foregroundColor(PlumpyTheme.primary)
                        .padding(.horizontal, PlumpyTheme.Spacing.small)
                        .padding(.vertical, PlumpyTheme.Spacing.tiny)
                        .background(
                            RoundedRectangle(cornerRadius: PlumpyTheme.Radius.small)
                                .fill(PlumpyTheme.primary.opacity(0.1))
                        )
                    }
                }
            }
            
            HStack(spacing: PlumpyTheme.Spacing.small) {
                Spacer()
                ForEach(StatisticsPeriod.allCases, id: \.self) { period in
                    PlumpyChip(
                        title: period.displayName,
                        style: selectedPeriod == period ? .primary : .outline,
                        isSelected: selectedPeriod == period
                    ) {
                        selectedPeriod = period
                    }
                    .frame(minWidth: PlumpyTheme.Spacing.huge)
                }
                Spacer()
            }
        }
        .statisticsCard()
        .frame(height: 120) // Фиксированная высота вместо minHeight
    }
    
    private var mainStatistics: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: PlumpyTheme.Spacing.medium) {
            StatisticsCard(
                title: "Total Calories",
                value: String(totalCalories),
                subtitle: "This period",
                icon: "flame.fill",
                iconColor: PlumpyTheme.warning,
                trend: getCaloriesTrend()
            )
            
            StatisticsCard(
                title: "Meals",
                value: String(totalMeals),
                subtitle: "This period",
                icon: "fork.knife",
                iconColor: PlumpyTheme.primaryAccent,
                trend: getMealsTrend()
            )
            
            StatisticsCard(
                title: "Avg. Daily",
                value: String(averageDailyCalories),
                subtitle: "Calories",
                icon: "chart.line.uptrend.xyaxis",
                iconColor: PlumpyTheme.secondaryAccent,
                trend: getAverageDailyCaloriesTrend()
            )
            
            StatisticsCard(
                title: "Goal Met",
                value: String(format: "%.0f%%", getGoalAchievementRate()),
                subtitle: "Of days",
                icon: "target",
                iconColor: PlumpyTheme.success,
                trend: getGoalTrend()
            )
        }
        // убран фиксированный размер, чтобы сетка не накладывалась
    }

    private var totalMeals: Int {
        cachedPeriodEntries.count
    }
    
    private var totalCalories: Int {
        cachedPeriodEntries.reduce(0) { $0 + $1.totalCalories }
    }
    
    private var averageDailyCalories: Int {
        let days = max(1, uniqueDayCount)
        return totalCalories / days
    }
    
    private var uniqueDayCount: Int {
        let calendar = Calendar.current
        let days = Set(cachedPeriodEntries.map { calendar.startOfDay(for: $0.date) })
        return days.count
    }
    
    private var chartData: [ChartDataPoint] {
        cachedChartData
    }
    
    private var maxCalories: Int {
        let max = chartData.map { $0.calories }.max() ?? 0
        return max > 0 ? max : 1000
    }
    
    private var chartView: some View {
        VStack(spacing: PlumpyTheme.Spacing.small) {
            let values = chartData.map { Double($0.calories) }
            let rawLabels = chartData.map { $0.dateLabel }
            let displayLabels: [String] = {
                switch selectedPeriod {
                case .week:
                    return rawLabels
                case .month:
                    // каждые 2 дня показываем число, остальное пусто
                    return rawLabels.enumerated().map { i, l in i % 2 == 0 ? l : "" }
                case .year:
                    return rawLabels // месяцы короткие
                case .custom:
                    return rawLabels.enumerated().map { i, l in i % 3 == 0 ? l : "" }
                }
            }()
            PlumpyLineChart(
                values: values,
                labels: displayLabels,
                lineColor: PlumpyTheme.primaryAccent,
                areaOpacity: 0.14,
                showDots: true
            )
            .frame(height: 160)

            chartLegend
        }
        .frame(height: 200)
        .frame(maxWidth: .infinity)
    }
    
    private var chartBars: some View {
        ZStack(alignment: .bottom) {
            chartGrid
            chartColumns
        }
        .frame(height: 160)
        .frame(maxWidth: .infinity)
    }
    
    private var chartGrid: some View {
        VStack(spacing: 0) {
            ForEach(0..<5, id: \.self) { index in
                Rectangle()
                    .fill(PlumpyTheme.neutral200.opacity(0.6))
                    .frame(height: 1)
                    .frame(maxWidth: .infinity)
                
                if index < 4 {
                    Spacer()
                }
            }
        }
        .frame(height: 160)
        .frame(maxWidth: .infinity)
    }
    
    private var chartColumns: some View {
        GeometryReader { proxy in
            let count = max(chartData.count, 1)
            let spacing = PlumpyTheme.Spacing.tiny
            let availableWidth = proxy.size.width
            let barWidth = max(3, (availableWidth - spacing * CGFloat(count - 1)) / CGFloat(count))
            
            HStack(alignment: .bottom, spacing: spacing) {
                ForEach(Array(chartData.enumerated()), id: \.offset) { index, data in
                    chartColumn(index: index, data: data, barWidth: barWidth)
                }
            }
            .frame(height: 160, alignment: .bottom)
            .frame(maxWidth: .infinity, alignment: .bottom)
        }
        .frame(height: 160)
    }
    
    private func chartColumn(index: Int, data: ChartDataPoint, barWidth: CGFloat) -> some View {
        VStack(spacing: PlumpyTheme.Spacing.tiny) {
            RoundedRectangle(cornerRadius: PlumpyTheme.Radius.small)
                .fill(
                    LinearGradient(
                        colors: [PlumpyTheme.primaryAccent, PlumpyTheme.secondaryAccent],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .frame(width: barWidth, height: max(4, CGFloat(data.calories) / CGFloat(maxCalories) * 160))
                .shadow(
                    color: PlumpyTheme.shadow.opacity(0.03),
                    radius: PlumpyTheme.Shadow.small.radius,
                    x: PlumpyTheme.Shadow.small.x,
                    y: PlumpyTheme.Shadow.small.y
                )
            
            Text(data.dateLabel)
                .font(PlumpyTheme.Typography.caption2)
                .foregroundColor(PlumpyTheme.textSecondary)
                .rotationEffect(.degrees(-45))
                .offset(y: PlumpyTheme.Spacing.small)
                .frame(width: max(barWidth + 6, 16), height: 20)
        }
        .frame(width: max(barWidth + 6, 16))
    }
    
    private var chartLegend: some View {
        HStack(spacing: PlumpyTheme.Spacing.medium) {
            HStack(spacing: PlumpyTheme.Spacing.tiny) {
                Circle()
                    .fill(PlumpyTheme.primaryAccent)
                    .frame(width: PlumpyTheme.Spacing.small, height: PlumpyTheme.Spacing.small)
                Text("Calories")
                    .font(PlumpyTheme.Typography.caption2)
                    .foregroundColor(PlumpyTheme.textSecondary)
            }
            
            Spacer()
            
            Text("Max: \(maxCalories) cal")
                .font(PlumpyTheme.Typography.caption2)
                .foregroundColor(PlumpyTheme.textSecondary)
        }
        .padding(.horizontal, PlumpyTheme.Spacing.medium)
        .frame(height: 40)
    }
    
    private var caloriesChart: some View {
        VStack(spacing: PlumpyTheme.Spacing.medium) {
            Text("Calories Over Time")
                .font(PlumpyTheme.Typography.headline)
                .fontWeight(.semibold)
                .foregroundColor(PlumpyTheme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ZStack {
                if isLoading {
                    RoundedRectangle(cornerRadius: PlumpyTheme.Radius.medium)
                        .fill(PlumpyTheme.surfaceSecondary)
                        .frame(height: 200)
                        .frame(maxWidth: .infinity)
                        .overlay(
                            VStack(spacing: PlumpyTheme.Spacing.medium) {
                                ProgressView()
                                    .foregroundColor(PlumpyTheme.primary)
                                
                                Text("Loading data...")
                                    .font(PlumpyTheme.Typography.caption1)
                                    .foregroundColor(PlumpyTheme.textSecondary)
                            }
                        )
                } else if chartData.isEmpty {
                    RoundedRectangle(cornerRadius: PlumpyTheme.Radius.medium)
                        .fill(PlumpyTheme.surfaceSecondary)
                        .frame(height: 200)
                        .frame(maxWidth: .infinity)
                        .overlay(
                            VStack(spacing: PlumpyTheme.Spacing.medium) {
                                Image(systemName: "chart.line.uptrend.xyaxis")
                                    .font(.system(size: 40))
                                    .foregroundColor(PlumpyTheme.textTertiary)
                                
                                Text("No data for this period")
                                    .font(PlumpyTheme.Typography.caption1)
                                    .foregroundColor(PlumpyTheme.textTertiary)
                            }
                        )
                } else {
                    chartView
                }
            }
            .frame(height: 200)
            .frame(maxWidth: .infinity)
        }
        .statisticsCard()
    }
    
    private var additionalStats: some View {
        VStack(spacing: PlumpyTheme.Spacing.medium) {
            Text("Additional Insights")
                .font(PlumpyTheme.Typography.headline)
                .fontWeight(.semibold)
                .foregroundColor(PlumpyTheme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: PlumpyTheme.Spacing.small) {
                // Самый частый тип приема пищи
                let mostCommonMeal = getMostCommonMeal()
                StatisticsInfoCard(
                    title: "Most Common Meal",
                    subtitle: "\(mostCommonMeal.type) - \(mostCommonMeal.count) times",
                    icon: "sunrise.fill",
                    iconColor: PlumpyTheme.warning,
                    action: {}
                )
                
                // Лучший день по калориям
                let bestDay = getBestDay()
                StatisticsInfoCard(
                    title: "Best Day",
                    subtitle: "\(bestDay.day) - \(bestDay.calories) cal",
                    icon: "star.fill",
                    iconColor: PlumpyTheme.warning,
                    action: {}
                )
                
                // Текущая серия дней подряд
                let currentStreak = getCurrentStreak()
                StatisticsInfoCard(
                    title: "Current Streak",
                    subtitle: "\(currentStreak) days in a row",
                    icon: "flame.fill",
                    iconColor: PlumpyTheme.error,
                    action: {}
                )
                
                // Среднее количество калорий
                let averageCalories = getAverageCalories()
                StatisticsInfoCard(
                    title: "Average Daily Calories",
                    subtitle: "\(averageCalories) cal",
                    icon: "chart.bar.fill",
                    iconColor: PlumpyTheme.primary,
                    action: {}
                )
                
                // Процент достижения цели
                let goalRate = getGoalAchievementRate()
                StatisticsInfoCard(
                    title: "Goal Achievement",
                    subtitle: String(format: "%.1f%%", goalRate),
                    icon: "target",
                    iconColor: PlumpyTheme.success,
                    action: {}
                )
                
                // Самый калорийный прием пищи
                let mostCaloricMeal = getMostCaloricMeal()
                StatisticsInfoCard(
                    title: "Most Caloric Meal",
                    subtitle: "\(mostCaloricMeal.type) - \(mostCaloricMeal.calories) cal",
                    icon: "bolt.fill",
                    iconColor: PlumpyTheme.warning,
                    action: {}
                )
            }
        }
        .statisticsCard()
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    // MARK: - Data Loading
    
    private func loadData() {
        guard !isDataLoading else { return }
        
        isDataLoading = true
        isLoading = true
        
        Task {
            await loadPeriodEntries()
            await loadChartData()
            
            await MainActor.run {
                isLoading = false
                isDataLoading = false
            }
        }
    }
    
    @MainActor
    private func loadPeriodEntries() async {
        let calendar = Calendar.current
        let startDate: Date
        let endDate: Date
        
        switch selectedPeriod {
        case .week:
            startDate = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
            endDate = Date()
        case .month:
            startDate = calendar.date(byAdding: .month, value: -1, to: Date()) ?? Date()
            endDate = Date()
        case .year:
            startDate = calendar.date(byAdding: .year, value: -1, to: Date()) ?? Date()
            endDate = Date()
        case .custom:
            startDate = calendar.startOfDay(for: selectedDate)
            endDate = calendar.date(byAdding: .day, value: 1, to: startDate) ?? startDate
        }
        
        let descriptor = FetchDescriptor<FoodEntry>(
            predicate: #Predicate<FoodEntry> { entry in
                entry.date >= startDate && entry.date < endDate
            },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        do {
            cachedPeriodEntries = try modelContext.fetch(descriptor)
        } catch {
            print("Error fetching period entries: \(error)")
            cachedPeriodEntries = []
        }
    }
    
    @MainActor
    private func loadChartData() async {
        switch selectedPeriod {
        case .week:
            cachedChartData = generateWeekData()
        case .month:
            cachedChartData = generateMonthData()
        case .year:
            cachedChartData = generateYearData()
        case .custom:
            cachedChartData = generateCustomData()
        }
    }
    
    // MARK: - Chart Data Generation
    
    private func generateWeekData() -> [ChartDataPoint] {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        
        var data: [ChartDataPoint] = []
        let today = Date()
        
        for i in 0..<7 {
            let date = calendar.date(byAdding: .day, value: -i, to: today) ?? today
            let startOfDay = calendar.startOfDay(for: date)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? startOfDay
            
            let dayEntries = cachedPeriodEntries.filter { entry in
                entry.date >= startOfDay && entry.date < endOfDay
            }
            
            let calories = dayEntries.reduce(0) { $0 + $1.totalCalories }
            let dateLabel = formatter.string(from: date)
            
            data.append(ChartDataPoint(date: date, calories: calories, dateLabel: dateLabel))
        }
        
        return data.reversed()
    }
    
    private func generateMonthData() -> [ChartDataPoint] {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        
        var data: [ChartDataPoint] = []
        let today = Date()
        
        for i in 0..<30 {
            let date = calendar.date(byAdding: .day, value: -i, to: today) ?? today
            let startOfDay = calendar.startOfDay(for: date)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? startOfDay
            
            let dayEntries = cachedPeriodEntries.filter { entry in
                entry.date >= startOfDay && entry.date < endOfDay
            }
            
            let calories = dayEntries.reduce(0) { $0 + $1.totalCalories }
            let dateLabel = formatter.string(from: date)
            
            data.append(ChartDataPoint(date: date, calories: calories, dateLabel: dateLabel))
        }
        
        return data.reversed()
    }
    
    private func generateYearData() -> [ChartDataPoint] {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        
        var data: [ChartDataPoint] = []
        let today = Date()
        
        for i in 0..<12 {
            let date = calendar.date(byAdding: .month, value: -i, to: today) ?? today
            let startOfMonth = calendar.dateInterval(of: .month, for: date)?.start ?? date
            let endOfMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth) ?? startOfMonth
            
            let monthEntries = cachedPeriodEntries.filter { entry in
                entry.date >= startOfMonth && entry.date < endOfMonth
            }
            
            let calories = monthEntries.reduce(0) { $0 + $1.totalCalories }
            let dateLabel = formatter.string(from: date)
            
            data.append(ChartDataPoint(date: date, calories: calories, dateLabel: dateLabel))
        }
        
        return data.reversed()
    }
    
    private func generateCustomData() -> [ChartDataPoint] {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? startOfDay
        
        let dayEntries = cachedPeriodEntries.filter { entry in
            entry.date >= startOfDay && entry.date < endOfDay
        }
        
        var hourlyData: [Int: Int] = [:]
        for entry in dayEntries {
            let hour = calendar.component(.hour, from: entry.date)
            hourlyData[hour, default: 0] += entry.totalCalories
        }
        
        var data: [ChartDataPoint] = []
        for hour in 0..<24 {
            let calories = hourlyData[hour] ?? 0
            let date = calendar.date(byAdding: .hour, value: hour, to: startOfDay) ?? startOfDay
            let dateLabel = formatter.string(from: date)
            
            data.append(ChartDataPoint(date: date, calories: calories, dateLabel: dateLabel))
        }
        
        return data
    }
    
    // MARK: - Additional Statistics Calculations
    
    /// Получить самый частый тип приема пищи
    private func getMostCommonMeal() -> (type: String, count: Int) {
        var mealCounts: [String: Int] = [:]
        
        for entry in cachedPeriodEntries {
            let mealType = entry.mealType.displayName
            mealCounts[mealType, default: 0] += 1
        }
        
        let mostCommon = mealCounts.max { $0.value < $1.value }
        return (mostCommon?.key ?? "None", mostCommon?.value ?? 0)
    }
    
    /// Получить лучший день по калориям
    private func getBestDay() -> (day: String, calories: Int) {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        
        var dailyCalories: [Date: Int] = [:]
        
        for entry in cachedPeriodEntries {
            let startOfDay = calendar.startOfDay(for: entry.date)
            dailyCalories[startOfDay, default: 0] += entry.totalCalories
        }
        
        let bestDay = dailyCalories.max { $0.value < $1.value }
        let dayName = bestDay != nil ? formatter.string(from: bestDay!.key) : "None"
        
        return (dayName, bestDay?.value ?? 0)
    }
    
    /// Получить текущую серию дней подряд
    private func getCurrentStreak() -> Int {
        let calendar = Calendar.current
        let today = Date()
        var streak = 0
        var currentDate = today
        
        while true {
            let startOfDay = calendar.startOfDay(for: currentDate)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? startOfDay
            
            let dayEntries = cachedPeriodEntries.filter { entry in
                entry.date >= startOfDay && entry.date < endOfDay
            }
            
            if dayEntries.isEmpty {
                break
            }
            
            streak += 1
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
        }
        
        return streak
    }
    
    /// Получить среднее количество калорий за период
    private func getAverageCalories() -> Int {
        guard !cachedPeriodEntries.isEmpty else { return 0 }
        
        let totalCalories = cachedPeriodEntries.reduce(0) { $0 + $1.totalCalories }
        let uniqueDays = Set(cachedPeriodEntries.map { Calendar.current.startOfDay(for: $0.date) })
        
        return uniqueDays.isEmpty ? 0 : totalCalories / uniqueDays.count
    }
    
    /// Получить самый калорийный прием пищи
    private func getMostCaloricMeal() -> (type: String, calories: Int) {
        let mostCaloric = cachedPeriodEntries.max { $0.totalCalories < $1.totalCalories }
        let mealType = mostCaloric?.mealType.displayName ?? "None"
        let calories = mostCaloric?.totalCalories ?? 0
        
        return (mealType, calories)
    }
    
    /// Получить процент дней, когда достигнута цель по калориям
    private func getGoalAchievementRate() -> Double {
        let calendar = Calendar.current
        let calorieGoal = DailyGoalsService.shared.getDailyCalorieGoal(from: modelContext)
        
        var uniqueDays = Set<Date>()
        for entry in cachedPeriodEntries {
            uniqueDays.insert(calendar.startOfDay(for: entry.date))
        }
        
        var daysWithGoal = 0
        for day in uniqueDays {
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: day) ?? day
            let dayEntries = cachedPeriodEntries.filter { entry in
                entry.date >= day && entry.date < endOfDay
            }
            
            let dayCalories = dayEntries.reduce(0) { $0 + $1.totalCalories }
            if dayCalories >= calorieGoal {
                daysWithGoal += 1
            }
        }
        
        return uniqueDays.isEmpty ? 0.0 : Double(daysWithGoal) / Double(uniqueDays.count) * 100.0
    }
    
    // MARK: - Trend Calculations
    
    /// Получить тренд для калорий (сравнение с предыдущим периодом)
    private func getCaloriesTrend() -> PlumpyTrend {
        let currentAvg = getAverageCalories()
        let previousAvg = getPreviousPeriodAverageCalories()
        
        if currentAvg > previousAvg * 1.1 {
            return .up
        } else if currentAvg < previousAvg * 0.9 {
            return .down
        } else {
            return .neutral
        }
    }
    
    /// Получить тренд для количества приемов пищи
    private func getMealsTrend() -> PlumpyTrend {
        let currentAvg = Double(totalMeals) / Double(max(1, uniqueDayCount))
        let previousAvg = getPreviousPeriodAverageMeals()
        
        if currentAvg > previousAvg * 1.1 {
            return .up
        } else if currentAvg < previousAvg * 0.9 {
            return .down
        } else {
            return .neutral
        }
    }
    
    /// Получить тренд для достижения цели
    private func getGoalTrend() -> PlumpyTrend {
        let currentRate = getGoalAchievementRate()
        let previousRate = getPreviousPeriodGoalRate()
        
        if currentRate > previousRate + 5 {
            return .up
        } else if currentRate < previousRate - 5 {
            return .down
        } else {
            return .neutral
        }
    }
    
    /// Получить тренд для средних дневных калорий
    private func getAverageDailyCaloriesTrend() -> PlumpyTrend {
        let currentAvg = averageDailyCalories
        let previousAvg = getPreviousPeriodAverageCalories()
        
        if currentAvg > previousAvg * 1.05 {
            return .up
        } else if currentAvg < previousAvg * 0.95 {
            return .down
        } else {
            return .neutral
        }
    }
    
    /// Получить среднее количество калорий за предыдущий период
    private func getPreviousPeriodAverageCalories() -> Int {
        let calendar = Calendar.current
        let currentStartDate: Date
        let currentEndDate: Date
        
        switch selectedPeriod {
        case .week:
            currentStartDate = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
            currentEndDate = Date()
        case .month:
            currentStartDate = calendar.date(byAdding: .month, value: -1, to: Date()) ?? Date()
            currentEndDate = Date()
        case .year:
            currentStartDate = calendar.date(byAdding: .year, value: -1, to: Date()) ?? Date()
            currentEndDate = Date()
        case .custom:
            return 2000 // Для кастомного периода используем дефолт
        }
        
        let previousStartDate = calendar.date(byAdding: .day, value: -7, to: currentStartDate) ?? currentStartDate
        let previousEndDate = currentStartDate
        
        let descriptor = FetchDescriptor<FoodEntry>(
            predicate: #Predicate<FoodEntry> { entry in
                entry.date >= previousStartDate && entry.date < previousEndDate
            }
        )
        
        do {
            let previousEntries = try modelContext.fetch(descriptor)
            let totalCalories = previousEntries.reduce(0) { $0 + $1.totalCalories }
            let uniqueDays = Set(previousEntries.map { calendar.startOfDay(for: $0.date) })
            return uniqueDays.isEmpty ? 2000 : totalCalories / uniqueDays.count
        } catch {
            return 2000
        }
    }
    
    /// Получить среднее количество приемов пищи за предыдущий период
    private func getPreviousPeriodAverageMeals() -> Double {
        let calendar = Calendar.current
        let currentStartDate: Date
        let currentEndDate: Date
        
        switch selectedPeriod {
        case .week:
            currentStartDate = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
            currentEndDate = Date()
        case .month:
            currentStartDate = calendar.date(byAdding: .month, value: -1, to: Date()) ?? Date()
            currentEndDate = Date()
        case .year:
            currentStartDate = calendar.date(byAdding: .year, value: -1, to: Date()) ?? Date()
            currentEndDate = Date()
        case .custom:
            return 3.0 // Для кастомного периода используем дефолт
        }
        
        let previousStartDate = calendar.date(byAdding: .day, value: -7, to: currentStartDate) ?? currentStartDate
        let previousEndDate = currentStartDate
        
        let descriptor = FetchDescriptor<FoodEntry>(
            predicate: #Predicate<FoodEntry> { entry in
                entry.date >= previousStartDate && entry.date < previousEndDate
            }
        )
        
        do {
            let previousEntries = try modelContext.fetch(descriptor)
            let uniqueDays = Set(previousEntries.map { calendar.startOfDay(for: $0.date) })
            return uniqueDays.isEmpty ? 3.0 : Double(previousEntries.count) / Double(uniqueDays.count)
        } catch {
            return 3.0
        }
    }
    
    /// Получить процент достижения цели за предыдущий период
    private func getPreviousPeriodGoalRate() -> Double {
        let calendar = Calendar.current
        let currentStartDate: Date
        let currentEndDate: Date
        
        switch selectedPeriod {
        case .week:
            currentStartDate = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
            currentEndDate = Date()
        case .month:
            currentStartDate = calendar.date(byAdding: .month, value: -1, to: Date()) ?? Date()
            currentEndDate = Date()
        case .year:
            currentStartDate = calendar.date(byAdding: .year, value: -1, to: Date()) ?? Date()
            currentEndDate = Date()
        case .custom:
            return 80.0 // Для кастомного периода используем дефолт
        }
        
        let previousStartDate = calendar.date(byAdding: .day, value: -7, to: currentStartDate) ?? currentStartDate
        let previousEndDate = currentStartDate
        
        let descriptor = FetchDescriptor<FoodEntry>(
            predicate: #Predicate<FoodEntry> { entry in
                entry.date >= previousStartDate && entry.date < previousEndDate
            }
        )
        
        do {
            let previousEntries = try modelContext.fetch(descriptor)
            let calorieGoal = DailyGoalsService.shared.getDailyCalorieGoal(from: modelContext)
            
            var uniqueDays = Set<Date>()
            for entry in previousEntries {
                uniqueDays.insert(calendar.startOfDay(for: entry.date))
            }
            
            var daysWithGoal = 0
            for day in uniqueDays {
                let endOfDay = calendar.date(byAdding: .day, value: 1, to: day) ?? day
                let dayEntries = previousEntries.filter { entry in
                    entry.date >= day && entry.date < endOfDay
                }
                
                let dayCalories = dayEntries.reduce(0) { $0 + $1.totalCalories }
                if dayCalories >= calorieGoal {
                    daysWithGoal += 1
                }
            }
            
            return uniqueDays.isEmpty ? 80.0 : Double(daysWithGoal) / Double(uniqueDays.count) * 100.0
        } catch {
            return 80.0
        }
    }
}

// MARK: - Statistics Info Card

struct StatisticsInfoCard: View {
    let title: String
    let subtitle: String?
    let icon: String
    let iconColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: PlumpyTheme.Spacing.medium) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(iconColor)
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: PlumpyTheme.Spacing.tiny) {
                    Text(title)
                        .font(PlumpyTheme.Typography.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(PlumpyTheme.textPrimary)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(PlumpyTheme.Typography.caption1)
                            .foregroundColor(PlumpyTheme.textSecondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(PlumpyTheme.textTertiary)
            }
            .padding(.horizontal, PlumpyTheme.Spacing.medium)
            .padding(.vertical, PlumpyTheme.Spacing.medium)
            .background(PlumpyTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: PlumpyTheme.Radius.medium))
            .overlay(
                RoundedRectangle(cornerRadius: PlumpyTheme.Radius.medium)
                    .stroke(PlumpyTheme.neutral200, lineWidth: 1)
            )
            .shadow(
                color: PlumpyTheme.shadow.opacity(0.02),
                radius: PlumpyTheme.Shadow.small.radius,
                x: PlumpyTheme.Shadow.small.x,
                y: PlumpyTheme.Shadow.small.y
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Statistics Card

struct StatisticsCard: View {
    let title: String
    let value: String
    let subtitle: String?
    let icon: String
    let iconColor: Color
    let trend: PlumpyTrend
    
    enum PlumpyTrend {
        case up
        case down
        case neutral
        
        var icon: String {
            switch self {
            case .up: return "arrow.up.right"
            case .down: return "arrow.down.right"
            case .neutral: return "minus"
            }
        }
        
        var color: Color {
            switch self {
            case .up: return PlumpyTheme.success
            case .down: return PlumpyTheme.error
            case .neutral: return PlumpyTheme.textTertiary
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: PlumpyTheme.Spacing.medium) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(iconColor)
                    .frame(width: 24, height: 24)
                
                Spacer()
                
                Image(systemName: trend.icon)
                    .font(.caption)
                    .foregroundColor(trend.color)
            }
            
            VStack(alignment: .leading, spacing: PlumpyTheme.Spacing.tiny) {
                Text(value)
                    .font(PlumpyTheme.Typography.title2)
                    .fontWeight(.bold)
                    .foregroundColor(PlumpyTheme.textPrimary)
                
                Text(title)
                    .font(PlumpyTheme.Typography.caption1)
                    .foregroundColor(PlumpyTheme.textSecondary)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(PlumpyTheme.Typography.caption2)
                        .foregroundColor(PlumpyTheme.textTertiary)
                }
            }
        }
        .padding(.horizontal, PlumpyTheme.Spacing.medium)
        .padding(.vertical, PlumpyTheme.Spacing.medium)
        .background(PlumpyTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: PlumpyTheme.Radius.medium))
        .overlay(
            RoundedRectangle(cornerRadius: PlumpyTheme.Radius.medium)
                .stroke(PlumpyTheme.neutral200, lineWidth: 1)
        )
        .shadow(
            color: PlumpyTheme.shadow.opacity(0.02),
            radius: PlumpyTheme.Shadow.small.radius,
            x: PlumpyTheme.Shadow.small.x,
            y: PlumpyTheme.Shadow.small.y
        )
    }
}

// MARK: - Statistics Card Modifier

extension View {
    func statisticsCard() -> some View {
        self
            .padding(.horizontal, PlumpyTheme.Spacing.medium)
            .padding(.vertical, PlumpyTheme.Spacing.medium)
            .background(PlumpyTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: PlumpyTheme.Radius.medium))
            .overlay(
                RoundedRectangle(cornerRadius: PlumpyTheme.Radius.medium)
                    .stroke(PlumpyTheme.neutral200, lineWidth: 1)
            )
            .shadow(
                color: PlumpyTheme.shadow.opacity(0.02),
                radius: PlumpyTheme.Shadow.small.radius,
                x: PlumpyTheme.Shadow.small.x,
                y: PlumpyTheme.Shadow.small.y
            )
    }
}

#Preview {
    StatisticsView()
        .modelContainer(for: [FoodEntry.self, FoodProduct.self, UserProfile.self], inMemory: true)
}
