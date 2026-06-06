import SwiftUI
import ProjectMShared

@MainActor
final class ChatViewModel: ObservableObject {
    @Published var conversations: [ConversationDTO] = []
    @Published var messages: [MessageDTO] = []
    @Published var isLoadingMessages = false
    @Published var typingUserIds: Set<UUID> = []

    private let api: APIClient
    private let ws: WebSocketClient
    var currentConversationId: UUID?

    init(api: APIClient, ws: WebSocketClient) {
        self.api = api
        self.ws = ws
        ws.onEvent = { [weak self] event in
            Task { @MainActor in self?.handle(event: event) }
        }
    }

    func loadConversations() async {
        conversations = (try? await api.get(.conversations)) ?? []
    }

    func loadMessages(conversationId: UUID) async {
        currentConversationId = conversationId
        isLoadingMessages = true
        defer { isLoadingMessages = false }
        messages = (try? await api.get(.messages(conversationId: conversationId.uuidString))) ?? []
    }

    func sendMessage(conversationId: UUID, text: String) async {
        struct Body: Encodable { let contentType: String; let content: String }
        guard let msg: MessageDTO = try? await api.post(
            .sendMessage(conversationId: conversationId.uuidString),
            body: Body(contentType: "text", content: text)
        ) else { return }
        messages.append(msg)
    }

    func sendTyping(conversationId: UUID, userId: UUID) {
        ws.send(.userTyping, payload: WSTypingPayload(conversationId: conversationId, userId: userId))
    }

    private func handle(event: WSEvent) {
        switch event.type {
        case .messageNew:
            if let msg = try? JSONDecoder().decode(MessageDTO.self, from: event.payload) {
                if msg.conversationId == currentConversationId {
                    messages.append(msg)
                }
                // Update last message in conversation list
                if let idx = conversations.firstIndex(where: { $0.id == msg.conversationId }) {
                    let old = conversations[idx]
                    conversations[idx] = ConversationDTO(
                        id: old.id, type: old.type, name: old.name,
                        members: old.members, lastMessage: msg, createdAt: old.createdAt
                    )
                }
            }
        case .userTyping:
            if let p = try? JSONDecoder().decode(WSTypingPayload.self, from: event.payload),
               p.conversationId == currentConversationId {
                typingUserIds.insert(p.userId)
                Task {
                    try? await Task.sleep(nanoseconds: 3_000_000_000)
                    typingUserIds.remove(p.userId)
                }
            }
        default: break
        }
    }
}
