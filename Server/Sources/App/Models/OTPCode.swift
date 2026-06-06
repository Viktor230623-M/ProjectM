import Fluent
import Vapor

final class OTPCode: Model, @unchecked Sendable {
    static let schema = "otp_codes"

    @ID(key: .id) var id: UUID?
    @Field(key: "phone_number") var phoneNumber: String
    @Field(key: "code_hash") var codeHash: String
    @Field(key: "expires_at") var expiresAt: Date
    @Field(key: "used") var used: Bool

    init() {}

    init(id: UUID? = nil, phoneNumber: String, codeHash: String, expiresAt: Date, used: Bool = false) {
        self.id = id
        self.phoneNumber = phoneNumber
        self.codeHash = codeHash
        self.expiresAt = expiresAt
        self.used = used
    }

    var isExpired: Bool { expiresAt < Date() }
}
