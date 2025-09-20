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
    
    @State private var isVisible = false
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: PlumpyTheme.Spacing.large) {
                    // Header
                    VStack(spacing: PlumpyTheme.Spacing.medium) {
                        Text(LocalizationManager.shared.localizedString(.onboardingActivityTitle))
                            .font(PlumpyTheme.Typography.title1)
                            .fontWeight(.bold)
                            .foregroundColor(PlumpyTheme.textPrimary)
                            .multilineTextAlignment(.center)
                            .opacity(isVisible ? 1 : 0)
                            .offset(y: isVisible ? 0 : 20)
                            .animation(.easeOut(duration: 0.6).delay(0.1), value: isVisible)
                    }
                    .padding(.horizontal, PlumpyTheme.Spacing.medium)
                    .padding(.top, PlumpyTheme.Spacing.medium)
            
                // Activity Level Cards
                VStack(spacing: PlumpyTheme.Spacing.small) {
                ForEach(Array(ActivityLevel.allCases.enumerated()), id: \.element) { index, activityLevel in
                    ActivityLevelCard(
                        activityLevel: activityLevel,
                        isSelected: selectedActivityLevel == activityLevel,
                        onTap: {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                selectedActivityLevel = activityLevel
                            }
                        }
                    )
                    .opacity(isVisible ? 1 : 0)
                    .offset(y: isVisible ? 0 : 30)
                    .scaleEffect(isVisible ? 1 : 0.8)
                    .animation(.easeOut(duration: 0.6).delay(0.3 + Double(index) * 0.1), value: isVisible)
                }
                }
                .padding(.horizontal, PlumpyTheme.Spacing.medium)
                .padding(.bottom, PlumpyTheme.Spacing.large)
            }
            
            // Next Button - прибита снизу
            VStack {
                Divider()
                    .background(PlumpyTheme.border)
                    .opacity(isVisible ? 1 : 0)
                    .animation(.easeOut(duration: 0.3).delay(0.7), value: isVisible)
                
                PlumpyButton(
                    title: LocalizationManager.shared.localizedString(.onboardingContinue),
                    icon: "arrow.right",
                    style: selectedActivityLevel != nil ? .primary : .ghost,
                    isEnabled: selectedActivityLevel != nil,
                    action: onNext
                )
                .padding(.horizontal, PlumpyTheme.Spacing.medium)
                .padding(.vertical, PlumpyTheme.Spacing.medium)
                .opacity(isVisible ? 1 : 0)
                .offset(y: isVisible ? 0 : 20)
                .scaleEffect(isVisible ? 1 : 0.9)
                .animation(.easeOut(duration: 0.6).delay(0.8), value: isVisible)
            }
            .background(PlumpyTheme.background)
        }
        .background(PlumpyTheme.background)
        .onAppear {
            withAnimation {
                isVisible = true
            }
        }
    }
}

// MARK: - ActivityLevelCard Component

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
                    .scaleEffect(isSelected ? 1.1 : 1.0)
                    .rotationEffect(.degrees(isSelected ? 5 : 0))
                
                // Content
                VStack(alignment: .leading, spacing: PlumpyTheme.Spacing.small) {
                    Text(activityLevel.onboardingDescription)
                        .font(PlumpyTheme.Typography.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(PlumpyTheme.textPrimary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text(activityLevel.displayName)
                        .font(PlumpyTheme.Typography.caption1)
                        .foregroundColor(PlumpyTheme.textSecondary)
                        .lineLimit(nil)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
                
                // Selection Indicator
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isSelected ? PlumpyTheme.secondary : PlumpyTheme.neutral300)
                    .scaleEffect(isSelected ? 1.2 : 1.0)
                    .rotationEffect(.degrees(isSelected ? 360 : 0))
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
        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: isSelected)
    }
}

#Preview {
    ActivityLevelView(selectedActivityLevel: .constant(nil)) {
        // Preview action
    }
}