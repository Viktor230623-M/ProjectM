import Fluent

struct CreateStories: AsyncMigration {
    func prepare(on db: Database) async throws {
        try await db.schema("stories")
            .id()
            .field("author_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .field("content_type", .string, .required)
            .field("content", .string, .required)
            .field("expires_at", .datetime, .required)
            .field("created_at", .datetime)
            .create()
    }

    func revert(on db: Database) async throws {
        try await db.schema("stories").delete()
    }
}
