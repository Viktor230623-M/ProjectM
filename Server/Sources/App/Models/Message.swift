import Fluent
import Vapor
import ProjectMShared

final class Message: Model, @unchecked Sendable {
    static let schema = "messages"

    @ID(key: .id) var id: UUID?
    @Field(key: "conversation_id") var conversationId: UUID
    @Field(key: "sender_id") var senderId: UUID
    @Field(key: "content_type") var contentType: String
    @Field(key: "content") var content: String
    @Timestamp(key: "created_at", on: .create) var createdAt: Date?
    @OptionalField(key: "deleted_at") var deletedAt: Date?

    init() {}

    init(id: UUID? = nil, conversationId: UUID, senderId: UUID, contentType: ContentType, content: String) {
        self.id = id
        self.conversationId = conversationId
        self.senderId = senderId
        self.contentType = contentType.rawValue
        self.content = content
    }

    func toDTO() throws -> MessageDTO {
        try MessageDTO(
            id: requireID(),
            conversationId: conversationId,
            senderId: senderId,
            contentType: ContentType(rawValue: contentType) ?? .text,
            content: content,
            createdAt: createdAt ?? Date()
        )
    }
}
