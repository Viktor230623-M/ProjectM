import Fluent

struct CreateUsers: AsyncMigration {
    func prepare(on db: Database) async throws {
        try await db.schema("users")
            .id()
            .field("phone_number", .string, .required)
            .field("username", .string, .required)
            .field("display_name", .string, .required)
            .field("avatar_url", .string)
            .field("graph_visibility", .bool, .required, .sql(.default(true)))
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .unique(on: "phone_number")
            .unique(on: "username")
            .create()
    }

    func revert(on db: Database) async throws {
        try await db.schema("users").delete()
    }
}
