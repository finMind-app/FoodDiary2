//
//  FoodEntryDetailView.swift
//  FoodDiaryTwo
//
//  Created by user on 16.08.2025.
//

import SwiftUI
import SwiftData
import PhotosUI

struct FoodEntryDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var foodEntry: FoodEntry
    
    @State private var isEditing = false
    @State private var showingDeleteAlert = false
    @State private var showingImagePicker = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    
    // Редактируемые поля
    @State private var editedName: String = ""
    @State private var editedMealType: MealType = .breakfast
    @State private var editedDate = Date()
    @State private var editedNotes: String = ""
    @State private var editedProducts: [FoodProduct] = []
    
    var body: some View {
        ZStack {
            PlumpyBackground(style: .primary)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Navigation Bar
                PlumpyNavigationBar(
                    title: isEditing ? LocalizationManager.shared.localizedString(.edit) + " " + LocalizationManager.shared.localizedString(.addMeal) : LocalizationManager.shared.localizedString(.addMeal),
                    subtitle: isEditing ? LocalizationManager.shared.localizedString(.edit) : foodEntry.mealType.displayName,
                    leftButton: PlumpyNavigationButton(
                        icon: "xmark",
                        title: LocalizationManager.shared.localizedString(.cancel),
                        action: {
                            if isEditing {
                                // Отменить редактирование
                                resetToOriginalValues()
                                isEditing = false
                            } else {
                                dismiss()
                            }
                        }
                    ),
                    rightButton: PlumpyNavigationButton(
                        icon: isEditing ? "checkmark" : "pencil",
                        title: isEditing ? LocalizationManager.shared.localizedString(.save) : LocalizationManager.shared.localizedString(.edit),
                        action: {
                            if isEditing {
                                saveChanges()
                                isEditing = false
                            } else {
                                startEditing()
                            }
                        }
                    )
                )
                
                ScrollView {
                    VStack(spacing: PlumpyTheme.Spacing.large) {
                        // Фото приема пищи
                        photoSection
                        
                        // Основная информация
                        basicInfoSection
                        
                        // Продукты
                        productsSection
                        
                        // Заметки
                        notesSection
                        
                        // Статистика
                        nutritionSection
                        
                        // Кнопка удаления
                        if !isEditing {
                            deleteButton
                        }
                        
                        PlumpySpacer(size: .huge)
                    }
                    .padding(.horizontal, PlumpyTheme.Spacing.medium)
                    .padding(.top, PlumpyTheme.Spacing.medium)
                }
            }
        }
        .onAppear {
            resetToOriginalValues()
        }
        .onChange(of: selectedPhotoItem) { _, newItem in
            Task {
                if let newItem = newItem,
                   let data = try? await newItem.loadTransferable(type: Data.self) {
                    if isEditing {
                        // В режиме редактирования сохраняем во временную переменную
                        // Фото будет сохранено при нажатии "Сохранить"
                    } else {
                        // В режиме просмотра сразу обновляем
                        $foodEntry.photoData.wrappedValue = data
                        try? modelContext.save()
                    }
                }
            }
        }
        .alert(LocalizationManager.shared.localizedString(.delete), isPresented: $showingDeleteAlert) {
            Button(LocalizationManager.shared.localizedString(.cancel), role: .cancel) { }
            Button(LocalizationManager.shared.localizedString(.delete), role: .destructive) {
                deleteMeal()
            }
        } message: {
            Text(LocalizationManager.shared.localizedString(.clearAllDataAlertMessage))
        }
    }
    
    // MARK: - Photo Section
    private var photoSection: some View {
        VStack(spacing: PlumpyTheme.Spacing.medium) {
            if let photoData = $foodEntry.photoData.wrappedValue, let uiImage = UIImage(data: photoData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: PlumpyTheme.Radius.large))
                    .overlay(
                        RoundedRectangle(cornerRadius: PlumpyTheme.Radius.large)
                            .stroke(PlumpyTheme.neutral200, lineWidth: 1)
                    )
                    .shadow(
                        color: PlumpyTheme.shadow.opacity(0.1),
                        radius: PlumpyTheme.Shadow.medium.radius,
                        x: PlumpyTheme.Shadow.medium.x,
                        y: PlumpyTheme.Shadow.medium.y
                    )
            } else {
                RoundedRectangle(cornerRadius: PlumpyTheme.Radius.large)
                    .fill(PlumpyTheme.neutral100)
                    .frame(height: 200)
                    .overlay(
                        VStack(spacing: PlumpyTheme.Spacing.small) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 40))
                                .foregroundColor(PlumpyTheme.textTertiary)
                            Text(LocalizationManager.shared.localizedString(.profilePhoto))
                                .font(PlumpyTheme.Typography.caption1)
                                .foregroundColor(PlumpyTheme.textTertiary)
                        }
                    )
            }
            
            if isEditing {
                HStack(spacing: PlumpyTheme.Spacing.medium) {
                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        PlumpyButton(
                            title: LocalizationManager.shared.localizedString(.tapToChangePhoto),
                            icon: "photo",
                            style: .outline,
                            size: .small
                        ) {
                            // Action handled by PhotosPicker
                        }
                    }
                    
                    if $foodEntry.photoData.wrappedValue != nil {
                        PlumpyButton(
                            title: LocalizationManager.shared.localizedString(.delete),
                            icon: "trash",
                            style: .outline,
                            size: .small
                        ) {
                            $foodEntry.photoData.wrappedValue = nil
                        }
                    }
                }
            }
        }
        .plumpyCard()
    }
    
    // MARK: - Basic Info Section
    private var basicInfoSection: some View {
        VStack(spacing: PlumpyTheme.Spacing.medium) {
            Text(LocalizationManager.shared.localizedString(.foodDiary))
                .font(PlumpyTheme.Typography.headline)
                .fontWeight(.semibold)
                .foregroundColor(PlumpyTheme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: PlumpyTheme.Spacing.medium) {
                // Название
                VStack(alignment: .leading, spacing: PlumpyTheme.Spacing.tiny) {
                    Text(LocalizationManager.shared.localizedString(.userName))
                        .font(PlumpyTheme.Typography.caption1)
                        .fontWeight(.medium)
                        .foregroundColor(PlumpyTheme.textSecondary)
                    
                    if isEditing {
                        PlumpyField(
                            title: LocalizationManager.shared.localizedString(.mealName),
                            placeholder: LocalizationManager.shared.localizedString(.mealName),
                            text: $editedName
                        )
                    } else {
                        Text(foodEntry.displayName)
                            .font(PlumpyTheme.Typography.body)
                            .foregroundColor(PlumpyTheme.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(PlumpyTheme.Spacing.medium)
                            .background(
                                RoundedRectangle(cornerRadius: PlumpyTheme.Radius.medium)
                                    .fill(PlumpyTheme.neutral50)
                            )
                    }
                }
                
                // Тип приема пищи
                VStack(alignment: .leading, spacing: PlumpyTheme.Spacing.tiny) {
                    Text(LocalizationManager.shared.localizedString(.mealType))
                        .font(PlumpyTheme.Typography.caption1)
                        .fontWeight(.medium)
                        .foregroundColor(PlumpyTheme.textSecondary)
                    
                    if isEditing {
                        HStack(spacing: PlumpyTheme.Spacing.small) {
                            ForEach(MealType.allCases, id: \.self) { mealType in
                                PlumpyChip(
                                    title: mealType.displayName,
                                    style: editedMealType == mealType ? .primary : .outline,
                                    isSelected: editedMealType == mealType
                                ) {
                                    editedMealType = mealType
                                }
                            }
                        }
                    } else {
                        HStack(spacing: PlumpyTheme.Spacing.small) {
                            Image(systemName: foodEntry.mealType.icon)
                                .foregroundColor(foodEntry.mealType.color)
                            Text(foodEntry.mealType.displayName)
                                .font(PlumpyTheme.Typography.body)
                                .foregroundColor(PlumpyTheme.textPrimary)
                        }
                        .padding(PlumpyTheme.Spacing.medium)
                        .background(
                            RoundedRectangle(cornerRadius: PlumpyTheme.Radius.medium)
                                .fill(foodEntry.mealType.color.opacity(0.1))
                        )
                    }
                }
                
                // Дата и время
                VStack(alignment: .leading, spacing: PlumpyTheme.Spacing.tiny) {
                    Text(LocalizationManager.shared.localizedString(.mealTime))
                        .font(PlumpyTheme.Typography.caption1)
                        .fontWeight(.medium)
                        .foregroundColor(PlumpyTheme.textSecondary)
                    
                    if isEditing {
                        DatePicker(
                            LocalizationManager.shared.localizedString(.mealTime),
                            selection: $editedDate,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .datePickerStyle(.compact)
                        .labelsHidden()
                        .padding(PlumpyTheme.Spacing.medium)
                        .background(
                            RoundedRectangle(cornerRadius: PlumpyTheme.Radius.medium)
                                .fill(PlumpyTheme.neutral50)
                        )
                    } else {
                        HStack(spacing: PlumpyTheme.Spacing.small) {
                            Image(systemName: "calendar")
                                .foregroundColor(PlumpyTheme.textSecondary)
                            Text(foodEntry.formattedDate)
                                .font(PlumpyTheme.Typography.body)
                                .foregroundColor(PlumpyTheme.textPrimary)
                            Text("•")
                                .foregroundColor(PlumpyTheme.textSecondary)
                            Text(foodEntry.formattedTime)
                                .font(PlumpyTheme.Typography.body)
                                .foregroundColor(PlumpyTheme.textPrimary)
                        }
                        .padding(PlumpyTheme.Spacing.medium)
                        .background(
                            RoundedRectangle(cornerRadius: PlumpyTheme.Radius.medium)
                                .fill(PlumpyTheme.neutral50)
                        )
                    }
                }
            }
        }
        .plumpyCard()
    }
    
    // MARK: - Products Section
    private var productsSection: some View {
        VStack(spacing: PlumpyTheme.Spacing.medium) {
            HStack {
                Text(LocalizationManager.shared.localizedString(.products))
                    .font(PlumpyTheme.Typography.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(PlumpyTheme.textPrimary)
                
                Spacer()
                
                Text("\(foodEntry.products.count) \(LocalizationManager.shared.localizedString(.items))")
                    .font(PlumpyTheme.Typography.caption1)
                    .foregroundColor(PlumpyTheme.textSecondary)
            }
            
            if foodEntry.products.isEmpty {
                PlumpyEmptyState(
                    icon: "fork.knife",
                    title: LocalizationManager.shared.localizedString(.products),
                    subtitle: nil,
                    actionTitle: isEditing ? LocalizationManager.shared.localizedString(.addProduct) : nil
                ) {
                    // TODO: Добавить логику добавления продукта
                }
            } else {
                LazyVStack(spacing: PlumpyTheme.Spacing.small) {
                    ForEach(foodEntry.products) { product in
                        HStack(spacing: PlumpyTheme.Spacing.medium) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(product.name)
                                    .font(PlumpyTheme.Typography.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(PlumpyTheme.textPrimary)
                                
                                Text("\(product.caloriesPerServing) \(LocalizationManager.shared.localizedString(.calUnit)) • \(product.servingSize)g")
                                    .font(PlumpyTheme.Typography.caption2)
                                    .foregroundColor(PlumpyTheme.textSecondary)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("\(product.caloriesPerServing)")
                                    .font(PlumpyTheme.Typography.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(PlumpyTheme.textPrimary)
                                
                                Text(LocalizationManager.shared.localizedString(.calUnit))
                                    .font(PlumpyTheme.Typography.caption2)
                                    .foregroundColor(PlumpyTheme.textSecondary)
                            }
                        }
                        .padding(PlumpyTheme.Spacing.medium)
                        .background(
                            RoundedRectangle(cornerRadius: PlumpyTheme.Radius.medium)
                                .fill(PlumpyTheme.surfaceSecondary)
                        )
                    }
                }
            }
        }
        .plumpyCard()
    }
    
    // MARK: - Notes Section
    private var notesSection: some View {
        VStack(spacing: PlumpyTheme.Spacing.medium) {
            Text(LocalizationManager.shared.localizedString(.notes))
                .font(PlumpyTheme.Typography.headline)
                .fontWeight(.semibold)
                .foregroundColor(PlumpyTheme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if isEditing {
                PlumpyTextArea(
                    title: LocalizationManager.shared.localizedString(.notes),
                    placeholder: LocalizationManager.shared.localizedString(.notes),
                    text: $editedNotes
                )
            } else {
                if let notes = foodEntry.notes, !notes.isEmpty {
                    Text(notes)
                        .font(PlumpyTheme.Typography.body)
                        .foregroundColor(PlumpyTheme.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(PlumpyTheme.Spacing.medium)
                        .background(
                            RoundedRectangle(cornerRadius: PlumpyTheme.Radius.medium)
                                .fill(PlumpyTheme.neutral50)
                        )
                } else {
                    Text(LocalizationManager.shared.localizedString(.notes))
                        .font(PlumpyTheme.Typography.body)
                        .foregroundColor(PlumpyTheme.textTertiary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(PlumpyTheme.Spacing.medium)
                        .background(
                            RoundedRectangle(cornerRadius: PlumpyTheme.Radius.medium)
                                .fill(PlumpyTheme.neutral50)
                        )
                }
            }
        }
        .plumpyCard()
    }
    
    // MARK: - Nutrition Section
    private var nutritionSection: some View {
        VStack(spacing: PlumpyTheme.Spacing.medium) {
            Text(LocalizationManager.shared.localizedString(.totalCalories))
                .font(PlumpyTheme.Typography.headline)
                .fontWeight(.semibold)
                .foregroundColor(PlumpyTheme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: PlumpyTheme.Spacing.medium) {
                PlumpyStatsCard(
                    title: LocalizationManager.shared.localizedString(.calories),
                    value: "\(foodEntry.totalCalories)",
                    subtitle: LocalizationManager.shared.localizedString(.totalCalories),
                    icon: "flame.fill",
                    iconColor: PlumpyTheme.warning
                )
                
                PlumpyStatsCard(
                    title: LocalizationManager.shared.localizedString(.protein),
                    value: String(format: "%.1fg", foodEntry.totalProtein),
                    subtitle: LocalizationManager.shared.localizedString(.totalCalories),
                    icon: "circle.fill",
                    iconColor: PlumpyTheme.primary
                )
                
                PlumpyStatsCard(
                    title: LocalizationManager.shared.localizedString(.carbs),
                    value: String(format: "%.1fg", foodEntry.totalCarbs),
                    subtitle: LocalizationManager.shared.localizedString(.totalCalories),
                    icon: "circle.fill",
                    iconColor: PlumpyTheme.secondary
                )
                
                PlumpyStatsCard(
                    title: LocalizationManager.shared.localizedString(.fat),
                    value: String(format: "%.1fg", foodEntry.totalFat),
                    subtitle: LocalizationManager.shared.localizedString(.totalCalories),
                    icon: "circle.fill",
                    iconColor: PlumpyTheme.tertiary
                )
            }
        }
        .plumpyCard()
    }
    
    // MARK: - Delete Button
    private var deleteButton: some View {
        PlumpyButton(
            title: LocalizationManager.shared.localizedString(.delete),
            icon: "trash",
            style: .outline
        ) {
            showingDeleteAlert = true
        }
        .plumpyCard()
    }
    
    // MARK: - Helper Methods
    private func startEditing() {
        isEditing = true
        resetToOriginalValues()
    }
    
    private func resetToOriginalValues() {
        editedName = foodEntry.name
        editedMealType = foodEntry.mealType
        editedDate = foodEntry.date
        editedNotes = foodEntry.notes ?? ""
        editedProducts = foodEntry.products
    }
    
    private func saveChanges() {
        // Обновляем данные
        foodEntry.name = editedName
        foodEntry.mealType = editedMealType
        foodEntry.date = editedDate
        foodEntry.notes = editedNotes.isEmpty ? nil : editedNotes
        foodEntry.products = editedProducts
        
        // Пересчитываем общие значения
        foodEntry.totalCalories = editedProducts.reduce(0) { $0 + $1.caloriesPerServing }
        foodEntry.totalProtein = editedProducts.reduce(0) { $0 + $1.protein }
        foodEntry.totalCarbs = editedProducts.reduce(0) { $0 + $1.carbs }
        foodEntry.totalFat = editedProducts.reduce(0) { $0 + $1.fat }
        
        foodEntry.updatedAt = Date()
        
        // Сохраняем изменения
        try? modelContext.save()
    }
    
    private func deleteMeal() {
        modelContext.delete(foodEntry)
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    // Preview temporarily disabled due to SwiftData model initialization complexity
    Text("FoodEntryDetailView Preview")
}
