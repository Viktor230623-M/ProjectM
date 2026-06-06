import Foundation

public enum WSEventType: String, Codable, Sendable {
    case messageNew
    case messageRead
    case messageDeleted
    case userTyping
    case userStoppedTyping
    case storyNew
    case storyExpired
    case friendRequestReceived
    case friendRequestAccepted
    case presenceOnline
    case presenceOffline
}

public struct WSEvent: Codable, Sendable {
    public let type: WSEventType
    public let payload: Data

    public init(type: WSEventType, payload: Data) {
        self.type = type
        self.payload = payload
    }
}

// Typed payloads
public struct WSMessagePayload: Codable, Sendable {
    public let message: MessageDTO
    public init(message: MessageDTO) { self.message = message }
}

public struct WSTypingPayload: Codable, Sendable {
    public let conversationId: UUID
    public let userId: UUID
    public init(conversationId: UUID, userId: UUID) {
        self.conversationId = conversationId
        self.userId = userId
    }
}

public struct WSPresencePayload: Codable, Sendable {
    public let userId: UUID
    public init(userId: UUID) { self.userId = userId }
}
