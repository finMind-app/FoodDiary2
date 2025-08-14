//
//  AddMealView.swift
//  FoodDiaryTwo
//
//  Created by user on 31.07.2025.
//

import SwiftUI

struct AddMealView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var mealName = ""
    @State private var selectedMealType: MealType = .breakfast
    @State private var selectedTime = Date()
    @State private var calories = ""
    @State private var notes = ""
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    
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
                    VStack(spacing: PlumpyTheme.Spacing.large) {
                        // Основная информация
                        basicInfoSection
                        
                        // Фото
                        photoSection
                        
                        // Заметки
                        notesSection
                        
                        PlumpySpacer(size: .huge)
                    }
                    .padding(.horizontal, PlumpyTheme.Spacing.large)
                    .padding(.top, PlumpyTheme.Spacing.large)
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
                        PlumpyButton(
                            title: "Change Photo",
                            icon: "camera.fill",
                            style: .secondary
                        ) {
                            showingImagePicker = true
                        }
                        
                        PlumpyButton(
                            title: "Remove",
                            icon: "trash.fill",
                            style: .error
                        ) {
                            self.selectedImage = nil
                        }
                    }
                }
            } else {
                Button(action: {
                    showingImagePicker = true
                }) {
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
    }
    
    private var notesSection: some View {
        VStack(spacing: PlumpyTheme.Spacing.medium) {
            Text("Notes")
                .font(PlumpyTheme.Typography.headline)
                .fontWeight(.semibold)
                .foregroundColor(PlumpyTheme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            PlumpyTextArea(
                title: "",
                placeholder: "Add notes about your meal...",
                text: $notes
            )
        }
        .plumpyCard()
    }
    
    private func saveMeal() {
        // Здесь будет логика сохранения приема пищи
        dismiss()
    }
}

#Preview {
    AddMealView()
}
