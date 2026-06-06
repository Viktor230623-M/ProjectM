import Foundation

public struct FriendshipDTO: Codable, Sendable {
    public enum Status: String, Codable, Sendable {
        case pending, accepted, blocked
    }

    public let userAId: UUID
    public let userBId: UUID
    public let status: Status

    public init(userAId: UUID, userBId: UUID, status: Status) {
        self.userAId = userAId
        self.userBId = userBId
        self.status = status
    }
}
