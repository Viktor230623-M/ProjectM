import Foundation

public enum ContentType: String, Codable, Sendable {
    case text, photo, video, audio
}

public struct MessageDTO: Codable, Identifiable, Sendable {
    public let id: UUID
    public let conversationId: UUID
    public let senderId: UUID
    public let contentType: ContentType
    public let content: String
    public let createdAt: Date

    public init(id: UUID, conversationId: UUID, senderId: UUID, contentType: ContentType, content: String, createdAt: Date) {
        self.id = id
        self.conversationId = conversationId
        self.senderId = senderId
        self.contentType = contentType
        self.content = content
        self.createdAt = createdAt
    }
}

public struct ConversationDTO: Codable, Identifiable, Sendable {
    public enum ConversationType: String, Codable, Sendable {
        case direct, group
    }

    public let id: UUID
    public let type: ConversationType
    public let name: String?
    public let members: [UserDTO]
    public let lastMessage: MessageDTO?
    public let createdAt: Date

    public init(id: UUID, type: ConversationType, name: String?, members: [UserDTO], lastMessage: MessageDTO?, createdAt: Date) {
        self.id = id
        self.type = type
        self.name = name
        self.members = members
        self.lastMessage = lastMessage
        self.createdAt = createdAt
    }
}
