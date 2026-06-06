import Fluent

struct CreateOTPCodes: AsyncMigration {
    func prepare(on db: Database) async throws {
        try await db.schema("otp_codes")
            .id()
            .field("phone_number", .string, .required)
            .field("code_hash", .string, .required)
            .field("expires_at", .datetime, .required)
            .field("used", .bool, .required, .sql(.default(false)))
            .create()
    }

    func revert(on db: Database) async throws {
        try await db.schema("otp_codes").delete()
    }
}
