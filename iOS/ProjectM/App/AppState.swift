import SwiftUI
import ProjectMShared

@MainActor
final class AppState: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: UserDTO?

    let apiClient = APIClient()
    let webSocketClient = WebSocketClient()
    let authManager: AuthManager

    init() {
        authManager = AuthManager(keychain: KeychainStore())
        isAuthenticated = authManager.hasValidToken()
    }

    func signIn(user: UserDTO) {
        currentUser = user
        isAuthenticated = true
        webSocketClient.connect(token: authManager.accessToken ?? "")
    }

    func signOut() {
        authManager.clearTokens()
        webSocketClient.disconnect()
        currentUser = nil
        isAuthenticated = false
    }
}
