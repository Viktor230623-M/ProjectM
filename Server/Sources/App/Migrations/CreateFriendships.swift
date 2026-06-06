import Fluent

struct CreateFriendships: AsyncMigration {
    func prepare(on db: Database) async throws {
        try await db.schema("friendships")
            .id()
            .field("user_a_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .field("user_b_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .field("status", .string, .required, .sql(.default("pending")))
            .field("created_at", .datetime)
            .unique(on: "user_a_id", "user_b_id")
            .create()
    }

    func revert(on db: Database) async throws {
        try await db.schema("friendships").delete()
    }
}
