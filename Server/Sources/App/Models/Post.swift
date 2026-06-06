import Fluent
import Vapor
import ProjectMShared

final class Post: Model, @unchecked Sendable {
    static let schema = "posts"

    @ID(key: .id) var id: UUID?
    @Field(key: "author_id") var authorId: UUID
    @Field(key: "content_type") var contentType: String
    @Field(key: "content") var content: String
    @OptionalField(key: "caption") var caption: String?
    @Timestamp(key: "created_at", on: .create) var createdAt: Date?
    @OptionalField(key: "deleted_at") var deletedAt: Date?

    init() {}

    init(id: UUID? = nil, authorId: UUID, contentType: ContentType, content: String, caption: String? = nil) {
        self.id = id
        self.authorId = authorId
        self.contentType = contentType.rawValue
        self.content = content
        self.caption = caption
    }
}
