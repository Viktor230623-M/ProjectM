import Foundation

public struct StoryDTO: Codable, Identifiable, Sendable {
    public let id: UUID
    public let authorId: UUID
    public let author: UserDTO?
    public let contentType: ContentType
    public let content: String
    public let expiresAt: Date
    public let createdAt: Date

    public init(id: UUID, authorId: UUID, author: UserDTO?, contentType: ContentType, content: String, expiresAt: Date, createdAt: Date) {
        self.id = id
        self.authorId = authorId
        self.author = author
        self.contentType = contentType
        self.content = content
        self.expiresAt = expiresAt
        self.createdAt = createdAt
    }

    public var isExpired: Bool { expiresAt < Date() }
}
