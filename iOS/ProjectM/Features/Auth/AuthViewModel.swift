import SwiftUI
import ProjectMShared

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var phoneNumber = ""
    @Published var otpCode = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showOTPEntry = false
    @Published var devOTP: String?

    private let api: APIClient
    private let authManager: AuthManager
    var onAuthenticated: ((UserDTO) -> Void)?

    init(api: APIClient, authManager: AuthManager) {
        self.api = api
        self.authManager = authManager
    }

    func requestOTP() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        struct Request: Encodable { let phoneNumber: String }
        struct Response: Decodable { let message: String; let otp: String? }

        do {
            let res: Response = try await api.post(.requestOTP, body: Request(phoneNumber: phoneNumber))
            devOTP = res.otp
            showOTPEntry = true
        } catch {
            errorMessage = "Failed to send OTP. Check your number."
        }
    }

    func verifyOTP() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        struct Request: Encodable { let phoneNumber: String; let code: String }
        struct UserRes: Decodable { let id: UUID; let username: String; let displayName: String }
        struct Response: Decodable { let accessToken: String; let refreshToken: String; let user: UserRes }

        do {
            let res: Response = try await api.post(.verifyOTP, body: Request(phoneNumber: phoneNumber, code: otpCode))
            authManager.saveTokens(access: res.accessToken, refresh: res.refreshToken)
            let user = UserDTO(id: res.user.id, phoneNumber: phoneNumber, username: res.user.username, displayName: res.user.displayName, avatarURL: nil, graphVisibility: true)
            onAuthenticated?(user)
        } catch {
            errorMessage = "Invalid code. Try again."
        }
    }
}
