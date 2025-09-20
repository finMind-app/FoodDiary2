//
//  PaywallView.swift
//  FoodDiaryTwo
//
//  Created by AI Assistant
//

import SwiftUI

struct PaywallView: View {
    let onUnlock: () -> Void
    let onContinueFree: () -> Void
    
    var body: some View {
        VStack(spacing: PlumpyTheme.Spacing.extraLarge) {
            // Header
            VStack(spacing: PlumpyTheme.Spacing.medium) {
                Text(LocalizationManager.shared.localizedString(.onboardingPaywallTitle))
                    .font(PlumpyTheme.Typography.title1)
                    .fontWeight(.bold)
                    .foregroundColor(PlumpyTheme.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
            .padding(.horizontal, PlumpyTheme.Spacing.medium)
            
            // Benefits List
            VStack(spacing: PlumpyTheme.Spacing.medium) {
                BenefitRow(
                    icon: "fork.knife",
                    title: LocalizationManager.shared.localizedString(.onboardingBenefitPersonalPlan),
                    description: LocalizationManager.shared.localizedString(.onboardingBenefitPersonalPlanDesc)
                )
                
                BenefitRow(
                    icon: "chart.line.uptrend.xyaxis",
                    title: LocalizationManager.shared.localizedString(.onboardingBenefitProgressTracker),
                    description: LocalizationManager.shared.localizedString(.onboardingBenefitProgressTrackerDesc)
                )
                
                BenefitRow(
                    icon: "brain.head.profile",
                    title: LocalizationManager.shared.localizedString(.onboardingBenefitAIRecommendations),
                    description: LocalizationManager.shared.localizedString(.onboardingBenefitAIRecommendationsDesc)
                )
                
                BenefitRow(
                    icon: "bell.badge",
                    title: LocalizationManager.shared.localizedString(.onboardingBenefitNotifications),
                    description: LocalizationManager.shared.localizedString(.onboardingBenefitNotificationsDesc)
                )
                
                BenefitRow(
                    icon: "icloud.and.arrow.up",
                    title: LocalizationManager.shared.localizedString(.onboardingBenefitSync),
                    description: LocalizationManager.shared.localizedString(.onboardingBenefitSyncDesc)
                )
            }
            .padding(.horizontal, PlumpyTheme.Spacing.medium)
            
            Spacer()
            
            // Action Buttons
            VStack(spacing: PlumpyTheme.Spacing.medium) {
                // Main CTA Button
                PlumpyButton(
                    title: LocalizationManager.shared.localizedString(.onboardingUnlockPlan),
                    icon: "crown.fill",
                    style: .primary,
                    action: onUnlock
                )
                .padding(.horizontal, PlumpyTheme.Spacing.medium)
                
                // Secondary Button
                Button(action: onContinueFree) {
                    Text(LocalizationManager.shared.localizedString(.onboardingContinueFree))
                        .font(PlumpyTheme.Typography.subheadline)
                        .foregroundColor(PlumpyTheme.textSecondary)
                        .underline()
                }
                .padding(.bottom, PlumpyTheme.Spacing.large)
            }
        }
        .background(PlumpyTheme.background)
    }
}

struct BenefitRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: PlumpyTheme.Spacing.medium) {
            // Icon
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(PlumpyTheme.primary)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(PlumpyTheme.primary.opacity(0.1))
                )
            
            // Content
            VStack(alignment: .leading, spacing: PlumpyTheme.Spacing.tiny) {
                Text(title)
                    .font(PlumpyTheme.Typography.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(PlumpyTheme.textPrimary)
                    .multilineTextAlignment(.leading)
                
                Text(description)
                    .font(PlumpyTheme.Typography.caption1)
                    .foregroundColor(PlumpyTheme.textSecondary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
            }
            
            Spacer()
            
            // Checkmark
            Image(systemName: "checkmark.circle.fill")
                .font(.title3)
                .foregroundColor(PlumpyTheme.success)
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

#Preview {
    PaywallView(
        onUnlock: {
            print("Unlock tapped")
        },
        onContinueFree: {
            print("Continue free tapped")
        }
    )
}
