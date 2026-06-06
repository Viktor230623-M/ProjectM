import Foundation

public struct UserDTO: Codable, Identifiable, Sendable {
    public let id: UUID
    public let phoneNumber: String
    public let username: String
    public let displayName: String
    public let avatarURL: String?
    public let graphVisibility: Bool

    public init(id: UUID, phoneNumber: String, username: String, displayName: String, avatarURL: String?, graphVisibility: Bool) {
        self.id = id
        self.phoneNumber = phoneNumber
        self.username = username
        self.displayName = displayName
        self.avatarURL = avatarURL
        self.graphVisibility = graphVisibility
    }
}
