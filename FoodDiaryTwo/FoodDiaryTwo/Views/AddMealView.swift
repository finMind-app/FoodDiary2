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
    @State private var selectedImage: UIImage? = nil
    
    // Новые состояния для распознавания еды
    @StateObject private var recognitionViewModel = FoodRecognitionViewModel()
    @State private var showRecognitionResults = false
    @State private var showImagePicker = false
    @State private var showCamera = false
    
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
                        
                        // Фото с распознаванием
                        photoSectionWithRecognition
                        
                        // Заметки
                        notesSection
                        
                        PlumpySpacer(size: .large)
                    }
                    .padding(.horizontal, PlumpyTheme.Spacing.medium)
                    .padding(.top, PlumpyTheme.Spacing.medium)
                }
            }
        }
        .sheet(isPresented: $showRecognitionResults) {
            if let result = recognitionViewModel.recognitionResult {
                NavigationView {
                    FoodRecognitionResultView(
                        result: result,
                        onApply: {
                            applyRecognitionResults(result)
                            showRecognitionResults = false
                        },
                        onRetry: {
                            showRecognitionResults = false
                        }
                    )
                }
            }
        }
        .alert("Ошибка", isPresented: $recognitionViewModel.showError) {
            Button("OK") { }
        } message: {
            Text(recognitionViewModel.errorMessage ?? "Неизвестная ошибка")
        }
        .onChange(of: selectedPhotoItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    selectedImage = image
                    recognitionViewModel.selectedImage = image
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
    
    // MARK: - Секция фото с распознаванием
    private var photoSectionWithRecognition: some View {
        VStack(spacing: PlumpyTheme.Spacing.medium) {
            Text("Photo & Recognition")
                .font(PlumpyTheme.Typography.headline)
                .fontWeight(.semibold)
                .foregroundColor(PlumpyTheme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Выбор фото
            VStack(spacing: PlumpyTheme.Spacing.small) {
                if let selectedImage = selectedImage {
                    // Показать выбранное изображение
                    Image(uiImage: selectedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .clipped()
                        .cornerRadius(PlumpyTheme.Radius.medium)
                        .overlay(
                            RoundedRectangle(cornerRadius: PlumpyTheme.Radius.medium)
                                .stroke(PlumpyTheme.border, lineWidth: 1)
                        )
                    
                    // Кнопки действий с фото
                    HStack(spacing: PlumpyTheme.Spacing.medium) {
                        // Кнопка распознавания
                        Button(action: {
                            Task {
                                await recognitionViewModel.recognizeFood()
                                if recognitionViewModel.recognitionResult != nil {
                                    showRecognitionResults = true
                                }
                            }
                        }) {
                            HStack {
                                if recognitionViewModel.isProcessing {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Image(systemName: "camera.viewfinder")
                                }
                                Text(recognitionViewModel.recognitionButtonText)
                                    .fontWeight(.medium)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, PlumpyTheme.Spacing.small)
                            .background(recognitionViewModel.recognitionButtonColor)
                            .foregroundColor(.white)
                            .cornerRadius(PlumpyTheme.Radius.medium)
                        }
                        .disabled(!recognitionViewModel.canStartRecognition)
                        
                        // Кнопка сброса
                        Button(action: {
                            selectedImage = nil
                            selectedPhotoItem = nil
                            recognitionViewModel.resetResults()
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                                .frame(width: 44, height: 44)
                                .background(PlumpyTheme.surfaceSecondary)
                                .cornerRadius(PlumpyTheme.Radius.medium)
                        }
                    }
                    
                    // Прогресс распознавания
                    if recognitionViewModel.isProcessing {
                        VStack(spacing: PlumpyTheme.Spacing.small) {
                            ProgressView(value: recognitionViewModel.processingProgress)
                                .progressViewStyle(LinearProgressViewStyle(tint: PlumpyTheme.primaryAccent))
                            
                            Text("Анализируем изображение...")
                                .font(PlumpyTheme.Typography.caption1)
                                .foregroundColor(PlumpyTheme.textSecondary)
                        }
                        .padding(.horizontal, PlumpyTheme.Spacing.medium)
                    }
                    
                    // Статус
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(recognitionViewModel.statusColor)
                        Text(recognitionViewModel.statusText)
                            .font(PlumpyTheme.Typography.caption1)
                            .foregroundColor(recognitionViewModel.statusColor)
                    }
                    .padding(.horizontal, PlumpyTheme.Spacing.medium)
                    .padding(.vertical, PlumpyTheme.Spacing.small)
                    .background(recognitionViewModel.statusColor.opacity(0.1))
                    .cornerRadius(PlumpyTheme.Radius.small)
                    
                } else {
                    // Показать кнопки выбора фото
                    VStack(spacing: PlumpyTheme.Spacing.medium) {
                        // Кнопка выбора из галереи
                        PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                            HStack {
                                Image(systemName: "photo.on.rectangle")
                                Text("Выбрать из галереи")
                                    .fontWeight(.medium)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, PlumpyTheme.Spacing.medium)
                            .background(PlumpyTheme.primaryAccent)
                            .foregroundColor(.white)
                            .cornerRadius(PlumpyTheme.Radius.medium)
                        }
                        
                        // Кнопка камеры
                        Button(action: {
                            recognitionViewModel.takePhoto()
                        }) {
                            HStack {
                                Image(systemName: "camera.fill")
                                Text("Сделать фото")
                                    .fontWeight(.medium)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, PlumpyTheme.Spacing.medium)
                            .background(PlumpyTheme.surfaceSecondary)
                            .foregroundColor(PlumpyTheme.textPrimary)
                            .cornerRadius(PlumpyTheme.Radius.medium)
                        }
                        
                        // Информация о распознавании
                        VStack(spacing: PlumpyTheme.Spacing.small) {
                            Image(systemName: "camera.viewfinder")
                                .font(.title2)
                                .foregroundColor(PlumpyTheme.primaryAccent)
                            
                            Text("Сфотографируйте еду для автоматического распознавания калорий и БЖУ")
                                .font(PlumpyTheme.Typography.caption1)
                                .foregroundColor(PlumpyTheme.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(PlumpyTheme.Spacing.medium)
                        .background(PlumpyTheme.surfaceSecondary)
                        .cornerRadius(PlumpyTheme.Radius.medium)
                    }
                }
            }
        }
        .plumpyCard()
    }
    
    // MARK: - Применение результатов распознавания
    private func applyRecognitionResults(_ result: FoodRecognitionResult) {
        // Автозаполнение полей на основе результатов распознавания
        if mealName.isEmpty {
            mealName = generateMealName(from: result)
        }
        
        if calories.isEmpty {
            calories = String(Int(result.totalCalories))
        }
        
        if notes.isEmpty {
            notes = generateMealNotes(from: result)
        }
        
        // Показываем уведомление об успешном применении
        // В реальном приложении здесь можно добавить haptic feedback
    }
    
    private func generateMealName(from result: FoodRecognitionResult) -> String {
        let foodNames = result.recognizedFoods.map { $0.name }
        
        if foodNames.count == 1 {
            return foodNames[0]
        } else if foodNames.count <= 3 {
            return foodNames.joined(separator: " + ")
        } else {
            return "Смешанное блюдо"
        }
    }
    
    private func generateMealNotes(from result: FoodRecognitionResult) -> String {
        var notes: [String] = []
        
        notes.append("📸 Распознано по фото")
        notes.append("Уверенность: \(result.confidenceText)")
        
        for food in result.recognizedFoods {
            let confidence = Int(food.confidence * 100)
            notes.append("• \(food.name): \(confidence)% уверенность")
        }
        
        if let cookingMethod = result.recognizedFoods.first?.cookingMethod {
            notes.append("Способ приготовления: \(cookingMethod.rawValue)")
        }
        
        return notes.joined(separator: "\n")
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
