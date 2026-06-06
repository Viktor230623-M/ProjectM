import Vapor
import ProjectMShared

struct ChatController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let chat = routes.grouped("chat")
        chat.get("conversations", use: listConversations)
        chat.get("conversations", ":conversationId", "messages", use: getMessages)
        chat.post("conversations", use: createConversation)
        chat.post("conversations", ":conversationId", "messages", use: sendMessage)
    }

    func listConversations(req: Request) async throws -> [ConversationDTO] {
        let userId = try req.userId

        let members = try await ConversationMember.query(on: req.db)
            .filter(\.$user.$id == userId)
            .with(\.$conversation) { conv in conv.with(\.$members) { m in m.with(\.$user) } }
            .all()

        return try members.compactMap { member -> ConversationDTO? in
            let conv = member.conversation
            let users = try conv.members.map { try $0.user.toDTO() }

            let lastMessage = try await Message.query(on: req.db)
                .filter(\.$conversationId == conv.requireID())
                .sort(\.$createdAt, .descending)
                .first()

            return try ConversationDTO(
                id: conv.requireID(),
                type: conv.type == "group" ? .group : .direct,
                name: conv.name,
                members: users,
                lastMessage: try lastMessage?.toDTO(),
                createdAt: conv.createdAt ?? Date()
            )
        }
    }

    func getMessages(req: Request) async throws -> [MessageDTO] {
        guard let convId = req.parameters.get("conversationId", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        let userId = try req.userId
        try await assertMembership(userId: userId, conversationId: convId, db: req.db)

        return try await Message.query(on: req.db)
            .filter(\.$conversationId == convId)
            .filter(\.$deletedAt == nil)
            .sort(\.$createdAt, .ascending)
            .all()
            .map { try $0.toDTO() }
    }

    struct CreateConversationRequest: Content {
        let type: String
        let name: String?
        let memberIds: [UUID]
    }

    func createConversation(req: Request) async throws -> ConversationDTO {
        let body = try req.content.decode(CreateConversationRequest.self)
        let userId = try req.userId

        let conv = Conversation(type: body.type, name: body.name)
        try await conv.save(on: req.db)
        let convId = try conv.requireID()

        var allMembers = Set(body.memberIds)
        allMembers.insert(userId)

        for memberId in allMembers {
            let m = ConversationMember(conversationId: convId, userId: memberId)
            try await m.save(on: req.db)
        }

        let users = try await User.query(on: req.db)
            .filter(\.$id ~~ Array(allMembers))
            .all()
            .map { try $0.toDTO() }

        return ConversationDTO(id: convId, type: body.type == "group" ? .group : .direct, name: body.name, members: users, lastMessage: nil, createdAt: Date())
    }

    struct SendMessageRequest: Content {
        let contentType: String
        let content: String
    }

    func sendMessage(req: Request) async throws -> MessageDTO {
        guard let convId = req.parameters.get("conversationId", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        let userId = try req.userId
        try await assertMembership(userId: userId, conversationId: convId, db: req.db)

        let body = try req.content.decode(SendMessageRequest.self)
        let ct = ContentType(rawValue: body.contentType) ?? .text
        let msg = Message(conversationId: convId, senderId: userId, contentType: ct, content: body.content)
        try await msg.save(on: req.db)

        let dto = try msg.toDTO()

        // Broadcast via WebSocket
        await ChatWebSocketHandler.broadcast(
            event: WSEventType.messageNew,
            payload: dto,
            toConversation: convId,
            excludingUser: userId
        )

        return dto
    }

    private func assertMembership(userId: UUID, conversationId: UUID, db: Database) async throws {
        let exists = try await ConversationMember.query(on: db)
            .filter(\.$conversation.$id == conversationId)
            .filter(\.$user.$id == userId)
            .count() > 0
        guard exists else { throw Abort(.forbidden) }
    }
}
