import Fluent

struct CreateMessages: AsyncMigration {
    func prepare(on db: Database) async throws {
        try await db.schema("messages")
            .id()
            .field("conversation_id", .uuid, .required, .references("conversations", "id", onDelete: .cascade))
            .field("sender_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .field("content_type", .string, .required)
            .field("content", .string, .required)
            .field("created_at", .datetime)
            .field("deleted_at", .datetime)
            .create()
    }

    func revert(on db: Database) async throws {
        try await db.schema("messages").delete()
    }
}
