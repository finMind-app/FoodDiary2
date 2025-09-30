import SwiftUI
import AuthenticationServices

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
                
                // Apple Registration (native button per Apple guidelines)
                AppleSignInButton(type: .signUp, style: .black) {
                    registerWithApple()
                }
                .frame(height: 52)
                .clipShape(RoundedRectangle(cornerRadius: PlumpyTheme.Radius.large))
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
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            isRegistering = false
            return
        }
        Task { @MainActor in
            do {
                let user = try await AuthService.shared.signInWithGoogle(presentingWindowScene: windowScene)
                UserDefaults.standard.set(true, forKey: "isRegistered")
                UserDefaults.standard.set(user.provider, forKey: "registrationMethod")
                UserDefaults.standard.set(user.name, forKey: "userName")
                UserDefaults.standard.set(user.email, forKey: "userEmail")
                UserDefaults.standard.set(user.avatarURL?.absoluteString, forKey: "userAvatarURL")
                isRegistering = false
                onRegistrationComplete()
            } catch {
                isRegistering = false
                print("Google Sign-In failed: \(error)")
            }
        }
    }
    
    private func registerWithApple() {
        isRegistering = true
        Task { @MainActor in
            do {
                let user = try await AuthService.shared.signInWithApple()
                UserDefaults.standard.set(true, forKey: "isRegistered")
                UserDefaults.standard.set(user.provider, forKey: "registrationMethod")
                UserDefaults.standard.set(user.name, forKey: "userName")
                UserDefaults.standard.set(user.email, forKey: "userEmail")
                UserDefaults.standard.set(user.avatarURL?.absoluteString, forKey: "userAvatarURL")
                isRegistering = false
                onRegistrationComplete()
            } catch {
                isRegistering = false
                print("Apple Sign-In failed: \(error)")
            }
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

// Removed mock user data. Real auth is used.

// MARK: - Native Sign in with Apple button wrapper
struct AppleSignInButton: UIViewRepresentable {
    let type: ASAuthorizationAppleIDButton.ButtonType
    let style: ASAuthorizationAppleIDButton.Style
    let action: () -> Void

    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        let button = ASAuthorizationAppleIDButton(type: type, style: style)
        button.addAction(UIAction { _ in
            action()
        }, for: .touchUpInside)
        return button
    }

    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {
        // No dynamic updates required
    }
}

#Preview {
    RegistrationView(
        onRegistrationComplete: {},
        onSkip: {}
    )
}
