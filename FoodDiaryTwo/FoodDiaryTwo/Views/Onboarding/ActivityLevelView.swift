//
//  ActivityLevelView.swift
//  FoodDiaryTwo
//
//  Created by AI Assistant
//

import SwiftUI

struct ActivityLevelView: View {
    @Binding var selectedActivityLevel: ActivityLevel?
    let onNext: () -> Void
    
    var body: some View {
        VStack(spacing: PlumpyTheme.Spacing.extraLarge) {
            // Header
            VStack(spacing: PlumpyTheme.Spacing.medium) {
                Text(LocalizationManager.shared.localizedString(.onboardingActivityTitle))
                    .font(PlumpyTheme.Typography.title1)
                    .fontWeight(.bold)
                    .foregroundColor(PlumpyTheme.textPrimary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, PlumpyTheme.Spacing.medium)
            
            // Activity Level Cards
            VStack(spacing: PlumpyTheme.Spacing.medium) {
                ForEach(ActivityLevel.allCases, id: \.self) { activityLevel in
                    ActivityLevelCard(
                        activityLevel: activityLevel,
                        isSelected: selectedActivityLevel == activityLevel,
                        onTap: {
                            withAnimation(PlumpyTheme.Animation.smooth) {
                                selectedActivityLevel = activityLevel
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, PlumpyTheme.Spacing.medium)
            
            Spacer()
            
            // Next Button
            PlumpyButton(
                title: LocalizationManager.shared.localizedString(.onboardingContinue),
                icon: "arrow.right",
                style: selectedActivityLevel != nil ? .primary : .ghost,
                isEnabled: selectedActivityLevel != nil,
                action: onNext
            )
            .padding(.horizontal, PlumpyTheme.Spacing.medium)
            .padding(.bottom, PlumpyTheme.Spacing.large)
        }
        .background(PlumpyTheme.background)
    }
}

struct ActivityLevelCard: View {
    let activityLevel: ActivityLevel
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: PlumpyTheme.Spacing.medium) {
                // Emoji Icon
                Text(activityLevel.onboardingEmoji)
                    .font(.system(size: 32))
                    .frame(width: 60, height: 60)
                    .background(
                        Circle()
                            .fill(isSelected ? PlumpyTheme.secondary.opacity(0.1) : PlumpyTheme.neutral100)
                    )
                
                // Content
                VStack(alignment: .leading, spacing: PlumpyTheme.Spacing.tiny) {
                    Text(activityLevel.onboardingDescription)
                        .font(PlumpyTheme.Typography.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(PlumpyTheme.textPrimary)
                        .multilineTextAlignment(.leading)
                    
                    Text(activityLevel.displayName)
                        .font(PlumpyTheme.Typography.caption1)
                        .foregroundColor(PlumpyTheme.textSecondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                // Selection Indicator
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isSelected ? PlumpyTheme.secondary : PlumpyTheme.neutral300)
            }
            .padding(PlumpyTheme.Spacing.medium)
            .background(
                RoundedRectangle(cornerRadius: PlumpyTheme.Radius.large)
                    .fill(isSelected ? PlumpyTheme.secondary.opacity(0.05) : PlumpyTheme.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: PlumpyTheme.Radius.large)
                            .stroke(
                                isSelected ? PlumpyTheme.secondary : PlumpyTheme.border,
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .shadow(
                color: isSelected ? PlumpyTheme.secondary.opacity(0.1) : PlumpyTheme.shadow.opacity(0.05),
                radius: isSelected ? 8 : 4,
                x: 0,
                y: isSelected ? 4 : 2
            )
        }
        .buttonStyle(PlainButtonStyle())
        .animation(PlumpyTheme.Animation.spring, value: isSelected)
    }
}

#Preview {
    ActivityLevelView(selectedActivityLevel: .constant(nil)) {
        print("Next tapped")
    }
}
