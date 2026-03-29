import SwiftUI
import AuthenticationServices

struct SignInView: View {
    
    @ObservedObject private var authService = AuthService.shared
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(hex: "534AB7"),
                    Color(hex: "27500A")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Logo/Title
                VStack(spacing: 12) {
                    Image(systemName: "moon.stars.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.white)
                    
                    Text("Vakit Niyet")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Namaz Takip Uygulaması")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                // Sign in button
                VStack(spacing: 16) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                    } else {
                        SignInWithAppleButton(
                            onRequest: { request in
                                request.requestedScopes = [.fullName, .email]
                            },
                            onCompletion: { result in
                                handleSignIn(result)
                            }
                        )
                        .signInWithAppleButtonStyle(.white)
                        .frame(height: 50)
                        .cornerRadius(12)
                        .padding(.horizontal, 40)
                    }
                    
                    if let error = errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red.opacity(0.9))
                            .padding(.horizontal)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.bottom, 60)
            }
        }
    }
    
    // MARK: - Handle Sign In
    
    private func handleSignIn(_ result: Result<ASAuthorization, Error>) {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                switch result {
                case .success(let authorization):
                    try await authService.signInWithApple(
                        authorization: authorization,
                        deviceToken: nil
                    )
                    
                case .failure(let error):
                    throw error
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
}

#Preview {
    SignInView()
}
