import Vapor
import ProjectMShared

actor ChatWebSocketHandler {
    static let shared = ChatWebSocketHandler()

    private var connections: [UUID: WebSocket] = [:]

    static func handle(req: Request, ws: WebSocket) async {
        // Authenticate via query token
        guard let token = req.query[String.self, at: "token"] else {
            try? await ws.close(code: .policyViolation)
            return
        }

        guard let payload = try? await req.jwt.verify(token, as: UserJWTPayload.self) else {
            try? await ws.close(code: .policyViolation)
            return
        }

        let userId = payload.userId
        await shared.register(userId: userId, socket: ws)

        ws.onText { ws, text in
            await shared.handleIncoming(text: text, from: userId, req: req)
        }

        ws.onClose.whenComplete { _ in
            Task { await shared.unregister(userId: userId) }
        }
    }

    func register(userId: UUID, socket: WebSocket) {
        connections[userId] = socket
    }

    func unregister(userId: UUID) {
        connections.removeValue(forKey: userId)
    }

    static func broadcast<T: Encodable & Sendable>(
        event: WSEventType,
        payload: T,
        toConversation conversationId: UUID,
        excludingUser: UUID
    ) async {
        guard let data = try? JSONEncoder().encode(payload) else { return }
        let wsEvent = WSEvent(type: event, payload: data)
        guard let eventData = try? JSONEncoder().encode(wsEvent),
              let json = String(data: eventData, encoding: .utf8) else { return }

        // In production: look up conversation members and only send to them
        // For MVP: broadcast to all connected users except sender
        await shared.broadcastText(json, excluding: excludingUser)
    }

    func broadcastText(_ text: String, excluding userId: UUID) async {
        for (id, ws) in connections where id != userId {
            try? await ws.send(text)
        }
    }

    func send(text: String, to userId: UUID) async {
        try? await connections[userId]?.send(text)
    }
}
