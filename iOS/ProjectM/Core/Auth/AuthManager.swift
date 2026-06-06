import Foundation
import ProjectMShared

final class AuthManager {
    private let keychain: KeychainStore

    var accessToken: String? { keychain.read(key: .accessToken) }
    var refreshToken: String? { keychain.read(key: .refreshToken) }

    init(keychain: KeychainStore) {
        self.keychain = keychain
    }

    func hasValidToken() -> Bool {
        accessToken != nil
    }

    func saveTokens(access: String, refresh: String) {
        keychain.save(access, key: .accessToken)
        keychain.save(refresh, key: .refreshToken)
    }

    func clearTokens() {
        keychain.delete(key: .accessToken)
        keychain.delete(key: .refreshToken)
    }
}
