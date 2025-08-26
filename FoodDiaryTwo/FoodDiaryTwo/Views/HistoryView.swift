//
//  HistoryView.swift
//  FoodDiaryTwo
//
//  Created by user on 31.07.2025.
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allFoodEntries: [FoodEntry]
    
    @State private var searchText = ""
    @State private var selectedPeriod: HistoryPeriod = .week
    @State private var selectedDate = Date()
    @State private var showingCalendar = false
    @State private var pagedEntries: [FoodEntry] = []
    @State private var pageSize = 30
    @State private var isLoadingPage = false
    
    enum HistoryPeriod: String, CaseIterable {
        case week = "week"
        case month = "month"
        case year = "year"
        case custom = "custom"
        
        var displayName: String {
            switch self {
            case .week: return LocalizationManager.shared.localizedString(.week)
            case .month: return LocalizationManager.shared.localizedString(.month)
            case .year: return LocalizationManager.shared.localizedString(.year)
            case .custom: return LocalizationManager.shared.localizedString(.custom)
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
                    title: LocalizationManager.shared.localizedString(.history),
                    subtitle: ""
                )
                
                ScrollView {
                    VStack(spacing: PlumpyTheme.Spacing.large) {
                        // Период и календарь
                        periodSelector
                        
                        // Поиск
                        searchSection
                        
                        // Список записей
                        historyList
                        
                        PlumpySpacer(size: .huge)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, PlumpyTheme.Spacing.medium)
                    .padding(.top, PlumpyTheme.Spacing.medium)
                }
            }
        }
        .sheet(isPresented: $showingCalendar) {
            CalendarView(selectedDate: $selectedDate)
        }
    }
    
    private var periodSelector: some View {
        VStack(alignment: .leading, spacing: PlumpyTheme.Spacing.medium) {
            HStack {
                Text(LocalizationManager.shared.localizedString(.dailyProgress))
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
                ForEach(HistoryPeriod.allCases, id: \.self) { period in
                    PlumpyChip(
                        title: period.displayName,
                        style: selectedPeriod == period ? .primary : .outline,
                        isSelected: selectedPeriod == period
                    ) {
                        selectedPeriod = period
                        if period != .custom {
                            selectedDate = Date()
                        }
                    }
                    .frame(minWidth: PlumpyTheme.Spacing.huge) // Увеличиваем минимальную ширину для лучшего размещения текста
                }
                Spacer()
            }
        }
        .plumpyCard()
    }
    
    private var searchSection: some View {
        VStack(spacing: PlumpyTheme.Spacing.medium) {
            PlumpySearchField(
                text: $searchText,
                placeholder: LocalizationManager.shared.localizedString(.search),
                onSearch: { query in
                    // Поиск уже реализован через computed property
                }
            )
            
            if !searchText.isEmpty {
                HStack {
                    Text("\(filteredEntries.count)")
                        .font(PlumpyTheme.Typography.caption1)
                        .foregroundColor(PlumpyTheme.textSecondary)
                    
                    Spacer()
                    
                    Button(LocalizationManager.shared.localizedString(.cancel)) {
                        searchText = ""
                    }
                    .font(PlumpyTheme.Typography.caption1)
                    .foregroundColor(PlumpyTheme.primary)
                }
            }
        }
    }
    
    private var historyList: some View {
        VStack(spacing: PlumpyTheme.Spacing.medium) {
            HStack {
                Text(selectedPeriod == .custom ? "\(formatDate(selectedDate))" : LocalizationManager.shared.localizedString(.todaysMeals))
                    .font(PlumpyTheme.Typography.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(PlumpyTheme.textPrimary)
                
                Spacer()
                
                Text("\(filteredEntries.count)")
                    .font(PlumpyTheme.Typography.caption1)
                    .foregroundColor(PlumpyTheme.textSecondary)
            }
            
            let entries = pagedEntries
            if entries.isEmpty {
                PlumpyEmptyState(
                    icon: "clock",
                    title: searchText.isEmpty ? LocalizationManager.shared.localizedString(.noMealsToday) : LocalizationManager.shared.localizedString(.search),
                    subtitle: searchText.isEmpty ? 
                        LocalizationManager.shared.localizedString(.startTrackingHint) :
                        LocalizationManager.shared.localizedString(.search),
                    actionTitle: searchText.isEmpty ? LocalizationManager.shared.localizedString(.addMealCta) : LocalizationManager.shared.localizedString(.cancel)
                ) {
                    if !searchText.isEmpty {
                        searchText = ""
                    }
                }
            } else {
                LazyVStack(spacing: PlumpyTheme.Spacing.small) {
                    ForEach(entries) { entry in
                        FoodEntryHistoryCard(entry: entry)
                            .frame(height: 80)
                            .onAppear {
                                if entry.id == entries.last?.id {
                                    loadNextPageIfNeeded()
                                }
                            }
                    }
                    if isLoadingPage {
                        ProgressView().padding()
                    }
                }
            }
        }
        .plumpyCard()
        .task(id: filteredEntries.map(\.id)) {
            PerformanceLogger.begin("history_filter_compute")
            // reset paging on new filter
            pagedEntries = Array(filteredEntries.prefix(pageSize))
            PerformanceLogger.end("history_filter_compute")
        }
    }

    private var filteredEntries: [FoodEntry] {
        var entries = allFoodEntries
        
        // Фильтрация по периоду
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedPeriod {
        case .week:
            let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) ?? now
            entries = entries.filter { $0.date >= weekAgo }
        case .month:
            let monthAgo = calendar.date(byAdding: .month, value: -1, to: now) ?? now
            entries = entries.filter { $0.date >= monthAgo }
        case .year:
            let yearAgo = calendar.date(byAdding: .year, value: -1, to: now) ?? now
            entries = entries.filter { $0.date >= yearAgo }
        case .custom:
            let startOfDay = calendar.startOfDay(for: selectedDate)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? startOfDay
            entries = entries.filter { $0.date >= startOfDay && $0.date < endOfDay }
        }
        
        // Фильтрация по поиску
        if !searchText.isEmpty {
            let searchLower = searchText.lowercased()
            entries = entries.filter { entry in
                // Поиск по названию приема пищи
                if entry.displayName.lowercased().contains(searchLower) {
                    return true
                }
                
                // Поиск по продуктам
                if entry.products.contains(where: { product in
                    product.name.lowercased().contains(searchLower)
                }) {
                    return true
                }
                
                // Поиск по заметкам
                if let notes = entry.notes, notes.lowercased().contains(searchLower) {
                    return true
                }
                
                // Поиск по типу приема пищи
                if entry.mealType.displayName.lowercased().contains(searchLower) {
                    return true
                }
                
                return false
            }
        }
        
        // Сортировка по дате (новые сначала)
        return entries.sorted { $0.date > $1.date }
    }

    private func loadNextPageIfNeeded() {
        guard !isLoadingPage else { return }
        let currentCount = pagedEntries.count
        guard currentCount < filteredEntries.count else { return }
        isLoadingPage = true
        let nextEnd = min(currentCount + pageSize, filteredEntries.count)
        DispatchQueue.global(qos: .userInitiated).async {
            let nextSlice = Array(filteredEntries[currentCount..<nextEnd])
            DispatchQueue.main.async {
                withAnimation(.easeInOut(duration: 0.2)) {
                    pagedEntries.append(contentsOf: nextSlice)
                    isLoadingPage = false
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// MARK: - Calendar View
struct CalendarView: View {
    @Binding var selectedDate: Date
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: PlumpyTheme.Spacing.large) {
                DatePicker(
                    LocalizationManager.shared.localizedString(.selectDate),
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .padding()
                
                Spacer()
                
                PlumpyButton(
                    title: LocalizationManager.shared.localizedString(.selectDate),
                    style: .primary
                ) {
                    dismiss()
                }
                .padding(.horizontal, PlumpyTheme.Spacing.large)
                .padding(.bottom, PlumpyTheme.Spacing.large)
            }
            .navigationTitle(LocalizationManager.shared.localizedString(.selectDate))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(LocalizationManager.shared.localizedString(.cancel)) {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Food Entry History Card
struct FoodEntryHistoryCard: View {
    let entry: FoodEntry
    @State private var showingDetail = false
    
    var body: some View {
        Button(action: {
            showingDetail = true
        }) {
            HStack(spacing: PlumpyTheme.Spacing.medium) {
                // Фото или иконка
                if let photoData = entry.photoData {
                    let key = entry.id.uuidString
                    let uiImage = previewImage(forKey: key, data: photoData)
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: PlumpyTheme.Spacing.huge, height: PlumpyTheme.Spacing.huge)
                        .clipShape(RoundedRectangle(cornerRadius: PlumpyTheme.Radius.small))
                } else {
                    Image(systemName: entry.mealType.icon)
                        .font(.system(size: 20))
                        .foregroundColor(entry.mealType.color)
                        .frame(width: PlumpyTheme.Spacing.huge, height: PlumpyTheme.Spacing.huge)
                        .background(
                            RoundedRectangle(cornerRadius: PlumpyTheme.Radius.small)
                                .fill(entry.mealType.color.opacity(0.1))
                        )
                }
                
                VStack(alignment: .leading, spacing: PlumpyTheme.Spacing.tiny) {
                    Text(entry.displayName)
                        .font(PlumpyTheme.Typography.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(PlumpyTheme.textPrimary)
                    
                    HStack(spacing: PlumpyTheme.Spacing.small) {
                        Text(entry.mealType.displayName)
                            .font(PlumpyTheme.Typography.caption2)
                            .foregroundColor(entry.mealType.color)
                            .padding(.horizontal, PlumpyTheme.Spacing.tiny)
                            .padding(.vertical, PlumpyTheme.Spacing.tiny)
                            .background(
                                RoundedRectangle(cornerRadius: PlumpyTheme.Radius.small)
                                    .fill(entry.mealType.color.opacity(0.1))
                            )
                        
                        Text(entry.formattedDate)
                            .font(PlumpyTheme.Typography.caption2)
                            .foregroundColor(PlumpyTheme.textSecondary)
                    }
                    
                    if !entry.products.isEmpty {
                        Text("\(entry.products.count) \(LocalizationManager.shared.localizedString(.products))")
                            .font(PlumpyTheme.Typography.caption2)
                            .foregroundColor(PlumpyTheme.textTertiary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: PlumpyTheme.Spacing.tiny) {
                    Text("\(entry.totalCalories)")
                        .font(PlumpyTheme.Typography.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(PlumpyTheme.textPrimary)
                    
                    Text(LocalizationManager.shared.localizedString(.calUnit))
                        .font(PlumpyTheme.Typography.caption2)
                        .foregroundColor(PlumpyTheme.textSecondary)
                }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(PlumpyTheme.textTertiary)
            }
            .padding(PlumpyTheme.Spacing.medium)
            .background(
                RoundedRectangle(cornerRadius: PlumpyTheme.Radius.medium)
                    .fill(PlumpyTheme.surfaceSecondary)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingDetail) {
            FoodEntryDetailView(foodEntry: entry)
        }
    }
}

extension FoodEntryHistoryCard {
    private func previewImage(forKey key: String, data: Data) -> UIImage {
        if let cached = ImageCache.shared.image(forKey: key) {
            return cached
        }
        if let ui = UIImage(data: data) {
            ImageCache.shared.set(ui, forKey: key)
            return ui
        }
        return UIImage()
    }
}

#Preview {
    HistoryView()
        .modelContainer(for: [FoodEntry.self, FoodProduct.self, UserProfile.self], inMemory: true)
}

