import SwiftUI

struct RegistrationView: View {
    @Environment(\.dismiss) private var dismiss
    let onRegistrationComplete: () -> Void
    let onSkip: () -> Void
    
    @State private var isVisible = false
    @State private var isRegistering = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: PlumpyTheme.Spacing.large) {
                // Close button
                HStack {
                    Spacer()
                    Button(action: {
                        onSkip()
                    }) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundColor(PlumpyTheme.textSecondary)
                            .frame(width: 32, height: 32)
                            .background(
                                Circle()
                                    .fill(PlumpyTheme.surfaceSecondary)
                            )
                    }
                }
                .padding(.horizontal, PlumpyTheme.Spacing.medium)
                .padding(.top, PlumpyTheme.Spacing.medium)
                
                // Title and subtitle
                VStack(spacing: PlumpyTheme.Spacing.medium) {
                    Text(LocalizationManager.shared.localizedString(.registrationTitle))
                        .font(PlumpyTheme.Typography.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(PlumpyTheme.textPrimary)
                        .multilineTextAlignment(.center)
                        .opacity(isVisible ? 1 : 0)
                        .offset(y: isVisible ? 0 : 20)
                        .animation(.easeOut(duration: 0.6).delay(0.1), value: isVisible)
                    
                    Text(LocalizationManager.shared.localizedString(.registrationSubtitle))
                        .font(PlumpyTheme.Typography.body)
                        .foregroundColor(PlumpyTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .opacity(isVisible ? 1 : 0)
                        .offset(y: isVisible ? 0 : 20)
                        .animation(.easeOut(duration: 0.6).delay(0.3), value: isVisible)
                }
                .padding(.horizontal, PlumpyTheme.Spacing.large)
            }
            
            Spacer()
            
            // Registration buttons
            VStack(spacing: PlumpyTheme.Spacing.medium) {
                // Google Registration
                RegistrationButton(
                    title: LocalizationManager.shared.localizedString(.registerWithGoogle),
                    icon: "globe",
                    backgroundColor: Color.white,
                    textColor: Color.black,
                    borderColor: PlumpyTheme.border,
                    isLoading: isRegistering
                ) {
                    registerWithGoogle()
                }
                .opacity(isVisible ? 1 : 0)
                .offset(y: isVisible ? 0 : 30)
                .scaleEffect(isVisible ? 1 : 0.8)
                .animation(.easeOut(duration: 0.6).delay(0.5), value: isVisible)
                
                // Apple Registration
                RegistrationButton(
                    title: LocalizationManager.shared.localizedString(.registerWithApple),
                    icon: "applelogo",
                    backgroundColor: Color.black,
                    textColor: Color.white,
                    borderColor: Color.clear,
                    isLoading: isRegistering
                ) {
                    registerWithApple()
                }
                .opacity(isVisible ? 1 : 0)
                .offset(y: isVisible ? 0 : 30)
                .scaleEffect(isVisible ? 1 : 0.8)
                .animation(.easeOut(duration: 0.6).delay(0.6), value: isVisible)
                
                // Skip button
                Button(action: {
                    onSkip()
                }) {
                    Text(LocalizationManager.shared.localizedString(.skipRegistration))
                        .font(PlumpyTheme.Typography.body)
                        .fontWeight(.medium)
                        .foregroundColor(PlumpyTheme.textSecondary)
                        .padding(.vertical, PlumpyTheme.Spacing.medium)
                }
                .opacity(isVisible ? 1 : 0)
                .offset(y: isVisible ? 0 : 20)
                .animation(.easeOut(duration: 0.6).delay(0.7), value: isVisible)
            }
            .padding(.horizontal, PlumpyTheme.Spacing.large)
            .padding(.bottom, PlumpyTheme.Spacing.large)
        }
        .background(PlumpyTheme.background)
        .onAppear {
            withAnimation {
                isVisible = true
            }
        }
    }
    
    private func registerWithGoogle() {
        isRegistering = true
        
        // Mock registration delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isRegistering = false
            
            // Mock user data
            let mockUser = MockUserData.googleUser
            
            // Save registration status
            UserDefaults.standard.set(true, forKey: "isRegistered")
            UserDefaults.standard.set("google", forKey: "registrationMethod")
            UserDefaults.standard.set(mockUser.name, forKey: "userName")
            UserDefaults.standard.set(mockUser.email, forKey: "userEmail")
            UserDefaults.standard.set(mockUser.avatarURL, forKey: "userAvatarURL")
            
            onRegistrationComplete()
        }
    }
    
    private func registerWithApple() {
        isRegistering = true
        
        // Mock registration delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isRegistering = false
            
            // Mock user data
            let mockUser = MockUserData.appleUser
            
            // Save registration status
            UserDefaults.standard.set(true, forKey: "isRegistered")
            UserDefaults.standard.set("apple", forKey: "registrationMethod")
            UserDefaults.standard.set(mockUser.name, forKey: "userName")
            UserDefaults.standard.set(mockUser.email, forKey: "userEmail")
            UserDefaults.standard.set(mockUser.avatarURL, forKey: "userAvatarURL")
            
            onRegistrationComplete()
        }
    }
}

struct RegistrationButton: View {
    let title: String
    let icon: String
    let backgroundColor: Color
    let textColor: Color
    let borderColor: Color
    let isLoading: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: PlumpyTheme.Spacing.medium) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: textColor))
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundColor(textColor)
                }
                
                Text(title)
                    .font(PlumpyTheme.Typography.body)
                    .fontWeight(.semibold)
                    .foregroundColor(textColor)
                
                Spacer()
            }
            .padding(.horizontal, PlumpyTheme.Spacing.large)
            .padding(.vertical, PlumpyTheme.Spacing.medium)
            .background(
                RoundedRectangle(cornerRadius: PlumpyTheme.Radius.large)
                    .fill(backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: PlumpyTheme.Radius.large)
                            .stroke(borderColor, lineWidth: 1)
                    )
            )
            .shadow(
                color: PlumpyTheme.shadow.opacity(0.1),
                radius: 8,
                x: 0,
                y: 4
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isLoading)
        .animation(.easeInOut(duration: 0.2), value: isLoading)
    }
}

// MARK: - Mock User Data

struct MockUserData {
    static let googleUser = MockUser(
        name: "Алексей Петров",
        email: "alexey.petrov@gmail.com",
        avatarURL: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face"
    )
    
    static let appleUser = MockUser(
        name: "Мария Иванова",
        email: "maria.ivanova@icloud.com",
        avatarURL: "https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150&h=150&fit=crop&crop=face"
    )
}

struct MockUser {
    let name: String
    let email: String
    let avatarURL: String
}

#Preview {
    RegistrationView(
        onRegistrationComplete: {},
        onSkip: {}
    )
}
