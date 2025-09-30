//
//  AuthService.swift
//  FoodDiaryTwo
//
//  Provides authentication via Google and Apple.
//

import Foundation
import SwiftUI
import AuthenticationServices
import GoogleSignIn
import GoogleSignInSwift

struct AuthUserInfo {
    let id: String
    let name: String
    let email: String
    let avatarURL: URL?
    let provider: String
}

final class AuthService: NSObject {
    static let shared = AuthService()

    // MARK: - Google
    func signInWithGoogle(presentingWindowScene: UIWindowScene) async throws -> AuthUserInfo {
        guard let presentingViewController = presentingWindowScene.keyWindow?.rootViewController else {
            throw NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No presenting view controller"])
        }

        // Prefer restoring previous sign-in first
        if let restored = try? await GIDSignIn.sharedInstance.restorePreviousSignIn() {
            return Self.mapGoogleUser(restored)
        }

        let config = GIDConfiguration(clientID: Self.googleClientID())
        GIDSignIn.sharedInstance.configuration = config

        let user = try await GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController).user
        return Self.mapGoogleUser(user)
    }

    private static func mapGoogleUser(_ user: GIDGoogleUser) -> AuthUserInfo {
        let profile = user.profile
        let name = [profile?.givenName, profile?.familyName].compactMap { $0 }.joined(separator: " ")
        let email = profile?.email ?? ""
        let avatarURL = profile?.imageURL(withDimension: 120)
        return AuthUserInfo(
            id: user.userID ?? UUID().uuidString,
            name: name.isEmpty ? (profile?.name ?? "") : name,
            email: email,
            avatarURL: avatarURL,
            provider: "google"
        )
    }

    private static func googleClientID() -> String {
        // If you added the plist, Google SDK reads it automatically. ClientID here is a fallback.
        // You can optionally parse the bundled plist if needed.
        return Bundle.main.object(forInfoDictionaryKey: "GIDClientID") as? String ?? ""
    }

    // MARK: - Apple
    private var appleContinuation: CheckedContinuation<AuthUserInfo, Error>?

    func signInWithApple() async throws -> AuthUserInfo {
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<AuthUserInfo, Error>) in
            self.appleContinuation = continuation
            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.fullName, .email]

            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self
            controller.performRequests()
        }
    }
}

extension AuthService: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // Use key window if available
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow } ?? UIWindow()
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            appleContinuation?.resume(throwing: NSError(domain: "AuthService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid Apple credential"]))
            appleContinuation = nil
            return
        }

        let userId = appleIDCredential.user
        let email = appleIDCredential.email ?? ""
        let fullName = [appleIDCredential.fullName?.givenName, appleIDCredential.fullName?.familyName]
            .compactMap { $0 }
            .joined(separator: " ")
        let userInfo = AuthUserInfo(
            id: userId,
            name: fullName,
            email: email,
            avatarURL: nil,
            provider: "apple"
        )
        appleContinuation?.resume(returning: userInfo)
        appleContinuation = nil
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        appleContinuation?.resume(throwing: error)
        appleContinuation = nil
    }
}

private extension UIWindowScene {
    var keyWindow: UIWindow? {
        return self.windows.first(where: { $0.isKeyWindow })
    }
}


