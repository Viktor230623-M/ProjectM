import Fluent
import Vapor

final class Conversation: Model, @unchecked Sendable {
    static let schema = "conversations"

    @ID(key: .id) var id: UUID?
    @Field(key: "type") var type: String
    @OptionalField(key: "name") var name: String?
    @Children(for: \.$conversation) var members: [ConversationMember]
    @Timestamp(key: "created_at", on: .create) var createdAt: Date?

    init() {}

    init(id: UUID? = nil, type: String, name: String? = nil) {
        self.id = id
        self.type = type
        self.name = name
    }
}

final class ConversationMember: Model, @unchecked Sendable {
    static let schema = "conversation_members"

    @ID(key: .id) var id: UUID?
    @Parent(key: "conversation_id") var conversation: Conversation
    @Parent(key: "user_id") var user: User
    @Timestamp(key: "joined_at", on: .create) var joinedAt: Date?

    init() {}

    init(conversationId: UUID, userId: UUID) {
        self.$conversation.id = conversationId
        self.$user.id = userId
    }
}
