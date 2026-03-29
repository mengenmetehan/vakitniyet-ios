import Foundation
import Combine
import AuthenticationServices
import SwiftUI

@MainActor
class AuthService: ObservableObject {
    
    static let shared = AuthService()
    
    @Published var isAuthenticated: Bool = false
    @Published var currentUserId: String?
    @Published var userName: String?
    @Published var subscriptionStatus: SubscriptionInfo?
    
    private let api = PrayerAPIService.shared
    private let network = NetworkService.shared
    
    private init() {
        checkAuthStatus()
    }
    
    // MARK: - Check Auth
    
    private func checkAuthStatus() {
        isAuthenticated = network.isLoggedIn
    }
    
    // MARK: - Apple Sign In
    
    func signInWithApple(
        authorization: ASAuthorization,
        deviceToken: String? = nil
    ) async throws {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            throw AuthError.invalidCredential
        }
        
        guard let identityToken = appleIDCredential.identityToken,
              let tokenString = String(data: identityToken, encoding: .utf8),
              let authCode = appleIDCredential.authorizationCode,
              let authCodeString = String(data: authCode, encoding: .utf8)
        else {
            throw AuthError.missingToken
        }
        
        // Kullanıcı adı (sadece ilk giriş)
        let fullName = appleIDCredential.fullName
        let name = [fullName?.givenName, fullName?.familyName]
            .compactMap { $0 }
            .joined(separator: " ")
        
        // Backend'e gönder
        let response = try await api.signInWithApple(
            identityToken: tokenString,
            authorizationCode: authCodeString,
            name: name.isEmpty ? nil : name,
            deviceToken: deviceToken
        )
        
        // Token'ları kaydet
        await network.saveTokens(access: response.accessToken, refresh: response.refreshToken)
        
        // State güncelle
        isAuthenticated = true
        currentUserId = response.userId
        userName = response.name ?? name
        subscriptionStatus = response.subscription
        
        print("✅ Signed in successfully: \(response.userId)")
    }
    
    // MARK: - Sign Out
    
    func signOut() async {
        await network.clearTokens()
        isAuthenticated = false
        currentUserId = nil
        userName = nil
        subscriptionStatus = nil
    }
    
    // MARK: - Device Token Update
    
    func updateDeviceToken(_ token: String) async {
        do {
            try await api.updateDeviceToken(token)
            print("✅ Device token updated")
        } catch {
            print("❌ Device token update failed: \(error)")
        }
    }
    
    // MARK: - Subscription
    
    func refreshSubscriptionStatus() async {
        guard isAuthenticated else { return }
        
        do {
            let status = try await api.getSubscriptionStatus()
            subscriptionStatus = SubscriptionInfo(
                plan: status.plan,
                status: status.status,
                isActive: status.isActive,
                trialDaysLeft: status.trialDaysLeft,
                currentPeriodEnd: status.currentPeriodEnd
            )
        } catch {
            print("❌ Subscription status refresh failed: \(error)")
        }
    }
}

// MARK: - Auth Error

enum AuthError: LocalizedError {
    case invalidCredential
    case missingToken
    case signInFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidCredential:
            return "Geçersiz kimlik bilgisi"
        case .missingToken:
            return "Token bulunamadı"
        case .signInFailed:
            return "Giriş başarısız"
        }
    }
}

// MARK: - Sign In Coordinator

class SignInCoordinator: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    private var continuation: CheckedContinuation<ASAuthorization, Error>?
    
    func signIn() async throws -> ASAuthorization {
        try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            
            let provider = ASAuthorizationAppleIDProvider()
            let request = provider.createRequest()
            request.requestedScopes = [.fullName, .email]
            
            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self
            controller.performRequests()
        }
    }
    
    // MARK: - ASAuthorizationControllerDelegate
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        continuation?.resume(returning: authorization)
        continuation = nil
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        continuation?.resume(throwing: error)
        continuation = nil
    }
    
    // MARK: - ASAuthorizationControllerPresentationContextProviding
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first else {
            return UIWindow()
        }
        return window
    }
}
