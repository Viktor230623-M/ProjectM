import Fluent

struct CreateConversations: AsyncMigration {
    func prepare(on db: Database) async throws {
        try await db.schema("conversations")
            .id()
            .field("type", .string, .required)
            .field("name", .string)
            .field("created_at", .datetime)
            .create()
    }

    func revert(on db: Database) async throws {
        try await db.schema("conversations").delete()
    }
}

struct CreateConversationMembers: AsyncMigration {
    func prepare(on db: Database) async throws {
        try await db.schema("conversation_members")
            .id()
            .field("conversation_id", .uuid, .required, .references("conversations", "id", onDelete: .cascade))
            .field("user_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .field("joined_at", .datetime)
            .unique(on: "conversation_id", "user_id")
            .create()
    }

    func revert(on db: Database) async throws {
        try await db.schema("conversation_members").delete()
    }
}
