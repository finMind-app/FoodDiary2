//
//  UserInfoView.swift
//  FoodDiaryTwo
//
//  Created by AI Assistant
//

import SwiftUI

struct UserInfoView: View {
    @Binding var gender: Gender?
    @Binding var age: Int?
    @Binding var height: Double?
    @Binding var weight: Double?
    
    let onNext: () -> Void
    
    @State private var ageText: String = ""
    @State private var heightText: String = ""
    @State private var weightText: String = ""
    
    var body: some View {
        VStack(spacing: PlumpyTheme.Spacing.extraLarge) {
            // Header
            VStack(spacing: PlumpyTheme.Spacing.medium) {
                Text(LocalizationManager.shared.localizedString(.onboardingUserInfoTitle))
                    .font(PlumpyTheme.Typography.title1)
                    .fontWeight(.bold)
                    .foregroundColor(PlumpyTheme.textPrimary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, PlumpyTheme.Spacing.medium)
            
            // Form Fields
            VStack(spacing: PlumpyTheme.Spacing.large) {
                // Gender Selection
                VStack(alignment: .leading, spacing: PlumpyTheme.Spacing.small) {
                    Text(LocalizationManager.shared.localizedString(.gender))
                        .font(PlumpyTheme.Typography.headline)
                        .foregroundColor(PlumpyTheme.textPrimary)
                    
                    HStack(spacing: PlumpyTheme.Spacing.small) {
                        ForEach(Gender.allCases, id: \.self) { genderOption in
                            GenderButton(
                                gender: genderOption,
                                isSelected: gender == genderOption,
                                onTap: {
                                    withAnimation(PlumpyTheme.Animation.smooth) {
                                        gender = genderOption
                                    }
                                }
                            )
                        }
                    }
                }
                
                // Age Input
                UserInfoField(
                    title: LocalizationManager.shared.localizedString(.ageLabel),
                    icon: "calendar",
                    placeholder: "25",
                    text: $ageText,
                    keyboardType: .numberPad,
                    unit: LocalizationManager.shared.localizedString(.yearsSuffix)
                ) { value in
                    age = Int(value)
                }
                
                // Height Input
                UserInfoField(
                    title: LocalizationManager.shared.localizedString(.heightLabel),
                    icon: "ruler",
                    placeholder: "175",
                    text: $heightText,
                    keyboardType: .decimalPad,
                    unit: LocalizationManager.shared.localizedString(.cmUnit)
                ) { value in
                    height = Double(value)
                }
                
                // Weight Input
                UserInfoField(
                    title: LocalizationManager.shared.localizedString(.weightLabel),
                    icon: "scalemass",
                    placeholder: "70",
                    text: $weightText,
                    keyboardType: .decimalPad,
                    unit: LocalizationManager.shared.localizedString(.kgUnit)
                ) { value in
                    weight = Double(value)
                }
            }
            .padding(.horizontal, PlumpyTheme.Spacing.medium)
            
            Spacer()
            
            // Next Button
            PlumpyButton(
                title: LocalizationManager.shared.localizedString(.onboardingContinue),
                icon: "arrow.right",
                style: isFormValid ? .primary : .ghost,
                isEnabled: isFormValid,
                action: onNext
            )
            .padding(.horizontal, PlumpyTheme.Spacing.medium)
            .padding(.bottom, PlumpyTheme.Spacing.large)
        }
        .background(PlumpyTheme.background)
        .onAppear {
            // Initialize text fields with existing values
            if let age = age {
                ageText = String(age)
            }
            if let height = height {
                heightText = String(Int(height))
            }
            if let weight = weight {
                weightText = String(Int(weight))
            }
        }
    }
    
    private var isFormValid: Bool {
        return gender != nil && 
               age != nil && 
               height != nil && 
               weight != nil &&
               age! >= 16 && age! <= 100 &&
               height! >= 120 && height! <= 250 &&
               weight! >= 30 && weight! <= 200
    }
}

struct GenderButton: View {
    let gender: Gender
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: PlumpyTheme.Spacing.small) {
                Image(systemName: gender == .male ? "person.fill" : "person.fill")
                    .font(.title3)
                    .foregroundColor(isSelected ? PlumpyTheme.textInverse : PlumpyTheme.textPrimary)
                
                Text(gender.displayName)
                    .font(PlumpyTheme.Typography.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? PlumpyTheme.textInverse : PlumpyTheme.textPrimary)
            }
            .padding(.horizontal, PlumpyTheme.Spacing.medium)
            .padding(.vertical, PlumpyTheme.Spacing.small)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: PlumpyTheme.Radius.medium)
                    .fill(isSelected ? PlumpyTheme.primary : PlumpyTheme.surfaceSecondary)
                    .overlay(
                        RoundedRectangle(cornerRadius: PlumpyTheme.Radius.medium)
                            .stroke(
                                isSelected ? PlumpyTheme.primary : PlumpyTheme.border,
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .animation(PlumpyTheme.Animation.smooth, value: isSelected)
    }
}

struct UserInfoField: View {
    let title: String
    let icon: String
    let placeholder: String
    @Binding var text: String
    let keyboardType: UIKeyboardType
    let unit: String
    let onValueChanged: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: PlumpyTheme.Spacing.small) {
            Text(title)
                .font(PlumpyTheme.Typography.headline)
                .foregroundColor(PlumpyTheme.textPrimary)
            
            HStack(spacing: PlumpyTheme.Spacing.medium) {
                // Icon
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(PlumpyTheme.primary)
                    .frame(width: 24, height: 24)
                
                // Text Field
                TextField(placeholder, text: $text)
                    .font(PlumpyTheme.Typography.body)
                    .keyboardType(keyboardType)
                    .textFieldStyle(PlainTextFieldStyle())
                    .onChange(of: text) { _, newValue in
                        onValueChanged(newValue)
                    }
                
                // Unit
                Text(unit)
                    .font(PlumpyTheme.Typography.caption1)
                    .foregroundColor(PlumpyTheme.textSecondary)
                    .frame(minWidth: 30)
            }
            .padding(PlumpyTheme.Spacing.medium)
            .background(
                RoundedRectangle(cornerRadius: PlumpyTheme.Radius.medium)
                    .fill(PlumpyTheme.surfaceSecondary)
                    .overlay(
                        RoundedRectangle(cornerRadius: PlumpyTheme.Radius.medium)
                            .stroke(PlumpyTheme.border, lineWidth: 1)
                    )
            )
        }
    }
}

#Preview {
    UserInfoView(
        gender: .constant(nil),
        age: .constant(nil),
        height: .constant(nil),
        weight: .constant(nil)
    ) {
        print("Next tapped")
    }
}
