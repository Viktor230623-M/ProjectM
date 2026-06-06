import Foundation

public struct PostDTO: Codable, Identifiable, Sendable {
    public let id: UUID
    public let authorId: UUID
    public let author: UserDTO?
    public let contentType: ContentType
    public let content: String
    public let caption: String?
    public let createdAt: Date

    public init(id: UUID, authorId: UUID, author: UserDTO?, contentType: ContentType, content: String, caption: String?, createdAt: Date) {
        self.id = id
        self.authorId = authorId
        self.author = author
        self.contentType = contentType
        self.content = content
        self.caption = caption
        self.createdAt = createdAt
    }
}
