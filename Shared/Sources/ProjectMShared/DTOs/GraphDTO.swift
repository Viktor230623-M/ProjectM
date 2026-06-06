import Foundation

public struct GraphNodeDTO: Codable, Identifiable, Sendable {
    public let id: UUID
    public let displayName: String
    public let username: String
    public let avatarURL: String?
    public let connectionCount: Int

    public init(id: UUID, displayName: String, username: String, avatarURL: String?, connectionCount: Int) {
        self.id = id
        self.displayName = displayName
        self.username = username
        self.avatarURL = avatarURL
        self.connectionCount = connectionCount
    }
}

public struct GraphEdgeDTO: Codable, Identifiable, Sendable {
    public var id: String { "\(sourceId.uuidString)-\(targetId.uuidString)" }
    public let sourceId: UUID
    public let targetId: UUID

    public init(sourceId: UUID, targetId: UUID) {
        self.sourceId = sourceId
        self.targetId = targetId
    }
}

public struct GraphResponseDTO: Codable, Sendable {
    public let nodes: [GraphNodeDTO]
    public let edges: [GraphEdgeDTO]

    public init(nodes: [GraphNodeDTO], edges: [GraphEdgeDTO]) {
        self.nodes = nodes
        self.edges = edges
    }
}
