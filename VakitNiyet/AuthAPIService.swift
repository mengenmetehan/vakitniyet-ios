import Foundation
import AuthenticationServices

class AuthAPIService {

    static let shared = AuthAPIService()
    private init() {}

    private let network = NetworkService.shared

    // MARK: - Apple Sign In

    func signInWithApple(
        identityToken: String,
        authorizationCode: String,
        name: String?,
        deviceToken: String? = nil
    ) async throws -> AuthResponse {
        let body = AppleSignInRequest(
            identityToken: identityToken,
            authorizationCode: authorizationCode,
            name: name,
            deviceToken: deviceToken
        )

        let response: AuthResponse = try await network.request(
            path: "/auth/apple",
            method: "POST",
            body: body,
            requiresAuth: false
        )

        await network.saveTokens(access: response.accessToken, refresh: response.refreshToken)

        // UserId'yi kaydet
        UserDefaults.standard.set(response.userId, forKey: "userId")
        UserDefaults.standard.set(response.name, forKey: "userName")

        return response
    }

    // MARK: - Device Token Güncelle

    func updateDeviceToken(_ token: String) async {
        do {
            struct EmptyRes: Decodable {}
            let body = UpdateDeviceTokenRequest(deviceToken: token)
            let _: EmptyRes = try await network.request(
                path: "/auth/device-token",
                method: "PUT",
                body: body
            )
        } catch {
            print("Device token güncellenemedi: \(error)")
        }
    }

    // MARK: - Çıkış

    func signOut() async {
        await network.clearTokens()
        UserDefaults.standard.removeObject(forKey: "userId")
        UserDefaults.standard.removeObject(forKey: "userName")
    }
}
