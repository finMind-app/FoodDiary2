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
    @State private var showingCamera = false

    @StateObject private var recognitionViewModel = FoodRecognitionViewModel()

    @State private var showErrorAlert = false
    @State private var showingRegistration = false

    @State private var products: [FoodProduct] = []
    @State private var showingSearch = false
    @State private var productGrams: [UUID: Double] = [:]

    init(mealType: MealType = .breakfast) {
        self._selectedMealType = State(initialValue: mealType)
    }

    var body: some View {
        ZStack {
            PlumpyBackground(style: .primary)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                PlumpyNavigationBar(
                    title: LocalizationManager.shared.localizedString(.addMeal),
                    leftButton: PlumpyNavigationButton(
                        icon: "xmark",
                        title: LocalizationManager.shared.localizedString(.cancel),
                        style: .outline
                    ) { dismiss() },
                    rightButton: PlumpyNavigationButton(
                        icon: "checkmark",
                        title: LocalizationManager.shared.localizedString(.save),
                        style: .primary
                    ) { saveMeal() }
                )

                ScrollView {
                    VStack(spacing: 20) {
                        photoSection
                        basicInfoSection
                        notesSection
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
        }
        .sheet(isPresented: $showingRegistration) {
            RegistrationView(
                onRegistrationComplete: {
                    showingRegistration = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { saveMeal() }
                },
                onSkip: {
                    UserDefaults.standard.set(true, forKey: "registrationSkipped")
                    showingRegistration = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { saveMeal() }
                }
            )
        }
        .sheet(isPresented: $showingCamera) {
            CameraPicker(image: $selectedImage)
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
        .alert(LocalizationManager.shared.localizedString(.recognitionErrorTitle), isPresented: $showErrorAlert) {
            Button(LocalizationManager.shared.localizedString(.ok)) { }
        } message: {
            Text(recognitionViewModel.errorMessage ?? LocalizationManager.shared.localizedString(.unknownError))
        }
        .onReceive(recognitionViewModel.$showError) { showError in
            if showError { showErrorAlert = true }
        }
        .onReceive(recognitionViewModel.$recognitionResult) { result in
            if let result = result {
                mealName = result.name
                calories = String(format: "%.0f", result.calories)
                protein = String(format: "%.1f", result.protein)
                fat = String(format: "%.1f", result.fat)
                carbs = String(format: "%.1f", result.carbs)
            }
        }
    }

    private func autoGenerateMealName() -> String {
        if products.isEmpty { return "" }
        if products.count == 1 {
            return products[0].name
        } else {
            let names = products.prefix(2).map { $0.name }
            return names.joined(separator: " + ") + "…"
        }
    }

    private var photoSection: some View {
        VStack(spacing: 16) {
            if let image = selectedImage {
                GeometryReader { geometry in
                    ZStack(alignment: .topTrailing) {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width, height: 240)
                            .clipped()
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(PlumpyTheme.border, lineWidth: 1)
                            )

                        Button {
                            selectedImage = nil
                            selectedPhotoItem = nil
                            recognitionViewModel.resetResults()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .background(Color.black.opacity(0.6))
                                .clipShape(Circle())
                        }
                        .padding(12)
                    }
                }
                .frame(height: 240)

                Button {
                    Task { await recognitionViewModel.recognizeFood() }
                } label: {
                    HStack(spacing: 8) {
                        if recognitionViewModel.isProcessing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                            Text(LocalizationManager.shared.localizedString(.analyzing))
                                .fontWeight(.medium)
                        } else {
                            Image(systemName: "camera.viewfinder")
                                .font(.title3)
                            Text(LocalizationManager.shared.localizedString(.recognizeCalories))
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

                if recognitionViewModel.isProcessing {
                    VStack(spacing: 8) {
                        ProgressView(value: recognitionViewModel.processingProgress)
                            .progressViewStyle(LinearProgressViewStyle(tint: PlumpyTheme.primaryAccent))
                        Text(String(format: LocalizationManager.shared.localizedString(.imageProcessingProgress), Int(recognitionViewModel.processingProgress * 100)))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(PlumpyTheme.surfaceSecondary)
                    .cornerRadius(8)
                }

            } else {
                VStack(spacing: 16) {
                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        VStack(spacing: 12) {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.system(size: 32))
                                .foregroundColor(PlumpyTheme.primaryAccent)
                            Text(LocalizationManager.shared.localizedString(.selectFromGallery))
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(PlumpyTheme.textPrimary)
                            Text(LocalizationManager.shared.localizedString(.photoSectionSubtitle))
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

                    Button {
                        showingCamera = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "camera")
                            Text(LocalizationManager.shared.localizedString(.useCamera))
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

    private var basicInfoSection: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text(LocalizationManager.shared.localizedString(.mealName))
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(PlumpyTheme.textPrimary)
                TextField(LocalizationManager.shared.localizedString(.enterMealName), text: $mealName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.body)
            }

            VStack(alignment: .leading, spacing: 12) {
                Text(LocalizationManager.shared.localizedString(.mealType))
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(PlumpyTheme.textPrimary)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                    ForEach(MealType.allCases, id: \.self) { mealType in
                        Button {
                            selectedMealType = mealType
                        } label: {
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

            VStack(alignment: .leading, spacing: 8) {
                Text(LocalizationManager.shared.localizedString(.timeLabel))
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

            productsSection

            VStack(alignment: .leading, spacing: 8) {
                Text(LocalizationManager.shared.localizedString(.calories))
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(PlumpyTheme.textPrimary)
                TextField("0", text: $calories)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .font(.body)
            }

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(LocalizationManager.shared.localizedString(.protein))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(PlumpyTheme.textSecondary)
                    TextField("0", text: $protein)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                        .font(.body)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(LocalizationManager.shared.localizedString(.fat))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(PlumpyTheme.textSecondary)
                    TextField("0", text: $fat)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                        .font(.body)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(LocalizationManager.shared.localizedString(.carbs))
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
        .onChange(of: productGrams) { _ in
            recalcTotals()
        }
    }

    private var productsSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text(LocalizationManager.shared.localizedString(.products))
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(PlumpyTheme.textPrimary)
                Spacer()
                Button {
                    showingSearch = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(PlumpyTheme.primaryAccent)
                        .font(.title2)
                }
            }

            ForEach(products.indices, id: \.self) { index in
                let product = products[index]
                let grams = productGrams[product.id] ?? 100
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(product.name)
                            .fontWeight(.medium)
                        Spacer()
                        Button {
                            products.remove(at: index)
                        } label: {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                    Slider(value: Binding(
                        get: { grams },
                        set: { newVal in
                            productGrams[product.id] = newVal
                        }

                    ), in: 10...500, step: 10)
                    .accentColor(PlumpyTheme.primary)

                    HStack {
                        Text("\(Int(grams)) g")
                        Spacer()
                        Text("\(Int(Double(product.caloriesPerServing) / 100.0 * grams)) kcal")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                .padding(8)
                .background(PlumpyTheme.surfaceSecondary)
                .cornerRadius(12)
            }
        }
        .background(PlumpyTheme.surface)
        .cornerRadius(20)
        .sheet(isPresented: $showingSearch) {
            SearchProductsView { selected in
                let newProduct = FoodProduct(
                    name: selected.productName ?? "Unknown",
                    caloriesPerServing: Int(selected.nutriments?["energy-kcal_100g"] as? Double ?? 0),
                    protein: selected.nutriments?["proteins_100g"] as? Double ?? 0,
                    carbs: selected.nutriments?["carbohydrates_100g"] as? Double ?? 0,
                    fat: selected.nutriments?["fat_100g"] as? Double ?? 0
                )
                products.append(newProduct)
                productGrams[newProduct.id] = 100
                recalcTotals()
            }
        }
    }

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(LocalizationManager.shared.localizedString(.notes))
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(PlumpyTheme.textPrimary)
            TextField(LocalizationManager.shared.localizedString(.addNotesOptional), text: $notes, axis: .vertical)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .lineLimit(3...6)
                .font(.body)
        }
        .padding(20)
        .background(PlumpyTheme.surface)
        .cornerRadius(20)
    }

    private func recalcTotals() {
        var totalCalories = 0.0
        var totalProtein = 0.0
        var totalCarbs = 0.0
        var totalFat = 0.0

        for product in products {
            let grams = productGrams[product.id] ?? 100
            totalCalories += Double(product.caloriesPerServing) / 100.0 * grams
            totalProtein += product.protein / 100.0 * grams
            totalCarbs += product.carbs / 100.0 * grams
            totalFat += product.fat / 100.0 * grams
        }

        calories = String(format: "%.0f", totalCalories)
        protein = String(format: "%.1f", totalProtein)
        carbs = String(format: "%.1f", totalCarbs)
        fat = String(format: "%.1f", totalFat)
    }

    private func saveMeal() {
        if !isUserRegistered && !isRegistrationSkipped {
            showingRegistration = true
            return
        }

        let finalMealName = mealName.isEmpty ? autoGenerateMealName() : mealName
        guard !finalMealName.isEmpty, let caloriesInt = Int(calories), caloriesInt > 0 else { return }

        let photoData = selectedImage?.jpegData(compressionQuality: 0.8)

        // Создаём продукты с учётом выбранного количества граммов
        let adjustedProducts = products.map { product -> FoodProduct in
            let grams = productGrams[product.id] ?? 100
            return FoodProduct(
                name: product.name,
                caloriesPerServing: Int(Double(product.caloriesPerServing) / 100.0 * grams),
                protein: product.protein / 100.0 * grams,
                carbs: product.carbs / 100.0 * grams,
                fat: product.fat / 100.0 * grams
            )
        }

        let foodEntry = FoodEntry(
            name: finalMealName,
            date: selectedTime,
            mealType: selectedMealType,
            products: adjustedProducts,
            notes: notes.isEmpty ? nil : notes,
            photoData: photoData
        )

        modelContext.insert(foodEntry)
        try? modelContext.save()
        dismiss()
    }

    private var isUserRegistered: Bool {
        UserDefaults.standard.bool(forKey: "isRegistered")
    }

    private var isRegistrationSkipped: Bool {
        UserDefaults.standard.bool(forKey: "registrationSkipped")
    }
}

struct CameraPicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        picker.allowsEditing = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPicker
        init(_ parent: CameraPicker) { self.parent = parent }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

#Preview {
    AddMealView(mealType: .lunch)
}
