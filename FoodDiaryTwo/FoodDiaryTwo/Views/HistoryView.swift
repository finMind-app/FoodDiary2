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
    
    enum HistoryPeriod: String, CaseIterable {
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
                    title: "History",
                    subtitle: "Your meal history"
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
                placeholder: "Search meals, products, notes...",
                onSearch: { query in
                    // Поиск уже реализован через computed property
                }
            )
            
            if !searchText.isEmpty {
                HStack {
                    Text("Search results: \(filteredEntries.count)")
                        .font(PlumpyTheme.Typography.caption1)
                        .foregroundColor(PlumpyTheme.textSecondary)
                    
                    Spacer()
                    
                    Button("Clear") {
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
                Text(selectedPeriod == .custom ? "Meals for \(formatDate(selectedDate))" : "Recent Meals")
                    .font(PlumpyTheme.Typography.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(PlumpyTheme.textPrimary)
                
                Spacer()
                
                Text("\(filteredEntries.count) meals")
                    .font(PlumpyTheme.Typography.caption1)
                    .foregroundColor(PlumpyTheme.textSecondary)
            }
            
            let entries = filteredEntries
            if entries.isEmpty {
                PlumpyEmptyState(
                    icon: "clock",
                    title: searchText.isEmpty ? "No meals found" : "No search results",
                    subtitle: searchText.isEmpty ? 
                        "Your meal history will appear here once you start tracking" :
                        "Try adjusting your search terms",
                    actionTitle: searchText.isEmpty ? "Add First Meal" : "Clear Search"
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
                    }
                }
            }
        }
        .plumpyCard()
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
                    "Select Date",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .padding()
                
                Spacer()
                
                PlumpyButton(
                    title: "Select Date",
                    style: .primary
                ) {
                    dismiss()
                }
                .padding(.horizontal, PlumpyTheme.Spacing.large)
                .padding(.bottom, PlumpyTheme.Spacing.large)
            }
            .navigationTitle("Select Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
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
                if let photoData = entry.photoData, let uiImage = UIImage(data: photoData) {
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
                        Text("\(entry.products.count) products")
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
                    
                    Text("cal")
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

#Preview {
    HistoryView()
        .modelContainer(for: [FoodEntry.self, FoodProduct.self, UserProfile.self], inMemory: true)
}

