import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @EnvironmentObject var appState: AppState
    @State private var isLoading = false
    @State private var errorMessage: String? = nil

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Logo & başlık
            VStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(hex: "27500A"))
                        .frame(width: 96, height: 96)

                    // Hilal
                    Canvas { ctx, size in
                        let cx = size.width / 2
                        let cy = size.height / 2
                        var path = Path()
                        path.addArc(center: CGPoint(x: cx + 4, y: cy),
                                    radius: 28, startAngle: .degrees(0),
                                    endAngle: .degrees(360), clockwise: false)
                        var cutout = Path()
                        cutout.addArc(center: CGPoint(x: cx + 14, y: cy),
                                      radius: 20, startAngle: .degrees(0),
                                      endAngle: .degrees(360), clockwise: false)
                        ctx.fill(path, with: .color(.white))
                        ctx.blendMode = .destinationOut
                        ctx.fill(cutout, with: .color(.white))
                    }
                    .frame(width: 96, height: 96)
                    .compositingGroup()
                }

                VStack(spacing: 6) {
                    Text("Vakit Niyet")
                        .font(.system(size: 32, weight: .semibold))
                    Text("Namaz takibini kolaylaştır")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            VStack(spacing: 12) {
                if let error = errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                if isLoading {
                    ProgressView()
                        .frame(height: 50)
                } else {
                    SignInWithAppleButton(.signIn) { request in
                        request.requestedScopes = [.fullName, .email]
                    } onCompletion: { result in
                        handleAppleSignIn(result)
                    }
                    .frame(height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Text("Devam ederek Gizlilik Politikası'nı\nkabul etmiş olursunuz.")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 48)
        }
    }

    private func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let auth):
            guard let credential = auth.credential as? ASAuthorizationAppleIDCredential,
                  let tokenData = credential.identityToken,
                  let token = String(data: tokenData, encoding: .utf8),
                  let codeData = credential.authorizationCode,
                  let code = String(data: codeData, encoding: .utf8)
            else {
                errorMessage = "Apple kimlik bilgileri alınamadı"
                return
            }

            let name: String? = {
                guard let fn = credential.fullName else { return nil }
                return [fn.givenName, fn.familyName]
                    .compactMap { $0 }
                    .joined(separator: " ")
                    .isEmpty ? nil : [fn.givenName, fn.familyName]
                    .compactMap { $0 }.joined(separator: " ")
            }()

            isLoading = true
            errorMessage = nil

            Task {
                do {
                    let response = try await AuthAPIService.shared.signInWithApple(
                        identityToken: token,
                        authorizationCode: code,
                        name: name
                    )
                    await MainActor.run {
                        appState.isLoggedIn = true
                        appState.userName = response.name
                        appState.subscriptionActive = response.subscription.isActive
                        appState.trialDaysLeft = response.subscription.trialDaysLeft
                        isLoading = false
                    }
                } catch {
                    await MainActor.run {
                        errorMessage = error.localizedDescription
                        isLoading = false
                    }
                }
            }

        case .failure(let error):
            if (error as NSError).code != ASAuthorizationError.canceled.rawValue {
                errorMessage = error.localizedDescription
            }
        }
    }
}
