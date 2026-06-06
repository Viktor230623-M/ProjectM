import Fluent
import Vapor
import ProjectMShared

final class Story: Model, @unchecked Sendable {
    static let schema = "stories"

    @ID(key: .id) var id: UUID?
    @Field(key: "author_id") var authorId: UUID
    @Field(key: "content_type") var contentType: String
    @Field(key: "content") var content: String
    @Field(key: "expires_at") var expiresAt: Date
    @Timestamp(key: "created_at", on: .create) var createdAt: Date?

    init() {}

    init(id: UUID? = nil, authorId: UUID, contentType: ContentType, content: String) {
        self.id = id
        self.authorId = authorId
        self.contentType = contentType.rawValue
        self.content = content
        self.expiresAt = Date().addingTimeInterval(86400) // 24h
    }
}
