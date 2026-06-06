import Fluent

struct CreatePosts: AsyncMigration {
    func prepare(on db: Database) async throws {
        try await db.schema("posts")
            .id()
            .field("author_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .field("content_type", .string, .required)
            .field("content", .string, .required)
            .field("caption", .string)
            .field("created_at", .datetime)
            .field("deleted_at", .datetime)
            .create()
    }

    func revert(on db: Database) async throws {
        try await db.schema("posts").delete()
    }
}
