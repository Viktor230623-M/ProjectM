import Fluent
import Vapor
import ProjectMShared

final class User: Model, @unchecked Sendable {
    static let schema = "users"

    @ID(key: .id) var id: UUID?
    @Field(key: "phone_number") var phoneNumber: String
    @Field(key: "username") var username: String
    @Field(key: "display_name") var displayName: String
    @OptionalField(key: "avatar_url") var avatarURL: String?
    @Field(key: "graph_visibility") var graphVisibility: Bool
    @Timestamp(key: "created_at", on: .create) var createdAt: Date?
    @Timestamp(key: "updated_at", on: .update) var updatedAt: Date?

    init() {}

    init(id: UUID? = nil, phoneNumber: String, username: String, displayName: String, avatarURL: String? = nil, graphVisibility: Bool = true) {
        self.id = id
        self.phoneNumber = phoneNumber
        self.username = username
        self.displayName = displayName
        self.avatarURL = avatarURL
        self.graphVisibility = graphVisibility
    }

    func toDTO() throws -> UserDTO {
        try UserDTO(id: requireID(), phoneNumber: phoneNumber, username: username, displayName: displayName, avatarURL: avatarURL, graphVisibility: graphVisibility)
    }
}
