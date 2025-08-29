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
    @State private var protein = ""
    @State private var carbs = ""
    @State private var fat = ""
    @State private var notes = ""
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedImage: UIImage? = nil
    
    // Состояния для работы с фото
    @State private var showImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .camera
    
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
                    title: LocalizationManager.shared.localizedString(.addMeal),
                    leftButton: PlumpyNavigationButton(
                        icon: "xmark",
                        title: LocalizationManager.shared.localizedString(.cancel),
                        style: .outline
                    ) {
                        dismiss()
                    },
                    rightButton: PlumpyNavigationButton(
                        icon: "checkmark",
                        title: LocalizationManager.shared.localizedString(.save),
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
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(
                selectedImage: $selectedImage, 
                sourceType: sourceType
            )
        }
        .onChange(of: selectedPhotoItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    selectedImage = image
                }
            }
        }
    }
    
    private var basicInfoSection: some View {
        VStack(spacing: PlumpyTheme.Spacing.medium) {
            Text(LocalizationManager.shared.localizedString(.foodDiary))
                .font(PlumpyTheme.Typography.headline)
                .fontWeight(.semibold)
                .foregroundColor(PlumpyTheme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Название приема пищи
            PlumpyField(
                title: LocalizationManager.shared.localizedString(.mealName),
                placeholder: LocalizationManager.shared.localizedString(.mealName),
                text: $mealName,
                icon: "fork.knife",
                isRequired: true
            )
            
            // Тип приема пищи
            VStack(alignment: .leading, spacing: PlumpyTheme.Spacing.small) {
                Text(LocalizationManager.shared.localizedString(.mealType))
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
                Text(LocalizationManager.shared.localizedString(.timeLabel))
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
                title: LocalizationManager.shared.localizedString(.calories),
                placeholder: LocalizationManager.shared.localizedString(.calories),
                text: $calories,
                keyboardType: .numberPad,
                icon: "flame.fill",
                iconColor: PlumpyTheme.warning,
                isRequired: true
            )

            // БЖУ
            HStack(spacing: PlumpyTheme.Spacing.medium) {
                PlumpyField(
                    title: LocalizationManager.shared.localizedString(.protein),
                    placeholder: LocalizationManager.shared.localizedString(.protein),
                    text: $protein,
                    keyboardType: .decimalPad,
                    icon: "bolt.heart",
                    iconColor: PlumpyTheme.secondaryAccent,
                    isRequired: false
                )
                PlumpyField(
                    title: LocalizationManager.shared.localizedString(.carbs),
                    placeholder: LocalizationManager.shared.localizedString(.carbs),
                    text: $carbs,
                    keyboardType: .decimalPad,
                    icon: "leaf",
                    iconColor: PlumpyTheme.primaryAccent,
                    isRequired: false
                )
                PlumpyField(
                    title: LocalizationManager.shared.localizedString(.fat),
                    placeholder: LocalizationManager.shared.localizedString(.fat),
                    text: $fat,
                    keyboardType: .decimalPad,
                    icon: "drop",
                    iconColor: PlumpyTheme.tertiaryAccent,
                    isRequired: false
                )
            }
        }
        .plumpyCard()
    }
    
    // MARK: - Секция фото с распознаванием
    private var photoSectionWithRecognition: some View {
        VStack(spacing: PlumpyTheme.Spacing.medium) {
            Text(LocalizationManager.shared.localizedString(.recognizeCalories))
                .font(PlumpyTheme.Typography.headline)
                .fontWeight(.semibold)
                .foregroundColor(PlumpyTheme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Выбор фото
            VStack(spacing: PlumpyTheme.Spacing.small) {
                if let image = selectedImage {
                    // Показать выбранное изображение
                    Image(uiImage: image)
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
                        // Кнопка распознавания калорий
                        Button(action: {
                            recognizeCalories()
                        }) {
                            HStack {
                                Image(systemName: "camera.viewfinder")
                                Text(LocalizationManager.shared.localizedString(.recognizeCalories))
                                    .fontWeight(.medium)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, PlumpyTheme.Spacing.small)
                            .background(PlumpyTheme.primaryAccent)
                            .foregroundColor(.white)
                            .cornerRadius(PlumpyTheme.Radius.medium)
                        }
                        
                        // Кнопка сброса
                        Button(action: {
                            selectedImage = nil
                            selectedPhotoItem = nil
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                                .frame(width: 44, height: 44)
                                .background(PlumpyTheme.surfaceSecondary)
                                .cornerRadius(PlumpyTheme.Radius.medium)
                        }
                    }
                    
                    // Простое сообщение о распознавании
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text(LocalizationManager.shared.localizedString(.photoReady))
                            .font(PlumpyTheme.Typography.caption1)
                            .foregroundColor(.green)
                    }
                    .padding(.horizontal, PlumpyTheme.Spacing.medium)
                    .padding(.vertical, PlumpyTheme.Spacing.small)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(PlumpyTheme.Radius.small)
                    
                } else {
                    // Показать кнопки выбора фото
                    VStack(spacing: PlumpyTheme.Spacing.medium) {
                        // Кнопка выбора из галереи
                        PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                            HStack {
                                Image(systemName: "photo.on.rectangle")
                                Text(LocalizationManager.shared.localizedString(.pickFromGallery))
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
                            sourceType = .camera
                            showImagePicker = true
                        }) {
                            HStack {
                                Image(systemName: "camera.fill")
                                Text(LocalizationManager.shared.localizedString(.takePhoto))
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
                            
                            Text(LocalizationManager.shared.localizedString(.photoHint))
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
    
    private func recognizeCalories() {
        // Используем центральный сервис для распознавания
        Task {
            if let image = selectedImage {
                let result = await FoodDataService.shared.recognizeFoodFromImage(image)
                await MainActor.run {
                    applyRecognitionResults(result)
                }
            }
        }
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

        if protein.isEmpty {
            protein = String(format: "%.1f", result.totalProtein)
        }
        if carbs.isEmpty {
            carbs = String(format: "%.1f", result.totalCarbs)
        }
        if fat.isEmpty {
            fat = String(format: "%.1f", result.totalFat)
        }
        
        if notes.isEmpty {
            notes = generateMealNotes(from: result)
        }
        
        // Показываем уведомление об успешном применении
        print("Калории распознаны и применены!")
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
            Text(LocalizationManager.shared.localizedString(.notes))
                .font(PlumpyTheme.Typography.headline)
                .fontWeight(.semibold)
                .foregroundColor(PlumpyTheme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(alignment: .leading, spacing: PlumpyTheme.Spacing.small) {
                Text(LocalizationManager.shared.localizedString(.notes))
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
                        Text(LocalizationManager.shared.localizedString(.notes))
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
            protein: Double(protein) ?? 0,
            carbs: Double(carbs) ?? 0,
            fat: Double(fat) ?? 0
        )
        
        // Конвертируем изображение в Data для сохранения
        var photoData: Data? = nil
        if let image = selectedImage {
            photoData = image.jpegData(compressionQuality: 0.8)
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
