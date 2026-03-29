import Foundation
import SwiftUI
import Combine

class AppState: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var userName: String? = nil
    @Published var subscriptionActive: Bool = true
    @Published var trialDaysLeft: Int? = nil
    
    private var cancellables = Set<AnyCancellable>()
    private let authService = AuthService.shared

    init() {
        // AuthService'ten state'i dinle
        authService.$isAuthenticated
            .receive(on: DispatchQueue.main)
            .assign(to: &$isLoggedIn)
        
        authService.$userName
            .receive(on: DispatchQueue.main)
            .assign(to: &$userName)
        
        authService.$subscriptionStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                self?.subscriptionActive = status?.isActive ?? false
                self?.trialDaysLeft = status?.trialDaysLeft
            }
            .store(in: &cancellables)
    }
    
    func signOut() {
        Task {
            await authService.signOut()
        }
    }
}
