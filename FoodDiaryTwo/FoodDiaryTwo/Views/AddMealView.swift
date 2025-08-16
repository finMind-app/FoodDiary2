//
//  AddMealView.swift
//  FoodDiaryTwo
//
//  Created by user on 31.07.2025.
//

import SwiftUI
import SwiftData
import PhotosUI

struct AddMealView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var mealName = ""
    @State private var selectedMealType: MealType
    @State private var selectedTime = Date()
    @State private var calories = ""
    @State private var notes = ""
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    
    init(mealType: MealType = .breakfast) {
        self._selectedMealType = State(initialValue: mealType)
    }
    
    // MealType is defined in FoodEntry.swift
    
    var body: some View {
        ZStack {
            PlumpyBackground(style: .primary)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Navigation Bar
                PlumpyNavigationBar(
                    title: "Add Meal",
                    leftButton: PlumpyNavigationButton(
                        icon: "xmark",
                        title: "Cancel",
                        style: .outline
                    ) {
                        dismiss()
                    },
                    rightButton: PlumpyNavigationButton(
                        icon: "checkmark",
                        title: "Save",
                        style: .primary
                    ) {
                        saveMeal()
                    }
                )
                
                ScrollView {
                    VStack(spacing: PlumpyTheme.Spacing.medium) {
                        // Основная информация
                        basicInfoSection
                        
                        // Фото
                        photoSection
                        
                        // Заметки
                        notesSection
                        
                        PlumpySpacer(size: .large)
                    }
                    .padding(.horizontal, PlumpyTheme.Spacing.medium)
                    .padding(.top, PlumpyTheme.Spacing.medium)
                }
            }
        }
    }
    
    private var basicInfoSection: some View {
        VStack(spacing: PlumpyTheme.Spacing.medium) {
            Text("Basic Information")
                .font(PlumpyTheme.Typography.headline)
                .fontWeight(.semibold)
                .foregroundColor(PlumpyTheme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Название приема пищи
            PlumpyField(
                title: "Meal Name",
                placeholder: "Enter meal name",
                text: $mealName,
                icon: "fork.knife",
                isRequired: true
            )
            
            // Тип приема пищи
            VStack(alignment: .leading, spacing: PlumpyTheme.Spacing.small) {
                Text("Meal Type")
                    .font(PlumpyTheme.Typography.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(PlumpyTheme.textSecondary)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: PlumpyTheme.Spacing.small) {
                    ForEach(MealType.allCases, id: \.self) { mealType in
                        PlumpyChip(
                            title: mealType.displayName,
                            icon: mealType.icon,
                            style: selectedMealType == mealType ? .primary : .outline,
                            isSelected: selectedMealType == mealType
                        ) {
                            selectedMealType = mealType
                        }
                    }
                }
            }
            
            // Время приема пищи
            VStack(alignment: .leading, spacing: PlumpyTheme.Spacing.small) {
                Text("Time")
                    .font(PlumpyTheme.Typography.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(PlumpyTheme.textSecondary)
                
                DatePicker("", selection: $selectedTime, displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .padding(PlumpyTheme.Spacing.medium)
                    .plumpyCard(
                        cornerRadius: PlumpyTheme.Radius.medium,
                        backgroundColor: PlumpyTheme.surfaceSecondary
                    )
            }
            
            // Калории
            PlumpyField(
                title: "Calories",
                placeholder: "Enter calories",
                text: $calories,
                keyboardType: .numberPad,
                icon: "flame.fill",
                iconColor: PlumpyTheme.warning,
                isRequired: true
            )
        }
        .plumpyCard()
    }
    
    private var photoSection: some View {
        VStack(spacing: PlumpyTheme.Spacing.medium) {
            Text("Photo")
                .font(PlumpyTheme.Typography.headline)
                .fontWeight(.semibold)
                .foregroundColor(PlumpyTheme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if let selectedImage = selectedImage {
                VStack(spacing: PlumpyTheme.Spacing.medium) {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: PlumpyTheme.Radius.medium))
                        .shadow(
                            color: PlumpyTheme.shadow.opacity(0.1),
                            radius: PlumpyTheme.Shadow.medium.radius,
                            x: PlumpyTheme.Shadow.medium.x,
                            y: PlumpyTheme.Shadow.medium.y
                        )
                    
                    HStack(spacing: PlumpyTheme.Spacing.medium) {
                        PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                            PlumpyButton(
                                title: "Change",
                                icon: "camera.fill",
                                style: .secondary,
                                size: .small
                            ) {
                                // Action handled by PhotosPicker
                            }
                        }
                        
                        PlumpyButton(
                            title: "Remove",
                            icon: "trash.fill",
                            style: .error,
                            size: .small
                        ) {
                            self.selectedImage = nil
                            self.selectedPhotoItem = nil
                        }
                    }
                }
            } else {
                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    VStack(spacing: PlumpyTheme.Spacing.medium) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 40))
                            .foregroundColor(PlumpyTheme.primaryAccent)
                        
                        Text("Add Photo")
                            .font(PlumpyTheme.Typography.headline)
                            .fontWeight(.medium)
                            .foregroundColor(PlumpyTheme.primaryAccent)
                        
                        Text("Take a photo or choose from gallery")
                            .font(PlumpyTheme.Typography.caption1)
                            .foregroundColor(PlumpyTheme.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(PlumpyTheme.Spacing.extraLarge)
                    .plumpyCard(
                        cornerRadius: PlumpyTheme.Radius.large,
                        backgroundColor: PlumpyTheme.primary.opacity(0.1),
                        borderColor: PlumpyTheme.primaryAccent,
                        borderWidth: 2
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .plumpyCard()
        .onChange(of: selectedPhotoItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    selectedImage = image
                }
            }
        }
    }
    
    private var notesSection: some View {
        VStack(spacing: PlumpyTheme.Spacing.medium) {
            Text("Notes")
                .font(PlumpyTheme.Typography.headline)
                .fontWeight(.semibold)
                .foregroundColor(PlumpyTheme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(alignment: .leading, spacing: PlumpyTheme.Spacing.small) {
                Text("Additional notes")
                    .font(PlumpyTheme.Typography.caption1)
                    .fontWeight(.medium)
                    .foregroundColor(PlumpyTheme.textSecondary)
                
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: PlumpyTheme.Radius.medium)
                        .fill(PlumpyTheme.neutral50)
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
                    
                    if notes.isEmpty {
                        Text("Add notes about your meal...")
                            .font(PlumpyTheme.Typography.body)
                            .foregroundColor(PlumpyTheme.textTertiary)
                            .padding(.horizontal, PlumpyTheme.Spacing.medium)
                            .padding(.top, PlumpyTheme.Spacing.medium)
                    }
                    
                    TextEditor(text: $notes)
                        .font(PlumpyTheme.Typography.body)
                        .foregroundColor(PlumpyTheme.textPrimary)
                        .padding(.horizontal, PlumpyTheme.Spacing.medium)
                        .padding(.vertical, PlumpyTheme.Spacing.medium)
                        .background(Color.clear)
                        .frame(minHeight: 80, maxHeight: 120)
                }
            }
        }
        .plumpyCard()
    }
    
    private func saveMeal() {
        // Валидация данных
        guard !mealName.isEmpty else {
            // Можно добавить алерт для пользователя
            print("Meal name is required")
            return
        }
        
        guard let caloriesInt = Int(calories), caloriesInt > 0 else {
            // Можно добавить алерт для пользователя
            print("Valid calories are required")
            return
        }
        
        // Создаем продукт для приема пищи
        let product = FoodProduct(
            name: mealName,
            caloriesPerServing: caloriesInt,
            protein: 0, // Можно добавить поля для ввода
            carbs: 0,
            fat: 0
        )
        
        // Конвертируем изображение в Data для сохранения
        var photoData: Data? = nil
        if let selectedImage = selectedImage {
            photoData = selectedImage.jpegData(compressionQuality: 0.8)
        }
        
        // Создаем запись о приеме пищи
        let foodEntry = FoodEntry(
            name: mealName,
            date: selectedTime,
            mealType: selectedMealType,
            products: [product],
            notes: notes.isEmpty ? nil : notes,
            photoData: photoData
        )
        
        // Сохраняем в базу данных
        modelContext.insert(foodEntry)
        
        do {
            try modelContext.save()
            print("Meal saved successfully: \(foodEntry.displayName)")
            dismiss()
        } catch {
            print("Error saving meal: \(error)")
            // Можно добавить алерт для пользователя
        }
    }
}

#Preview {
    AddMealView(mealType: .lunch)
}
