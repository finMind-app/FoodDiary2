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
    @State private var isImageLoading = false
    
    // ViewModel для распознавания
    @StateObject private var recognitionViewModel = FoodRecognitionViewModel()
    
    // Состояния для ошибок
    @State private var showErrorAlert = false
    
    init(mealType: MealType = .breakfast) {
        self._selectedMealType = State(initialValue: mealType)
    }
    
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
                    VStack(spacing: 20) {
                        // Секция фото с распознаванием
                        photoSection
                        
                        // Основная информация
                        basicInfoSection
                        
                        // Заметки
                        notesSection
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
        }
        .onChange(of: selectedPhotoItem) {
            Task {
                isImageLoading = true
                if let item = selectedPhotoItem,
                   let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    selectedImage = image
                    recognitionViewModel.setImage(image)
                }
                isImageLoading = false
            }
        }
        .alert("Ошибка распознавания", isPresented: $showErrorAlert) {
            Button("OK") { }
        } message: {
            Text(recognitionViewModel.errorMessage ?? "Неизвестная ошибка")
        }
        .onReceive(recognitionViewModel.$showError) { showError in
            if showError {
                showErrorAlert = true
            }
        }
        .onReceive(recognitionViewModel.$recognitionResult) { result in
            if let result = result {
                // Автоматически заполняем поля результатами распознавания
                mealName = result.name
                calories = String(format: "%.0f", result.calories)
                protein = String(format: "%.1f", result.protein)
                fat = String(format: "%.1f", result.fat)
                carbs = String(format: "%.1f", result.carbs)
            }
        }
    }
    
    // MARK: - Секция фото с распознаванием
    private var photoSection: some View {
        VStack(spacing: 16) {
            if let image = selectedImage {
                // Показать выбранное изображение
                ZStack(alignment: .topTrailing) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 240)
                        .clipped()
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(PlumpyTheme.border, lineWidth: 1)
                        )
                    
                    // Кнопка удаления
                    Button(action: {
                        selectedImage = nil
                        selectedPhotoItem = nil
                        recognitionViewModel.resetResults()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                    .padding(12)
                }
                
                // Кнопка распознавания
                Button(action: {
                    Task {
                        await recognitionViewModel.recognizeFood()
                    }
                }) {
                    HStack(spacing: 8) {
                        if recognitionViewModel.isProcessing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                            Text("Анализируем...")
                                .fontWeight(.medium)
                        } else {
                            Image(systemName: "camera.viewfinder")
                                .font(.title3)
                            Text("Распознать калории")
                                .fontWeight(.medium)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(recognitionViewModel.isProcessing ? Color.gray : PlumpyTheme.primaryAccent)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(recognitionViewModel.isProcessing || isImageLoading)
                
                // Прогресс распознавания
                if recognitionViewModel.isProcessing {
                    VStack(spacing: 8) {
                        ProgressView(value: recognitionViewModel.processingProgress)
                            .progressViewStyle(LinearProgressViewStyle(tint: PlumpyTheme.primaryAccent))
                        
                        Text("Обработка изображения... \(Int(recognitionViewModel.processingProgress * 100))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(PlumpyTheme.surfaceSecondary)
                    .cornerRadius(8)
                }
                
            } else {
                // Кнопки выбора фото
                VStack(spacing: 16) {
                    // Основная кнопка выбора фото
                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        VStack(spacing: 12) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 32))
                                .foregroundColor(PlumpyTheme.primaryAccent)
                            
                            Text("Сфотографируйте еду")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(PlumpyTheme.textPrimary)
                            
                            Text("Автоматическое распознавание калорий и БЖУ")
                                .font(.subheadline)
                                .foregroundColor(PlumpyTheme.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 160)
                        .background(PlumpyTheme.surfaceSecondary)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(PlumpyTheme.border, lineWidth: 1)
                        )
                    }
                    
                    // Альтернативная кнопка камеры
                    Button(action: {
                        // Здесь можно добавить вызов камеры
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "camera")
                            Text("Использовать камеру")
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(PlumpyTheme.surfaceSecondary)
                        .foregroundColor(PlumpyTheme.textPrimary)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(PlumpyTheme.border, lineWidth: 1)
                        )
                    }
                }
            }
        }
        .padding(20)
        .background(PlumpyTheme.surface)
        .cornerRadius(20)
    }
    
    // MARK: - Секция основной информации
    private var basicInfoSection: some View {
        VStack(spacing: 20) {
            // Название приема пищи
            VStack(alignment: .leading, spacing: 8) {
                Text("Название")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(PlumpyTheme.textPrimary)
                
                TextField("Введите название блюда", text: $mealName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.body)
            }
            
            // Тип приема пищи
            VStack(alignment: .leading, spacing: 12) {
                Text("Тип приема")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(PlumpyTheme.textPrimary)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                    ForEach(MealType.allCases, id: \.self) { mealType in
                        Button(action: {
                            selectedMealType = mealType
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: mealType.icon)
                                    .font(.title3)
                                Text(mealType.displayName)
                                    .fontWeight(.medium)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(selectedMealType == mealType ? PlumpyTheme.primaryAccent : PlumpyTheme.surfaceSecondary)
                            .foregroundColor(selectedMealType == mealType ? .white : PlumpyTheme.textPrimary)
                            .cornerRadius(12)
                        }
                    }
                }
            }
            
            // Время приема пищи
            VStack(alignment: .leading, spacing: 8) {
                Text("Время")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(PlumpyTheme.textPrimary)
                
                DatePicker("", selection: $selectedTime, displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .padding(12)
                    .background(PlumpyTheme.surfaceSecondary)
                    .cornerRadius(12)
            }
            
            // Калории
            VStack(alignment: .leading, spacing: 8) {
                Text("Калории")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(PlumpyTheme.textPrimary)
                
                TextField("0", text: $calories)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .font(.body)
            }
            
            // БЖУ
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Белки")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(PlumpyTheme.textSecondary)
                    
                    TextField("0", text: $protein)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                        .font(.body)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Жиры")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(PlumpyTheme.textSecondary)
                    
                    TextField("0", text: $fat)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                        .font(.body)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Углеводы")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(PlumpyTheme.textSecondary)
                    
                    TextField("0", text: $carbs)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                        .font(.body)
                }
            }
        }
        .padding(20)
        .background(PlumpyTheme.surface)
        .cornerRadius(20)
    }
    
    // MARK: - Секция заметок
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Заметки")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(PlumpyTheme.textPrimary)
            
            TextField("Добавить заметки (необязательно)", text: $notes, axis: .vertical)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .lineLimit(3...6)
                .font(.body)
        }
        .padding(20)
        .background(PlumpyTheme.surface)
        .cornerRadius(20)
    }
    
    private func saveMeal() {
        // Валидация данных
        guard !mealName.isEmpty else {
            print("Meal name is required")
            return
        }
        
        guard let caloriesInt = Int(calories), caloriesInt > 0 else {
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
        }
    }
}

#Preview {
    AddMealView(mealType: .lunch)
}
